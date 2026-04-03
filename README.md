# Tidbyt CISA Alert Ticker 🛡️

**Author:** Rosie Domenech  
**Date:** April 2026  
**Description:** A Tidbyt applet that scrolls the latest CISA cybersecurity alerts across your 64×32 LED display, pulled live from the CISA RSS feed every 30 minutes.

---

## What It Looks Like

```
┌────────────────────────────────┐
│  ! CISA ALERTS                 │  ← Red header bar
│━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━│  ← Yellow divider
│  AA-24-123A: Critical vuln...  │  ← Scrolling alert titles
└────────────────────────────────┘
```

- 🔴 Red header with CISA branding
- 🟡 Yellow accent divider
- ⬜ Scrolling ticker of latest alert titles
- Updates every 30 minutes from live CISA RSS feed

---

## Setup

### 1. Install Pixlet
```bash
# macOS
brew install tidbyt/tidbyt/pixlet

# Linux / Windows — download binary from:
# https://github.com/tidbyt/pixlet/releases
```

### 2. Clone this repo
```bash
git clone https://github.com/RosieDomenech/tidbyt-cisa-ticker.git
cd tidbyt-cisa-ticker
```

### 3. Preview in your browser
```bash
pixlet serve cisa_ticker.star
# Open http://localhost:8080
```

### 4. Render to a WebP file
```bash
pixlet render cisa_ticker.star
```

### 5. Push to your Tidbyt
```bash
# Get your Device ID from the Tidbyt app → Settings → Get API Key
pixlet render cisa_ticker.star
pixlet push --api-token <YOUR_API_TOKEN> <YOUR_DEVICE_ID> cisa_ticker.webp
```

### 6. Add to your rotation (stays on device)
```bash
pixlet push \
  --api-token <YOUR_API_TOKEN> \
  --installation-id cisa-ticker \
  <YOUR_DEVICE_ID> \
  cisa_ticker.webp
```

---

## Configuration

| Option | Values | Default | Description |
|---|---|---|---|
| `max_alerts` | 3, 5, 10 | 5 | How many CISA alerts to scroll |

To pass config when rendering locally:
```bash
pixlet render cisa_ticker.star max_alerts=10
```

---

## Data Source

Live alerts from the [CISA RSS feed](https://www.cisa.gov/uscert/ncas/alerts.xml), cached for 30 minutes to avoid hammering the endpoint.

---

## Automate Updates

Since pushing a static WebP only shows it once, set up a cron job to re-render and push regularly:

```bash
# Every 30 minutes
*/30 * * * * cd /path/to/tidbyt-cisa-ticker && \
  pixlet render cisa_ticker.star && \
  pixlet push --api-token YOUR_TOKEN --installation-id cisa-ticker YOUR_DEVICE_ID cisa_ticker.webp
```

---

## Requirements

- [Pixlet](https://github.com/tidbyt/pixlet) installed locally
- A Tidbyt device + API token (from the Tidbyt mobile app)
- Internet connection (for live CISA feed)
