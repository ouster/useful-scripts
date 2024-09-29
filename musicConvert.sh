#!/bin/bash

# Generate timestamp for log file
timestamp=$(date '+%Y%m%d%H%M%S')
log_file="convert$timestamp.log"

# Function to convert a single file from AIFF to FLAC and preserve directory structure
convert_file() {
  input_file="$1"
  output_file="$2"

  # Check if the target FLAC file already exists
  if [[ -f "$output_file" ]]; then
    echo "Skipping conversion for '$input_file'. Target file '$output_file' already exists."
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Skipped conversion for '$input_file'. Target file '$output_file' already exists." >> "$log_file"
  else
    mkdir -p "$(dirname "$output_file")" # Create the destination directory if it doesn't exist

    echo "Converting '$input_file' to '$output_file'..."
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Converting '$input_file' to '$output_file'..." >> "$log_file"

    echo "input_file=$input_file, output_file=$output_file"
    ffmpeg -i "$input_file" -c:a flac -compression_level 12 "$output_file"

    echo "Converted '$input_file' to '$output_file'."
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Converted '$input_file' to '$output_file'." >> "$log_file"

    # Preserve metadata using metaflac
    metaflac --import-tags-from="$input_file" "$output_file"

    echo "Preserved metadata for '$output_file'."
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Preserved metadata for '$output_file'." >> "$log_file"
  fi
}

# Function to handle termination signal
trap 'echo "Script terminated." >&2; exit 1' INT

# Main execution
music_dir="${1:-./Music}"
output_dir="${2:-./NewMusic}"

# Create the log file if it doesn't exist
touch "$log_file"

# Start the conversion process
echo "Starting conversion process..."
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting conversion process..." >> "$log_file"

# Generate a map of the source directory using the tree command
#map=$(tree -fi "$music_dir" | grep -e "\.aiff$")
#echo "map=$map"

# Loop through the map and convert each file
IFS=$'\n'
for i in $(find "$music_dir" -name '*.aiff' -type f); do
  echo "i='$i'"

  file_w_ext="$(basename -- "$i")"
  echo "file_w_ext='$file_w_ext'"

  file_name="${file_w_ext%.*}"
  echo "file_name='$file_name'"


  base_dir="$(dirname "$i")"
  echo "base_dir='$base_dir'"

  target_dir=$(basename $base_dir)
  echo "target_dir='$target_dir'"
  
  target_file="$output_dir/$target_dir/$file_name.flac"
  echo "target_file='$target_file'"
  
  convert_file "$i" "$target_file"
done
unset IFS

echo "Conversion process completed."
echo "$(date '+%Y-%m-%d %H:%M:%S') - Conversion process completed." >> "$log_file"

