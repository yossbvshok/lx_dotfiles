#!/bin/bash

source ~/tools/lx_dotfiles/utils/expcolors.sh

# Function to print usage information
print_usage() {
  section "Usage Information"
  echo "Usage: $0 <target_host>"
  echo ""
  echo "Examples:"
  echo "$0 10.129.27.108"
  echo ""
  echo "With faketime:"
  echo "faketime \"\$(kerbasyncrc.sh 10.129.27.108)\" impacket-getST eighteen.htb/adam.scott:iloveyou1 -impersonate 'enc_dmsa' -self -dmsa -debug"
}

# Check for help flag or no arguments
if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  print_usage
  exit 0
fi

# Core function definition using ntpdate
getDate() {
  local target_host="$1"
  local ntp_output
  ntp_output=$(ntpdate -u "$target_host" 2>&1)

  # Filter the line that starts with the date and remove milliseconds
  echo "$ntp_output" | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}' | awk '{print $1, substr($2, 1, 8)}'
}

# Check and install faketime (silent)
check_faketime() {
  if ! command -v faketime &>/dev/null; then
    info "faketime is not installed. Attempting silent installation..."
    sudo apt update >/dev/null 2>&1 && sudo apt install -y faketime >/dev/null 2>&1

    if [ $? -ne 0 ]; then
      error "Failed to install faketime package automatically."
      warning "Please install it manually: sudo apt install faketime"
      return 1
    fi
    success "faketime installed successfully."
  fi
  return 0
}

# Main execution
main() {
  local target_host="$1"

  # Validations
  if [ -z "$target_host" ]; then
    error "No target host specified."
    print_usage
    exit 1
  fi

  # Check faketime silently or handle installation
  if ! check_faketime; then
    exit 1
  fi

  # Get server date via NTP
  local server_date
  server_date=$(getDate "$target_host")

  if [ -n "$server_date" ]; then
    echo "$server_date"
    exit 0
  else
    error "Failed to retrieve NTP date from target: $target_host"
    exit 1
  fi
}

# Run main function with all arguments
main "$@"