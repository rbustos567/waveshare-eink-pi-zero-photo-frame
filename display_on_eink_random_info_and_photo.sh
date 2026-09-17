#!/usr/bin/env bash

# Ensure script is executed with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "[INFO] Re-running script with sudo privileges..." >&2
    exec sudo "$0" "$@"
fi

# Load main configuration file
CONFIG_FILE="${CONFIG_FILE:-frame.conf}"

#if [ -f "$CONFIG_FILE" ]; then
#    export $(grep -v '^#' "$CONFIG_FILE" | xargs)
#else
#    echo "[ERROR] Configuration file '$CONFIG_FILE' not found." >&2
#    exit 1
#fi

if [ -f "$CONFIG_FILE" ]; then
    set -a
    source "$CONFIG_FILE"
    set +a
else
    echo "[ERROR] Configuration file '$CONFIG_FILE' not found." >&2
    exit 1
fi


# Common mandatory path validations
for VAR in EINK_RENDERER_PATH OUTPUT_FILE_PATH; do
    if [ -z "${!VAR}" ]; then
        echo "[ERROR] '$VAR' is not set in $CONFIG_FILE." >&2
        exit 1
    fi
done

if [ ! -f "$EINK_RENDERER_PATH" ]; then
    echo "[ERROR] e-Ink renderer script not found at: $EINK_RENDERER_PATH" >&2
    exit 1
fi

# Mode determination: $1 can be "photo", "info", or "random" (default)
MODE="${1:-random}"
QUERY="$2"

if [ "$MODE" = "random" ]; then
    MODES=("photo" "info")
    MODE=${MODES[$RANDOM % ${#MODES[@]}]}
    echo "[INFO] Random mode selected: $MODE" >&2
fi

# Execute mode logic
case "$MODE" in
    "info")
        if [ -z "$PYTHON_API_RENDERER_PATH" ] || [ ! -f "$PYTHON_API_RENDERER_PATH" ]; then
            echo "[ERROR] Invalid or missing PYTHON_API_RENDERER_PATH." >&2
            exit 1
        fi
        if [ -z "$PRESETS_CONFIG_PATH" ] || [ ! -f "$PRESETS_CONFIG_PATH" ]; then
            echo "[ERROR] Invalid or missing PRESETS_CONFIG_PATH." >&2
            exit 1
        fi
        if [ -z "$PRESETS" ]; then
            echo "[ERROR] 'PRESETS' variable is empty or not set in $CONFIG_FILE." >&2
            exit 1
        fi

        # Convert space-separated string into a clean Bash array
        PRESET_ARRAY=($PRESETS)
        TOTAL_PRESETS=${#PRESET_ARRAY[@]}

        if [ "$TOTAL_PRESETS" -eq 0 ]; then
            echo "[ERROR] No presets found in PRESET_ARRAY." >&2
            exit 1
        fi

        RANDOM_INDEX=$(( RANDOM % TOTAL_PRESETS ))
        SELECTED_PRESET="${PRESET_ARRAY[$RANDOM_INDEX]}"
        
        echo "[INFO] Running INFO mode with preset: $SELECTED_PRESET (Index $RANDOM_INDEX of $TOTAL_PRESETS)" >&2

        python3 "$PYTHON_API_RENDERER_PATH" \
          --preset-file "$PRESETS_CONFIG_PATH" \
          --preset "${SELECTED_PRESET}" \
          --log-level "${LOG_LEVEL:-INFO}" \
	  --output "${OUTPUT_FILE_PATH}"

        if [ $? -ne 0 ]; then
            echo "[ERROR] Failed to generate info image using preset: $SELECTED_PRESET." >&2
            exit 1
        fi
        ;;

    "photo")
        if [ -z "$PYTHON_FETCHER_PATH" ] || [ ! -f "$PYTHON_FETCHER_PATH" ]; then
            echo "[ERROR] Invalid or missing PYTHON_FETCHER_PATH." >&2
            exit 1
        fi
        if [ -z "$PROVIDERS_CONFIG_PATH" ] || [ ! -f "$PROVIDERS_CONFIG_PATH" ]; then
            echo "[ERROR] Invalid or missing PROVIDERS_CONFIG_PATH." >&2
            exit 1
        fi
        # Use provided query or fall back to DEFAULT_SEARCH_QUERY from conf
        SEARCH_QUERY="${QUERY:-${DEFAULT_SEARCH_QUERY:-landscape}}"

        PROVIDERS=("unsplash" "pixabay" "pexels")
        SELECTED_PROVIDER=${PROVIDERS[$RANDOM % ${#PROVIDERS[@]}]}

        echo "[INFO] Running PHOTO mode using $SELECTED_PROVIDER with query: \"$SEARCH_QUERY\"" >&2

        IMAGE_URL=$(python3 "$PYTHON_FETCHER_PATH" \
          -u "$SELECTED_PROVIDER" \
          -q "$SEARCH_QUERY" \
          -o "${ORIENTATION:-landscape}" \
          -c "$PROVIDERS_CONFIG_PATH" \
          --log-level "${LOG_LEVEL:-INFO}")

        if [ -z "$IMAGE_URL" ]; then
            echo "[ERROR] Failed to retrieve image URL from $SELECTED_PROVIDER." >&2
            exit 1
        fi

        echo "[INFO] Resolved URL: $IMAGE_URL" >&2
        echo "[INFO] Downloading image..." >&2

        # 2. Download the image using curl
        FINAL_OUTPUT="${OUTPUT_FILE_PATH:-output.jpg}"

        if curl -sSL -f --connect-timeout 10 -A "Mozilla/5.0" "$IMAGE_URL" -o "$FINAL_OUTPUT"; then
            echo "[OK] Image successfully saved to $FINAL_OUTPUT (Provider: $SELECTED_PROVIDER)" >&2
        else
            echo "[ERROR] Image download failed with curl." >&2
            exit 2
        fi
        ;;

    *)
        echo "[ERROR] Unknown mode '$MODE'. Valid modes: photo, info, random." >&2
        exit 1
        ;;
esac

echo "[INFO] Rendering final image to e-Paper display..." >&2

python3 "$EINK_RENDERER_PATH" "$OUTPUT_FILE_PATH" \
  --width "${DISPLAY_WIDTH:-800}" \
  --height "${DISPLAY_HEIGHT:-480}" \
  --display

RENDER_STATUS=$?

if [ $RENDER_STATUS -eq 0 ]; then
    echo "[OK] e-Paper display rendering finished successfully." >&2
else
    echo "[ERROR] Failed to render image to e-Paper display." >&2
fi

# The 'trap' registered above will automatically execute here to restore Wi-Fi
exit $RENDER_STATUS
