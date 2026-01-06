# polish2aretomo3

Update [AreTomo3](https://github.com/czimaginginstitute/AreTomo3) alignment files with [RELION5](https://github.com/3dem/relion/tree/ver5.0) Bayesian polishing results and generate a SLURM script to realign tomograms using Cmd 2.

## Overview

This utility integrates RELION5 tomography polishing per-tilt alignment updates into existing AreTomo3 tilt-series alignments (`.aln` files), then generates a SLURM script to re-run AreTomo3 Cmd 2 for updated tomogram reconstruction.

## What It Does

For each `Position_*` tilt series:

1. **Reads** the original AreTomo3 alignment file: `Position_X.aln`
2. **Reads** the RELION polishing STAR file: `Position_X_projections.star`
3. **Matches** RELION tilts to AreTomo tilts by angle (handles removed tilts)
4. **Updates** the alignment file:
   - `ROT` → replaced with RELION `rlnTomoZRot`
   - `TILT` → replaced with RELION `rlnTomoYTilt`
   - `TX/TY` → replaced with RELION shifts converted from Ångströms to unbinned pixels:
     ```
     TX_new = XShiftAngst / pixel_size
     TY_new = YShiftAngst / pixel_size
     ```
5. **Generates** a SLURM submission script (`submit_cmd2.sh`) that:
   - Creates temporary working directories
   - Links input files (`.mrc`, `_TLT.txt`, `_CTF*.txt`)
   - Copies updated `.aln` files
   - Runs AreTomo3 `-Cmd 2` with outputs to `results/<Position>/cmd2/`
   - Cleans up temporary files


## Input Requirements

### 1. AreTomo3 Output Directory

Typical layout:
```
aretomo3/
├── Position_1.aln          # Required
├── Position_1.mrc          # Required
├── Position_1_TLT.txt      # Required
├── Position_1_CTF.txt      # Optional (for CTF correction)
├── Position_1_CTF_Imod.txt # Optional
├── Position_1_Vol.mrc
├── Position_1_ODD.mrc
├── Position_1_EVN.mrc
└── ...
```

**Minimum required per position:**
- `Position_X.aln`
- `Position_X.mrc`
- `Position_X_TLT.txt`

### 2. RELION5 Polish Output Directory

Typical layout:
```
Polish/jobXXX/temp/
├── Position_1_projections.star  # Required
├── Position_1_motion.star
├── Position_1_positions.star
├── Position_1_shifts.eps
└── ...
```

## Usage

### Basic Example

```bash
python polish2aretomo3.py \
  -i path/to/aretomo3/output/ \
  -p path/to/relion/Polish/jobXXX/temp/ \
  --pixel-size 2.42 \
  --binning 4 \
  --vol-z 2048
```

Then submit the job:
```bash
sbatch results_cmd2/submit_cmd2.sh
```

### Filter Specific Positions

```bash
# Process only Position_22*
python polish2aretomo3.py \
  -i aretomo3/ \
  -p polish/temp/ \
  --pixel-size 2.42 \
  --binning 4 \
  --vol-z 2048 \
  --include "Position_2*"

# Exclude specific positions
python polish2aretomo3.py \
  -i aretomo3/ \
  -p polish/temp/ \
  --pixel-size 2.42 \
  --binning 4 \
  --vol-z 2048 \
  --exclude "Position_1,Position_2"
```

### Enable CTF Correction (recommended)

```bash
python polish2aretomo3.py \
  -i aretomo3/ \
  -p polish/temp/ \
  --pixel-size 2.42 \
  --binning 4 \
  --vol-z 2048 \
  --ctf-correction \
  --ctf-lowpass 15
```

## Command-Line Options

### Required Arguments

| Argument | Description |
|----------|-------------|
| `-i, --input-dir` | AreTomo3 output directory containing `Position_*.aln/.mrc/_TLT.txt` |
| `-p, --polish-dir` | RELION polish directory (e.g., `Polish/job001/temp/`) |
| `--pixel-size` | Unbinned pixel size in Ångströms |
| `--binning` | AreTomo3 binning factor (AtBin) |
| `--vol-z` | Tomogram thickness in pixels |

### Optional Arguments

#### Input/Output
| Argument | Default | Description |
|----------|---------|-------------|
| `-o, --output-dir` | `results_cmd2` | Output directory for updated files |
| `--relion-suffix` | `_projections.star` | Suffix for RELION projection files |

#### Filtering
| Argument | Description |
|----------|-------------|
| `--include` | Comma-separated wildcard patterns to include (e.g., `Position_1,Position_2*`) |
| `--exclude` | Comma-separated wildcard patterns to exclude |

#### Sign Conventions
| Argument | Default | Description |
|----------|---------|-------------|
| `--tilt-sign` | `1.0` | Multiply RELION tilt angles by this factor |
| `--xshift-sign` | `1.0` | Multiply X shifts by this factor |
| `--yshift-sign` | `1.0` | Multiply Y shifts by this factor |

#### CTF Correction
| Argument | Default | Description |
|----------|---------|-------------|
| `--ctf-correction` | `False` | Enable CTF correction |
| `--ctf-lowpass` | `15` | CTF correction lowpass filter (Å) |

#### Microscope Parameters
| Argument | Default | Description |
|----------|---------|-------------|
| `--kv` | `300` | Acceleration voltage (kV) |
| `--cs` | `2.7` | Spherical aberration (mm) |
| `--amp-contrast` | `0.1` | Amplitude contrast |

#### Output Options
| Argument | Default | Description |
|----------|---------|-------------|
| `--output-imod` | `True` | Generate IMOD-compatible outputs |
| `--output-xf` | `True` | Generate `.xf` transformation files |

#### SLURM Configuration
| Argument | Default | Description |
|----------|---------|-------------|
| `--slurm-partition` | `emgpu` | SLURM partition |
| `--slurm-qos` | `emgpu` | SLURM QOS |
| `--slurm-time` | `00-01:00:00` | Time limit |
| `--slurm-mem` | `100G` | Memory allocation |
| `--slurm-cpus` | `4` | CPUs per task |
| `--slurm-gpus` | `1` | GPUs per task |

## Output Structure

```
results_cmd2/
├── submit_cmd2.sh              # SLURM submission script
├── Position_1/
│   ├── Position_1.aln          # Updated alignment file
│   └── cmd2/                   # AreTomo3 Cmd 2 outputs
│       ├── Position_1_Vol.mrc  # Reconstructed tomogram
│       ├── Position_1.aln      # Final alignment
│       └── ...
├── Position_2/
│   ├── Position_2.aln
│   └── cmd2/
│       └── ...
└── ...
```


## License

MIT License - see LICENSE file for details.

## Contributing

Contributions are very welcome! Please feel free to submit issues or pull requests.