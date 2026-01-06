#!/bin/bash
#SBATCH --job-name=aretomo3_cmd2
#SBATCH --output=aretomo3_cmd2_%j.out
#SBATCH --error=aretomo3_cmd2_%j.err
#SBATCH --partition=emgpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:1
#SBATCH --mem=100G
#SBATCH --time=00-01:00:00
#SBATCH --qos=emgpu

set -euo pipefail

# Load required modules
module purge
module load IMOD AreTomo3

# Directories
INPUT_DIR="/scicore/home/engel0006/vysamu91/aretomo3/deltarbcs/combo"
RESULTS_DIR="/scicore/home/engel0006/vysamu91/github/polish2aretomo3/results_cmd2"
VOL_Z=2048

# Create temporary working directory
TMPROOT="$(mktemp -d -p "${SLURM_TMPDIR:-/tmp}" "aretomo3_${SLURM_JOB_ID}_XXXXXX")"
trap 'rm -rf "${TMPROOT}"' EXIT INT TERM

# Process each tilt series
STEM="Position_1"

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
AreTomo3 -InPrefix "${WORKDIR}/${STEM}" -InSuffix ".mrc" -OutDir "${OUTDIR}" -Cmd 2 -Serial 1 -PixSize 2.42 -AtBin 4 -VolZ "${VOL_Z}" -Gpu 0 -Kv 300 -Cs 2.7 -AmpContrast 0.1 -Wbp 1 -FlipVol 1 -TiltCor 1 -CorrCTF 1 15 -OutXF 1 -OutImod 1

STEM="Position_10"

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
AreTomo3 -InPrefix "${WORKDIR}/${STEM}" -InSuffix ".mrc" -OutDir "${OUTDIR}" -Cmd 2 -Serial 1 -PixSize 2.42 -AtBin 4 -VolZ "${VOL_Z}" -Gpu 0 -Kv 300 -Cs 2.7 -AmpContrast 0.1 -Wbp 1 -FlipVol 1 -TiltCor 1 -CorrCTF 1 15 -OutXF 1 -OutImod 1

STEM="Position_11"

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
AreTomo3 -InPrefix "${WORKDIR}/${STEM}" -InSuffix ".mrc" -OutDir "${OUTDIR}" -Cmd 2 -Serial 1 -PixSize 2.42 -AtBin 4 -VolZ "${VOL_Z}" -Gpu 0 -Kv 300 -Cs 2.7 -AmpContrast 0.1 -Wbp 1 -FlipVol 1 -TiltCor 1 -CorrCTF 1 15 -OutXF 1 -OutImod 1

STEM="Position_12"

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
AreTomo3 -InPrefix "${WORKDIR}/${STEM}" -InSuffix ".mrc" -OutDir "${OUTDIR}" -Cmd 2 -Serial 1 -PixSize 2.42 -AtBin 4 -VolZ "${VOL_Z}" -Gpu 0 -Kv 300 -Cs 2.7 -AmpContrast 0.1 -Wbp 1 -FlipVol 1 -TiltCor 1 -CorrCTF 1 15 -OutXF 1 -OutImod 1

STEM="Position_1_2"

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
AreTomo3 -InPrefix "${WORKDIR}/${STEM}" -InSuffix ".mrc" -OutDir "${OUTDIR}" -Cmd 2 -Serial 1 -PixSize 2.42 -AtBin 4 -VolZ "${VOL_Z}" -Gpu 0 -Kv 300 -Cs 2.7 -AmpContrast 0.1 -Wbp 1 -FlipVol 1 -TiltCor 1 -CorrCTF 1 15 -OutXF 1 -OutImod 1

STEM="Position_2"

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
AreTomo3 -InPrefix "${WORKDIR}/${STEM}" -InSuffix ".mrc" -OutDir "${OUTDIR}" -Cmd 2 -Serial 1 -PixSize 2.42 -AtBin 4 -VolZ "${VOL_Z}" -Gpu 0 -Kv 300 -Cs 2.7 -AmpContrast 0.1 -Wbp 1 -FlipVol 1 -TiltCor 1 -CorrCTF 1 15 -OutXF 1 -OutImod 1

STEM="Position_20"

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
AreTomo3 -InPrefix "${WORKDIR}/${STEM}" -InSuffix ".mrc" -OutDir "${OUTDIR}" -Cmd 2 -Serial 1 -PixSize 2.42 -AtBin 4 -VolZ "${VOL_Z}" -Gpu 0 -Kv 300 -Cs 2.7 -AmpContrast 0.1 -Wbp 1 -FlipVol 1 -TiltCor 1 -CorrCTF 1 15 -OutXF 1 -OutImod 1

STEM="Position_21_2"

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
AreTomo3 -InPrefix "${WORKDIR}/${STEM}" -InSuffix ".mrc" -OutDir "${OUTDIR}" -Cmd 2 -Serial 1 -PixSize 2.42 -AtBin 4 -VolZ "${VOL_Z}" -Gpu 0 -Kv 300 -Cs 2.7 -AmpContrast 0.1 -Wbp 1 -FlipVol 1 -TiltCor 1 -CorrCTF 1 15 -OutXF 1 -OutImod 1

STEM="Position_21_3"

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
AreTomo3 -InPrefix "${WORKDIR}/${STEM}" -InSuffix ".mrc" -OutDir "${OUTDIR}" -Cmd 2 -Serial 1 -PixSize 2.42 -AtBin 4 -VolZ "${VOL_Z}" -Gpu 0 -Kv 300 -Cs 2.7 -AmpContrast 0.1 -Wbp 1 -FlipVol 1 -TiltCor 1 -CorrCTF 1 15 -OutXF 1 -OutImod 1

STEM="Position_22_2"

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
AreTomo3 -InPrefix "${WORKDIR}/${STEM}" -InSuffix ".mrc" -OutDir "${OUTDIR}" -Cmd 2 -Serial 1 -PixSize 2.42 -AtBin 4 -VolZ "${VOL_Z}" -Gpu 0 -Kv 300 -Cs 2.7 -AmpContrast 0.1 -Wbp 1 -FlipVol 1 -TiltCor 1 -CorrCTF 1 15 -OutXF 1 -OutImod 1

STEM="Position_22_3"

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
AreTomo3 -InPrefix "${WORKDIR}/${STEM}" -InSuffix ".mrc" -OutDir "${OUTDIR}" -Cmd 2 -Serial 1 -PixSize 2.42 -AtBin 4 -VolZ "${VOL_Z}" -Gpu 0 -Kv 300 -Cs 2.7 -AmpContrast 0.1 -Wbp 1 -FlipVol 1 -TiltCor 1 -CorrCTF 1 15 -OutXF 1 -OutImod 1

STEM="Position_22_4"

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
AreTomo3 -InPrefix "${WORKDIR}/${STEM}" -InSuffix ".mrc" -OutDir "${OUTDIR}" -Cmd 2 -Serial 1 -PixSize 2.42 -AtBin 4 -VolZ "${VOL_Z}" -Gpu 0 -Kv 300 -Cs 2.7 -AmpContrast 0.1 -Wbp 1 -FlipVol 1 -TiltCor 1 -CorrCTF 1 15 -OutXF 1 -OutImod 1

STEM="Position_23"

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
AreTomo3 -InPrefix "${WORKDIR}/${STEM}" -InSuffix ".mrc" -OutDir "${OUTDIR}" -Cmd 2 -Serial 1 -PixSize 2.42 -AtBin 4 -VolZ "${VOL_Z}" -Gpu 0 -Kv 300 -Cs 2.7 -AmpContrast 0.1 -Wbp 1 -FlipVol 1 -TiltCor 1 -CorrCTF 1 15 -OutXF 1 -OutImod 1

STEM="Position_4"

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
AreTomo3 -InPrefix "${WORKDIR}/${STEM}" -InSuffix ".mrc" -OutDir "${OUTDIR}" -Cmd 2 -Serial 1 -PixSize 2.42 -AtBin 4 -VolZ "${VOL_Z}" -Gpu 0 -Kv 300 -Cs 2.7 -AmpContrast 0.1 -Wbp 1 -FlipVol 1 -TiltCor 1 -CorrCTF 1 15 -OutXF 1 -OutImod 1

STEM="Position_6"

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
AreTomo3 -InPrefix "${WORKDIR}/${STEM}" -InSuffix ".mrc" -OutDir "${OUTDIR}" -Cmd 2 -Serial 1 -PixSize 2.42 -AtBin 4 -VolZ "${VOL_Z}" -Gpu 0 -Kv 300 -Cs 2.7 -AmpContrast 0.1 -Wbp 1 -FlipVol 1 -TiltCor 1 -CorrCTF 1 15 -OutXF 1 -OutImod 1

STEM="Position_7"

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
AreTomo3 -InPrefix "${WORKDIR}/${STEM}" -InSuffix ".mrc" -OutDir "${OUTDIR}" -Cmd 2 -Serial 1 -PixSize 2.42 -AtBin 4 -VolZ "${VOL_Z}" -Gpu 0 -Kv 300 -Cs 2.7 -AmpContrast 0.1 -Wbp 1 -FlipVol 1 -TiltCor 1 -CorrCTF 1 15 -OutXF 1 -OutImod 1

