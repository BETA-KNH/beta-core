#!/usr/bin/env bash
# headless-screenshot.sh — launch any GUI command under Xvfb and capture a screenshot.
#
# USAGE
#   headless-screenshot.sh [OPTIONS] -- <command...>
#
# OPTIONS
#   -o, --out FILE          Output PNG path            (default: screenshot.png)
#   -w, --wait SECS         Seconds to wait before capture (default: 3)
#   -W, --wait-window TITLE Block until a window matching TITLE appears (xdotool)
#   -r, --res WxH           Virtual display resolution (default: 1280x1024)
#   -c, --click X Y         Move pointer and click at X,Y after wait (repeatable)
#   -k, --key KEY           Send key after wait, e.g. Return Escape Tab (repeatable)
#   -t, --type TEXT         Type text after wait
#   -s, --script FILE       xdotool script to run before capture (advanced interactions)
#       --display N         Pin to display number N instead of auto-allocating
#       --keep              Do not kill Xvfb after capture (useful for debugging)
#       --depth D           Colour depth bits (default: 24)
#
# EXAMPLES
#   # Simple: launch rviz2, wait 5 s, screenshot
#   headless-screenshot.sh --wait 5 --out rviz.png -- \
#       bash -c "source /opt/ros/jazzy/setup.bash && rviz2 -d config.rviz"
#
#   # With interaction: open a Qt app, click a button, screenshot
#   headless-screenshot.sh --wait-window "My App" --click 200 150 --out after_click.png -- myapp
#
#   # Complex: drive via xdotool script file
#   headless-screenshot.sh --script interact.xdo --out result.png -- myapp
#
# DEPENDENCIES
#   Required : Xvfb  (apt install xvfb)
#   Screenshot: scrot (apt install scrot)  OR  ImageMagick import
#   Interaction: xdotool (apt install xdotool) — only needed with -W/-c/-k/-t/-s

set -euo pipefail

# ── helpers ──────────────────────────────────────────────────────────────────
die()  { echo "ERROR: $*" >&2; exit 1; }
log()  { echo "[headless-screenshot] $*" >&2; }
need() { command -v "$1" &>/dev/null || die "Required tool '$1' not found. Install with: apt install $2"; }

# ── defaults ─────────────────────────────────────────────────────────────────
OUT="screenshot.png"
WAIT=3
WAIT_WINDOW=""
RES="1280x1024"
DEPTH=24
DISPLAY_NUM=""
KEEP=false
CLICKS=()
KEYS=()
TYPE_TEXT=""
XDOTOOL_SCRIPT=""

# ── argument parsing ──────────────────────────────────────────────────────────
CMD=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--out)           OUT="$2";            shift 2 ;;
        -w|--wait)          WAIT="$2";           shift 2 ;;
        -W|--wait-window)   WAIT_WINDOW="$2";    shift 2 ;;
        -r|--res)           RES="$2";            shift 2 ;;
        -c|--click)         CLICKS+=("$2 $3");   shift 3 ;;
        -k|--key)           KEYS+=("$2");        shift 2 ;;
        -t|--type)          TYPE_TEXT="$2";      shift 2 ;;
        -s|--script)        XDOTOOL_SCRIPT="$2"; shift 2 ;;
        --display)          DISPLAY_NUM="$2";    shift 2 ;;
        --keep)             KEEP=true;           shift ;;
        --depth)            DEPTH="$2";          shift 2 ;;
        --)                 shift; CMD=("$@");   break ;;
        -h|--help)
            sed -n '2,40p' "$0" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        *)  die "Unknown option: $1 (use -- to separate the command)" ;;
    esac
done

[[ ${#CMD[@]} -gt 0 ]] || die "No command specified. Use: headless-screenshot.sh [OPTIONS] -- <command>"

# ── dependency checks ─────────────────────────────────────────────────────────
need Xvfb xvfb

SCREENSHOT_TOOL=""
if command -v scrot &>/dev/null; then
    SCREENSHOT_TOOL="scrot"
elif command -v import &>/dev/null; then
    SCREENSHOT_TOOL="import"
else
    die "No screenshot tool found. Install one: apt install scrot  OR  apt install imagemagick"
fi

HAS_XDOTOOL=false
if command -v xdotool &>/dev/null; then
    HAS_XDOTOOL=true
fi

INTERACTION_REQUESTED=false
[[ -n "$WAIT_WINDOW" || ${#CLICKS[@]} -gt 0 || ${#KEYS[@]} -gt 0 || -n "$TYPE_TEXT" || -n "$XDOTOOL_SCRIPT" ]] \
    && INTERACTION_REQUESTED=true

if $INTERACTION_REQUESTED && ! $HAS_XDOTOOL; then
    die "Interaction options require xdotool. Install with: apt install xdotool"
fi

# ── allocate virtual display ──────────────────────────────────────────────────
if [[ -n "$DISPLAY_NUM" ]]; then
    DISP=":${DISPLAY_NUM}"
else
    # Find a free display number
    DISPLAY_NUM=99
    while [[ -e "/tmp/.X${DISPLAY_NUM}-lock" ]]; do
        (( DISPLAY_NUM++ ))
    done
    DISP=":${DISPLAY_NUM}"
fi

log "Starting Xvfb on ${DISP} (${RES}x${DEPTH})"
Xvfb "${DISP}" -screen 0 "${RES}x${DEPTH}" -ac +extension GLX +render -noreset &
XVFB_PID=$!

cleanup() {
    local exit_code=$?
    if ! $KEEP; then
        log "Stopping Xvfb (PID ${XVFB_PID})"
        kill "$XVFB_PID" 2>/dev/null || true
        wait "$XVFB_PID" 2>/dev/null || true
    else
        log "Keeping Xvfb running on ${DISP} (PID ${XVFB_PID})"
    fi
    exit $exit_code
}
trap cleanup EXIT

# Give Xvfb a moment to start
sleep 0.5

export DISPLAY="${DISP}"
export LIBGL_ALWAYS_SOFTWARE=1  # software Mesa fallback when no GPU

# ── launch the target command ─────────────────────────────────────────────────
log "Launching: ${CMD[*]}"
"${CMD[@]}" &
APP_PID=$!

# ── wait logic ────────────────────────────────────────────────────────────────
if [[ -n "$WAIT_WINDOW" ]]; then
    log "Waiting for window matching '${WAIT_WINDOW}'..."
    TIMEOUT=30
    ELAPSED=0
    until xdotool search --name "${WAIT_WINDOW}" &>/dev/null; do
        sleep 0.5
        ELAPSED=$(( ELAPSED + 1 ))
        if (( ELAPSED >= TIMEOUT * 2 )); then
            log "WARNING: window '${WAIT_WINDOW}' not found after ${TIMEOUT}s, proceeding anyway"
            break
        fi
    done
else
    log "Waiting ${WAIT}s for app to render..."
    sleep "${WAIT}"
fi

# ── interactions ──────────────────────────────────────────────────────────────
if $INTERACTION_REQUESTED; then
    for COORD in "${CLICKS[@]+"${CLICKS[@]}"}"; do
        read -r X Y <<< "$COORD"
        log "Clicking at ${X},${Y}"
        xdotool mousemove --sync "${X}" "${Y}"
        xdotool click 1
        sleep 0.2
    done

    for KEY in "${KEYS[@]+"${KEYS[@]}"}"; do
        log "Sending key: ${KEY}"
        xdotool key "${KEY}"
        sleep 0.1
    done

    if [[ -n "$TYPE_TEXT" ]]; then
        log "Typing text"
        xdotool type --clearmodifiers "${TYPE_TEXT}"
    fi

    if [[ -n "$XDOTOOL_SCRIPT" ]]; then
        log "Running xdotool script: ${XDOTOOL_SCRIPT}"
        xdotool script "${XDOTOOL_SCRIPT}"
    fi

    # Brief pause for UI to settle after interactions
    sleep 0.5
fi

# ── capture ───────────────────────────────────────────────────────────────────
log "Capturing screenshot to: ${OUT}"
if [[ "$SCREENSHOT_TOOL" == "scrot" ]]; then
    scrot --display="${DISP}" "${OUT}"
else
    import -display "${DISP}" -window root "${OUT}"
fi

log "Done. Output: ${OUT}"

# Stop app
kill "$APP_PID" 2>/dev/null || true
