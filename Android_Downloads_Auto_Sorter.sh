#!/data/data/com.termux/files/usr/bin/bash
# Organize files in Android's Downloads folder into folders by file extension.
# Run this in Termux after: termux-setup-storage

set -u

SOURCE="$HOME/storage/downloads"

if [ ! -d "$SOURCE" ]; then
  echo "Downloads folder not found."
  echo "Open Termux and run: termux-setup-storage"
  exit 1
fi

moved=0
skipped=0

shopt -s nullglob dotglob

for file in "$SOURCE"/*; do
  [ -f "$file" ] || continue

  name="${file##*/}"

  # Put files without an extension into a dedicated folder.
  if [[ "$name" == .* && "$name" != *.*.* ]] || [[ "$name" != *.* ]]; then
    ext="NO_EXTENSION"
  else
    ext="${name##*.}"
    ext="${ext^^}"
    [ -n "$ext" ] || ext="NO_EXTENSION"
  fi

  # Keep folder names safe and simple.
  ext="${ext//[^A-Z0-9_-]/_}"
  destination="$SOURCE/$ext"
  mkdir -p "$destination"

  target="$destination/$name"
  if [ -e "$target" ]; then
    base="$name"
    count=1
    while [ -e "$destination/${base}.duplicate${count}" ]; do
      count=$((count + 1))
    done
    target="$destination/${base}.duplicate${count}"
  fi

  if mv -- "$file" "$target"; then
    moved=$((moved + 1))
  else
    skipped=$((skipped + 1))
    echo "Could not move: $name"
  fi
done

echo
echo "Finished. Files moved: $moved | Skipped: $skipped"
echo "Organized folders are inside: $SOURCE"
