#!/usr/bin/env bash
# Sets up the anki/ working directory by linking to the sibling anki-data/ repo.
#
# Two modes:
#   --init   Create a fresh anki-data/ repo (new machine, no existing data).
#   (none)   Link to an already-cloned anki-data/ (existing data).
#
# Expected layout after setup:
#   <parent>/
#     anki/         ← this config repo
#     anki-data/    ← data repo
#
# Usage:
#   bash setup.sh          # link to existing anki-data/
#   bash setup.sh --init   # create fresh anki-data/ and link

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="$(dirname "$SCRIPT_DIR")/anki-data"

make_link() {
  local target="$1"
  local link="$2"
  if [ -L "$link" ]; then
    echo "Already a symlink, skipping: $link"
  elif [ -e "$link" ]; then
    echo "Error: $link exists and is not a symlink — move it out of the way first."
    exit 1
  else
    ln -s "$target" "$link"
    echo "Created: $link -> $target"
  fi
}

if [ "${1:-}" = "--init" ]; then
  if [ -d "$DATA_DIR" ]; then
    echo "Error: $DATA_DIR already exists. Use 'bash setup.sh' (without --init) to link to it."
    exit 1
  fi
  echo "Initialising fresh data repo at $DATA_DIR ..."
  mkdir "$DATA_DIR"
  git -C "$DATA_DIR" init
  git -C "$DATA_DIR" checkout -b main
  mkdir "$DATA_DIR/cards"
  printf 'word,added_date,week,file\n' > "$DATA_DIR/cards/words_log.csv"
  git -C "$DATA_DIR" add .
  git -C "$DATA_DIR" commit -m "Initial empty data repo"
  echo "Data repo ready."
else
  if [ ! -d "$DATA_DIR" ]; then
    echo "Error: anki-data/ not found at $DATA_DIR"
    echo "Either clone the data repo there, or run 'bash setup.sh --init' to start fresh."
    exit 1
  fi
fi

make_link "$DATA_DIR/cards"               "$SCRIPT_DIR/cards"
make_link "$DATA_DIR/cards/words_log.csv" "$SCRIPT_DIR/words_log.csv"

echo "Done."
