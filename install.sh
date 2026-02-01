#!/usr/bin/env bash

# Color codes for different output styles
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
RESET="\033[0m"  # Reset color to default
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
    echo "To update your ~/.bashrc, run the following commands:"
    echo ""
    echo "1. Add ~/.local/bin to your PATH:"
    echo '   echo \"export PATH=\"$HOME/.local/bin:$PATH\"\" >> ~/.bashrc'
    echo '   source ~/.bashrc'
    echo ""
    echo "2. Enable pipenv auto-completion:"
    echo '   echo \"eval \"\$(pipenv --completion)\"\" >> ~/.bashrc'
    echo '   source ~/.bashrc'
    echo ""
    echo "3. Enable auto-completion for nodup (if using argcomplete):"
    echo '   echo \"eval \"\$(register-python-argcomplete nodup)\"\" >> ~/.bashrc'
    echo '   source ~/.bashrc'
    echo ""
    echo "Once you run these commands, restart your terminal or run 'source ~/.bashrc' to apply the changes."
}

# Main Install Script
APP_NAME=nodup
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
WRAPPER="$BIN_DIR/$APP_NAME"

# Redirect all stdout and stderr to install.log
LOG_FILE="./install.log"
exec > >(tee -a "$LOG_FILE") 2>&1

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

# Start installation
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

  # Upgrade pip inside the pipenv environment
  echo -e "  ▶ ${BLUE}Upgrading pip in pipenv environment...${RESET}"
  $(pipenv --venv)/bin/pip install --upgrade pip >> "$LOG_FILE" 2>&1
  echo -e "    ✅ ${GREEN}pip upgraded inside pipenv environment${RESET}"

  # Upgrade pipenv itself
  echo -e "  ▶ ${BLUE}Upgrading pipenv...${RESET}"
  $(pipenv --venv)/bin/pip install --upgrade pipenv >> "$LOG_FILE" 2>&1
  echo -e "    ✅ ${GREEN}pipenv upgraded to latest version${RESET}"
else
  echo -e "⚠️ ${YELLOW}pipenv is not installed, falling back to venv...${RESET}"
  create_venv
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
print_instructions_for_bashrc_update "$BLUE" "$RESET"
