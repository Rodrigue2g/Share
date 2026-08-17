export PATH="/opt/homebrew/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Kill a port already in use
# i.e. kp 3000
killport() {
  local pids=$(lsof -ti :"$1")
  if [[ -n "$pids" ]]; then
    echo "$pids" | xargs kill -9 2>/dev/null && echo "Port $1 freed"
  else
    echo "No process on port $1"
  fi
}

kp() {
  killport "$@"
}

v() {
    local VENV="${1:-.venv}"

    if [ ! -d "$VENV" ]; then
        echo "Creating virtual environment '$VENV'..."
        python3 -m venv "$VENV" || return 1
    fi

    source "$VENV/bin/activate"
}
