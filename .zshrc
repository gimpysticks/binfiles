# Main zshrc - loads personal configuration
export PATH="$HOME/.local/bin:$PATH"

# Enable emacs key bindings (required for Ctrl+R and other shortcuts)
bindkey -e

# Fix Ctrl+R by disabling terminal's reprint function
stty rprnt undef

# Fix terminal capabilities for fzf
if [[ $TERM != "screen"* ]] && [[ -n $DISPLAY ]]; then
    export TERM=xterm-256color
fi

# Some basic history settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt share_history
setopt hist_ignore_dups
setopt append_history

# Source personal configuration
if [[ -f ~/.zshrc-personal ]]; then
    source ~/.zshrc-personal
fi

# fzf integration is handled in .zshrc-personal
