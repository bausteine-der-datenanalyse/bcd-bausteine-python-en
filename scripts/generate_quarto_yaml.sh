#!/bin/bash

# Set output path for combined YAML
OUTPUT_YAML="_quarto.yml"

# Start the YAML file
cat <<EOF > $OUTPUT_YAML
project:
  type: book
  output-dir: output/book/
book:
  title: "Python Building Blocks"
  author:
    - Lukas Arnold
    - Simone Arnold
    - Florian Bagemihl
    - Matthias Baitsch
    - Marc Fehr
    - Maik Poetzsch
    - Sebastian Seipel
  date: today
  language: en-US
  downloads: [pdf]
  repo-url: "https://github.com/bausteine-der-datenanalyse/bcd-bausteine-python-en"
  repo-actions: [source]
  favicon: books/shared-media/logo/favicon.svg
  sidebar:
    title: "Python Building Blocks"
    logo: books/shared-media/logo/logo_with_text.svg
  chapters:
    - index.qmd
EOF

# Define the order of submodules (pedagogical order, not alphabetical)
SUBMODULES_ORDER=(
  "books/w-pseudocode-en"
  "books/w-python-minimal-en"
  "books/w-python-en"
  "books/w-python-numpy-grundlagen-en"
  "books/w-pandas-en"
  "books/w-python-matplotlib-en"
  "books/m-numerik-en"
  "books/m-einlesen-strukturierter-datensaetze-en"
  "books/m-datenfitting-und-optimierung-en"
  "books/m-sensordatenanalyse-en"
  "books/m-analyse-von-zeitdaten-en"
  "books/a-energiedatenanalyse-en"
  "books/a-auswertung-fds-daten-en"
)

# Step 2: Append parts and chapters under one unified 'book' section
for ITEM in "${SUBMODULES_ORDER[@]}"; do
  SUBMODULE="$ITEM"  # Define SUBMODULE from ITEM
  PART_NAME=$(basename "$SUBMODULE")  # Dynamically use folder name as part title

  # w-pseudocode is a single-document project (no book/chapters section) — special-case it
  if [[ "$PART_NAME" == "w-pseudocode-en" ]]; then
    echo "    - part: \"$PART_NAME\"" >> $OUTPUT_YAML
    echo "      chapters:" >> $OUTPUT_YAML
    echo "        - $SUBMODULE/Pseudocode.qmd" >> $OUTPUT_YAML
    continue
  fi

  # Prefer the 'full' profile config if present, otherwise fall back to the plain _quarto.yml
  YAML_PATH="${SUBMODULE}/_quarto-full.yml"
  if [[ ! -f "$YAML_PATH" ]]; then
    YAML_PATH="${SUBMODULE}/_quarto.yml"
  fi

  if [[ -f "$YAML_PATH" ]]; then
    CHAPTERS=$(yq eval '.book.chapters[]' "$YAML_PATH")

    if [[ -z "$CHAPTERS" ]]; then
      echo "No book.chapters found in $YAML_PATH, skipping..."
      continue
    fi

    echo "    - part: \"$PART_NAME\"" >> $OUTPUT_YAML
    echo "      chapters:" >> $OUTPUT_YAML
    while read -r CHAPTER; do
      echo "        - $SUBMODULE/$CHAPTER" >> $OUTPUT_YAML
    done <<< "$CHAPTERS"
  else
    echo "No _quarto-full.yml or _quarto.yml in $SUBMODULE, skipping..."
  fi
done

cat <<EOF >> $OUTPUT_YAML
format:
  html:
    theme: flatly
    toc: true
    toc-depth: 2
  pdf:
    number-sections: true

execute:
  freeze: auto
EOF

echo "Combined _quarto.yml with parts and chapters from submodules generated."
