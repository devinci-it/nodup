from nodup.nodup_parser import NoDupParser
from nodup.nodup_handler import NoDupHandler  

def main():
    # Instantiate the argument parser
    parser = NoDupParser()

    # Parse arguments from the command line
    args = parser.parse_arguments()

    # Access parsed arguments
    directory = parser.directory
    extension = parser.extension
    recursive = parser.recursive
    delete = parser.delete
    force = parser.force

    # Create the handler (NoDupHandler)
    handler = NoDupHandler(
        directory=directory,
        extension=extension,
        recursive=recursive,
        force=force
    )

    # Find duplicates
    print(f"Looking for duplicates in directory: {directory}")
    duplicates = handler.find_duplicates()

    if not duplicates:
        print("No duplicates found.")
    else:
        print(f"\nFound duplicates:")
        for hash_value, file_paths in duplicates.items():
            print(f"Hash: {hash_value}")
            for file_path in file_paths:
                print(f"  {file_path}")

        if delete:
            print(f"\nDeleting duplicates...")
            handler.delete_duplicates(duplicates)

if __name__ == "__main__":
    main()
