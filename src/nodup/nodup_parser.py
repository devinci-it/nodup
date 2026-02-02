import argparse
import argcomplete

class NoDupParser:
    def __init__(self, argument_handler=None):
        """Initialize the argument parser and set up dynamic argument methods."""
        # Initialize the argument dictionary

        self.args = {
            "directory": {"type": str, "help": "Directory to scan", "required": True},
            "extension": {"type": str, "default": "txt", "help": "File extension (default: txt)","short": "x"},
            "recursive": {"action": "store_true", "help": "Enable recursive scanning", "short": "r"},
            "delete": {"action": "store_true", "help": "Delete duplicates after finding them", "short": "d"},
            "force": {"action": "store_true", "help": "Force delete duplicates without confirmation", "short": "f"}
        }

        # Set placeholder for dynamic attributes
        for arg in self.args:
            self.args[arg]["value"] = None

        # Initialize the ArgumentParser object
        self.parser = argparse.ArgumentParser(description="NoDup - Find and delete duplicate files by hash")
        
        # Use the injected argument handler, or fall back to the default handler
        self.argument_handler = argument_handler if argument_handler else self

        # Add dynamic methods for argument setting and getting using @property
        self._create_argument_properties()

        # Add default behavior for -n (non-recursive) and -r (recursive)
        self._set_default_behavior()

        # Add arguments to the parser
        self.add_arguments()

    def _create_argument_properties(self):
        """Store argument names for dynamic attribute access."""
        self._arg_names = list(self.args.keys())

    def __getattr__(self, name):
        """Dynamically get argument values using __getattr__."""
        if name in self.args:
            return self.args[name].get("value", self.args[name].get("default", None))
        raise AttributeError(f"'{type(self).__name__}' object has no attribute '{name}'")

    def __setattr__(self, name, value):
        """Dynamically set argument values using __setattr__."""
        # Handle special attributes normally
        if name in ('args', 'parser', 'argument_handler', '_arg_names'):
            super().__setattr__(name, value)
        elif hasattr(self, 'args') and name in self.args:
            self.args[name]["value"] = value
        else:
            super().__setattr__(name, value)

    def _is_positional(self, arg):
        """Helper method to check if an argument is positional (without flag)."""
        return arg == "directory"  # Only "directory" is considered positional

    def _set_default_behavior(self):
        """Set default behavior for non-recursive processing (-r flag to enable)."""
        # By default, recursive is False (non-recursive)
        self.args['recursive']['default'] = False
        self.args['recursive']['action'] = 'store_true'  # -r flag enables recursive mode
        self.args['delete']['action'] = 'store_true'  # -d flag enables delete

    def add_arguments(self):
        """Dynamically add arguments to the parser from the arguments dictionary."""
        for arg, options in self.args.items():
            kwargs = {k: v for k, v in options.items() if k not in ("short", "required", "value")}  # Remove 'short', 'required', and 'value' from kwargs
            
            if self._is_positional(arg):  # Handle positional arguments
                self.parser.add_argument(arg, **kwargs)  # Handle positional arguments (no flag)
            else:
                # Handle optional arguments with flags (e.g., --extension)
                if 'short' in options:
                    # Add both short and long flags
                    self.parser.add_argument(f"-{options['short']}", f"--{arg}", **kwargs)
                else:
                    self.parser.add_argument(f"--{arg}", **kwargs)

        return self  # Enable method chaining

    def parse_arguments(self):
        """Parse arguments and store the parsed values."""
        # Enable argcomplete if available
        argcomplete.autocomplete(self.parser)

        # Parse the command line arguments
        parsed_args = self.parser.parse_args()

        # Check for conflicting options (force and recursive together)
        if parsed_args.force and parsed_args.recursive:
            print("⚠️ Warning: Using both -f and -r will force deletion recursively. Use with caution!")

        # If -ff is used, set force deletion recursively
        if parsed_args.force and parsed_args.recursive:
            print("⚠️ Force deletion recursively enabled due to -ff")
        
        # Set the parsed values into the args dictionary
        for arg, value in vars(parsed_args).items():
            self.args[arg]["value"] = value
        
        return parsed_args

    def set_argument(self, name, options):
        """Dynamically set or update an argument."""
        self.args[name] = options
        return self  # Enable method chaining

    def get_arguments(self):
        """Return the argument dictionary."""
        return self.args

    def get_parser(self):
        """Return the actual ArgumentParser object."""
        return self.parser
