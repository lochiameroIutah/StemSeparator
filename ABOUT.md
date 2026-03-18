# Stems Shortcut — Documento Completo

## Cos'e

Stems Shortcut e una app macOS che vive nella menu bar e permette di separare gli stem in Ableton Live con una singola scorciatoia da tastiera, senza toccare il mouse.

L'utente preme una combinazione di tasti (default: ⌥⌘G) e l'app automaticamente:

1. Trova il processo di Ableton Live in esecuzione
2. Lo porta in primo piano
3. Naviga nel menu "Create" (o "Crea" in italiano, e in altre 10 lingue)
4. Clicca la voce "Separate Stems" (posizione 19 nel menu)

Tutto questo avviene in automatico tramite le Accessibility API di macOS (AXUIElement), senza bisogno di AppleScript o plugin.

---

## Cosa fa, nel dettaglio

### Funzionalita principali

- **Hotkey globale personalizzabile**: l'utente registra qualsiasi combinazione di tasti (modifier + lettera/numero/tasto funzione). La shortcut funziona a livello di sistema, anche quando Ableton non e in primo piano.

- **Automazione menu di Ableton via Accessibility API**: l'app usa le AXUIElement API di macOS per navigare programmaticamente nella menu bar di Ableton, trovare il menu "Create" (supporta 12 lingue: inglese, italiano, tedesco, francese, spagnolo, portoghese, giapponese, cinese semplificato e tradizionale, coreano, russo, olandese) e premere la voce di separazione stem.

- **Menu bar app**: non ha dock icon ne finestre permanenti. Vive esclusivamente nella menu bar con un'icona waveform che cambia stato durante il trigger.

- **Avvio al login**: supporto nativo per SMAppService — l'utente puo abilitare l'avvio automatico all'accensione del Mac.

- **Localizzazione inline IT/EN**: tutta l'interfaccia si adatta automaticamente in italiano o inglese in base alla lingua di sistema, senza file .strings.

### Flusso al primo avvio

1. **Schermata di licenza** — l'utente deve inserire una license key Gumroad per attivare il prodotto. Chi non ha una licenza viene rimandato alla pagina di acquisto su Gumroad.
2. **Onboarding guidato** (5 step con animazioni fire-themed):
   - Welcome: overview delle feature
   - Shortcut: scelta della combinazione di tasti
   - Accessibility: guida per abilitare il permesso di Accessibilita nelle Impostazioni di Sistema
   - Login Item: toggle per l'avvio al login
   - Done: conferma che tutto e pronto
3. **Menu bar attiva**: da qui in poi l'app resta nella menu bar e risponde alla shortcut.

### Sistema di licenze

- Validazione tramite API Gumroad (`/v2/licenses/verify`)
- Product ID hardcoded
- La chiave viene salvata in UserDefaults dopo la verifica
- Nessun sistema di scadenza o subscription — una tantum

### Requisiti di sistema

- macOS 13.0+ (Ventura o successivo)
- Permesso di Accessibilita (Privacy & Security > Accessibility)
- Ableton Live 12 (con menu "Create" contenente la voce stem separation alla posizione 19)

---

## Perche esiste

Ableton Live 12 ha introdotto la funzione di separazione stem nativamente, ma e accessibile solo tramite menu: `Create > Separate Stems`. Non esiste una scorciatoia da tastiera nativa per questa operazione.

Per un produttore musicale nel pieno del workflow creativo, dover:
1. Selezionare una clip audio
2. Andare al menu Create
3. Scorrere fino in fondo al menu
4. Cliccare "Separate Stems"

...interrompe il flusso. Moltiplicato per decine di clip in una sessione, diventa un collo di bottiglia reale.

**Stems Shortcut elimina completamente questo attrito**: un tasto, stem separati. L'utente non lascia mai la tastiera.

---

## Target e posizionamento

### Chi e il cliente ideale

- **Produttori musicali** che usano Ableton Live 12 quotidianamente
- **DJ/remixer** che separano stem frequentemente per remix, mashup o live set
- **Sound designer** che analizzano componenti di tracce
- **Educatori musicali** che dimostrano la separazione stem in lezioni
- **Power user** che ottimizzano ogni aspetto del workflow in Ableton

### Pain point risolto

La separazione stem in Ableton e una delle poche operazioni frequenti che non ha una shortcut nativa. Nessun altro tool sul mercato risolve questo problema specifico.

### Dimensione del mercato

- Ableton dichiara milioni di utenti attivi
- La separazione stem e una feature molto richiesta (introdotta in Live 12)
- Il segmento di power user disposti a pagare per micro-utility di produttivita e ben consolidato (vedi il successo di tool come TouchDesigner, Stream Deck, etc.)

---

## Come si potrebbe vendere

### Modello attuale

- **Vendita one-shot su Gumroad** tramite il profilo "abletonaccelerator"
- License key verificata via API
- Nessuna subscription

### Prezzo suggerito

- **$9–19 USD** come utility one-shot: abbastanza basso da essere un acquisto impulsivo, abbastanza alto da comunicare valore professionale.
- Alternativa: **$4.99** per volume massimo, puntando sulla viralita nel mondo Ableton.

### Canali di distribuzione

1. **Gumroad** (gia configurato) — ideale per creator e nicchie
2. **Mac App Store** — visibilita, ma richiede sandboxing (attualmente l'app NON e sandboxed perche deve usare le Accessibility API)
3. **Sito web dedicato** con Paddle/LemonSqueezy per licenze e distribuzione DMG
4. **Community Ableton** — forum ufficiale, r/ableton, gruppi Facebook, Discord di produzione musicale

### Strategie di marketing

- **Video demo** di 30 secondi: mostrare il prima (4 click) vs il dopo (1 tasto). Il contrasto visivo e immediato.
- **Post su r/ableton e forum Ableton** — il target e gia li, concentrato e appassionato.
- **YouTube**: tutorial brevi "Ableton Tips" con CTA per il tool.
- **Partnership con creator Ableton** su YouTube/Instagram (tipo "Ableton Accelerator" o simili).
- **Free trial limitata** (es. 7 giorni o 50 trigger) per abbassare la barriera all'ingresso.
- **Branding "Weero"** gia integrato nell'app (Instagram @doitweero), che linka direttamente al brand del creator.

### Punti di forza per il marketing

- **Zero configurazione**: installa, attiva, premi un tasto
- **Nessun plugin da installare in Ableton**: non modifica la DAW
- **Funziona a livello di sistema**: non importa quale finestra e in primo piano
- **Supporto multilingua**: funziona con Ableton in qualsiasi lingua
- **Leggero**: nessuna dipendenza esterna, app nativa Swift, pochi MB

### Rischi e limitazioni

- **Dipendenza dalla struttura del menu di Ableton**: se Ableton cambia la posizione della voce "Separate Stems" nel menu (attualmente posizione 19), l'app si rompe. Serve un aggiornamento.
- **Accessibilita macOS**: richiede un permesso che puo spaventare utenti meno tecnici. L'onboarding mitiga questo, ma resta un punto di frizione.
- **Solo macOS**: nessun supporto Windows. Questo limita il mercato (Ableton e cross-platform).
- **Nessun App Store**: la necessita di Accessibility API rende difficile il sandboxing richiesto dal Mac App Store.
- **Ableton potrebbe aggiungere una shortcut nativa**: se Ableton implementa una scorciatoia da tastiera per la separazione stem, il valore del tool diminuisce drasticamente.

---

## Architettura tecnica (riassunto)

| Componente | File | Ruolo |
|---|---|---|
| Entry point | `StemSeparatorApp.swift` | MenuBarExtra + AppDelegate |
| Stato globale | `AppState.swift` | Hotkey, permessi, trigger |
| Automazione Ableton | `AbletonController.swift` | AXUIElement API, navigazione menu |
| Hotkey globale | `HotkeyManager.swift` | Carbon Event API |
| UI menu bar | `MenuBarContentView.swift` | SwiftUI popup |
| Onboarding | `OnboardingView.swift` | 5 step guidati |
| Licenze | `LicenseManager.swift` | Verifica Gumroad API |
| Permessi | `PermissionsManager.swift` | Check/request Accessibility |
| Login item | `LoginItemManager.swift` | SMAppService |
| Localizzazione | `L.swift` | IT/EN inline |
| Finestre | `*WindowManager.swift` | Gestione NSWindow |

**Stack**: Swift 5.9, SwiftUI, Carbon Events, AXUIElement, macOS 13+, nessuna dipendenza esterna.

---

## Possibili evoluzioni

- **Supporto per altre operazioni Ableton** (freeze, flatten, export, etc.) — trasformare l'app in un "Ableton Shortcut Manager"
- **Profili shortcut multipli** — diverse combinazioni per diverse operazioni
- **Riconoscimento automatico della posizione nel menu** (invece di indice hardcoded) — cercare la voce per nome rende l'app resistente agli aggiornamenti di Ableton
- **Versione Windows** — tramite UI Automation API di Windows
- **Trial gratuita** con contatore trigger
- **Notifiche** quando la separazione stem e completata (Ableton impiega tempo a processare)
