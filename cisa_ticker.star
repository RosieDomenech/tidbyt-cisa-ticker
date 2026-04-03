# CISA Alert Ticker
# Author: Rosie Domenech
# Date: April 2026
# Description: Scrolls the latest CISA cybersecurity alerts across
#              the Tidbyt 64x32 LED display, pulled live from the CISA RSS feed.

load("render.star", "render")
load("http.star", "http")
load("cache.star", "cache")
load("schema.star", "schema")

CISA_RSS    = "https://www.cisa.gov/uscert/ncas/alerts.xml"
CACHE_KEY   = "cisa_alerts_v1"
CACHE_TTL   = 1800  # 30 minutes

# Colors
RED         = "#CC0000"
YELLOW      = "#FFD700"
WHITE       = "#FFFFFF"
BLACK       = "#000000"
LIGHT_GRAY  = "#AAAAAA"

def get_alerts(max_alerts):
    """Fetch and parse CISA alert titles from RSS feed."""
    cached = cache.get(CACHE_KEY)
    if cached != None:
        return cached.split("|||")[:max_alerts]

    resp = http.get(CISA_RSS, ttl_seconds = CACHE_TTL)
    if resp.status_code != 200:
        return ["CISA feed unavailable — visit cisa.gov/alerts"]

    body   = resp.body()
    titles = []

    # Parse titles from each <item> block
    items = body.split("<item>")
    for item in items[1:]:
        start = item.find("<title>")
        end   = item.find("</title>")
        if start == -1 or end == -1:
            continue
        title = item[start + 7 : end].strip()

        # Strip CDATA wrappers if present
        if title.startswith("<![CDATA["):
            title = title[9:]
        if title.endswith("]]>"):
            title = title[:-3]
        title = title.strip()

        if title:
            titles.append(title)
        if len(titles) >= 10:
            break

    if not titles:
        return ["No CISA alerts found — check cisa.gov/alerts"]

    cache.set(CACHE_KEY, "|||".join(titles), ttl_seconds = CACHE_TTL)
    return titles[:max_alerts]

def main(config):
    max_alerts = int(config.get("max_alerts") or "5")
    alerts     = get_alerts(max_alerts)

    # Join alerts with a bullet separator for the ticker
    ticker_text = "   •   ".join(alerts)

    return render.Root(
        delay = 30,  # ms per frame — controls scroll speed
        child = render.Column(
            children = [
                # ── Header bar ──────────────────────────────
                render.Box(
                    width  = 64,
                    height = 10,
                    color  = RED,
                    child  = render.Padding(
                        pad   = (3, 2, 0, 0),
                        child = render.Text(
                            content = "! CISA ALERTS",
                            font    = "CG-pixel-3x5-mono",
                            color   = WHITE,
                        ),
                    ),
                ),
                # ── Accent divider ───────────────────────────
                render.Box(
                    width  = 64,
                    height = 1,
                    color  = YELLOW,
                ),
                # ── Scrolling ticker ─────────────────────────
                render.Box(
                    width  = 64,
                    height = 21,
                    color  = BLACK,
                    child  = render.Padding(
                        pad   = (0, 5, 0, 0),
                        child = render.Marquee(
                            width        = 64,
                            offset_start = 64,
                            offset_end   = 64,
                            child        = render.Text(
                                content = ticker_text,
                                font    = "tb-8",
                                color   = WHITE,
                            ),
                        ),
                    ),
                ),
            ],
        ),
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields  = [
            schema.Dropdown(
                id      = "max_alerts",
                name    = "Number of Alerts",
                desc    = "How many recent CISA alerts to scroll",
                icon    = "triangleExclamation",
                default = "5",
                options = [
                    schema.Option(display = "3 alerts",  value = "3"),
                    schema.Option(display = "5 alerts",  value = "5"),
                    schema.Option(display = "10 alerts", value = "10"),
                ],
            ),
        ],
    )
