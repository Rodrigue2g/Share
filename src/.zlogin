GH_CACHE="$HOME/.cache/gh-notifications"

if [[ -t 1 ]]; then
    echo
    echo "Welcome, $USER  $(hostname -s)"
    echo "  $(date '+%A, %d %B %Y — %H:%M')"
    echo "  $(uptime | sed 's/.*up /up /')"

    # Display cached GitHub notifications
    if [[ -f "$GH_CACHE" ]]; then
        echo "  GitHub: $(<"$GH_CACHE") notifications"
    fi

    echo
fi

# Refresh GitHub notification cache in background
if command -v gh >/dev/null; then
    mkdir -p "${GH_CACHE:h}"
    gh api notifications --jq 'length' > "$GH_CACHE" 2>/dev/null &
fi
