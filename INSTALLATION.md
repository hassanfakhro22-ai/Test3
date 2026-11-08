# awesome-llm-apps – heruntergeladen, installiert & genutzt

Stand: **8. November 2026, 18:25 Uhr (MEZ/CET)** · Quelle: https://github.com/Shubhamsaboo/awesome-llm-apps

---

## 1. Was im Workspace liegt

| Pfad | Inhalt |
|---|---|
| `/home/user/awesome-llm-apps/` | Klon (`git clone --depth 1`), 1.990 Dateien, ~91 MB |
| `/home/user/scraper-env/.venv/` | Python-venv für `ai_scrapper.py` **und** die Flashscore-Extraktion (114 Pakete) |
| `/home/user/awesome-llm-apps/.venv/` | venv der Quickstart-App (wird bei Bedarf per `install-app.sh` neu erzeugt) |
| `/home/user/install-app.sh` | Installiert die Abhängigkeiten einer beliebigen Einzel-App |
| `/home/user/setup-ai-scrapper.sh` | Stellt venv + Playwright/Chromium + Systemlibs reproduzierbar wieder her |
| `/home/user/awesome-llm-apps/starter_ai_agents/web_scraping_ai_agent/flashscore_programm.py` | Extraktor für die 6 Top-Ligen |
| `/home/user/awesome-llm-apps/starter_ai_agents/web_scraping_ai_agent/flashscore_programm_app.py` | Streamlit-Oberfläche dafür |
| `/home/user/flashscore/` | Ergebnisse: `.html`, `.md`, `.csv`, `.json` + Roh-Snapshot |
| `/home/user/INSTALLATION.md` | Diese Anleitung |

Geklonter Stand: Commit **`c129f31`** (5. Nov 2026, `main`). Der Klon ist *shallow*; `.git` wird vom
Workspace-Snapshot nicht garantiert mitgespeichert (bei Bedarf erneut klonen).

---

## 2. Warum es „die eine Installation" nicht gibt

Das Projekt ist eine Sammlung aus 100+ eigenständigen Apps: **161** `requirements.txt`, **9** `pyproject.toml`,
**25** `package.json`, plus Markdown-Agent-Skills. Im Wurzelverzeichnis gibt es **keinen** Installer.
Deshalb wird pro App installiert (eigene venv), genau wie in der offiziellen README.

---

## 3. Installiert und geprüft

### 3.1 Quickstart `starter_ai_agents/ai_travel_agent`
69 Pakete (streamlit 1.67.0, agno 3.1.12, openai 3.46.0) · `pip check` OK · alle Imports OK.
Wiederherstellen: `bash /home/user/install-app.sh starter_ai_agents/ai_travel_agent`.

### 3.2 Gewählte App `starter_ai_agents/web_scraping_ai_agent/ai_scrapper.py`
114 Pakete (streamlit 1.67.0, scrapegraphai 2.3.1, playwright 1.64.1) · `pip check` OK ·
`SmartScraperGraph`-Import OK · **Chromium 156 + Systembibliotheken** installiert · Browser-Starttest OK.
`ai_scrapper.py` fragt in der UI nach einem OpenAI-Key (`gpt-4o` / `gpt-5`).

> Der **LLM-Teil** (`SmartScraperGraph.run()`) braucht zwingend einen OpenAI- oder Ollama-Key.
> Für die Flashscore-Extraktion unten wurde deshalb dieselbe installierte Umgebung genutzt, aber der
> DOM direkt mit Playwright + BeautifulSoup ausgelesen – **ohne API-Key**.

### 3.3 Flashscore-Programm (heute, 08.11.2026) ⚽

Aus `https://www.flashscore.de/` wurden mit dem installierten Stack **25 Spiele in 6 Ligen** extrahiert:

| Liga | Spiele |
|---|---:|
| Bundesliga | 3 |
| 2. Bundesliga | 3 |
| 3. Liga | 3 |
| Premier League | 5 |
| Ligue 1 | 6 |
| La Liga | 5 |

Enthalten: Status (Beendet / Live-Minute / Halbzeit / Anstoßzeit), Heim, Auswärts, Ergebnis, Match-URL.
Zeiten in **Europe/Berlin** – wichtig, denn eine amerikanisch gerenderte Seite zeigt z. B. `13:30` statt `19:30`.

**Dateien in `/home/user/flashscore/`:**
- `flashscore_programm_2026-11-08.html` – aufbereiteter Report (Haupt-Ergebnis)
- `flashscore_programm_2026-11-08.md`, `…csv`, `…json`
- `snapshot_2026-11-08_1824.html` – unverändertes gerendertes DOM als Nachweis

**Erneut ausführen:**
```bash
cd /home/user/awesome-llm-apps/starter_ai_agents/web_scraping_ai_agent
/home/user/scraper-env/.venv/bin/python flashscore_programm.py
```

---

## 4. Live-Vorschau

| Port | Vorschau | Inhalt |
|---|---|---|
| **8502** | „Flashscore Programm (6 Ligen)" | `flashscore_programm_app.py` – 6 Tabs, Refresh, CSV/JSON/HTML-Download |

`GET /_stcore/health` → `HTTP 200`; die Oberfläche wurde zusätzlich im Browser getestet
(„Stand: 08.11.2026, 19:42:53 Uhr · 25 Spiele in 6 Ligen", keine Fehler).

Nach einem Sandbox-Reset sind venvs, Chromium und Systemlibs weg – dann zuerst
`bash /home/user/setup-ai-scrapper.sh` ausführen und danach den Streamlit-Befehl starten.
Port 8501 (AI Travel Agent) ist derzeit **nicht** aktiv; bei Bedarf:
`bash /home/user/install-app.sh starter_ai_agents/ai_travel_agent` und anschließend
`.venv/bin/streamlit run travel_agent.py --server.address 0.0.0.0 --server.port 8501`.

Weitere Apps starten z. B. mit:
```bash
/home/user/scraper-env/.venv/bin/streamlit run ai_scrapper.py --server.address 0.0.0.0 --server.port 8503
```

---

## 5. Jede andere App installieren

```bash
cd /home/user
bash ./install-app.sh --list        # 193 App-Ordner mit Abhängigkeitsdateien
bash ./install-app.sh rag_tutorials/local_rag_agent
VENV_DIR=/home/user/andere-app-env/.venv bash ./install-app.sh <app-ordner>
```
> `chmod +x` geht beim Snapshot-Reset verloren – daher mit `bash …` aufrufen.

Node-Projekte: `npm install && npm run dev`. Skills: `npx skills add …/agent_skills/<name>`.

---

## 6. Nach einem Sandbox-Reset

Virtuelle Umgebungen, Playwright-Browser (`~/.cache/ms-playwright`), `.git` und `build/`-Verzeichnisse
werden nicht dauerhaft gespeichert. Einmalig:
```bash
bash /home/user/setup-ai-scrapper.sh                                   # venv + Chromium + Systemlibs
bash /home/user/install-app.sh starter_ai_agents/ai_travel_agent        # optional: Quickstart
cd /home/user/awesome-llm-apps && git checkout -- .                     # fehlende Build-Assets (falls .git da)
```

Auf dem eigenen Rechner klassisch:
```bash
git clone https://github.com/Shubhamsaboo/awesome-llm-apps.git
cd awesome-llm-apps/starter_ai_agents/web_scraping_ai_agent
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt && playwright install chromium
streamlit run ai_scrapper.py
```

---

## 7. Hinweise

- **Live-Daten:** Die Stände/Minuten der laufenden Spiele ändern sich; der Report ist eine Momentaufnahme
  von 18:24 Uhr. Der Streamlit-Cache hält 3 Minuten, „🔄 Aktualisieren" lädt neu.
- **Rechtliches:** Nur private Information; Nutzungsbedingungen/Robots von Flashscore beachten, keine
  Massenabfragen.
- **Git-LFS:** 20 Demo-PNGs im Repo sind defekte LFS-Pointer (Server liefert 404) – betrifft nur Bilder.
- **Pinned Versionen:** Manche Apps pinnen z. B. `numpy==1.26.4`, das auf Python 3.13 nicht baut.
- **Sicherheit:** Community-Beispielcode; Keys nie in Code/`.env` committen.
