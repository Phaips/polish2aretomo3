#!/usr/bin/env python3
"""
Update AreTomo3 alignment files with RELION polished shifts and generate
a SLURM script to run AreTomo3 reconstruction (Cmd 2).

This script converts RELION polish per-tilt shifts from Ångstroms to AreTomo3's
expected pixel coordinates and updates the alignment files accordingly.
"""

import argparse
import fnmatch
import re
import warnings
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List

try:
    import starfile
except ImportError:
    starfile = None

# Regex to identify data rows in .aln files (lines starting with a number)
ALN_DATA_LINE = re.compile(r"^\s*\d+\s+")


@dataclass
class AlignmentRow:
    """Represents one tilt in an AreTomo3 .aln file."""
    sec: int
    rot: float
    gmag: float
    tx: float
    ty: float
    smean: float
    sfit: float
    scale: float
    base: float
    tilt: float
    raw_line: str


@dataclass
class ProjectionRow:
    """Represents one tilt from a RELION polish _projections.star file."""
    ytilt: float
    zrot: float
    dx_ang: float  # X shift in Ångstroms
    dy_ang: float  # Y shift in Ångstroms


def discover_tilt_series(directory: Path) -> List[str]:
    """Find all valid tilt series in the directory (Position_*.aln + .mrc + _TLT.txt)."""
    series = []
    for aln_file in sorted(directory.glob("Position_*.aln")):
        stem = aln_file.stem
        if (directory / f"{stem}.mrc").exists() and (directory / f"{stem}_TLT.txt").exists():
            series.append(stem)
    return series


def parse_aln_file(path: Path) -> tuple[List[str], List[AlignmentRow]]:
    """Parse an AreTomo3 .aln file into header lines and data rows."""
    lines = path.read_text().splitlines(keepends=True)
    rows = []
    
    for line in lines:
        if not ALN_DATA_LINE.match(line):
            continue
        
        fields = line.split()
        if len(fields) < 10:
            continue
        
        rows.append(AlignmentRow(
            sec=int(fields[0]),
            rot=float(fields[1]),
            gmag=float(fields[2]),
            tx=float(fields[3]),
            ty=float(fields[4]),
            smean=float(fields[5]),
            sfit=float(fields[6]),
            scale=float(fields[7]),
            base=float(fields[8]),
            tilt=float(fields[9]),
            raw_line=line,
        ))
    
    return lines, rows


def parse_relion_projections(path: Path, tilt_sign: float) -> List[ProjectionRow]:
    """Parse a RELION polish _projections.star file."""
    if starfile is None:
        raise RuntimeError("starfile package required. Install with: pip install starfile")
    
    with warnings.catch_warnings():
        warnings.filterwarnings("ignore", category=FutureWarning)
        data = starfile.read(str(path))
    
    # Handle both dict and DataFrame returns
    df = data[next(iter(data.keys()))] if isinstance(data, dict) else data
    
    # Find required columns (case-insensitive partial match)
    def find_column(columns, keywords):
        for keyword in keywords:
            for col in columns:
                if keyword.lower() in col.lower():
                    return col
        raise KeyError(f"Required column not found. Tried: {keywords}")
    
    cols = list(df.columns)
    tilt_col = find_column(cols, ["TomoYTilt"])
    zrot_col = find_column(cols, ["TomoZRot"])
    dx_col = find_column(cols, ["TomoXShiftAngst"])
    dy_col = find_column(cols, ["TomoYShiftAngst"])
    
    rows = []
    for _, row in df.iterrows():
        rows.append(ProjectionRow(
            ytilt=float(row[tilt_col]) * tilt_sign,
            zrot=float(row[zrot_col]),
            dx_ang=float(row[dx_col]),
            dy_ang=float(row[dy_col]),
        ))
    
    return rows


def match_tilts(aln_tilts: List[float], proj_tilts: List[float]) -> Dict[int, int]:
    """
    Match AreTomo3 tilts to RELION tilts using dynamic programming.
    Returns a mapping: {aln_index: proj_index}.
    """
    n_aln = len(aln_tilts)
    n_proj = len(proj_tilts)
    
    if n_proj == 0 or n_aln < n_proj:
        return {}
    
    # Sort indices by tilt angle
    aln_sorted = sorted(range(n_aln), key=lambda i: aln_tilts[i])
    proj_sorted = sorted(range(n_proj), key=lambda i: proj_tilts[i])
    
    # DP: find best monotonic matching minimizing tilt angle differences
    dp = [[float('inf')] * (n_aln + 1) for _ in range(n_proj + 1)]
    backtrack = [[0] * (n_aln + 1) for _ in range(n_proj + 1)]
    
    # Base case: 0 proj tilts matched
    for j in range(n_aln + 1):
        dp[0][j] = 0.0
    
    for i in range(1, n_proj + 1):
        for j in range(1, n_aln + 1):
            # Option 1: Skip this aln tilt
            skip_cost = dp[i][j - 1]
            
            # Option 2: Match proj[i-1] with aln[j-1]
            aln_idx = aln_sorted[j - 1]
            proj_idx = proj_sorted[i - 1]
            match_cost = dp[i - 1][j - 1] + abs(proj_tilts[proj_idx] - aln_tilts[aln_idx])
            
            if match_cost < skip_cost:
                dp[i][j] = match_cost
                backtrack[i][j] = 1  # Matched
            else:
                dp[i][j] = skip_cost
                backtrack[i][j] = 0  # Skipped
    
    # Reconstruct matches
    matches = {}
    i, j = n_proj, n_aln
    while i > 0 and j > 0:
        if backtrack[i][j] == 1:
            matches[aln_sorted[j - 1]] = proj_sorted[i - 1]
            i -= 1
            j -= 1
        else:
            j -= 1
    
    return matches


def write_updated_aln(
    original_lines: List[str],
    aln_rows: List[AlignmentRow],
    proj_rows: List[ProjectionRow],
    matches: Dict[int, int],
    output_path: Path,
    pixel_size: float,
    binning: int,
    xshift_sign: float,
    yshift_sign: float,
) -> None:
    """
    Write updated .aln file with RELION polish shifts.
    
    Conversion: RELION shifts (Å) → unbinned pixels → write to .aln
    TX/TY in output = (shift_angstrom / pixel_size)
    """
    output_lines = []
    row_index = 0
    
    for line in original_lines:
        # Keep header lines unchanged
        if not ALN_DATA_LINE.match(line):
            output_lines.append(line)
            continue
        
        row = aln_rows[row_index]
        
        # If this tilt has no match, keep original
        if row_index not in matches:
            output_lines.append(row.raw_line)
            row_index += 1
            continue
        
        # Update with RELION polish values
        proj = proj_rows[matches[row_index]]
        
        # Convert Ångstroms to unbinned pixels
        tx_new = (proj.dx_ang * xshift_sign) / pixel_size
        ty_new = (proj.dy_ang * yshift_sign) / pixel_size
        
        # Write updated row (format matches AreTomo3 .aln style)
        output_lines.append(
            f"{row.sec:5d} {proj.zrot:10.4f} {row.gmag:10.5f} "
            f"{tx_new:10.3f} {ty_new:10.3f} "
            f"{row.smean:8.2f} {row.sfit:8.2f} {row.scale:8.2f} "
            f"{row.base:8.2f} {proj.ytilt:9.2f}\n"
        )
        row_index += 1
    
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("".join(output_lines))


def generate_slurm_script(
    tilt_series: List[str],
    input_dir: Path,
    results_dir: Path,
    pixel_size: float,
    binning: int,
    vol_z: int,
    partition: str,
    qos: str,
    time_limit: str,
    memory: str,
    cpus: int,
    gpus: int,
    ctf_correction: bool,
    ctf_lowpass: int,
    kv: int,
    cs: float,
    amp_contrast: float,
    output_imod: bool,
    output_xf: bool,
) -> str:
    """Generate SLURM batch script to run AreTomo3 Cmd 2 (reconstruction only)."""
    
    # Build AreTomo3 command
    cmd_parts = [
        "AreTomo3",
        '-InPrefix "${WORKDIR}/${STEM}"',
        '-InSuffix ".mrc"',
        '-OutDir "${OUTDIR}"',
        "-Cmd 2",  # Reconstruction only
        "-Serial 1",
        f"-PixSize {pixel_size}",
        f"-AtBin {binning}",
        '-VolZ "${VOL_Z}"',
        "-Gpu 0",
        f"-Kv {kv}",
        f"-Cs {cs}",
        f"-AmpContrast {amp_contrast}",
        "-Wbp 1",
        "-FlipVol 1",
        "-TiltCor 1",
    ]
    
    if ctf_correction:
        cmd_parts.append(f"-CorrCTF 1 {ctf_lowpass}")
    
    if output_xf:
        cmd_parts.append("-OutXF 1")
    
    if output_imod:
        cmd_parts.append("-OutImod 1")
    
    aretomo_cmd = " ".join(cmd_parts)
    
    # Build SLURM script
    script = f"""#!/bin/bash
#SBATCH --job-name=aretomo3_cmd2
#SBATCH --output=aretomo3_cmd2_%j.out
#SBATCH --error=aretomo3_cmd2_%j.err
#SBATCH --partition={partition}
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task={cpus}
#SBATCH --gres=gpu:{gpus}
#SBATCH --mem={memory}
#SBATCH --time={time_limit}
#SBATCH --qos={qos}

set -euo pipefail

# Load required modules
module purge
module load IMOD AreTomo3

# Directories
INPUT_DIR="{input_dir.resolve()}"
RESULTS_DIR="{results_dir.resolve()}"
VOL_Z={vol_z}

# Create temporary working directory
TMPROOT="$(mktemp -d -p "${{SLURM_TMPDIR:-/tmp}}" "aretomo3_${{SLURM_JOB_ID}}_XXXXXX")"
trap 'rm -rf "${{TMPROOT}}"' EXIT INT TERM

# Process each tilt series
"""
    
    for stem in tilt_series:
        script += f'STEM="{stem}"\n'
        script += """
echo "=== Processing ${STEM} ==="

# Setup output directory
OUTDIR="${RESULTS_DIR}/${STEM}/cmd2"
mkdir -p "${OUTDIR}"

# Check for updated .aln file
NEW_ALN="${RESULTS_DIR}/${STEM}/${STEM}.aln"
if [ ! -f "$NEW_ALN" ]; then
    echo "ERROR: Missing updated .aln file: $NEW_ALN" >&2
    exit 1
fi

# Create temporary working directory for this tilt series
WORKDIR="${TMPROOT}/${STEM}"
mkdir -p "${WORKDIR}"

# Link required input files
ln -sf "${INPUT_DIR}/${STEM}.mrc" "${WORKDIR}/${STEM}.mrc"
ln -sf "${INPUT_DIR}/${STEM}_TLT.txt" "${WORKDIR}/${STEM}_TLT.txt"

# Link optional CTF files if they exist
if [ -f "${INPUT_DIR}/${STEM}_CTF.txt" ]; then
    ln -sf "${INPUT_DIR}/${STEM}_CTF.txt" "${WORKDIR}/${STEM}_CTF.txt"
fi
if [ -f "${INPUT_DIR}/${STEM}_CTF_Imod.txt" ]; then
    ln -sf "${INPUT_DIR}/${STEM}_CTF_Imod.txt" "${WORKDIR}/${STEM}_CTF_Imod.txt"
fi

# Copy updated alignment file
cp -f "$NEW_ALN" "${WORKDIR}/${STEM}.aln"

# Run AreTomo3 reconstruction
"""
        script += f"{aretomo_cmd}\n\n"
    
    return script


def main():
    parser = argparse.ArgumentParser(
        description="Update AreTomo3 alignments with RELION polish and generate reconstruction script"
    )
    
    # Input/output paths
    parser.add_argument(
        "-i", "--input-dir",
        type=Path,
        required=True,
        help="Directory containing AreTomo3 output (Position_*.aln, .mrc, _TLT.txt files)"
    )
    parser.add_argument(
        "-p", "--polish-dir",
        type=Path,
        required=True,
        help="Directory containing RELION polish output (*_projections.star files)"
    )
    parser.add_argument(
        "-o", "--output-dir",
        type=Path,
        default=Path("results_cmd2"),
        help="Output directory for updated .aln files and SLURM script (default: results_cmd2)"
    )
    parser.add_argument(
        "--relion-suffix",
        default="_projections.star",
        help="Suffix for RELION projection files (default: _projections.star)"
    )
    
    # Filtering
    parser.add_argument(
        "--include",
        help="Comma-separated wildcard patterns to include (e.g., 'Position_1,Position_2*')"
    )
    parser.add_argument(
        "--exclude",
        help="Comma-separated wildcard patterns to exclude"
    )
    
    # Image parameters
    parser.add_argument(
        "--pixel-size",
        type=float,
        required=True,
        help="Unbinned pixel size in Ångstroms"
    )
    parser.add_argument(
        "--binning",
        type=int,
        required=True,
        help="AreTomo3 binning factor"
    )
    parser.add_argument(
        "--vol-z",
        type=int,
        required=True,
        help="Tomogram thickness in pixels"
    )
    
    # Sign conventions
    parser.add_argument(
        "--tilt-sign",
        type=float,
        default=1.0,
        help="Sign flip for tilt angles (default: 1.0)"
    )
    parser.add_argument(
        "--xshift-sign",
        type=float,
        default=1.0,
        help="Sign flip for X shifts (default: 1.0)"
    )
    parser.add_argument(
        "--yshift-sign",
        type=float,
        default=1.0,
        help="Sign flip for Y shifts (default: 1.0)"
    )
    
    # CTF correction
    parser.add_argument(
        "--ctf-correction",
        action="store_true",
        help="Enable CTF correction in AreTomo3"
    )
    parser.add_argument(
        "--ctf-lowpass",
        type=int,
        default=15,
        help="CTF correction lowpass filter in Ångstroms (default: 15)"
    )
    
    # Microscope parameters
    parser.add_argument(
        "--kv",
        type=int,
        default=300,
        help="Acceleration voltage in kV (default: 300)"
    )
    parser.add_argument(
        "--cs",
        type=float,
        default=2.7,
        help="Spherical aberration in mm (default: 2.7)"
    )
    parser.add_argument(
        "--amp-contrast",
        type=float,
        default=0.1,
        help="Amplitude contrast (default: 0.1)"
    )
    
    # Output options
    parser.add_argument(
        "--output-imod",
        action="store_true",
        default=True,
        help="Generate IMOD-compatible outputs (default: True)"
    )
    parser.add_argument(
        "--output-xf",
        action="store_true",
        default=True,
        help="Generate .xf transformation files (default: True)"
    )
    
    # SLURM parameters
    parser.add_argument("--slurm-partition", default="emgpu", help="SLURM partition (default: emgpu)")
    parser.add_argument("--slurm-qos", default="emgpu", help="SLURM QOS (default: emgpu)")
    parser.add_argument("--slurm-time", default="00-01:00:00", help="Time limit (default: 00-01:00:00)")
    parser.add_argument("--slurm-mem", default="100G", help="Memory allocation (default: 100G)")
    parser.add_argument("--slurm-cpus", type=int, default=4, help="CPUs per task (default: 4)")
    parser.add_argument("--slurm-gpus", type=int, default=1, help="GPUs per task (default: 1)")
    
    args = parser.parse_args()
    
    # Parse include/exclude patterns
    include_patterns = [p.strip() for p in args.include.split(",")] if args.include else []
    exclude_patterns = [p.strip() for p in args.exclude.split(",")] if args.exclude else []
    
    # Discover tilt series
    all_series = discover_tilt_series(args.input_dir)
    
    # Filter by include/exclude patterns
    filtered_series = []
    for stem in all_series:
        if include_patterns and not any(fnmatch.fnmatch(stem, p) for p in include_patterns):
            continue
        if exclude_patterns and any(fnmatch.fnmatch(stem, p) for p in exclude_patterns):
            continue
        filtered_series.append(stem)
    
    if not filtered_series:
        raise SystemExit("ERROR: No tilt series found matching criteria")
    
    print(f"Found {len(filtered_series)} tilt series to process")
    
    # Process each tilt series
    updated_series = []
    polish_dir = args.polish_dir if args.polish_dir.is_dir() else args.polish_dir.parent
    
    for stem in filtered_series:
        star_file = polish_dir / f"{stem}{args.relion_suffix}"
        if not star_file.exists():
            print(f"  Skipping {stem}: no RELION star file found")
            continue
        
        # Parse files
        aln_lines, aln_rows = parse_aln_file(args.input_dir / f"{stem}.aln")
        proj_rows = parse_relion_projections(star_file, args.tilt_sign)
        
        # Match tilts
        matches = match_tilts(
            [row.tilt for row in aln_rows],
            [row.ytilt for row in proj_rows]
        )
        
        if not matches:
            print(f"  Skipping {stem}: could not match tilts")
            continue
        
        # Write updated .aln file
        output_aln = args.output_dir / stem / f"{stem}.aln"
        write_updated_aln(
            original_lines=aln_lines,
            aln_rows=aln_rows,
            proj_rows=proj_rows,
            matches=matches,
            output_path=output_aln,
            pixel_size=args.pixel_size,
            binning=args.binning,
            xshift_sign=args.xshift_sign,
            yshift_sign=args.yshift_sign,
        )
        
        updated_series.append(stem)
        print(f"  ✓ Updated {stem}")
    
    if not updated_series:
        raise SystemExit("ERROR: No tilt series were successfully updated")
    
    # Generate SLURM script
    script_content = generate_slurm_script(
        tilt_series=updated_series,
        input_dir=args.input_dir,
        results_dir=args.output_dir,
        pixel_size=args.pixel_size,
        binning=args.binning,
        vol_z=args.vol_z,
        partition=args.slurm_partition,
        qos=args.slurm_qos,
        time_limit=args.slurm_time,
        memory=args.slurm_mem,
        cpus=args.slurm_cpus,
        gpus=args.slurm_gpus,
        ctf_correction=args.ctf_correction,
        ctf_lowpass=args.ctf_lowpass,
        kv=args.kv,
        cs=args.cs,
        amp_contrast=args.amp_contrast,
        output_imod=args.output_imod,
        output_xf=args.output_xf,
    )
    
    args.output_dir.mkdir(parents=True, exist_ok=True)
    script_path = args.output_dir / "submit_cmd2.sh"
    script_path.write_text(script_content)
    script_path.chmod(0o755)
    
    print(f"\n✓ Successfully updated {len(updated_series)} alignment files")
    print(f"✓ Generated SLURM script: {script_path}")
    print(f"\nTo run reconstruction:\n  sbatch {script_path}")


if __name__ == "__main__":
    main()
