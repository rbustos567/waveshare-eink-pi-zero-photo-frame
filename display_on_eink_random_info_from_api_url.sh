#!/usr/bin/env bash

# Load configuration file
CONFIG_FILE="info_script.conf"

if [ -f "$CONFIG_FILE" ]; then
    export $(grep -v '^#' "$CONFIG_FILE" | xargs)
else
    echo "[ERROR] Configuration file '$CONFIG_FILE' not found." >&2
    exit 1
fi

# Validate PYTHON_API_RENDERER_PATH
if [ -z "$PYTHON_API_RENDERER_PATH" ]; then
    echo "[ERROR] 'PYTHON_API_RENDERER_PATH' is not set in $CONFIG_FILE." >&2
    exit 1
elif [ ! -f "$PYTHON_API_RENDERER_PATH" ]; then
    echo "[ERROR] Python script not found at path: $PYTHON_API_RENDERER_PATH" >&2
    exit 1
fi

# Validate PRESETS_CONFIG_PATH
if [ -z "$PRESETS_CONFIG_PATH" ]; then
    echo "[ERROR] 'PRESETS_CONFIG_PATH' is not set in $CONFIG_FILE." >&2
    exit 1
elif [ ! -f "$PRESETS_CONFIG_PATH" ]; then
    echo "[ERROR] Providers config JSON not found at path: $PRESETS_CONFIG_PATH" >&2
    exit 1
fi
# Validate EINK_RENDERER_PATH
if [ -z "$EINK_RENDERER_PATH" ]; then
    echo "[ERROR] 'EINK_RENDERER_PATH' is not set in $CONFIG_FILE." >&2
    exit 1
elif [ ! -f "$EINK_RENDERER_PATH" ]; then
    echo "[ERROR] e-Ink renderer script not found at path: $EINK_RENDERER_PATH" >&2
    exit 1
fi

# Validate OUTPUT_FILE_PATH
if [ -z "$OUTPUT_FILE_PATH" ]; then
    echo "[ERROR] 'OUTPUT_FILE_PATH' is not set in $CONFIG_FILE." >&2
    exit 1
fi

# Define supported providers
PRESETS=("wiki_en_tfa" "wiki_en_onthisday" "wiki_en_news" "wiki_en_dyk" "wiki_es_onthisday" "wiki_es_random" "random_joke" "tech_joke_two_part" "stoic_quote" "zen_quote" "open_trivia" "fact_facts" "meow_facts" "useless_facts" "daily_advice")

# Randomly select a provider
SELECTED_PRESET=${PRESETS[$RANDOM % ${#PRESETS[@]}]}

echo "[INFO] Selected provider: $SELECTED_PRESET" >&2
echo "[INFO] Using Python API Renderer at: $PYTHON_API_RENDERER_PATH" >&2
echo "[INFO] Using presets config at: $PRESETS_CONFIG_PATH" >&2

# 1. Execute the Python script using absolute paths for executable and JSON config
python3 "$PYTHON_API_RENDERER_PATH" \
  --preset-file "$PRESETS_CONFIG_PATH" \
  --preset "${SELECTED_PRESET}" \
  --log-level "${LOG_LEVEL:-INFO}"

# Check if it failed
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to generate image using preset: $SELECTED_PRESET." >&2
    exit 1
else
    echo "[INFO] Successfully generated image using preset: $SELECTED_PRESET." >&2
fi

# 2. Render image to e-Paper display
echo "[INFO] Rendering image to e-Paper display..." >&2

python3 "$EINK_RENDERER_PATH" "$OUTPUT_FILE_PATH" \
  --width "${DISPLAY_WIDTH:-800}" \
  --height "${DISPLAY_HEIGHT:-480}" \
  --display

if [ $? -eq 0 ]; then
    echo "[OK] e-Paper display rendering finished successfully." >&2
else
    echo "[ERROR] Failed to render image to e-Paper display." >&2
    exit 3
fi
