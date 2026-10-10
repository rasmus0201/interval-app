#!/bin/sh
# Captures App Store screenshots in English and Danish into AppStore/Screenshots/<locale>/<size>.
# large is the 6.9" display (1320 x 2868) and medium the 6.3" display (1206 x 2622), both with a Dynamic Island.
set -eu

DEVICES="${DEVICES:-large:iPhone 17 Pro Max
medium:iPhone 17 Pro}"
BUNDLE_ID="com.oliverkaersner.kyclaro"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/AppStore/Screenshots"
DERIVED="$(mktemp -d)"

xcodebuild -project "$ROOT/Interval.xcodeproj" -scheme Interval -configuration Debug \
    -destination "generic/platform=iOS Simulator" -derivedDataPath "$DERIVED" build -quiet
APP="$DERIVED/Build/Products/Debug-iphonesimulator/Interval.app"

# Sample history passed through the UserDefaults argument domain; nothing is persisted.
HISTORY="$(python3 - <<'EOF'
import json, time, uuid
now = time.time() - 978307200  # Seconds since 2001-01-01, the JSONEncoder default date format.
workouts = [
    (0.1, 45, 15, 8, 3, 60),
    (1.0, 30, 10, 10, 2, 0),
    (2.1, 40, 20, 6, 4, 30),
    (3.0, 45, 15, 8, 3, 60),
    (5.2, 20, 10, 8, 1, 0),
    (6.0, 60, 30, 5, 3, 60),
    (8.1, 45, 15, 8, 3, 60),
]
entries = [{
    "id": str(uuid.uuid4()).upper(),
    "completedAt": now - days * 86400,
    "startCountdownSeconds": 10,
    "configuration": {"workSeconds": w, "restSeconds": r, "repetitions": reps,
                      "rounds": rounds, "roundRestSeconds": rr},
} for days, w, r, reps, rounds, rr in workouts]
print("<" + json.dumps(entries).encode().hex() + ">")
EOF
)"

capture() {
    folder="$1"; language="$2"; locale="$3"; name="$4"; delay="$5"; shift 5
    mkdir -p "$OUT/$folder/$SIZE"
    xcrun simctl terminate "$UDID" "$BUNDLE_ID" 2>/dev/null || true
    xcrun simctl launch "$UDID" "$BUNDLE_ID" -AppleLanguages "($language)" -AppleLocale "$locale" \
        -workoutHistory "$HISTORY" "$@" >/dev/null
    sleep "$delay"
    xcrun simctl io "$UDID" screenshot "$OUT/$folder/$SIZE/$name.png" >/dev/null
    echo "Saved $OUT/$folder/$SIZE/$name.png"
}

echo "$DEVICES" | while IFS=: read -r SIZE DEVICE_NAME; do
    UDID="$(xcrun simctl list devices available | grep "    $DEVICE_NAME (" | head -1 | sed -E 's/.*\(([0-9A-F-]+)\).*/\1/')"
    [ -n "$UDID" ] || { echo "Simulator '$DEVICE_NAME' not found" >&2; exit 1; }

    xcrun simctl boot "$UDID" 2>/dev/null || true
    xcrun simctl bootstatus "$UDID" >/dev/null
    xcrun simctl ui "$UDID" appearance "${APPEARANCE:-light}"
    xcrun simctl status_bar "$UDID" override --time 9:41 --batteryState discharging --batteryLevel 100 \
        --cellularBars 4 --wifiBars 3 --dataNetwork wifi
    xcrun simctl install "$UDID" "$APP"

    for target in "en-US en en_US" "da-DK da da_DK"; do
        set -- $target
        capture "$@" 01-setup 3
        capture "$@" 02-workout 5 --screenshot-workout
        capture "$@" 03-history 3 --screenshot-history
    done

    xcrun simctl terminate "$UDID" "$BUNDLE_ID" 2>/dev/null || true
    xcrun simctl status_bar "$UDID" clear
done

rm -rf "$DERIVED"
