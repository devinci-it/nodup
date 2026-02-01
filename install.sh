#!/usr/bin/env bash

# Color codes for different output styles
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
RESET="\033[0m"  # Reset color to default

# Function to print the banner
print_banner() {
    local BLUE=$1
    local RESET=$2
    echo -e "${BLUE}                             
                █▄            
 ▄              ██            
 ████▄ ▄███▄ ▄████ ██ ██ ████▄
 ██ ██ ██ ██ ██ ██ ██ ██ ██ ██
▄██ ▀█▄▀███▀▄█▀███▄▀██▀█▄████▀
                         ██   
                         ▀    
${RESET}" 
}

# Function to print instructions for bashrc update
print_instructions_for_bashrc_update() {
    echo -e "${YELLOW}To update your ~/.bashrc, run the following commands:${RESET}"
    echo ""
    echo -e "${GREEN}1. Add ~/.local/bin to your PATH:${RESET}"
    echo -e '   echo \"export PATH=\"$HOME/.local/bin:$PATH\"\" >> ~/.bashrc'
    echo -e '   source ~/.bashrc'
    echo ""
    echo -e "${GREEN}2. Enable pipenv auto-completion:${RESET}"
    echo -e '   echo \"eval \"\$(pipenv --completion)\"\" >> ~/.bashrc'
    echo -e '   source ~/.bashrc'
    echo ""
    echo -e "${GREEN}3. Enable auto-completion for nodup (if using argcomplete):${RESET}"
    echo -e '   echo \"eval \"\$(register-python-argcomplete nodup)\"\" >> ~/.bashrc'
    echo -e '   source ~/.bashrc'
    echo ""
    echo -e "${YELLOW}Once you run these commands, restart your terminal or run 'source ~/.bashrc' to apply the changes.${RESET}"
}

# Main Install Script
APP_NAME=nodup
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
WRAPPER="$BIN_DIR/$APP_NAME"

# Log file to capture installation process
LOG_FILE="./install.log"

# Append to the log file instead of overwriting
exec >> >(tee -a "$LOG_FILE") 2>&1

# Check if pipenv is installed
check_pipenv() {
  command -v pipenv >/dev/null 2>&1
}

# Function to create a virtual environment using venv
create_venv() {
  echo -e "  ▶ ${BLUE}Creating venv environment...${RESET}"
  python3 -m venv "$PROJECT_DIR/venv" >> "$LOG_FILE" 2>&1
  echo -e "    ✅ ${GREEN}Virtual environment created at $PROJECT_DIR/venv${RESET}"

  echo -e "  ▶ ${BLUE}Activating virtual environment...${RESET}"
  . "$PROJECT_DIR/venv/bin/activate" >> "$LOG_FILE" 2>&1
  echo -e "    ✅ ${GREEN}Virtual environment activated${RESET}"

  echo -e "  ▶ ${BLUE}Installing dependencies...${RESET}"
  pip install -r "$PROJECT_DIR/requirements.txt" >> "$LOG_FILE" 2>&1
  echo -e "    ✅ ${GREEN}Dependencies installed from requirements.txt${RESET}"
}

# Generate wrapper function
generate_wrapper_script() {
  echo -e "▶ ${BLUE}Generating wrapper script...${RESET}"

  # Replace placeholders in the wrapper template
  sed \
    -e "s|{{PROJECT_DIR}}|$PROJECT_DIR|g" \
    -e "s|{{EXEC_NAME}}|$APP_NAME|g" \
    "$PROJECT_DIR/wrapper.tmpl" > "$WRAPPER"

  # Make the wrapper script executable
  chmod +x "$WRAPPER" >> "$LOG_FILE" 2>&1
  echo -e "    ✅ ${GREEN}Wrapper script generated and made executable${RESET}"
}

# Verify nodup executable in venv bin directory
verify_nodup_executable() {
  VENV_PATH=$(cd "$PROJECT_DIR" && pipenv --venv)
  VENV_BIN_DIR="$VENV_PATH/bin"

  if [ ! -f "$VENV_BIN_DIR/$APP_NAME" ]; then
    echo "❌ $APP_NAME executable not found in virtual environment at $VENV_BIN_DIR."
    exit 1
  fi

  echo -e "    ✅ ${GREEN}$APP_NAME executable found in virtual environment at $VENV_BIN_DIR${RESET}"
}

# Ensure setuptools and wheel are installed in the venv
ensure_setuptools_and_wheel() {
  echo -e "▶ ${BLUE}Ensuring setuptools and wheel are installed...${RESET}"
  pip install --upgrade setuptools wheel >> "$LOG_FILE" 2>&1
  echo -e "    ✅ ${GREEN}setuptools and wheel installed/updated${RESET}"
}

# Start installation
print_banner "$BLUE" "$RESET"
echo -e "▶ ${BLUE}Starting installation for $APP_NAME...${RESET}"
echo "Logging to $LOG_FILE"

# Check if pipenv is installed
if check_pipenv; then
  echo -e "▶ ${BLUE}pipenv is installed, creating pipenv environment...${RESET}"

  # Get the system Python version (3.7 or above is required)
  PYTHON_VERSION=$(python3 --version | awk '{print $2}')
  echo -e "  ▶ ${BLUE}Detected system Python version: $PYTHON_VERSION${RESET}"

  # Create pipenv environment using the system Python version
  pipenv --python "$PYTHON_VERSION" install --dev >> "$LOG_FILE" 2>&1
  echo -e "    ✅ ${GREEN}pipenv environment created with Python $PYTHON_VERSION${RESET}"

  # cd into the project directory and ensure setuptools/wheel are installed, then run bdist_wheel
  cd "$PROJECT_DIR"
  ensure_setuptools_and_wheel
  VENV_PATH=$(pipenv --venv)
  VENV_BIN_DIR="$VENV_PATH/bin"
  
  # Run setup.py to build the wheel using the Python in the virtualenv
  echo -e "  ▶ ${BLUE}Building wheel...${RESET}"
  "$VENV_BIN_DIR/python3" setup.py bdist_wheel >> "$LOG_FILE" 2>&1
  echo -e "    ✅ ${GREEN}Wheel built successfully${RESET}"

  # Verify the executable after installation
  verify_nodup_executable

else
  echo -e "⚠️ ${YELLOW}pipenv is not installed, falling back to venv...${RESET}"
  create_venv
  ensure_setuptools_and_wheel
  VENV_BIN_DIR="$PROJECT_DIR/venv/bin"
  
  # Run setup.py to build the wheel using the Python in the venv
  echo -e "  ▶ ${BLUE}Building wheel...${RESET}"
  "$VENV_BIN_DIR/python3" setup.py bdist_wheel >> "$LOG_FILE" 2>&1
  echo -e "    ✅ ${GREEN}Wheel built successfully${RESET}"

  # Verify the executable after installation
  verify_nodup_executable
fi

# Ensure the binary directory exists
echo -e "▶ ${BLUE}Ensuring $BIN_DIR exists...${RESET}"
mkdir -p "$BIN_DIR" >> "$LOG_FILE" 2>&1
echo -e "    ✅ ${GREEN}$BIN_DIR created or already exists${RESET}"

# Generate the wrapper script
generate_wrapper_script

# Final completion message
echo -e "✅ ${GREEN}Installation complete${RESET}"
echo -e "➡ ${BLUE}$APP_NAME is now installed.${RESET}"
echo -e "➡ ${BLUE}You can run: $APP_NAME --help${RESET}"
echo -e "➡ ${YELLOW}Ensure ~/.local/bin is in your PATH${RESET}"

# Print bashrc update instructions
print_instructions_for_bashrc_update
