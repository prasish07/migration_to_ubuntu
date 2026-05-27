# 🚀 Ubuntu Migration Kit — prasish
### Pop!_OS 24.04 → Ubuntu 26.04 LTS

---

## How to use

1. **Copy this entire folder** to your new Ubuntu machine (USB drive, rclone, rsync, etc.)
2. Open a terminal and run:
   ```bash
   cd migration_to_ubuntu
   chmod +x install.sh
   bash install.sh
   ```
3. Follow any prompts. The script logs everything to `~/migration_install.log`

---

## What the script does

| Phase | What happens |
|-------|-------------|
| 1 | System update + base tools + i386 for Steam |
| 2 | Adds external repos (Brave, VS Code, Chrome, GitHub CLI, Tailscale, ngrok, .NET) |
| 3 | Installs all your apt packages |
| 4 | Installs Flatpak apps (Zen, Postman, Flameshot, LocalSend, Podman Desktop, Xournal++, Touché) |
| 5 | Downloads external `.deb` installers (Discord, DBeaver, Steam) |
| 6 | Sets up Zsh + Oh-My-Zsh + Powerlevel10k + zsh-autosuggestions + zsh-syntax-highlighting |
| 7 | Installs NVM → Node v20 + v24 (v24 default), Bun, Starship, all npm globals |
| 8 | Copies ALL dotfiles & configs (see table below) |
| 9 | Applies GNOME/dconf settings (dark mode, Guake keybindings, power settings, etc.) |
| 10 | Installs `adw-gtk3-dark` GTK theme + Bibata-Modern-Classic cursor |
| 11 | Enables Tailscale, SSH, Touchegg, cron services |
| 12 | Installs NVIDIA drivers (if GPU detected) |

---

## Configs included (`configs/`)

| Folder/File | Contents |
|-------------|----------|
| `kitty/` | `kitty.conf` + `current-theme.conf` (Atelier Lakeside Dark, opacity 0.95, cursor trail 200) |
| `ghostty/` | Split keybindings (Alt+Shift+D/S), tab switching Alt+1–9 |
| `nvim/` | Full kickstart.nvim config (init.lua, lua/, lazy-lock.json, all plugins) |
| `zsh/.zshrc` | OMZ + Powerlevel10k + nvm + bun + zoxide + starship + fzf |
| `zsh/.p10k.zsh` | Powerlevel10k lean 2-line config (dark ornaments) |
| `zsh/.profile` | XCURSOR_THEME=Bibata-Modern-Classic, XCURSOR_SIZE=24, LM Studio PATH |
| `zsh/.bashrc` | Bash config (for fallback sessions) |
| `git/.gitconfig` | user: prasish07, email, nvim editor, gh credential helper |
| `gh/config.yml` | GitHub CLI settings: aliases (`co: pr checkout`), git_protocol: https |
| `vscode/settings.json` | formatOnSave, Prettier, TypeScript, GitLens settings |
| `vscode/keybindings.json` | Custom keybindings (alt+left/right navigation, line copy, etc.) |
| `vscode/extensions.txt` | 58 extensions — auto-installed by script |
| `cursor/settings.json` | Full Cursor AI settings (Cascadia Code font, One Dark Pro, all preferences) |
| `cursor/keybindings.json` | Same keybindings as VS Code |
| `cursor/extensions.txt` | 44 Cursor extensions |
| `zed/settings.json` | Project panel right, VSCode keymap, One Dark theme, font sizes |
| `copyq/` | CopyQ clipboard manager config + tabs |
| `touchegg/` | Touchpad gesture config (3-finger swipe tile, 4-finger desktop switch) |
| `opentabletdriver/` | XP-Pen Star G960S tablet settings (area mapping, bindings) |
| `dconf/settings.dconf` | Full GNOME dump: Guake keybindings, power settings, interface prefs |
| `system/85-canon-capt.rules` | Canon LBP2900 printer udev rule |
| `npm-global-packages.txt` | Reference list of all global npm packages |
| `containers/dev-services/compose.yml` | MySQL 8.0 + Redis 7 + Adminer (always-on dev tools) |
| `containers/subscription/docker-compose.yml` | Postgres 16-alpine + Redis 7-alpine (subscription project) |
| `containers/seatflow/docker-compose.yml` | Postgres 15 + Redis 7 (seatflow project) |
| `containers/spin-up.sh` | Master script to start/stop/pull any or all stacks |
| `dbeaver/data-sources.json` | DBeaver connections: PostgreSQL `subscription_db` on localhost:5432, connection type settings |
| `dbeaver/project-settings.json` | DBeaver project settings |
| `transmission/settings.json` | Transmission: download dir `~/Downloads`, peer port 51413, queue size 5, ratio limit 2, DHT/PEX on |
| `vlc/vlcrc` | VLC preferences: privacy ask disabled, metadata network access enabled |
| `vlc/vlc-qt-interface.conf` | VLC window layout (playlist docked, no status bar) |
| `claude/settings.json` | Claude Code global: model `sonnet[1m]`, statusline, `defaultMode: auto`, skip permission prompts |
| `claude/settings.local.json` | Claude Code local permission allowlist (arecord, pactl, lsusb, flatpak, etc.) |
| `claude/memory/*.md` | All 4 Claude Code memory files: user profile, RN/Expo stack, architecture pattern, project setup workflow |
| `claude/plugins/claude-usage-monitor/` | Custom statusline plugin (shows 5h/7d quota usage, tokens, git branch, cost) |

---

## Containers

All images are pre-pulled by the install script. To spin up after migration:

```bash
cd ~/dev-services
bash spin-up.sh all          # start all three stacks
bash spin-up.sh dev          # MySQL + Redis + Adminer only
bash spin-up.sh subscription # Postgres 16 + Redis (subscription project)
bash spin-up.sh seatflow     # Postgres 15 + Redis (seatflow project)
bash spin-up.sh stop         # stop everything
bash spin-up.sh status       # show running containers
bash spin-up.sh pull         # refresh all images
```

| Stack | Containers | Ports |
|-------|-----------|-------|
| **dev-services** | `dev-mysql` (MySQL 8.0), `dev-redis` (Redis 7), `dev-adminer` (Adminer) | 3306, 6379, 8081 |
| **subscription** | `subscription-postgres` (Postgres 16-alpine), `subscription-redis` (Redis 7-alpine) | 5432, 6379 |
| **seatflow** | `seatflow_postgres_1` (Postgres 15), `seatflow_redis_1` (Redis 7) | 5432, 6379 |

> ⚠️ `subscription` and `seatflow` both bind port **5432** — only run one at a time, or change one stack's host port.

---

## npm Global Packages (auto-installed)

| Package | Version |
|---------|---------|
| @anthropic-ai/claude-code | 2.1.92 |
| @nestjs/cli | 11.0.19 |
| @openai/codex | 0.116.0 |
| eas-cli | 19.1.0 |
| eslint | 10.0.2 |
| http-server | 14.1.1 |
| live-server | 1.2.2 |
| nodemon | 3.1.14 |
| pnpm | 10.30.2 |
| prettier | 3.8.1 |
| ts-node | 10.9.2 |
| typescript | 5.9.3 |
| vercel | 50.23.2 |
| yarn | 1.22.22 |

---

## Key Config Highlights

### Terminal
- **Kitty**: `adw-gtk3-dark` bg, opacity 0.95, cursor trail 200, tab powerline style, Alt+arrow split navigation, Alt+Shift+S/D split windows
- **Ghostty**: Identical split keybindings to Kitty

### Shell
- **Zsh**: Oh-My-Zsh + `powerlevel10k/powerlevel10k` theme + `zsh-syntax-highlighting` + `zsh-autosuggestions`
- **Prompt**: Powerlevel10k lean 2-line (git status, time, exit code)
- **Tools**: `zoxide` (replaces `cd`), `fzf`, `starship` (also loaded), `nvm`, `bun`

### Editors
- **Neovim**: kickstart.nvim — lazy.nvim, LSP, Telescope, Treesitter, Tokyo Night, Mason
- **VS Code**: Prettier formatter, formatOnSave, GitLens, 58 extensions
- **Cursor AI**: Cascadia Code font (14px), One Dark Pro Darker, sidebar right, minimap off
- **Zed**: One Dark theme, VSCode keymap, project panel right, 15px buffer font

### GNOME
- Dark mode (`adw-gtk3-dark` + `prefer-dark`)
- Cursor: `Bibata-Modern-Classic` size 24
- Button layout: minimize + maximize + close (right side)
- Guake: Alt+Q toggle, 91% height fullwidth, Desert palette, zsh

### Hardware
- **Tablet**: XP-Pen Star G960S via OpenTabletDriver (absolute mode, 3840×1080 display area)
- **Printer**: Canon LBP2900 (cndrvcups-capt, serial: 0000C340EM3l)

---

## Apps Needing Manual Install

| App | URL | Notes |
|-----|-----|-------|
| **LM Studio** | https://lmstudio.ai | Download .deb |
| **NoMachine** | https://www.nomachine.com/download/linux&id=1 | Download .deb |
| **Iriun Webcam** | https://iriun.com | Download .deb |
| **OpenTabletDriver** | https://opentabletdriver.net/Wiki/Install/Linux | Config auto-restored |
| **Cursor AI** | https://cursor.com | Download .deb, config auto-restored |
| **Canon cndrvcups** | https://www.canon-europe.com/support/ | cndrvcups-capt driver |
| **opencode CLI** | https://opencode.ai | Re-install binary |
| **Steam** | Auto-handled | Login → games re-download, cloud saves restore automatically |

---

## Post-Install Checklist

- [ ] `sudo tailscale up` — rejoin tailnet
- [ ] `gh auth login` — re-authenticate GitHub CLI
- [ ] `ngrok config add-authtoken YOUR_TOKEN` — restore ngrok auth
- [ ] `rclone config` — re-auth gdrive remotes (tokens don't transfer)
- [ ] Open **Neovim** → lazy.nvim auto-installs all plugins on first launch
- [ ] Install **MesloLGS NF** font for Powerlevel10k:
  ```bash
  mkdir -p ~/.local/share/fonts
  wget "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf" \
       -O ~/.local/share/fonts/"MesloLGS NF Regular.ttf"
  wget "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf" \
       -O ~/.local/share/fonts/"MesloLGS NF Bold.ttf"
  fc-cache -fv
  ```
  Then set your terminal font to `MesloLGS NF`
- [ ] **Cursor AI** font: Install **Cascadia Code** (used in your Cursor settings):
  ```bash
  sudo apt install fonts-cascadia-code
  ```
- [ ] Re-login to Brave / Chrome to sync bookmarks + passwords
- [ ] Re-pair KDE Connect devices
- [ ] Re-pair Iriun / DroidCam if used
- [ ] Install Canon LBP2900 driver (cndrvcups-capt) — udev rule is already applied
- [ ] Open Postman/Zed/DBeaver and re-login to their cloud sync

---

## Transferring this Folder

```bash
# Option 1: USB drive
cp -r ~/migration_to_ubuntu /media/prasish/YOURDRIVE/

# Option 2: rsync over SSH (once Ubuntu is running)
rsync -avz ~/migration_to_ubuntu prasish@ubuntu-machine:~/

# Option 3: rclone (push to Google Drive first)
rclone copy ~/migration_to_ubuntu gdrive:/migration_to_ubuntu
# Then on Ubuntu:
rclone copy gdrive:/migration_to_ubuntu ~/migration_to_ubuntu
```

---

## Node.js

Script installs **Node v20** and **v24** via NVM, with v24 as default.

```bash
nvm use 20   # switch to v20
nvm use 24   # switch to v24 (default)
node --version
```
