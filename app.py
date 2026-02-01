import hashlib
import os
import argparse
import argcomplete
from collections import defaultdict

def hash_file(path, block_size=65536):
    hasher = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(block_size), b""):
            hasher.update(chunk)
    return hasher.hexdigest()

def find_duplicates(directory, extension, recursive=True):
    hashes = defaultdict(list)

    for root, _, files in os.walk(directory):
        for name in files:
            if name.lower().endswith(f".{extension.lower()}"):
                full_path = os.path.join(root, name)
                try:
                    file_hash = hash_file(full_path)
                    hashes[file_hash].append(full_path)
                except Exception as e:
                    print(f"⚠️ Skipped {full_path}: {e}")

        if not recursive:
            break

    return {h: paths for h, paths in hashes.items() if len(paths) > 1}

def delete_duplicates(dups, force=False):
    for file_hash, paths in dups.items():
        keep = paths[0]
        to_delete = paths[1:]

        print(f"\nDuplicate group (hash {file_hash}):")
        print(f"  Keeping: {keep}")

        for p in to_delete:
            if force:
                os.remove(p)
                print(f"  ❌ Deleted: {p}")
            else:
                ans = input(f"Delete {p}? [y/N]: ").strip().lower()
                if ans == "y":
                    os.remove(p)
                    print(f"  ❌ Deleted: {p}")
                else:
                    print(f"  ⏭ Skipped: {p}")

def main():
    parser = argparse.ArgumentParser(
        description="Find and optionally delete duplicate files by hash"
    )
    parser.add_argument("directory", help="Directory to scan")

    parser.add_argument(
        "-x", "--extension",
        default="pdf",
        help="File extension to scan (without dot), default: pdf"
    )

    parser.add_argument(
        "-n", "--no-recursive",
        action="store_true",
        help="Do not scan subdirectories"
    )

    parser.add_argument(
        "-d", "--delete",
        action="store_true",
        help="Prompt before deleting duplicates"
    )

    parser.add_argument(
        "-f", "--force",
        action="store_true",
        help="Delete duplicates without confirmation"
    )

    argcomplete.autocomplete(parser)
    args = parser.parse_args()

    duplicates = find_duplicates(
        args.directory,
        args.extension,
        recursive=not args.no_recursive
    )

    if not duplicates:
        print("No duplicates found.")
        return

    print("\nPossible duplicates found:\n")
    for h, paths in duplicates.items():
        print(f"Hash: {h}")
        for p in paths:
            print(f"  {p}")

    if args.force:
        delete_duplicates(duplicates, force=True)
    elif args.delete:
        delete_duplicates(duplicates, force=False)
    else:
        print("\n(No files deleted — use -d or -f)")

if __name__ == "__main__":
    main()

