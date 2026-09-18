#!/usr/bin/env bash

# Explicitly set PATH for safety
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Dynamic path discovery
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$PROJECT_DIR")"

echo "=================================================="
echo " Waveshare e-Paper Photo Frame - Setup & Installer"
echo "=================================================="
echo ""

# 1. Clone dependency repositories in the parent directory
echo "[INFO] Step 1/6: Checking and cloning required dependency repositories..."

DEPENDENCIES=(
    "https://github.com/rbustos567/multi-provider-url-image-fetcher.git"
    "https://github.com/rbustos567/url-image-to-eink.git"
    "https://github.com/rbustos567/eink-api-renderer.git"
)

for REPO_URL in "${DEPENDENCIES[@]}"; do
    REPO_NAME="$(basename "$REPO_URL" .git)"
    TARGET_PATH="$PARENT_DIR/$REPO_NAME"

    if [ -d "$TARGET_PATH" ]; then
        echo "  - Dependency '$REPO_NAME' already exists at $TARGET_PATH. Skipping clone."
    else
        echo "  - Cloning '$REPO_NAME' into $TARGET_PATH..."
        git clone "$REPO_URL" "$TARGET_PATH"
    fi
done

echo ""

# 2. Grant execution permissions to local script files
echo "[INFO] Step 2/6: Setting execution permissions on local scripts..."
cd "$PROJECT_DIR" || exit 1
chmod +x *.sh 2>/dev/null
echo "  - Executable permissions (+x) applied to existing shell scripts."

echo ""

# 3. Create frame.conf with dynamically resolved absolute paths
echo "[INFO] Step 3/6: Verifying and generating frame.conf..."
if [ ! -f "frame.conf" ]; then
    echo "  - Resolving dynamic absolute paths relative to: $PARENT_DIR"
    
    EINK_RENDERER_PATH="$PARENT_DIR/url-image-to-eink/url_jpg_to_eink.py"
    OUTPUT_FILE_PATH="$PROJECT_DIR/output.bmp"
    PYTHON_FETCHER_PATH="$PARENT_DIR/multi-provider-url-image-fetcher/fetch_photo_url.py"
    PROVIDERS_CONFIG_PATH="$PARENT_DIR/multi-provider-url-image-fetcher/providers.json"
    PYTHON_API_RENDERER_PATH="$PARENT_DIR/eink-api-renderer/generate_eink_image_from_api.py"
    PRESETS_CONFIG_PATH="$PARENT_DIR/eink-api-renderer/presets.json"

    cat <<EOF > frame.conf
# Core Paths
EINK_RENDERER_PATH="$EINK_RENDERER_PATH"
OUTPUT_FILE_PATH="$OUTPUT_FILE_PATH"

# Photo Mode Settings
PYTHON_FETCHER_PATH="$PYTHON_FETCHER_PATH"
PROVIDERS_CONFIG_PATH="$PROVIDERS_CONFIG_PATH"
DEFAULT_SEARCH_QUERY="street photography"
PROVIDERS="unsplash pixabay pexels"

# Info Mode Settings
PYTHON_API_RENDERER_PATH="$PYTHON_API_RENDERER_PATH"
PRESETS_CONFIG_PATH="$PRESETS_CONFIG_PATH"
PRESETS="wiki_en_tfa wiki_en_onthisday wiki_en_news wiki_en_dyk wiki_es_onthisday wiki_es_random random_joke tech_joke_two_part stoic_quote zen_quote open_trivia fact_facts meow_facts useless_facts daily_advice"

# Display Parameters
DISPLAY_WIDTH=800
DISPLAY_HEIGHT=480
LOG_LEVEL=INFO
EOF
    echo "  - 'frame.conf' generated successfully with absolute paths."
else
    echo "  - 'frame.conf' already exists. Skipping generation."
fi

echo ""

# 4. Generate the run_on_cron_display_on_eink.sh wrapper script dynamically
echo "[INFO] Step 4/6: Generating cron wrapper script (run_on_cron_display_on_eink.sh)..."
CRON_SCRIPT="$PROJECT_DIR/run_on_cron_display_on_eink.sh"

cat <<EOF > "$CRON_SCRIPT"
#!/usr/bin/env bash

# Explicitly export PATH so cron can locate standard system binaries
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Input arguments
MODE="\${1:-random}"
PHOTO_QUERY="\$2"

# Project root directory
PROJECT_DIR="$PROJECT_DIR"

# Navigate to project directory before executing relative commands
if ! cd "\$PROJECT_DIR" 2>/dev/null; then
    echo "[\$(date -Iseconds)] [ERROR] Failed to navigate to project directory: \$PROJECT_DIR" >&2
    exit 1
fi

# Log directory and timestamp setup
LOG_DIR="\$PROJECT_DIR/logs"
mkdir -p "\$LOG_DIR"

TIMESTAMP=\$(date +%Y%m%d)
LOG_FILE="\$LOG_DIR/run_\${TIMESTAMP}.log"

# Automatic log retention: delete log files older than 14 days to preserve SD card space
find "\$LOG_DIR" -type f -name "run_*.log" -mtime +14 -delete 2>/dev/null

# Target script to execute
TARGET_SCRIPT="./display_on_eink_random_info_and_photo.sh"

# Validate that the target script exists and is executable
if [ ! -x "\$TARGET_SCRIPT" ]; then
    echo "[\$(date -Iseconds)] [ERROR] Executable script not found or missing execution permissions: \$TARGET_SCRIPT" >> "\$LOG_FILE"
    exit 1
fi

# Execute main wrapper logic and append output to log file
{
    echo "=================================================="
    echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Starting automated display-on-eink execution"
    echo "Mode: \$MODE | Query: \${PHOTO_QUERY:-<none>}"
    echo "--------------------------------------------------"
    
    # Run target script preserving double quotes for input arguments
    "\$TARGET_SCRIPT" "\$MODE" "\$PHOTO_QUERY"
    
    EXIT_CODE=\$?
    echo "--------------------------------------------------"
    echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Execution finished with exit code: \$EXIT_CODE"
    echo "=================================================="
    echo ""
} >> "\$LOG_FILE" 2>&1

exit \${EXIT_CODE:-0}
EOF

chmod +x "$CRON_SCRIPT"
echo "  - '$CRON_SCRIPT' created and granted +x execution permissions."

echo ""

# 5. Prompt for API Keys configuration
echo "[INFO] Step 5/6: API Providers Configuration"
PROVIDERS_JSON="$PARENT_DIR/multi-provider-url-image-fetcher/providers.json"
if [ -f "$PROVIDERS_JSON" ]; then
    echo "  - Found providers configuration at: $PROVIDERS_JSON"
else
    echo "  - [WARNING] $PROVIDERS_JSON not found. Please ensure multi-provider-url-image-fetcher is initialized."
fi

echo ""

# 6. Optional Cron Job installation
echo "[INFO] Step 6/6: Crontab Configuration"
CRON_CMD="0 9-21/2 * * * $CRON_SCRIPT random"

read -p "Do you want to automatically add the 2-hour refresh schedule to root's crontab? [y/N]: " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    if sudo crontab -l 2>/dev/null | grep -Fq "$CRON_SCRIPT"; then
        echo "  - Cron job entry already exists in root's crontab. Skipping."
    else
        (sudo crontab -l 2>/dev/null; echo "$CRON_CMD") | sudo crontab -
        echo "  - Successfully added cron job to root's crontab:"
        echo "    $CRON_CMD"
    fi
else
    echo "  - Skipped automatic cron configuration."
    echo "    To add it manually later, run 'sudo crontab -e' and paste:"
    echo "    $CRON_CMD"
fi

echo ""
echo "=================================================="
echo " Installation Complete!"
echo "=================================================="
echo "Next steps:"
echo "1. Review '$PROJECT_DIR/frame.conf' to confirm settings."
echo "2. Ensure API keys are set in:"
echo "   $PROVIDERS_JSON"
echo "3. Test execution manually by running:"
echo "   $CRON_SCRIPT random"
echo "=================================================="
