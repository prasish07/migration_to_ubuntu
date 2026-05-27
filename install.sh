#!/usr/bin/env bash
# =============================================================================
#  Ubuntu Migration Script — for prasish
#  Generated from Pop!_OS 24.04 → Ubuntu 26.04 LTS
#  Run: bash install.sh
# =============================================================================

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$HOME/migration_install.log"

log()   { echo -e "${GREEN}[✓]${NC} $*" | tee -a "$LOG_FILE"; }
info()  { echo -e "${CYAN}[→]${NC} $*" | tee -a "$LOG_FILE"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}[✗]${NC} $*" | tee -a "$LOG_FILE"; }
section() {
  echo "" | tee -a "$LOG_FILE"
  echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$LOG_FILE"
  echo -e "${BOLD}${BLUE}  $*${NC}" | tee -a "$LOG_FILE"
  echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$LOG_FILE"
}

STEP=0
step() {
  STEP=$((STEP+1))
  echo -e "\n${BOLD}[Step $STEP]${NC} $*" | tee -a "$LOG_FILE"
}

# ── Sanity checks ─────────────────────────────────────────────────────────────
if [[ "$EUID" -eq 0 ]]; then
  error "Don't run as root. The script uses sudo when needed."
  exit 1
fi

echo -e "${BOLD}${CYAN}"
echo "  ┌─────────────────────────────────────────────┐"
echo "  │   Ubuntu Migration Script — prasish          │"
echo "  │   Pop!_OS 24.04 → Ubuntu 26.04 LTS          │"
echo "  └─────────────────────────────────────────────┘"
echo -e "${NC}"
echo "Log file: $LOG_FILE"
echo ""
read -rp "$(echo -e ${YELLOW}Press ENTER to start, or Ctrl+C to abort...${NC})"

# =============================================================================
# PHASE 1 — SYSTEM PREP
# =============================================================================
section "PHASE 1 — System Prep"

step "Update apt"
sudo apt update -y && sudo apt upgrade -y 2>&1 | tail -5 | tee -a "$LOG_FILE"
log "System updated"

step "Install essential base tools"
sudo apt install -y \
  curl wget git gnupg ca-certificates software-properties-common \
  apt-transport-https lsb-release build-essential \
  2>&1 | tail -3 | tee -a "$LOG_FILE"
log "Base tools installed"

# Enable i386 for Steam
step "Enable i386 architecture (for Steam)"
sudo dpkg --add-architecture i386
log "i386 architecture enabled"

# =============================================================================
# PHASE 2 — ADD EXTERNAL REPOS & PPAs
# =============================================================================
section "PHASE 2 — External Repos & PPAs"

step "Brave Browser"
curl -fsS https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
  | sudo tee /usr/share/keyrings/brave-browser-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] \
https://brave-browser-apt-release.s3.brave.com/ stable main" \
  | sudo tee /etc/apt/sources.list.d/brave-browser.list
log "Brave repo added"

step "Visual Studio Code"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor \
  | sudo tee /usr/share/keyrings/microsoft.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] \
https://packages.microsoft.com/repos/code stable main" \
  | sudo tee /etc/apt/sources.list.d/vscode.list
log "VS Code repo added"

step "Google Chrome"
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub \
  | gpg --dearmor \
  | sudo tee /usr/share/keyrings/google-chrome.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] \
http://dl.google.com/linux/chrome/deb/ stable main" \
  | sudo tee /etc/apt/sources.list.d/google-chrome.list
log "Chrome repo added"

step "GitHub CLI"
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list
log "GitHub CLI repo added"

step "Tailscale"
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg \
  | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list \
  | sudo tee /etc/apt/sources.list.d/tailscale.list
log "Tailscale repo added"

step "Kitty Terminal"
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
log "Kitty installed (to ~/.local/kitty.app)"

step ".NET SDK (for dotnet-runtime-8.0)"
wget -q https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
sudo dpkg -i /tmp/packages-microsoft-prod.deb
log ".NET repo added"

step "ngrok"
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
  | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
  | sudo tee /etc/apt/sources.list.d/ngrok.list
log "ngrok repo added"

step "Update apt with new repos"
sudo apt update -y 2>&1 | tail -5 | tee -a "$LOG_FILE"
log "Repos updated"

# =============================================================================
# PHASE 3 — APT PACKAGES
# =============================================================================
section "PHASE 3 — APT Package Installation"

step "Install all apt packages"
sudo apt install -y \
  \
  `# — Terminals & Shell —` \
  zsh guake foot \
  \
  `# — Browsers —` \
  brave-browser google-chrome-stable \
  \
  `# — Dev Tools —` \
  code gh git vim \
  default-jdk \
  python3-pip python3-psutil python3-rich \
  dotnet-runtime-8.0 \
  \
  `# — Build Tools —` \
  autoconf automake build-essential cmake g++ gcc gcc-14 gdb \
  libtool make meson ninja-build pkg-config \
  \
  `# — Media & AV Libs —` \
  ffmpeg \
  libavcodec-dev libavdevice-dev libavformat-dev \
  libavutil-dev libswresample-dev \
  libsdl2-dev libusb-1.0-0-dev \
  \
  `# — CLI Tools —` \
  curl wget rsync unzip zip \
  fd-find fzf ripgrep xclip \
  zoxide strace ltrace \
  netcat-openbsd cron \
  lm-sensors cpufrequtils \
  scrcpy rclone ngrok \
  \
  `# — Desktop / GNOME —` \
  gnome-tweaks \
  gnome-software-plugin-flatpak \
  flatpak \
  copyq \
  kdeconnect \
  transmission \
  vlc \
  \
  `# — Productivity —` \
  \
  `# — Kernel / Hardware —` \
  v4l2loopback-dkms \
  ydotool \
  touchegg \
  \
  `# — Network / Remote —` \
  openssh-server tailscale \
  \
  `# — Flatpak runtime support —` \
  gvfs-backends gvfs-fuse \
  2>&1 | tail -10 | tee -a "$LOG_FILE"
log "APT packages installed"

# =============================================================================
# PHASE 4 — FLATPAK APPS
# =============================================================================
section "PHASE 4 — Flatpak Apps"

step "Add Flathub remote"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
log "Flathub added"

step "Install Flatpak apps"
FLATPAKS=(
  "app.zen_browser.zen"
  "com.getpostman.Postman"
  "com.github.joseexposito.touche"
  "com.github.xournalpp.xournalpp"
  "io.podman_desktop.PodmanDesktop"
  "org.flameshot.Flameshot"
  "org.localsend.localsend_app"
)
for app in "${FLATPAKS[@]}"; do
  info "Installing $app..."
  flatpak install -y flathub "$app" 2>&1 | tail -2 | tee -a "$LOG_FILE" || warn "Could not install $app, skipping"
done
log "Flatpak apps installed"

# =============================================================================
# PHASE 5 — EXTERNAL INSTALLERS (manual .deb / scripts)
# =============================================================================
section "PHASE 5 — External App Installers"

step "Podman (container tools)"
sudo apt install -y podman podman-compose 2>&1 | tail -3 | tee -a "$LOG_FILE"
# podman-docker alias
sudo apt install -y podman-docker 2>/dev/null || warn "podman-docker not available, skipping"
log "Podman installed"

step "Discord"
DISCORD_DEB="/tmp/discord.deb"
wget -qO "$DISCORD_DEB" "https://discord.com/api/download?platform=linux&format=deb"
sudo dpkg -i "$DISCORD_DEB" || sudo apt install -f -y
log "Discord installed"

step "LM Studio"
warn "LM Studio: Download manually from https://lmstudio.ai"
warn "  After install, run: lms (the CLI sets up PATH automatically)"

step "NoMachine"
warn "NoMachine: Download .deb from https://www.nomachine.com/download/linux&id=1"
warn "  Then run: sudo dpkg -i nomachine_*.deb"

step "Iriun Webcam"
warn "Iriun Webcam: Download from https://iriun.com → Linux → .deb"
warn "  Then run: sudo dpkg -i iriun*.deb"

step "OpenTabletDriver"
warn "OpenTabletDriver: See https://opentabletdriver.net/Wiki/Install/Linux"
warn "  Or check: https://github.com/OpenTabletDriver/OpenTabletDriver/releases"

step "DBeaver Community Edition"
DBEAVER_DEB="/tmp/dbeaver.deb"
wget -qO "$DBEAVER_DEB" "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb"
sudo dpkg -i "$DBEAVER_DEB" || sudo apt install -f -y
log "DBeaver CE installed"

step "Steam"
sudo apt install -y steam:i386 2>/dev/null || {
  warn "Steam via apt failed; downloading .deb..."
  wget -qO /tmp/steam.deb https://cdn.akamai.steamstatic.com/client/installer/steam.deb
  sudo dpkg -i /tmp/steam.deb || sudo apt install -f -y
}
log "Steam installed"

# =============================================================================
# PHASE 6 — ZSH SETUP (Oh My Zsh + plugins + p10k)
# =============================================================================
section "PHASE 6 — Zsh / Oh-My-Zsh Setup"

step "Set zsh as default shell"
chsh -s "$(which zsh)"
log "Default shell set to zsh"

step "Install Oh My Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  log "Oh My Zsh installed"
else
  warn "Oh My Zsh already installed, skipping"
fi

step "Install Powerlevel10k theme"
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
  log "Powerlevel10k installed"
else
  warn "Powerlevel10k already present"
fi

step "Install zsh-autosuggestions"
ZSH_AUTO="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
[ ! -d "$ZSH_AUTO" ] && \
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTO"
log "zsh-autosuggestions installed"

step "Install zsh-syntax-highlighting"
ZSH_SYNTAX="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
[ ! -d "$ZSH_SYNTAX" ] && \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_SYNTAX"
log "zsh-syntax-highlighting installed"

step "Install fzf shell integration"
if [ ! -d "$HOME/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --key-bindings --completion --no-update-rc
fi
log "fzf shell integration done"

# =============================================================================
# PHASE 7 — DEV TOOLS (NVM, Node, Bun, Starship, Zoxide)
# =============================================================================
section "PHASE 7 — Dev Tools"

step "Install NVM"
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi
# Load nvm for this session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
log "NVM installed"

step "Install Node.js v20 LTS"
nvm install 20
log "Node v20 installed"

step "Install Node.js v24"
nvm install 24
nvm alias default 24
log "Node v24 installed (set as default)"

step "Install Bun"
curl -fsSL https://bun.sh/install | bash
log "Bun installed"

step "Install Starship prompt"
curl -sS https://starship.rs/install.sh | sh -s -- --yes
log "Starship installed"

step "Install zoxide (already in apt, ensure init works)"
log "zoxide already installed via apt"

step "Install npm global packages"
# Load nvm if available
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
if command -v npm &>/dev/null; then
  info "Installing global npm packages..."
  npm install -g \
    @anthropic-ai/claude-code \
    @nestjs/cli \
    @openai/codex \
    eas-cli \
    eslint \
    http-server \
    live-server \
    nodemon \
    pnpm \
    prettier \
    ts-node \
    typescript \
    vercel \
    yarn \
    2>&1 | tail -5 | tee -a "$LOG_FILE"
  log "npm global packages installed"
else
  warn "npm not available yet — npm globals will install after NVM is loaded"
fi

step "Install opencode CLI"
if [ ! -d "$HOME/.opencode" ]; then
  warn "opencode: Install from https://opencode.ai or their GitHub releases"
else
  warn "opencode: Already exists at ~/.opencode — copy manually if needed"
fi

# =============================================================================
# PHASE 8 — DOTFILES & CONFIGS
# =============================================================================
section "PHASE 8 — Dotfiles & Configs"

CONF="$SCRIPT_DIR/configs"

step "Zsh config (.zshrc + .p10k.zsh)"
cp -v "$CONF/zsh/.zshrc" "$HOME/.zshrc"
cp -v "$CONF/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
log "Zsh configs applied"

step ".profile (cursor theme env vars)"
cp -v "$CONF/zsh/.profile" "$HOME/.profile"
log ".profile applied"

step "Git config (.gitconfig)"
cp -v "$CONF/git/.gitconfig" "$HOME/.gitconfig"
log ".gitconfig applied"

step "GitHub CLI config"
mkdir -p "$HOME/.config/gh"
cp -v "$CONF/gh/config.yml" "$HOME/.config/gh/config.yml"
log "gh CLI config applied (note: re-run 'gh auth login' for tokens)"

step "Kitty terminal config"
mkdir -p "$HOME/.config/kitty"
cp -v "$CONF/kitty/kitty.conf"         "$HOME/.config/kitty/kitty.conf"
cp -v "$CONF/kitty/current-theme.conf" "$HOME/.config/kitty/current-theme.conf"
log "Kitty config applied"

step "Ghostty terminal config"
mkdir -p "$HOME/.config/ghostty"
cp -v "$CONF/ghostty/config" "$HOME/.config/ghostty/config"
log "Ghostty config applied"

step "Neovim config (kickstart-based)"
mkdir -p "$HOME/.config/nvim"
cp -rv "$CONF/nvim/." "$HOME/.config/nvim/"
log "Neovim config applied"

step "CopyQ config"
mkdir -p "$HOME/.config/copyq"
cp -v "$CONF/copyq/copyq.conf" "$HOME/.config/copyq/copyq.conf"
[ -f "$CONF/copyq/copyq-commands.ini" ] && \
  cp -v "$CONF/copyq/copyq-commands.ini" "$HOME/.config/copyq/"
[ -f "$CONF/copyq/copyq_tabs.ini" ] && \
  cp -v "$CONF/copyq/copyq_tabs.ini"    "$HOME/.config/copyq/"
log "CopyQ config applied"

step "Touchegg gesture config"
mkdir -p "$HOME/.config/touchegg"
cp -v "$CONF/touchegg/touchegg.conf" "$HOME/.config/touchegg/touchegg.conf"
log "Touchegg config applied"

step "Zed editor config"
mkdir -p "$HOME/.config/zed"
cp -v "$CONF/zed/settings.json" "$HOME/.config/zed/settings.json"
log "Zed config applied"

step "VS Code settings & keybindings"
mkdir -p "$HOME/.config/Code/User"
cp -v "$CONF/vscode/settings.json"    "$HOME/.config/Code/User/settings.json"
cp -v "$CONF/vscode/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
log "VS Code settings applied"

step "VS Code extensions (58 extensions)"
if command -v code &>/dev/null; then
  info "Installing VS Code extensions..."
  while IFS= read -r ext; do
    [[ -z "$ext" ]] && continue
    code --install-extension "$ext" --force 2>&1 | tail -1 | tee -a "$LOG_FILE" || true
  done < "$CONF/vscode/extensions.txt"
  log "VS Code extensions installed"
else
  warn "VS Code not found — extensions will install on first launch"
fi

step "Cursor AI editor settings & keybindings"
mkdir -p "$HOME/.config/Cursor/User"
cp -v "$CONF/cursor/settings.json"    "$HOME/.config/Cursor/User/settings.json"
cp -v "$CONF/cursor/keybindings.json" "$HOME/.config/Cursor/User/keybindings.json"
log "Cursor AI settings applied"
warn "Cursor extensions: Install Cursor AI from https://cursor.com first, then extensions auto-restore"

step "OpenTabletDriver config (XP-Pen Star G960S tablet)"
mkdir -p "$HOME/.config/OpenTabletDriver"
cp -v "$CONF/opentabletdriver/settings.json" "$HOME/.config/OpenTabletDriver/settings.json"
log "OpenTabletDriver config applied"

step "CopyQ autostart"
mkdir -p "$HOME/.config/autostart"
cat > "$HOME/.config/autostart/copyq.desktop" <<'EOF'
[Desktop Entry]
Name=CopyQ
Icon=copyq
GenericName=Clipboard Manager
X-GNOME-Autostart-Delay=3
Type=Application
Terminal=false
X-KDE-autostart-after=panel
X-KDE-StartupNotify=false
Exec="/usr/bin/copyq"
Hidden=false
X-GNOME-Autostart-enabled=true
EOF
log "CopyQ autostart entry created"

step "Canon LBP2900 printer udev rule"
sudo cp -v "$CONF/system/85-canon-capt.rules" /etc/udev/rules.d/85-canon-capt.rules
sudo udevadm control --reload-rules
log "Canon printer udev rule applied"

step "DBeaver CE — database connections"
# DBeaver must have been launched at least once to create workspace dirs
mkdir -p "$HOME/.local/share/DBeaverData/workspace6/General/.dbeaver"
cp -v "$CONF/dbeaver/data-sources.json" \
      "$HOME/.local/share/DBeaverData/workspace6/General/.dbeaver/data-sources.json"
[ -f "$CONF/dbeaver/project-settings.json" ] && \
  cp -v "$CONF/dbeaver/project-settings.json" \
        "$HOME/.local/share/DBeaverData/workspace6/General/.dbeaver/project-settings.json"
warn "DBeaver: re-enter DB passwords after first launch (credentials not migrated for security)"
log "DBeaver connection definitions restored (subscription_db + connection types)"

step "Transmission — settings"
mkdir -p "$HOME/.config/transmission"
# Remove window geometry (screen-size dependent) before copying
python3 -c "
import json, sys
with open('$CONF/transmission/settings.json') as f:
    s = json.load(f)
# Strip window-position fields (monitor-layout specific)
for key in ['main-window-x','main-window-y','main-window-height','main-window-width','main-window-is-maximized']:
    s.pop(key, None)
with open('$HOME/.config/transmission/settings.json','w') as f:
    json.dump(s, f, indent=4)
"
log "Transmission settings restored (download dir, queue size, peer port, ratio limit)"

step "VLC — preferences"
mkdir -p "$HOME/.config/vlc"
cp -v "$CONF/vlc/vlcrc"                 "$HOME/.config/vlc/vlcrc"
cp -v "$CONF/vlc/vlc-qt-interface.conf" "$HOME/.config/vlc/vlc-qt-interface.conf"
log "VLC config restored (privacy & network settings, window layout)"

step "Claude Code global settings"
mkdir -p "$HOME/.claude/plugins/claude-usage-monitor"
# Global settings (model, statusline, auto permissions)
cp -v "$CONF/claude/settings.json"       "$HOME/.claude/settings.json"
# Local permissions allowlist
cp -v "$CONF/claude/settings.local.json" "$HOME/.claude/settings.local.json"
# Usage monitor statusline plugin (referenced in settings.json)
cp -v "$CONF/claude/plugins/claude-usage-monitor/statusline.sh" \
      "$HOME/.claude/plugins/claude-usage-monitor/statusline.sh"
cp -v "$CONF/claude/plugins/claude-usage-monitor/statusline.py" \
      "$HOME/.claude/plugins/claude-usage-monitor/statusline.py"
chmod +x "$HOME/.claude/plugins/claude-usage-monitor/statusline.sh"
log "Claude Code settings applied"

step "Claude Code memory files"
mkdir -p "$HOME/.claude/memory"
cp -v "$CONF/claude/memory/"*.md "$HOME/.claude/memory/"
log "Claude Code memory files restored ($(ls "$CONF/claude/memory/"*.md | wc -l) files)"

# =============================================================================
# PHASE 9 — GNOME / DCONF SETTINGS
# =============================================================================
section "PHASE 9 — GNOME Settings (dconf)"

step "Apply GNOME dconf settings"
# Strip Pop!_OS-specific keys before loading
grep -v "pop-cosmic\|system76\|pop-os\|pop-desktop\|Pop-Office\|Pop-System\|Pop-Utility" \
  "$CONF/dconf/settings.dconf" > /tmp/ubuntu-dconf-settings.ini

dconf load / < /tmp/ubuntu-dconf-settings.ini
log "dconf settings applied"

step "Apply specific GNOME appearance settings"
# Dark mode
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
# Cursor theme (Bibata — installed below)
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'
gsettings set org.gnome.desktop.interface cursor-size 24
# GTK dark theme
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
# Window buttons
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
log "GNOME appearance settings applied"

# =============================================================================
# PHASE 10 — THEMES & CURSORS
# =============================================================================
section "PHASE 10 — Themes & Cursors"

step "Install adw-gtk3-dark theme (flatpak)"
flatpak install -y flathub org.gtk.Gtk3theme.adw-gtk3-dark 2>/dev/null || warn "adw-gtk3-dark already installed"
log "adw-gtk3-dark installed"

step "Install Bibata cursor theme"
BIBATA_VER="v2.0.7"
BIBATA_DEB="Bibata-Modern-Classic.tar.xz"
wget -qO "/tmp/$BIBATA_DEB" \
  "https://github.com/ful1e5/Bibata_Cursor/releases/download/${BIBATA_VER}/Bibata-Modern-Classic.tar.xz"
mkdir -p "$HOME/.local/share/icons"
tar -xf "/tmp/$BIBATA_DEB" -C "$HOME/.local/share/icons/"
log "Bibata-Modern-Classic cursor theme installed"

# =============================================================================
# PHASE 11 — SERVICES
# =============================================================================
section "PHASE 11 — System Services"

step "Enable & start Tailscale"
sudo systemctl enable --now tailscaled
info "Login to tailscale: sudo tailscale up"
log "Tailscale service enabled"

step "Enable SSH server"
sudo systemctl enable --now ssh
log "SSH server enabled"

step "Enable Touchegg"
sudo systemctl enable --now touchegg
log "Touchegg service enabled"

step "Enable cron"
sudo systemctl enable --now cron
log "cron service enabled"

# =============================================================================
# PHASE 12 — NVIDIA (if applicable)
# =============================================================================
section "PHASE 12 — NVIDIA Drivers"

step "Check for NVIDIA GPU"
if lspci | grep -iq nvidia; then
  info "NVIDIA GPU detected. Installing drivers..."
  sudo apt install -y nvidia-driver-535 nvidia-utils-535 2>&1 | tail -5 | tee -a "$LOG_FILE" || \
    warn "Could not install nvidia-535, try: ubuntu-drivers autoinstall"
else
  warn "No NVIDIA GPU detected, skipping"
fi

# =============================================================================
# DONE
# =============================================================================
section "MIGRATION COMPLETE!"

echo ""
echo -e "${BOLD}${GREEN}Everything done! Here's what still needs manual attention:${NC}"
echo ""
echo -e "${YELLOW}  1. LM Studio${NC}          → https://lmstudio.ai (download .deb)"
echo -e "${YELLOW}  2. NoMachine${NC}           → https://www.nomachine.com/download/linux&id=1"
echo -e "${YELLOW}  3. Iriun Webcam${NC}        → https://iriun.com"
echo -e "${YELLOW}  4. OpenTabletDriver${NC}    → https://opentabletdriver.net/Wiki/Install/Linux"
echo -e "${YELLOW}  5. Cursor AI editor${NC}    → https://cursor.com (download .deb)"
echo -e "${YELLOW}  6. Tailscale login${NC}     → run: sudo tailscale up"
echo -e "${YELLOW}  7. GitHub CLI auth${NC}     → run: gh auth login"
echo -e "${YELLOW}  8. ngrok authtoken${NC}     → run: ngrok config add-authtoken YOUR_TOKEN"
echo -e "${YELLOW}  9. rclone remotes${NC}      → run: rclone config (re-auth gdrive)"
echo -e "${YELLOW} 10. Canon printer${NC}       → cndrvcups-capt from Canon:"
echo -e "                          https://www.canon-europe.com/support/consumer_products/software/"
echo -e "${YELLOW} 11. opencode CLI${NC}        → re-install from https://opencode.ai"
echo -e "${YELLOW} 12. VS Code extensions${NC}  → auto-installed (58 ext); re-login to sync"
echo -e "${YELLOW} 13. Neovim plugins${NC}      → open nvim — lazy.nvim will auto-install all"
echo -e "${YELLOW} 14. Bun completions${NC}     → already in .zshrc, loads automatically"
echo -e "${YELLOW} 15. DBeaver passwords${NC}   → re-enter DB passwords on first launch (not migrated for security)"
echo -e "${YELLOW} 16. Steam games${NC}         → login to Steam → games re-download automatically"
echo -e "                          Cloud saves restore on first launch per game"
echo -e "${YELLOW} 17. Claude Code${NC}         → install: npm i -g @anthropic-ai/claude-code (already in npm globals)"
echo -e "                          then: claude (memory + settings auto-restored)"
echo -e "${YELLOW} 16. Nerd Font${NC}           → for Powerlevel10k (MesloLGS NF):"
echo -e "    wget 'https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf'"
echo -e "    mv 'MesloLGS NF Regular.ttf' ~/.local/share/fonts/ && fc-cache -fv"
echo ""
echo -e "${CYAN}Log saved to: $LOG_FILE${NC}"
echo ""
echo -e "${BOLD}Reboot recommended after completion!${NC}"
echo ""
