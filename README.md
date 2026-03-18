# Stems Shortcut

App macOS menu bar che separa gli stem in Ableton Live con una singola scorciatoia da tastiera.

**Un tasto. Stem separati. Nessun menu, nessun click.**

## Come funziona

1. L'utente preme una combinazione di tasti (default: `⌥⌘G`)
2. L'app trova Ableton Live, lo porta in primo piano
3. Naviga automaticamente nel menu Create > Separate Stems via Accessibility API
4. Stem separati

Supporta Ableton in 12 lingue. Funziona a livello di sistema, anche quando Ableton non e in primo piano.

## Requisiti

- macOS 13.0+ (Ventura)
- Ableton Live 12
- Permesso Accessibilita (Privacy & Security > Accessibility)

## Stack

Swift 5.9, SwiftUI, Carbon Events, AXUIElement, Sparkle 2 — zero dipendenze esterne oltre Sparkle.

---

## Sistema di aggiornamento automatico

L'app usa **Sparkle 2** per gli aggiornamenti automatici. Gli utenti ricevono un popup "Aggiornamento disponibile" e cliccano per installare — l'app si chiude, si aggiorna e si riavvia da sola.

### Come funziona dietro le quinte

```
Tu fai modifiche → commit → tag → push
→ GitHub Actions builda l'app
→ Crea uno ZIP firmato con EdDSA
→ Pubblica una GitHub Release
→ Aggiorna appcast.xml su GitHub Pages
→ Gli utenti ricevono l'aggiornamento automaticamente
```

### Componenti

| Cosa | Dove |
|---|---|
| Workflow CI/CD | `.github/workflows/release.yml` |
| Appcast (feed Sparkle) | https://lochiamerolutah.github.io/StemSeparator/appcast.xml |
| GitHub Pages branch | `gh-pages` |
| Chiave pubblica EdDSA | `project.yml` → `SUPublicEDKey` |
| Chiave privata EdDSA | GitHub Secret `SPARKLE_PRIVATE_KEY` |
| Chiave privata locale | `sparkle_private_key.pem` (NON committata) |
| Updater nell'app | `StemSeparator/UpdaterManager.swift` |
| Check automatico | Ogni 24 ore |

---

## Come rilasciare un aggiornamento

### Metodo 1: Skill Claude Code (consigliato)

C'e una skill Claude Code chiamata **`rilascia-aggiornamento-stems-shortcut`** che automatizza tutto il processo.

Basta dire a Claude:

```
"rilascia una nuova versione di Stems Shortcut"
```

oppure invocare direttamente:

```
/rilascia-aggiornamento-stems-shortcut
```

La skill:
1. Controlla lo stato del repo e l'ultima versione
2. Ti chiede quale versione rilasciare (es. v1.1, v2.0)
3. Committa le modifiche pendenti
4. Crea il tag e pusha
5. Verifica che il workflow GitHub Actions parta
6. Ti da il riepilogo con i link

La skill e in: `~/.claude/skills/rilascia-aggiornamento-stems-shortcut/SKILL.md`

### Metodo 2: Manuale

Se preferisci fare tutto a mano:

```bash
# 1. Committa le modifiche
git add -A
git commit -m "Descrizione delle modifiche"

# 2. Crea il tag con la nuova versione
git tag v1.1

# 3. Pusha tutto
git push && git push --tags
```

Il workflow parte automaticamente quando pushi un tag che inizia con `v`.

### Cosa succede dopo il push

1. **GitHub Actions** (`.github/workflows/release.yml`):
   - Installa XcodeGen e genera il progetto Xcode
   - Risolve le dipendenze SPM (Sparkle)
   - Builda in configurazione Release
   - Crea lo ZIP della .app
   - Firma lo ZIP con la chiave EdDSA privata
   - Genera `appcast.xml` con versione, URL download e firma
   - Pubblica una GitHub Release con lo ZIP allegato
   - Deploya `appcast.xml` sul branch `gh-pages`

2. **GitHub Pages** serve l'appcast aggiornato

3. **L'app degli utenti** (entro 24 ore, o al check manuale):
   - Sparkle legge l'appcast
   - Confronta la versione
   - Mostra il banner "Aggiornamento disponibile"
   - L'utente clicca → Sparkle scarica lo ZIP, sostituisce la .app, riavvia

### Versioning

- Usa **semantic versioning**: `vMAJOR.MINOR.PATCH`
- `v1.1` → piccola modifica o fix
- `v2.0` → cambio importante
- Il numero versione appare nell'header del menu bar popup (`v1.0`, `v1.1`, ecc.)

---

## Struttura del progetto

```
StemSeparator/
├── .github/workflows/release.yml  ← CI/CD
├── project.yml                     ← Config XcodeGen
├── StemSeparator/
│   ├── StemSeparatorApp.swift      ← Entry point
│   ├── AppState.swift              ← Stato globale
│   ├── AbletonController.swift     ← Automazione menu Ableton
│   ├── HotkeyManager.swift         ← Hotkey globale (Carbon)
│   ├── MenuBarContentView.swift    ← UI menu bar
│   ├── OnboardingView.swift        ← Onboarding 5 step
│   ├── LicenseManager.swift        ← Verifica licenza Gumroad
│   ├── LicenseWindowManager.swift  ← Finestra attivazione
│   ├── UpdaterManager.swift        ← Sparkle auto-update
│   ├── PermissionsManager.swift    ← Accessibilita macOS
│   ├── LoginItemManager.swift      ← Avvio al login
│   ├── L.swift                     ← Localizzazione IT/EN
│   ├── Info.plist
│   ├── StemSeparator.entitlements
│   └── Assets.xcassets/
├── build_dmg.sh                    ← Script creazione DMG
├── make_dmg_bg.py                  ← Background DMG
└── ABOUT.md                        ← Documento dettagliato
```

## Cose da NON fare

- **NON committare** `sparkle_private_key.pem` — e nel `.gitignore` ma stai attento
- **NON cambiare** la chiave pubblica in `project.yml` senza aggiornare anche il secret GitHub
- **NON cancellare** il branch `gh-pages` — e dove vive l'appcast
- **NON pushare tag** senza aver verificato che il codice compili

## Licenze

Vendita one-shot su Gumroad (profilo "abletonaccelerator"). Validazione via API Gumroad.

Realizzata da **Weero** · [@doitweero](https://www.instagram.com/doitweero)
