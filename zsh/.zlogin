if [[ -t 1 ]]; then
    echo
    echo "Welcome, $USER  $(hostname -s)"
    echo "  $(date '+%A, %d %B %Y — %H:%M')"
    echo "  $(uptime | sed 's/.*up /up /')"
    echo
fi
