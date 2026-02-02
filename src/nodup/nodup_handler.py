import os
import hashlib

class NoDupHandler:
    def __init__(self, directory, extension="txt", recursive=False, force=False):
        self.directory = directory
        self.extension = extension
        self.recursive = recursive
        self.force = force
        self._duplicates = None

    @property
    def duplicates(self):
        """Lazily load and cache the duplicates."""
        if self._duplicates is None:
            self._duplicates = self.find_duplicates()  # Calculate once and store
        return self._duplicates

    def find_duplicates(self):
        """Find duplicates in the specified directory."""
        hashes = {}
        
        # Iterate over files lazily using the get_files generator
        for file_path in self.get_files():
            file_hash = self.hash_file(file_path)
            if file_hash:  # If the file has a valid hash
                if file_hash not in hashes:
                    hashes[file_hash] = []
                hashes[file_hash].append(file_path)

        # Return duplicate groups (files with the same hash)
        return {h: paths for h, paths in hashes.items() if len(paths) > 1}

    def get_files(self):
        """Generates valid files from the specified directory."""
        if self.recursive:
            # Recursive mode: walk through all subdirectories
            for root, _, files in os.walk(self.directory):
                for name in files:
                    full_path = os.path.join(root, name)
                    if self.is_valid_extension(name):
                        yield full_path
        else:
            # Non-recursive mode: only scan the top-level directory
            try:
                for name in os.listdir(self.directory):
                    full_path = os.path.join(self.directory, name)
                    if os.path.isfile(full_path) and self.is_valid_extension(name):
                        yield full_path
            except OSError as e:
                print(f"⚠️ Error reading directory {self.directory}: {e}")

    def is_valid_extension(self, filename):
        """Checks if the file has the correct extension."""
        return filename.lower().endswith(f".{self.extension.lower()}")

    def hash_file(self, file_path):
        """Calculates the SHA-256 hash of a file."""
        try:
            hasher = hashlib.sha256()
            with open(file_path, "rb") as file:
                for chunk in iter(lambda: file.read(65536), b""):
                    hasher.update(chunk)
            return hasher.hexdigest()
        except Exception as e:
            print(f"⚠️ Skipped {file_path}: {e}")
            return None

    def delete_duplicates(self, duplicates):
        """Deletes duplicates."""
        for hash_value, paths in duplicates.items():
            to_delete = paths[1:]  # Keep the first file, delete the rest
            for file_path in to_delete:
                self.delete_file(file_path)

    def delete_file(self, file_path):
        """Deletes the file (with confirmation if needed)."""
        if self.force:
            os.remove(file_path)
            print(f"❌ Force deleted: {file_path}")
        else:
            ans = input(f"Delete {file_path}? [y/N]: ").strip().lower()
            if ans == "y":
                os.remove(file_path)
                print(f"❌ Deleted: {file_path}")
            else:
                print(f"⏭ Skipped: {file_path}")
