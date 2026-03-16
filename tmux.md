# tmux-oppsett

Dette prosjektet setter opp tmux via GNU Stow og et par helper-funksjoner i zsh. Her er hva som allerede er på plass og hvordan du kan bruke det proaktivt.

## Hva finnes i repoet

- `stow/tmux/.tmux.conf`: den nye tmux-konfigurasjonen med egne hurtigtaster for splitting, navigasjon, resizing og session-switching. Den blir aktivert ved å kjøre `stow --target="$HOME" tmux` etter bootstrap.
- `stow/zsh/.zsh/tmux.zsh`: zsh-funksjoner og aliaser som lar deg starte eller hoppe inn i tmux-sessions uten å huske lange kommandoer. De brukes automatisk av shellen via stow-zsh-pakken.

## Slik starter du og holder tmux i gang

1. **Starter tmux**: Hvis tmux er installert og du ikke allerede er inne i en session, vil shellen automatisk starte `tmux` og koble deg til `default`-sessionen. Legg inn `tmux` i `Brewfile` hvis det ikke er installert.
2. **Velg session via helpers**:
   - `t` → åpner (eller oppretter) `default`-sessionen i gjeldende katalog.
   - `tc` → `commands`-session (generelle kommandoer).
   - `td` → `dev`-session med 3-pane-layout (ai cli | api / web).
   - `tp <navn>` → opprett eller bytt til et navngitt prosjekt (se under).
3. **Bootstrap standard sessions**: `tboot` starter `commands` og `dev` med riktig pane-layout.

## Prosjekter (`tp`)

Registrer prosjekter i `~/.zshrc`:

```bash
tmux_project myapp   "$HOME/projects/myapp/api"    "$HOME/projects/myapp/web"
tmux_project otherapp "$HOME/projects/other/server" "$HOME/projects/other/client"
```

Hvert prosjekt får sin egen navngitte session med denne layouten:

```
┌──────────────┬──────────────┐
│              │     api      │
│    ai cli    ├──────────────┤
│              │     web      │
└──────────────┴──────────────┘
```

- `tp` → list alle registrerte prosjekter
- `tp myapp` → opprett session (med layout) eller bytt til den, både inne og utenfor tmux

## Oppsett og hurtigtaster fra `~/.tmux.conf`

| Aksjon | Hurtigtast | Forklaring |
| --- | --- | --- |
| Prefix | `Ctrl+a` | Nytt prefix (det gamle `Ctrl+b` er deaktivert). |
| Ny vertikal pane | `Ctrl+a` + `v` | splitter vinduet vertikalt og åpner ny pane til høyre. |
| Ny vertikal pane (alternativ) | `Ctrl+a` + `\|` | samme som over, nyttig å vite om. |
| Ny horisontal pane | `Ctrl+a` + `-` | splitter vinduet horisontalt og åpner pane under. |
| Ny horisontal pane (beholder katalog) | `Ctrl+a` + `=` | splitter horisontalt og beholder gjeldende katalog i ny pane. |
| Nye sessions | `Ctrl+a` + `c` | starter en ny session i samme katalog. |
| Liste sessions | `Ctrl+a` + `s` | viser tilgjengelige sessions og lar deg bytte ved å velge en. |
| Bytt session (skriv navn) | `Ctrl+a` + `S` | ber om sessions-navn og bytter direkte. |
| Liste windows | `Ctrl+a` + `w` | velger et window (ofte pendler du mellom dem). |
| Navigering mellom panes | `Ctrl+a` + `h/j/k/l` | bruker home-row for å flytte fokus (venstre/ned/opp/høyre). |
| Resize panes | `Ctrl+a` + `H/J/K/L` | forsterker focus 5 kolonner/rader i valgt retning. |
| Reload config | `Ctrl+a` + `R` | laster inn `~/.tmux.conf` uten å starte tmux på nytt. |
| Kill session | `Ctrl+a` + `&` | ber om bekreftelse før gjeldende session stenges. |
| Copy mode (vi) | `Ctrl+a` + `[` | går inn i copy-mode med vi-bevegelser. `v` starter markering, `y` kopierer. |

## Pane- og session-workflow

- **Splitte**: bruk `Ctrl+a v` for vertikal (ny pane til høyre) og `Ctrl+a -` for horisontal (ny pane under). `Ctrl+a =` splitter horisontalt og beholder gjeldende katalog.
- **Nye sessioner**: `tmux new -s <navn>` fungerer, men du får samme resultat med helperen `t <navn>` fra zsh.
- **Bytte session**: `Ctrl+a s` viser session-tree, trykk på navnet for å bytte. `t`-funksjonen på nytt terminalvindu plukker automatisk `default` eller navn du gir.

## Navigering mellom sessioner og panes

- **Pane navigation**: `Ctrl+a h/j/k/l` (venstre/ned/opp/høyre) og `Ctrl+a H/J/K/L` for resizing.
- **Session/Window**: `Ctrl+a s` (sessions), `Ctrl+a w` (windows). `Ctrl+a Tab` kan også brukes (standard tmux) for å gå i syklisk rekkefølge.

## Aktivering

Etter å ha kjørt `./bootstrap.sh` og stowet resten av config, stow tmux-pakken via:

```bash
stow --target="$HOME" tmux
```

Dette legger `~/.tmux.conf` på plass. Husk å installere tmux via Homebrew om det ikke finnes (`brew install tmux`).

Hvis du gjør endringer, bruk `Ctrl+a R` inne i tmux for å laste nye knappesett mens sessionen lever.

## Oppsummering

- tmux kjører med `Ctrl+a`-prefix og har praktiske pane/resize-bindings.
- Zsh har helper-funksjoner (`t`, `tboot`, `tf`, `tb`, `tc`, `td`) for å starte eller bytte sessioner.
- Du kan trene på splitting, navigating og session-switching med de overnevnte hurtigtastene.
- Endringer i tmux-konfig laster du på nytt med `Ctrl+a R`.

Lykke til med tmux! Gi gjerne beskjed hvis du vil ha en egen kort-liste i `cheetsheet.md` også.
