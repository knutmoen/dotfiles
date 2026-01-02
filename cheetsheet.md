# Neovim Cheat Sheet – Daglig bruk (v1)

Dette er en **kortfattet oversikt** over funksjonaliteten du har satt opp nå. Tanken er at du kan åpne denne fila innimellom mens muskelminnet bygges.

> **Leader = Space**

---

## 🧭 Navigasjon i prosjektet

### 📂 Bla i filer (Oil.nvim)
**Når:** Du vil se struktur, bla manuelt, flytte/endre filer.

- `<leader>e` → Åpne filutforsker (prosjekt-root)
- `j / k` → Opp / ned
- `Enter` → Åpne fil / gå inn i mappe
- `-` → Gå til parent directory
- `q` → Lukk Oil

---

### 🔍 Finn filer raskt (Telescope)
**Når:** Du vet hva du leter etter.

- `<leader>ff` → Finn filer
- `<leader>fg` → Søk i prosjekt (grep)
- `<leader>fb` → Bytt buffer
- `<leader>fh` → Neovim help

I Telescope:
- `Ctrl-j / Ctrl-k` → Naviger
- `Enter` → Åpne
- `Esc` → Avbryt

---

### 🎯 Rask hopping mellom arbeidsfiler (Harpoon)
**Når:** Du jobber med 3–7 filer samtidig.

- `<leader>a` → Legg til gjeldende fil
- `<leader>1` → Gå til fil 1
- `<leader>2` → Gå til fil 2
- `<leader>3` → Gå til fil 3
- `<leader>4` → Gå til fil 4
- `<leader>h` → Åpne Harpoon-meny

I Harpoon-menyen:
- `Enter` → Åpne fil
- `d` → Fjern fil fra Harpoon
- `q` → Lukk meny

---

## 🧠 LSP – Forstå og navigere i kode

### 🔎 Gå i kode (brukes konstant)

- `gd` → Gå til definisjon
- `gr` → Finn referanser
- `gi` → Gå til implementasjon
- `gD` → Gå til deklarasjon

---

### 🧠 Dokumentasjon og hjelp

- `K` → Hover-dokumentasjon
- `Ctrl-k` → Signaturhjelp

---

### ✏️ Refaktorering

- `<leader>rn` → Rename symbol
- `<leader>ca` → Code actions

---

### 🚨 Feil og diagnostics

- `[d` → Forrige feil
- `]d` → Neste feil
- `<leader>ld` → Vis feilmelding
- `<leader>lq` → Liste med alle feil

---

## ✍️ Skriving og autocomplete (nvim-cmp)

I insert mode:

- Begynn å skrive → forslag vises
- `Ctrl-n / Ctrl-p` → Naviger forslag
- `Enter` → Bekreft valg
- `Ctrl-Space` → Tving completion
- `Tab / Shift-Tab` → Snippets / hopp

---

## 🗺️ Oversikt over keymaps (which-key)

- `Space` → Vis alle leader-kommandoer
- `Space + bokstav` → Se tilgjengelige handlinger
- `Esc` → Avbryt

---

## 🧠 Mental modell (viktig å huske)

- **Oil** → Se og endre struktur
- **Telescope** → Finn noe raskt
- **Harpoon** → Bytt raskt mellom viktige filer
- **LSP** → Forstå kode
- **which-key** → Aldri vær lost

---

