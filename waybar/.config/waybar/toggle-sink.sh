#!/bin/bash

# Get all sink names
sinks=($(pactl list short sinks | awk '{print $2}'))

# Get the currently default sink
current=$(pactl info | grep "Default Sink" | awk '{print $3}')

# Find the index of the current sink
for i in "${!sinks[@]}"; do
    if [[ "${sinks[$i]}" = "$current" ]]; then
        current_index=$i
        break
    fi
done

# Get next sink (loop back if at the end)
next_index=$(( (current_index + 1) % ${#sinks[@]} ))
next_sink="${sinks[$next_index]}"

# Set it as default
pactl set-default-sink "$next_sink"

# Move all currently playing audio streams to the new sink
for input in $(pactl list short sink-inputs | awk '{print $1}'); do
    pactl move-sink-input "$input" "$next_sink"
done
