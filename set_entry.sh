#!/bin/bash

# Usage:
#   ./set_entry.sh "Linux" "custom_template/debug" "my_template"
#   ./set_entry.sh "Linux" "export_path" "exports/test.x86_64"
#
# This works for entries in both:
#   [preset.N]
#   [preset.N.options]

PLATFORM="$1"
ENTRY="$2"
VALUE="$3"
FILE="$4"

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <platform> <entry> <value> <file>"
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "Error: $FILE not found."
    exit 1
fi


# ------------------------------------------------------------
# Find the preset number associated with the platform name
# ------------------------------------------------------------

PRESET=$(awk -v platform="$PLATFORM" '
    /^\[preset\.[0-9]+\]$/ {
        preset = $0
        sub(/^\[preset\./, "", preset)
        sub(/\]$/, "", preset)
    }

    /^name="/ {
        name = $0
        sub(/^name="/, "", name)
        sub(/"$/, "", name)

        if (name == platform) {
            print preset
            exit
        }
    }
' "$FILE")


if [ -z "$PRESET" ]; then
    echo "Error: Platform \"$PLATFORM\" not found."
    exit 1
fi


# ------------------------------------------------------------
# Replace the entry
# ------------------------------------------------------------

TEMP_FILE="${FILE}.tmp"

awk -v preset="$PRESET" \
    -v entry="$ENTRY" \
    -v value="$VALUE" '

BEGIN {
    in_target_section = 0
    found = 0
}


# ------------------------------------------------------------
# [preset.N] section
# ------------------------------------------------------------

$0 == "[preset." preset "]" {
    in_target_section = 1
    print
    next
}


# ------------------------------------------------------------
# [preset.N.options] section
# ------------------------------------------------------------

$0 == "[preset." preset ".options]" {
    in_target_section = 1
    print
    next
}


# ------------------------------------------------------------
# Any other section
# ------------------------------------------------------------

/^\[/ {
    in_target_section = 0
    print
    next
}


# ------------------------------------------------------------
# Replace the requested entry
# ------------------------------------------------------------

in_target_section && index($0, entry "=") == 1 {
    print entry "=\"" value "\""
    found = 1
    next
}


# ------------------------------------------------------------
# Everything else
# ------------------------------------------------------------

{
    print
}


END {
    if (!found) {
        print "Error: Entry \"" entry "\" not found in preset " preset "." > "/dev/stderr"
        exit 2
    }
}
' "$FILE" > "$TEMP_FILE"


if [ $? -ne 0 ]; then
    rm -f "$TEMP_FILE"
    exit 1
fi


mv "$TEMP_FILE" "$FILE"

echo "Successfully changed:"
echo "  Platform: $PLATFORM"
echo "  Entry:    $ENTRY"
echo "  Value:    $VALUE"
