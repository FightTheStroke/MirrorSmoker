# Analisi sincronizzazione App ↔︎ Widget ↔︎ Watch

Questo report documenta perché il numero di sigarette, l’azione di aggiunta e i log non risultano sincronizzati tra app iOS, widget e app watchOS, e propone un piano di correzione concreto.

## Executive Summary

- Origine unica dei dati (SwiftData, App Group) presente nell’app, ma il widget non la usa: legge/scrive chiavi UserDefaults diverse e non coerenti.
- Il pulsante “+” del widget attualmente non inserisce nessuna sigaretta nel database condiviso (intent placeholder o coda “pending” mai processata).
- L’app e il Watch scambiano dati via App Group + WatchConnectivity, ma il widget resta fuori da questo circuito.
- Esistono due implementazioni di widget nel target, con logiche tra loro differenti e parzialmente scollegate.

Conseguenza: aggiungendo una sigaretta dall’app il totale diventa 12, ma il widget continua a mostrare un valore diverso (o non si aggiorna), e lo stesso vale in direzione opposta.

---

## Architettura attuale (per componente)

- App iOS
  - Persistenza: SwiftData nel container App Group `group.fightthestroke.mirrorsmoker` (vedi `PersistenceController.swift`).
  - Sync centrale: `SyncCoordinator` aggiorna widget e Watch quando cambiano i dati (chiavi condivise e `WidgetCenter.reloadAllTimelines()`).
  - Esporta verso App Group UserDefaults: salva `todayCount`, `lastUpdated` e un JSON dei log giornalieri in chiavi del tipo `cigarettes_yyyy-MM-dd` (vedi `SyncCoordinator.updateSharedUserDefaults()`).

- Watch app
  - Legge/scrive su App Group UserDefaults (`group.fightthestroke.mirrorsmoker`) e usa `WCSession` per sync in tempo reale (file `MirrorSmokerStopper Watch App/SharedDataManager.swift` e `WatchConnectivityManager.swift`).
  - Chiavi usate: `todayCount`, `lastUpdated`, `cigarettes_yyyy-MM-dd`.

- Widget (target “MirrorSmokerStopper Widget”)
  - Widget attivo: `MirrorSmokerWidget` (in `MirrorSmokerStopper Widget/MirrorSmokerStopper_Widget.swift` con `@main` in `MirrorSmokerStopper_WidgetBundle.swift`).
  - Sorgente dati: `WidgetStore` che legge/scrive chiavi proprie: `widget_today_count`, `widget_last_cigarette_time`, `widget_pending_cigarettes`.
  - Azione “+”: usa `AddCigaretteIntent` (placeholder) che non inserisce nulla nel database condiviso.
  - Seconda implementazione presente ma non principale: `CigaretteWidget` (usa `QuickAddFromWidgetIntent`), scrive in `widget_pending_cigarettes` ma la coda non viene mai processata in app.

---

## Problemi puntuali rilevati (root cause)

1) Mismatch delle chiavi tra App/Watch e Widget
- App e Watch usano chiavi App Group `todayCount`, `lastUpdated`, `cigarettes_yyyy-MM-dd` (vedi `SyncCoordinator.updateSharedUserDefaults()` e `Watch App/SharedDataManager`).
- Il widget legge chiavi proprie: `widget_today_count`, `widget_last_cigarette_time` (vedi `MirrorSmokerStopper Widget/WidgetStore.swift`).
- Non esiste alcun punto in cui l’app aggiorni `widget_today_count`, quindi il widget non riflette i salvataggi reali.

2) Azione “+” del widget non inserisce alcuna sigaretta nel database condiviso
- `MirrorSmokerWidget` usa `AddCigaretteIntent` (file `AddCigaretteIntent.swift`), che esplicitamente non inserisce: è un placeholder con commento “In a real app, you would…”.
- La seconda via (`QuickAddFromWidgetIntent`) aggiunge un timestamp alla coda `widget_pending_cigarettes`, ma:
  - `processPendingCigarettes(modelContext:)` in `WidgetStore` è uno stub e non fa nulla.
  - Non c’è alcun consumer lato app che legga/flush la coda `widget_pending_cigarettes` in SwiftData.

3) Due implementazioni di widget nel target, con logica incoerente
- `MirrorSmokerWidget` (attivo) usa intent placeholder e chiavi `widget_*`.
- `CigaretteWidget` (presente ma non nel bundle @main) usa `QuickAddFromWidgetIntent` e ancora `WidgetStore` con coda pending.
- Nessuna delle due implementazioni accede al ModelContainer condiviso via App Group per leggere/scrivere il dato reale.

4) Il widget non usa la stessa “fonte unica” usata da App e Watch
- L’app scrive i dati verità in SwiftData (App Group) e, a beneficio del Watch, propaga un riassunto in UserDefaults (App Group).
- Il widget non legge né SwiftData (via `AppGroupManager.sharedModelContainer`) né le stesse chiavi UserDefaults (`todayCount`, `cigarettes_yyyy-MM-dd`) usate da Watch.

5) Refresh cronologico ok, ma senza dati corretti non sincronizza
- `WidgetCenter.reloadAllTimelines()` viene chiamato in vari punti (app, widget), ma il widget continua a leggere chiavi non aggiornate → ricarica con valori sbagliati.

---

## Effetti osservabili

- Aggiunta dall’app: `Cigarette` viene inserita in SwiftData; `SyncCoordinator` aggiorna `todayCount` nei UserDefaults condivisi e invia reload ai widget. Il widget però mostra ancora il vecchio valore perché legge `widget_today_count` che non viene mai scritto dall’app.
- Aggiunta dal widget (bundle attivo): `AddCigaretteIntent` non salva nulla → nessun cambiamento né in app, né in Watch, né nel widget stesso.
- Aggiunta dal widget (implementazione alternativa): il timestamp finisce nella coda `widget_pending_cigarettes`, mai consumata → nessun effetto in app/Watch; il widget può indicare “pending/syncing” ma il conteggio reale non cambia.
- Aggiunta dal Watch: l’app riceve via `WCSession` o via UserDefaults condivisi, aggiorna SwiftData e `todayCount`; il widget resta disallineato per lo stesso motivo del punto 1.

---

## Dove nel codice (riferimenti principali)

- App (SwiftData + Sync)
  - `MirrorSmokerStopper/Utilities/PersistenceController.swift`
  - `MirrorSmokerStopper/Utilities/SyncCoordinator.swift` → `updateSharedUserDefaults()` scrive `todayCount`, `lastUpdated`, `cigarettes_yyyy-MM-dd` in App Group UD.
  - `MirrorSmokerStopper/Views/ContentView.swift` → salva `Cigarette` e chiama `syncCoordinator.cigaretteAdded(from: .app, ...)`.

- Watch
  - `MirrorSmokerStopper Watch App/SharedDataManager.swift` → usa App Group UD con le chiavi: `todayCount`, `lastUpdated`, `cigarettes_yyyy-MM-dd`.
  - `MirrorSmokerStopper Watch App/WatchConnectivityManager.swift` → WCSession per sync live.

- Widget
  - `MirrorSmokerStopper Widget/MirrorSmokerStopper_Widget.swift` (+ bundle @main) → provider legge da `WidgetStore`.
  - `MirrorSmokerStopper Widget/WidgetStore.swift` → chiavi `widget_today_count`, `widget_last_cigarette_time`, `widget_pending_cigarettes`; `processPendingCigarettes` è vuoto.
  - `MirrorSmokerStopper Widget/AddCigaretteIntent.swift` → placeholder (nessun inserimento dati).
  - `MirrorSmokerStopper Widget/CigaretteWidget.swift` → implementazione alternativa non principale con `QuickAddFromWidgetIntent` (scrive solo pending).
  - Esiste già un accesso al ModelContainer condiviso, ma nel modulo app: `MirrorSmokerStopper/Utilities/AppGroupManager.swift` con `WidgetDataProvider.addCigaretteFromWidget()` che inserisce correttamente in SwiftData (non usato dal widget attivo).

---

## Piano di correzione (consigliato)

Priorità Alta (per allineare subito i conteggi):

1) Unificare la fonte dati del widget
- Opzione A (consigliata): far leggere al widget i dati direttamente da SwiftData nel contenitore App Group.
  - Usare `AppGroupManager.sharedModelContainer` nel provider per calcolare `todayCount` e “last cigarette time”.
  - Vantaggio: una sola fonte verità per App/Widget/Watch, nessun doppio canale.
- Opzione B (workaround veloce): se si preferisce restare su UserDefaults, far leggere al widget le stesse chiavi del Watch (`todayCount` e decodifica di `cigarettes_yyyy-MM-dd` per l’ora dell’ultima).
  - Aggiornare il provider del widget per usare `UserDefaults(suiteName: group)` con chiavi `todayCount`/`cigarettes_...` invece di `widget_today_count`.

2) Implementare l’azione “+” del widget per inserire davvero
- Collegare il pulsante “+” a un Intent che:
  - accede a `AppGroupManager.sharedModelContainer` e inserisce una nuova `Cigarette` (come fa `WidgetDataProvider.addCigaretteFromWidget()`).
  - al termine chiama `WidgetCenter.reloadAllTimelines()` e aggiorna un flag/`lastUpdated` in App Group UD per triggerare la UI app/Watch.
- Eliminare l’intent placeholder (`AddCigaretteIntent` così com’è) o sostituirne l’implementazione.

3) Rimuovere o completare la coda “pending”
- Se si passa a inserimento diretto nel ModelContainer condiviso, rimuovere completamente `widget_pending_cigarettes` e i relativi metodi.
- In alternativa, implementare realmente `processPendingCigarettes(modelContext:)` e una logica in app che la richiami in foreground/background per flushare la coda in SwiftData (ma è più fragile e ridondante rispetto all’inserimento diretto condiviso).

4) Consolidare a una sola implementazione di widget
- Tenere solo `MirrorSmokerWidget` o solo `CigaretteWidget`, ma allineata con i punti 1–3. Evitare doppioni che confondono flussi/chiavi.

Priorità Media (pulizia e robustezza):

5) Allineare le chiavi, se si mantiene un canale UD
- Se resta l’uso di UD per “last time” visibile nel widget, far scrivere ad `updateSharedUserDefaults()` anche `widget_last_cigarette_time` (opzionale se si legge SwiftData direttamente).

6) Verificare tempi di aggiornamento
- Tenere `WidgetCenter.reloadAllTimelines()` nei punti chiave (post-save app, post-intent widget, post-sync Watch) – già presente – e ridurre policy del timeline provider solo se necessario.

---

## Cosa cambierei concretamente (indicazioni operative)

- Nel target Widget, sostituire `WidgetStore` con un provider che usa `AppGroupManager.sharedModelContainer` per leggere `todayCount` e l’ultima sigaretta del giorno, similmente a `WidgetDataProvider.getTodayStats()`.
- Implementare l’intent di aggiunta nel widget richiamando `WidgetDataProvider.addCigaretteFromWidget()` (già pronto nel codice, ma non utilizzato dal widget attivo).
- Rimuovere `AddCigaretteIntent` placeholder o implementarlo davvero con inserimento in SwiftData condiviso.
- Eliminare `widget_pending_cigarettes` e metodi collegati se si adotta l’inserimento diretto.
- Facoltativo: se per qualsiasi motivo si preferisce UD, far leggere al widget `todayCount` e calcolare l’ora dell’ultima dal JSON in `cigarettes_yyyy-MM-dd` (chiavi già scritte da `SyncCoordinator`).

---

## Verifica finale attesa (post-fix)

- Aggiungo una sigaretta dall’App → `todayCount` e lista in SwiftData si aggiornano; il widget legge dalla stessa fonte e mostra 12; il Watch riceve via WCSession/UD e mostra 12; il widget rilegge e mostra 12.
- Aggiungo una sigaretta dal Widget → la `Cigarette` viene inserita in SwiftData (App Group); l’App (stesso store) e il Watch (via UD/Sync) mostrano 12; il widget rilegge e mostra 12.
- Aggiungo una sigaretta dal Watch → l’App salva, `SyncCoordinator` aggiorna UD e ricarica widget; widget e App mostrano 12.

---

## Note su entitlements e gruppi

- Tutti i target coinvolti dichiarano l’App Group `group.fightthestroke.mirrorsmoker` nei rispettivi `.entitlements` (coerente).
- Persistenza SwiftData dell’App è correttamente collocata nell’App Group (compatibile con condivisione al widget).

---

## File e righe utili (non esaustivo)

- Widget
  - `MirrorSmokerStopper Widget/MirrorSmokerStopper_WidgetBundle.swift` (bundle @main)
  - `MirrorSmokerStopper Widget/MirrorSmokerStopper_Widget.swift` (widget attivo)
  - `MirrorSmokerStopper Widget/WidgetStore.swift` (chiavi `widget_*`, coda pending non usata)
  - `MirrorSmokerStopper Widget/AddCigaretteIntent.swift` (placeholder)
  - `MirrorSmokerStopper Widget/CigaretteWidget.swift` (widget alternativo non @main)

- App
  - `MirrorSmokerStopper/Utilities/PersistenceController.swift` (SwiftData in App Group)
  - `MirrorSmokerStopper/Utilities/SyncCoordinator.swift` (`updateSharedUserDefaults()` → chiavi condivise per Watch)
  - `MirrorSmokerStopper/Views/ContentView.swift` (inserimento `Cigarette` e trigger sync)
  - `MirrorSmokerStopper/Utilities/AppGroupManager.swift` (`WidgetDataProvider.addCigaretteFromWidget()` già pronto per inserire dal widget)

- Watch
  - `MirrorSmokerStopper Watch App/SharedDataManager.swift`
  - `MirrorSmokerStopper Watch App/WatchConnectivityManager.swift`

---

## Conclusione

Il disallineamento nasce da due problemi principali: 1) il widget non usa la stessa fonte dati/chiavi dell’app e del Watch; 2) l’azione di aggiunta del widget non scrive nel database condiviso. Unificando la lettura/scrittura del widget al container SwiftData in App Group (o alle stesse chiavi UD) e collegando davvero l’intent di aggiunta all’inserimento in SwiftData, App/Widget/Watch mostreranno sempre lo stesso conteggio e lo stesso storico, con aggiornamenti in tempo reale.

