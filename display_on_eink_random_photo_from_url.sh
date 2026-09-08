#!/usr/bin/env bash

# Check for mandatory positional argument (Query)
if [ -z "$1" ]; then
    echo "[ERROR] Missing mandatory query argument." >&2
    echo "Usage: $0 \"<search_query>\"" >&2
    echo "Example: $0 \"minimalist architecture\"" >&2
    exit 1
fi

SEARCH_QUERY="$1"

# Load configuration file
CONFIG_FILE="script.conf"

if [ -f "$CONFIG_FILE" ]; then
    export $(grep -v '^#' "$CONFIG_FILE" | xargs)
else
    echo "[ERROR] Configuration file '$CONFIG_FILE' not found." >&2
    exit 1
fi

# Validate PYTHON_FETCHER_PATH
if [ -z "$PYTHON_FETCHER_PATH" ]; then
    echo "[ERROR] 'PYTHON_FETCHER_PATH' is not set in $CONFIG_FILE." >&2
    exit 1
elif [ ! -f "$PYTHON_FETCHER_PATH" ]; then
    echo "[ERROR] Python script not found at path: $PYTHON_FETCHER_PATH" >&2
    exit 1
fi

# Validate PROVIDERS_CONFIG_PATH
if [ -z "$PROVIDERS_CONFIG_PATH" ]; then
    echo "[ERROR] 'PROVIDERS_CONFIG_PATH' is not set in $CONFIG_FILE." >&2
    exit 1
elif [ ! -f "$PROVIDERS_CONFIG_PATH" ]; then
    echo "[ERROR] Providers config JSON not found at path: $PROVIDERS_CONFIG_PATH" >&2
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

# Load environment variables (.env) if present for API keys
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Define supported providers
PROVIDERS=("unsplash" "pixabay" "pexels")

# Randomly select a provider
SELECTED_PROVIDER=${PROVIDERS[$RANDOM % ${#PROVIDERS[@]}]}

# Configure endpoint and API key based on selected provider
case "$SELECTED_PROVIDER" in
    "unsplash")
        ENDPOINT="https://api.unsplash.com/photos/random"
        API_KEY="${UNSPLASH_API_KEY:-$API_KEY}"
        ;;
    "pixabay")
        ENDPOINT="https://pixabay.com/api/"
        API_KEY="${PIXABAY_API_KEY:-$API_KEY}"
        ;;
    "pexels")
        ENDPOINT="https://api.pexels.com/v1/search"
        API_KEY="${PEXELS_API_KEY:-$API_KEY}"
        ;;
esac

echo "[INFO] Search query: \"$SEARCH_QUERY\"" >&2
echo "[INFO] Selected provider: $SELECTED_PROVIDER" >&2
echo "[INFO] Using Python fetcher at: $PYTHON_FETCHER_PATH" >&2
echo "[INFO] Using providers config at: $PROVIDERS_CONFIG_PATH" >&2

# 1. Execute the Python script using absolute paths for executable and JSON config
IMAGE_URL=$(python3 "$PYTHON_FETCHER_PATH" \
  -u "$ENDPOINT" \
  -k "$API_KEY" \
  -q "$SEARCH_QUERY" \
  -o "${ORIENTATION:-landscape}" \
  -c "$PROVIDERS_CONFIG_PATH" \
  --log-level "${LOG_LEVEL:-INFO}")

# Validate that a URL was returned
if [ -z "$IMAGE_URL" ]; then
    echo "[ERROR] Failed to retrieve URL from $SELECTED_PROVIDER." >&2
    exit 1
fi

echo "[INFO] Resolved URL: $IMAGE_URL" >&2
echo "[INFO] Downloading image..." >&2

# 2. Download the image using curl
FINAL_OUTPUT="${OUTPUT_FILE:-output.jpg}"

if curl -sSL -f --connect-timeout 10 -A "Mozilla/5.0" "$IMAGE_URL" -o "$FINAL_OUTPUT"; then
    echo "[OK] Image successfully saved to $FINAL_OUTPUT (Provider: $SELECTED_PROVIDER)" >&2
else
    echo "[ERROR] Image download failed with curl." >&2
    exit 2
fi

# 3. Render image to e-Paper display
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
