# Letakkan di paling atas file .bashrc
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:$PATH"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Paksa jalankan starship
alias ls="ls --color=auto"
# Inisialisasi Starship Prompt

# Auto-launch Tmux secara profesional
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    # Mencoba masuk ke sesi 'main', jika tidak ada maka buat baru
    tmux attach-session -t home 2>/dev/null || tmux new-session -s home
fi
eval "$(starship init bash)"
