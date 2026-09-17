#!/usr/bin/env bash

# Explicitly export PATH so cron can locate standard system binaries
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Input arguments
MODE="${1:-random}"
PHOTO_QUERY="$2"

# Project root directory
PROJECT_DIR="/home/pi/projects/display-on-eink-random-photo"

# Navigate to project directory before executing relative commands
if ! cd "$PROJECT_DIR" 2>/dev/null; then
    echo "[$(date -Iseconds)] [ERROR] Failed to navigate to project directory: $PROJECT_DIR" >&2
    exit 1
fi

# Log directory and timestamp setup
LOG_DIR="$PROJECT_DIR/logs"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +%Y%m%d)
LOG_FILE="$LOG_DIR/run_${TIMESTAMP}.log"

# Automatic log retention: delete log files older than 14 days to preserve SD card space
find "$LOG_DIR" -type f -name "run_*.log" -mtime +14 -delete 2>/dev/null

# Target script to execute
TARGET_SCRIPT="./display_on_eink_random_info_photo.sh"

# Validate that the target script exists and is executable
if [ ! -x "$TARGET_SCRIPT" ]; then
    echo "[$(date -Iseconds)] [ERROR] Executable script not found or missing execution permissions: $TARGET_SCRIPT" >> "$LOG_FILE"
    exit 1
fi

# Execute main wrapper logic and append output to log file
{
    echo "=================================================="
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting automated display-on-eink execution"
    echo "Mode: $MODE | Query: ${PHOTO_QUERY:-<none>}"
    echo "--------------------------------------------------"
    
    # Run target script preserving double quotes for input arguments
    "$TARGET_SCRIPT" "$MODE" "$PHOTO_QUERY"
    
    EXIT_CODE=$?
    echo "--------------------------------------------------"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Execution finished with exit code: $EXIT_CODE"
    echo "=================================================="
    echo ""
} >> "$LOG_FILE" 2>&1

exit ${EXIT_CODE:-0}

