# ⚠️ Security — What Was NOT Committed Here

The following files on your Pop!_OS machine contain **secrets/credentials** and were
intentionally excluded from this repo. You'll need to handle them manually.

---

## 🔴 Stripe CLI — Live API Keys
**File:** `~/.config/stripe/config.toml`

Contains **live Stripe API keys** in plain text:
- `live_mode_api_key` (rk_live_…)
- `test_mode_api_key` (sk_test_…)
- `live_mode_pub_key` / `test_mode_pub_key`

**On Ubuntu:** Install Stripe CLI then run `stripe login` — it will re-authenticate
and write fresh keys. Do NOT manually copy this file.

---

## 🔴 ngrok Auth Token
**File:** `~/.config/ngrok/ngrok.yml`

Contains your ngrok `authtoken`.

**On Ubuntu:**
```bash
ngrok config add-authtoken YOUR_TOKEN
```
Find your token at: https://dashboard.ngrok.com/authtokens

---

## 🔴 rclone OAuth Tokens
**File:** `~/.config/rclone/rclone.conf`

The remote **structure** (gdrive, gdrive2) is included in this repo but
OAuth tokens are stripped. Re-authenticate after install:
```bash
rclone config reconnect gdrive:
rclone config reconnect gdrive2:
```

---

## 🟡 DBeaver Database Passwords
**File:** `~/.local/share/DBeaverData/workspace6/General/.dbeaver/credentials-config.json`

Not included. Re-enter passwords on first launch in DBeaver.

---

## 🟡 code-server Password
**File:** `~/.config/code-server/config.yaml`

Password field was replaced with `CHANGE_ME` in the committed version.
Edit `~/.config/code-server/config.yaml` on the new machine and set your password.

---

## 🟡 Claude Code Credentials
**File:** `~/.claude/.credentials.json`

Contains your Anthropic OAuth token. Not included.
Just run `claude` on the new machine and log in — it re-authenticates automatically.

---

## 🟡 SSH Known Hosts
**File:** `~/.ssh/known_hosts`

Not included — it's machine-specific fingerprint data.
It will rebuild automatically as you connect to hosts.
