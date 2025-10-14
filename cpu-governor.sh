#!/system/bin/sh

DESIRED_GOVERNOR="performance" # Or "schedutil", "ondemand", etc.

# runtime vars
SET_SUCCESS=true


# kmsg function: Logs a message to the kernel ring buffer (dmesg)
# Usage: kmsg [level] "Your message here"
# Levels: emerg, alert, crit, err, warn, notice, info, debug (default: info)
kmsg() {
    local level_code
    local message

    case "$1" in
        "emerg") level_code="<0>"; shift ;;
        "alrt") level_code="<1>"; shift ;;
        "crit")  level_code="<2>"; shift ;;
        "err")   level_code="<3>"; shift ;;
        "wrn")  level_code="<4>"; shift ;;
        "note") level_code="<5>"; shift ;;
        "inf")  level_code="<6>"; shift ;; # Default
        "dbg") level_code="<7>"; shift ;;
        *)       level_code="<6>" ;; # Default to info if no valid level or first arg is message
    esac

    # If first arg was not a level, it's the message
    if [[ -z "$message" ]]; then
        message="$1"
    else
        message="$@" # Capture remaining arguments as message
    fi

    if [[ -z "$scope" ]];then scope="[xlvini]"; fi

    # Prepend a unique tag to easily find your messages in dmesg
    echo "${level_code}${scope}: ${message}" | tee /dev/kmsg
}

kmsg dbg "Initialized"

sleep 15

kmsg dbg "CPU Governor in-use:"
for cpu in /sys/devices/system/cpu/cpu*; do
    if [ -f "$cpu/cpufreq/scaling_governor" ]; then
        kmsg dbg "$cpu: $(cat $cpu/cpufreq/scaling_governor)"
    fi
done

kmsg dbg "CPU Governors available:\n$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors)"

kmsg dbg "CPU Frequency in-use: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)"
kmsg dbg "CPU Frequencies available:\n$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies)"


# Loop through all available CPU cores and set the governor
kmsg inf "Setting CPU governor to '${DESIRED_GOVERNOR}'"

for cpu_path in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    CPU_ID=$(basename "$(dirname "$cpu_path")") # Extracts cpu0, cpu1, etc.
    if ! echo "${DESIRED_GOVERNOR}" > "$cpu_path"; then
        kmsg err "Failed to set governor for ${CPU_ID}. Check permissions or governor availability."
        SET_SUCCESS=false
    fi
done

if "$SET_SUCCESS"; then
    kmsg "All CPU governors set to '${DESIRED_GOVERNOR}' successfully."
else
    kmsg "Some CPU governor settings failed. Check previous error messages."
fi

# Optional: Add logs for max/min frequency settings too
# ... (your existing max/min freq logic)
