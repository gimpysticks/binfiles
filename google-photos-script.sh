#!/bin/bash
# Google Photos CLI Integration Script
# This script provides command-line functionality for Google Photos

# Requirements:
# - gphoto (Google Photos CLI - needs to be installed via pip)
# - jq (JSON processor)
# - curl

# Configuration
CREDENTIALS_FILE="$HOME/.config/google-photos/credentials.json"
TOKEN_FILE="$HOME/.config/google-photos/token.json"
CONFIG_DIR="$HOME/.config/google-photos"
ALBUM_CACHE_FILE="$CONFIG_DIR/albums.json"

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Check dependencies
check_dependencies() {
  missing=false
  
  if ! command -v pip3 &> /dev/null; then
    echo "Error: pip3 is required but not installed."
    missing=true
  fi
  
  if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    missing=true
  fi
  
  if ! command -v curl &> /dev/null; then
    echo "Error: curl is required but not installed."
    missing=true
  fi
  
  if $missing; then
    echo "Please install missing dependencies and try again."
    echo "You can install them with: sudo apt install python3-pip jq curl"
    exit 1
  fi
  
  # Check for gphoto installation
  if ! pip3 list | grep -q "gphoto"; then
    echo "Installing gphoto CLI tool..."
    pip3 install gphoto-cli
  fi
}

# Check if credentials exist, if not, guide the user
check_credentials() {
  if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "Google Photos API credentials not found."
    echo "To use this script, you need to:"
    echo "1. Go to https://console.developers.google.com/"
    echo "2. Create a new project"
    echo "3. Enable the Google Photos Library API"
    echo "4. Create OAuth 2.0 credentials (Desktop application type)"
    echo "5. Download the credentials JSON file"
    echo "6. Save it as $CREDENTIALS_FILE"
    return 1
  fi
  return 0
}

authenticate() {
  if [ ! -f "$TOKEN_FILE" ]; then
    echo "Authenticating with Google Photos..."
    gphoto auth --credentials "$CREDENTIALS_FILE" --token "$TOKEN_FILE"
  fi
}

# List all albums
list_albums() {
  echo "Fetching albums from Google Photos..."
  gphoto albums list --credentials "$CREDENTIALS_FILE" --token "$TOKEN_FILE" > "$ALBUM_CACHE_FILE"
  cat "$ALBUM_CACHE_FILE" | jq -r '.albums[] | "\(.id): \(.title)"'
}

# Upload a photo to a specific album
upload_photo() {
  local file="$1"
  local album_id="$2"
  
  if [ ! -f "$file" ]; then
    echo "Error: File not found: $file"
    return 1
  fi
  
  echo "Uploading $file to album $album_id..."
  if [ -z "$album_id" ]; then
    gphoto media upload "$file" --credentials "$CREDENTIALS_FILE" --token "$TOKEN_FILE"
  else
    gphoto media upload "$file" --album "$album_id" --credentials "$CREDENTIALS_FILE" --token "$TOKEN_FILE"
  fi
}

# Upload all photos in a directory
upload_directory() {
  local dir="$1"
  local album_id="$2"
  
  if [ ! -d "$dir" ]; then
    echo "Error: Directory not found: $dir"
    return 1
  fi
  
  echo "Uploading all photos in $dir to album $album_id..."
  find "$dir" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) | while read file; do
    upload_photo "$file" "$album_id"
  done
}

# Create a new album
create_album() {
  local album_name="$1"
  
  if [ -z "$album_name" ]; then
    echo "Error: Album name is required"
    return 1
  fi
  
  echo "Creating new album: $album_name"
  gphoto albums create "$album_name" --credentials "$CREDENTIALS_FILE" --token "$TOKEN_FILE"
}

# Display help
show_help() {
  echo "Google Photos CLI Integration"
  echo "Usage: $0 [command] [arguments]"
  echo ""
  echo "Commands:"
  echo "  auth                    Authenticate with Google Photos"
  echo "  albums                  List all albums"
  echo "  upload [file] [album]   Upload a photo to an album (album ID is optional)"
  echo "  upload-dir [dir] [album] Upload all photos in a directory to an album"
  echo "  create-album [name]     Create a new album"
  echo "  setup-nautilus          Create Nautilus integration (file manager actions)"
  echo "  mount                   Create a virtual mount point (read-only)"
  echo ""
  echo "Examples:"
  echo "  $0 auth"
  echo "  $0 albums"
  echo "  $0 upload photo.jpg"
  echo "  $0 upload photo.jpg AGj1XXXXXXXXXXXXXXXM"
  echo "  $0 upload-dir ~/Pictures/Vacation AGj1XXXXXXXXXXXXXXXM"
  echo "  $0 create-album \"Vacation 2025\""
}

# Setup Nautilus integration
setup_nautilus() {
  local nautilus_dir="$HOME/.local/share/nautilus/scripts"
  local script_path="$(realpath "$0")"
  
  # Create Nautilus scripts directory if it doesn't exist
  mkdir -p "$nautilus_dir"
  
  # Create "Upload to Google Photos" script
  cat > "$nautilus_dir/Upload to Google Photos" << EOL
#!/bin/bash
# Get selected files from Nautilus
files="\$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS"

# Display album selection dialog
albums=\$(${script_path} albums | zenity --list --title="Select Album" --column="ID" --column="Name" --height=500 --width=400)
album_id=\$(echo \$albums | cut -d: -f1)

if [ -n "\$album_id" ]; then
  for file in \$files; do
    ${script_path} upload "\$file" "\$album_id"
  done
  zenity --info --text="Upload complete!"
fi
EOL
  
  # Make the script executable
  chmod +x "$nautilus_dir/Upload to Google Photos"
  
  echo "Nautilus integration setup complete!"
  echo "You can now right-click on images in Nautilus, select Scripts > Upload to Google Photos"
  echo "You may need to restart Nautilus with: nautilus -q"
}

# Create a virtual mount point (read-only)
create_mount() {
  if ! command -v rclone &> /dev/null; then
    echo "Error: rclone is required for mounting but not installed."
    echo "Please install it with: curl https://rclone.org/install.sh | sudo bash"
    return 1
  fi
  
  # Check if rclone is configured for Google Photos
  if ! rclone listremotes | grep -q "gphotos:"; then
    echo "Setting up rclone for Google Photos..."
    echo "Please follow the instructions to configure rclone with your Google account."
    rclone config
  fi
  
  # Create mount point
  local mount_point="$HOME/GooglePhotos"
  mkdir -p "$mount_point"
  
  echo "Mounting Google Photos to $mount_point..."
  echo "This is a read-only mount to browse your photos."
  
  # Mount using rclone
  rclone mount gphotos: "$mount_point" --daemon
  
  echo "Google Photos mounted at $mount_point"
  echo "To unmount, run: fusermount -u $mount_point"
}

# Main function
main() {
  check_dependencies
  
  if [ $# -eq 0 ]; then
    show_help
    exit 0
  fi
  
  command="$1"
  shift
  
  case "$command" in
    auth)
      check_credentials && authenticate
      ;;
    albums)
      check_credentials && authenticate && list_albums
      ;;
    upload)
      if [ $# -lt 1 ]; then
        echo "Error: Missing file to upload"
        show_help
        exit 1
      fi
      check_credentials && authenticate && upload_photo "$1" "$2"
      ;;
    upload-dir)
      if [ $# -lt 1 ]; then
        echo "Error: Missing directory to upload"
        show_help
        exit 1
      fi
      check_credentials && authenticate && upload_directory "$1" "$2"
      ;;
    create-album)
      if [ $# -lt 1 ]; then
        echo "Error: Missing album name"
        show_help
        exit 1
      fi
      check_credentials && authenticate && create_album "$1"
      ;;
    setup-nautilus)
      setup_nautilus
      ;;
    mount)
      check_credentials && authenticate && create_mount
      ;;
    *)
      echo "Unknown command: $command"
      show_help
      exit 1
      ;;
  esac
}

# Execute main function
main "$@"
