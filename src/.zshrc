# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/usr/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/usr/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/usr/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/usr/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
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
    local VENV=".venv"

    if [ ! -d "$VENV" ]; then
        echo "Creating virtual environment..."
        python3 -m venv "$VENV" || return 1
    fi

    source "$VENV/bin/activate"
}