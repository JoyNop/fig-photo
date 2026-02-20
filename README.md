# FIG - Photo RAW/JPG Sort CLI

[English Version](README.md) | [中文版](README_CN.md)

---

## FIG Photo CLI

**Author**: HE-AN
**GitHub**: [https://github.com/JoyNop/fig-photo](https://github.com/JoyNop/fig-photo)

FIG is a lightweight, cross-platform CLI tool for sorting your camera photos. It automatically separates RAW and JPG files, organizes RAW by manufacturer, supports restore, dry-run preview, and provides detailed logging.

---

## Features

- Automatic RAW/JPG classification
- RAW files are organized by camera manufacturer (Sony, Canon, Nikon, Fujifilm, Panasonic, Leica, Pentax, Unknown)
- Supports both **move** and **copy** operations
- Interactive terminal mode for users unfamiliar with command-line arguments
- Restore files to original location from previous sorting
- Dry-run mode for previewing operations
- Progress bar during processing
- Detailed CSV log with file paths, type, and manufacturer

---

## Installation

```bash
# Option 1: Clone from Git
git clone https://github.com/JoyNop/fig-photo.git
cd fig-photo

# Option 2: Download from Release directly
# Open: https://github.com/JoyNop/fig-photo/releases
# Download the archive, then extract it and enter the project folder

# Make sure the script is executable
chmod +x fig.sh

# Optional: move it to your PATH
sudo mv fig.sh /usr/local/bin/fig
```

---

## Usage

### Interactive Mode

```bash
./fig.sh
```

- Choose directory: current or drag another folder
- Choose recognition mode: automatic (EXIF) or manual
- Select manufacturer if manual
- Choose operation: move or copy
- Enable dry-run preview if needed
- Optionally restore previous sorting

### Command-line Parameters

```bash
./fig.sh [options]

Options:
  -d, --dir PATH        Specify the target directory
  -m, --maker NAME      sony|canon|nikon|fuji|panasonic|leica|pentax|auto
  -a, --action TYPE     move|copy
  --dry-run             Preview mode
  --restore             Restore previously sorted files
  -h, --help            Show help
```

**Example:**

```bash
# Sort all photos in a folder using automatic detection
./fig.sh --dir /Users/username/DCIM --maker auto --action move

# Preview mode before moving
./fig.sh --dir /Users/username/DCIM --dry-run

# Restore previous sorting
./fig.sh --restore
```

---

## Logging

A CSV log `fig-photo.csv` will be generated in the target directory:

| filename | original_path | new_path | type | manufacturer |
| -------- | ------------- | -------- | ---- | ------------ |

This allows easy tracking and restoring files.

---

## Requirements

- Bash (macOS, Linux, Windows via Git Bash / WSL)
- Important: Windows PowerShell cannot run this script directly. Please use Git Bash or WSL.
- `exiftool` installed for automatic manufacturer detection (optional but recommended)
