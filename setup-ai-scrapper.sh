#!/usr/bin/env bash
# Reproduzierbare Komplett-Installation für
# awesome-llm-apps/starter_ai_agents/web_scraping_ai_agent/ai_scrapper.py
#
# Nötig, weil virtuelle Umgebungen, Playwright-Browser und Systempakete in dieser
# Sandbox nicht dauerhaft gespeichert werden. Einfach erneut ausführen:
#   bash /home/user/setup-ai-scrapper.sh
#
set -euo pipefail

REPO_DIR="${REPO_DIR:-/home/user/awesome-llm-apps}"
APP_DIR="$REPO_DIR/starter_ai_agents/web_scraping_ai_agent"
VENV_DIR="${VENV_DIR:-/home/user/scraper-env/.venv}"
SKIP_SYSTEM_DEPS="${SKIP_SYSTEM_DEPS:-0}"

if [ ! -f "$APP_DIR/ai_scrapper.py" ]; then
  echo "Fehler: $APP_DIR/ai_scrapper.py nicht gefunden." >&2
  exit 1
fi

echo "==> [1/6] Virtuelle Umgebung: $VENV_DIR"
[ -x "$VENV_DIR/bin/python" ] || python3 -m venv "$VENV_DIR"
"$VENV_DIR/bin/python" -m pip install -q --upgrade pip

echo "==> [2/6] Python-Abhängigkeiten (streamlit, scrapegraphai, playwright)"
"$VENV_DIR/bin/python" -m pip install -r "$APP_DIR/requirements.txt"
"$VENV_DIR/bin/python" -m pip check

echo "==> [3/6] Import-Test"
"$VENV_DIR/bin/python" -c "from scrapegraphai.graphs import SmartScraperGraph; import streamlit, playwright; print('Imports OK')"
"$VENV_DIR/bin/python" -m py_compile "$APP_DIR/ai_scrapper.py" "$APP_DIR/local_ai_scrapper.py"

echo "==> [4/6] Playwright-Chromium herunterladen"
"$VENV_DIR/bin/playwright" install chromium

echo "==> [5/6] Systembibliotheken für Chromium"
if [ "$SKIP_SYSTEM_DEPS" = "1" ]; then
  echo "    übersprungen (SKIP_SYSTEM_DEPS=1)"
elif sudo -n true 2>/dev/null; then
  sudo -n "$VENV_DIR/bin/playwright" install-deps chromium
else
  echo "    Kein passwortloses sudo - ggf. manuell nachinstallieren:" >&2
  echo "    sudo $VENV_DIR/bin/playwright install-deps chromium" >&2
fi

echo "==> [6/6] Chromium-Starttest"
"$VENV_DIR/bin/python" - <<'PY'
from playwright.sync_api import sync_playwright
with sync_playwright() as p:
    b = p.chromium.launch(headless=True)
    pg = b.new_page()
    pg.set_content("<h1>OK</h1>")
    print("Chromium:", pg.text_content("h1"))
    b.close()
PY

cat <<EOF

Fertig ✅  Starten mit:
  cd $APP_DIR
  $VENV_DIR/bin/streamlit run ai_scrapper.py --server.address 0.0.0.0 --server.port 8502

Die Oberfläche fragt nach einem OpenAI-API-Key (Modelle: gpt-4o / gpt-5).
Für die lokale Variante 'local_ai_scrapper.py' wird zusätzlich Ollama mit
'llama3.2' und 'nomic-embed-text' auf http://localhost:11434 benötigt.
EOF
