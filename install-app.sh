#!/usr/bin/env bash
# Hilfsskript für awesome-llm-apps: installiert die Abhängigkeiten EINER App.
# Das Repository ist eine Sammlung vieler eigenständiger Apps mit jeweils eigenen
# requirements.txt / pyproject.toml / package.json - es gibt keinen Global-Installer.
#
# Usage:
#   ./install-app.sh --list
#   ./install-app.sh starter_ai_agents/ai_travel_agent
#   VENV_DIR=/home/user/venv-travel ./install-app.sh rag_tutorials/xyz
#
set -euo pipefail

REPO_DIR="${REPO_DIR:-/home/user/awesome-llm-apps}"
VENV_DIR="${VENV_DIR:-$REPO_DIR/.venv}"

usage() {
  cat <<EOF
Verwendung: $(basename "$0") [APP-ORDNER | --list | --help]

  --list                    Alle App-Ordner mit Abhängigkeitsdateien auflisten
  APP-ORDNER                Relativer Pfad im Repo, z. B. starter_ai_agents/ai_travel_agent
                            (Standard: starter_ai_agents/ai_travel_agent)

Umgebungsvariablen:
  REPO_DIR   Pfad zum Klon        (Standard: $REPO_DIR)
  VENV_DIR   Pfad zur virtuellen Umgebung (Standard: \$REPO_DIR/.venv)
             -> für Apps mit widersprüchlichen Abhängigkeiten eine eigene venv nutzen.
EOF
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  --list|-l)
    cd "$REPO_DIR"
    find . -type f \( -name 'requirements*.txt' -o -name 'pyproject.toml' -o -name 'package.json' \) \
      -not -path './.git/*' -not -path './.venv/*' -not -path './node_modules/*' \
      -printf '%h\n' | sed 's|^\./||' | sort -u
    exit 0 ;;
esac

APP="${1:-starter_ai_agents/ai_travel_agent}"
APP="${APP%/}"
APP_DIR="$REPO_DIR/$APP"

if [ ! -d "$APP_DIR" ]; then
  echo "Fehler: Ordner nicht gefunden: $APP_DIR" >&2
  echo "Mit '$0 --list' siehst du alle gültigen App-Ordner." >&2
  exit 1
fi

echo "==> App:      $APP"
echo "==> venv:     $VENV_DIR"

if [ ! -x "$VENV_DIR/bin/python" ]; then
  echo "==> Erzeuge virtuelle Umgebung ..."
  python3 -m venv "$VENV_DIR"
fi
"$VENV_DIR/bin/python" -m pip install -q --upgrade pip

installed=0
if [ -f "$APP_DIR/requirements.txt" ]; then
  echo "==> pip install -r requirements.txt"
  "$VENV_DIR/bin/python" -m pip install -r "$APP_DIR/requirements.txt"
  installed=1
elif [ -f "$APP_DIR/pyproject.toml" ]; then
  echo "==> pip install (pyproject.toml)"
  "$VENV_DIR/bin/python" -m pip install "$APP_DIR"
  installed=1
elif [ -f "$APP_DIR/package.json" ]; then
  echo "==> npm install (Node.js-Projekt)"
  npm install --prefix "$APP_DIR"
  installed=1
fi

if [ "$installed" -eq 0 ]; then
  # Manche Apps lagern die Requirements eine Ebene tiefer (z. B. backend/frontend).
  req=$(find "$APP_DIR" -maxdepth 3 -name 'requirements*.txt' -not -path '*/.venv/*' | head -n 1 || true)
  if [ -n "$req" ]; then
    echo "==> pip install -r ${req#"$REPO_DIR/"}"
    "$VENV_DIR/bin/python" -m pip install -r "$req"
    installed=1
  fi
fi

if [ "$installed" -eq 0 ]; then
  echo "Hinweis: Keine Abhängigkeitsdatei in $APP gefunden (evtl. nur ein Skill/Markdown)." >&2
else
  echo "==> Prüfe Abhängigkeiten ..."
  "$VENV_DIR/bin/python" -m pip check
fi

if [ -f "$APP_DIR/.env.example" ]; then
  echo
  echo "==> Benötigte Umgebungsvariablen laut .env.example:"
  sed 's/^/    /' "$APP_DIR/.env.example"
fi

cat <<EOF

Fertig. Nächste Schritte:
  source $VENV_DIR/bin/activate
  cd $APP_DIR
  # z. B. streamlit run <datei>.py  /  python <datei>.py  /  npm run dev
  # API-Keys (OpenAI, SerpAPI, ...) ggf. als Umgebungsvariable setzen.
EOF
