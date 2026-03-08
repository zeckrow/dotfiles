alias ls="ls --color=auto"
# Inisialisasi Starship Prompt
eval "$(starship init bash)"
export PATH=$HOME/.local/bin:$HOME/.cargo/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:

# Auto-launch Tmux secara profesional
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    # Mencoba masuk ke sesi 'main', jika tidak ada maka buat baru
    tmux attach-session -t home 2>/dev/null || tmux new-session -s home
fi
