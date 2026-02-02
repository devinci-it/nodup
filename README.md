# NoDup - Duplicate File Finder and Remover

A command-line utility that efficiently finds and removes duplicate files in your directories by calculating SHA-256 hashes. NoDup helps you reclaim disk space by identifying and optionally deleting duplicate files with a simple, user-friendly interface.

## Features

- **Hash-based Detection**: Uses SHA-256 hashing to accurately identify duplicate files regardless of filename
- **Recursive Scanning**: Optionally scan directories recursively to find duplicates across nested folders
- **Extension Filtering**: Filter by file extension to target specific file types
- **Safe Deletion**: Interactive confirmation prompts before deleting files to prevent accidental data loss
- **Force Mode**: Optional force deletion without prompts for automated workflows
- **Efficient Processing**: Lazy-loaded file iteration for memory-efficient handling of large directories
- **Error Handling**: Gracefully handles file access errors and skips problematic files

## Installation

### From Source

1. Clone or download the repository:
```bash
cd nodup
```

2. Install using pip in development mode:
```bash
pip install -e .
```

Or use the provided install script:
```bash
chmod +x install.sh
./install.sh
```

3. Verify installation:
```bash
nodup --help
```

### Requirements

- Python 3.7 or higher
- Dependencies:
  - `argcomplete>=3.6.3` - Command-line argument completion
  - `pipenv>=2026.0.3` - Virtual environment management

Install dependencies:
```bash
pip install -r requirements.txt
```

## Usage

### Basic Usage

Find duplicate files with a specific extension in a directory:

```bash
nodup /path/to/directory
```

By default, this searches for `.txt` files in the specified directory (non-recursive).

### Command-Line Options

```
positional arguments:
  directory             Directory to scan (required)

optional arguments:
  -h, --help            Show this help message and exit
  -x, --extension EXT   File extension to search for (default: txt)
  -r, --recursive       Enable recursive scanning through subdirectories
  -d, --delete          Delete duplicate files after finding them
  -f, --force           Force deletion without confirmation prompts
```

### Examples

#### Find duplicate text files in a directory (non-recursive):
```bash
nodup ~/Documents
```

#### Find duplicate PDF files recursively:
```bash
nodup ~/Documents -x pdf -r
```

#### Find and delete duplicate images recursively with confirmation:
```bash
nodup ~/Pictures -x jpg -r -d
```

#### Force delete duplicate documents without prompts:
```bash
nodup ~/Documents -x doc -r -d -f
```

#### Find duplicates with mixed usage:
```bash
nodup /data/files -x mp3 -r --delete --force
```

## How It Works

### Duplicate Detection Algorithm

1. **Scanning Phase**: NoDup scans the specified directory (recursively if enabled) and collects all files matching the specified extension
2. **Hashing Phase**: Each file is processed using SHA-256 to generate a unique hash:
   - Files are read in 64KB chunks for memory efficiency
   - The hash represents the file's content, not its name
3. **Comparison Phase**: Files with identical hashes are grouped together
4. **Reporting Phase**: Groups containing more than one file are reported as duplicates
5. **Deletion Phase** (optional): 
   - Keeps the first file in each group
   - Prompts for confirmation on each duplicate (unless `--force` is used)
   - Removes confirmed duplicates

### Architecture

The project is organized into three main components:

#### NoDupParser (`nodup_parser.py`)
- Handles command-line argument parsing
- Manages argument validation and configuration
- Provides dynamic argument property access
- Integrates with `argcomplete` for shell argument completion

#### NoDupHandler (`nodup_handler.py`)
- Core duplicate detection logic
- File hashing with SHA-256
- Duplicate grouping and comparison
- File deletion with optional confirmation
- Lazy file iteration for memory efficiency

#### Entry Point (`app.py`)
- Main application orchestration
- Integrates parser and handler
- Displays results to the user
- Manages the deletion workflow

## Example Output

```
Looking for duplicates in directory: ~/Documents

Found duplicates:
Hash: a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6
  ~/Documents/file1.txt
  ~/Documents/backup/file1_copy.txt
Hash: f5e4d3c2b1a0z9y8x7w6v5u4t3s2r1q0p9o8n7m6l5k4j3i2h1g0
  ~/Documents/reports/report.txt
  ~/Documents/archive/report_old.txt

Deleting duplicates...
Delete ~/Documents/backup/file1_copy.txt? [y/N]: y
❌ Deleted: ~/Documents/backup/file1_copy.txt
Delete ~/Documents/archive/report_old.txt? [y/N]: n
⏭ Skipped: ~/Documents/archive/report_old.txt
```

## Project Structure

```
nodup/
├── src/
│   └── nodup/
│       ├── __init__.py              # Package initialization
│       ├── app.py                   # Main application entry point
│       ├── nodup_handler.py         # Duplicate detection and deletion logic
│       └── nodup_parser.py          # Command-line argument parsing
├── templates/
│   └── wrapper.tmpl                 # Template files (if used)
├── build/                           # Built distribution files
├── setup.py                         # Package configuration and installation
├── requirements.txt                 # Python dependencies
├── README.md                        # This file
├── LICENSE                          # License information
├── Pipfile                          # Pipenv dependencies
└── install.sh                       # Installation script
```

## Performance Considerations

### Memory Usage
- NoDup uses lazy file iteration via generator functions (`get_files()`)
- Files are processed in 64KB chunks during hashing to minimize memory footprint
- Suitable for directories with thousands of files

### Processing Speed
- SHA-256 hashing speed depends on:
  - File size
  - Disk I/O performance
  - System CPU capabilities
- Typical processing rate: 50-200 MB/second on modern hardware

### Tips for Large Directories
1. Use extension filtering to limit the number of files processed
2. Run during off-peak hours for large recursive scans
3. Test with `--delete` option before using `--force` mode
4. Consider running on directories with similar file types

## Error Handling

NoDup handles various error scenarios gracefully:

- **File Access Errors**: Skips files that cannot be read (permissions, deleted during scan, etc.)
- **Directory Not Found**: Displays clear error message if directory doesn't exist
- **Invalid Extension**: Returns empty results if no files match the specified extension
- **Deleted Files During Scan**: Safely handles files deleted between scan and deletion phases

## Security Considerations

### Safe Deletion
- **Interactive Mode** (default): Requires user confirmation for each deletion
- **Force Mode**: Use `--force` flag for automated deletion (use with caution)
- **Backup Recommendation**: Always maintain backups before running in delete mode
- **Selective Deletion**: Review duplicates carefully before confirming deletion

### File Permissions
- NoDup respects system file permissions
- Cannot delete files without write permissions to the directory
- Displays permission errors clearly for troubleshooting

## Development

### Setting Up Development Environment

```bash
# Clone the repository
git clone <repository-url>
cd nodup

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install in development mode with dev dependencies
pip install -e ".[dev]"

# Run tests (if available)
pytest
```

### Project Dependencies

**Core Dependencies:**
- `argcomplete` - Shell completion for command-line arguments
- `pipenv` - Virtual environment management

**Development Dependencies:**
- `setuptools` - Package building and installation
- `wheel` - Wheel distribution format
- `pytest` - Testing framework

### Code Style
The project follows Python conventions:
- Snake_case for functions and variables
- PascalCase for classes
- Docstrings for modules, classes, and functions
- Type hints where applicable

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Make your changes
4. Ensure code quality and tests pass
5. Submit a pull request with a clear description

## FAQ

### Q: Is it safe to use the `--force` flag?
**A:** Yes, but use it cautiously. It skips confirmation prompts but still keeps the first file in each duplicate group. Always test with confirmation prompts first.

### Q: Why does NoDup use SHA-256 hashing?
**A:** SHA-256 provides collision-resistant hashing, meaning it's virtually impossible for two different files to have the same hash. This is more reliable than comparing file sizes or names.

### Q: Can I undo a deletion?
**A:** NoDup permanently deletes files using `os.remove()`. Once deleted, files cannot be recovered through the tool. Use your system's trash/recycle bin or backups if available.

### Q: Why keep the first file when deleting duplicates?
**A:** The first file found is kept to preserve at least one copy of the content. This is a safe default behavior.

### Q: How long does it take to scan large directories?
**A:** Depends on file count, size, and hardware. A typical directory with 1000 files takes a few seconds to scan. Recursive scanning of large directory trees may take minutes.

### Q: Can I filter by multiple extensions?
**A:** Currently, you can only specify one extension per run. Run multiple times with different extensions if needed.

## Troubleshooting

### Issue: "Directory to scan [Required]" error
**Solution:** Ensure you provide a valid directory path as the first argument.

```bash
nodup /path/to/directory
```

### Issue: Permission denied when deleting files
**Solution:** Ensure you have write permissions to the directory:

```bash
chmod u+w /path/to/directory
```

### Issue: No duplicates found
**Solution:** Check that:
1. The directory path is correct
2. The extension matches your files (`-x pdf` for PDF files)
3. Enable recursive mode if files are in subdirectories (`-r`)

### Issue: Files deleted unexpectedly
**Solution:** Always review the duplicate list before confirming deletion. Use interactive mode (without `--force`) to verify each deletion.

---

**Version:** 1.2.0  
**Last Updated:** 2026  
**Python Version:** 3.7+

