# Roadmap

Questo documento traccia il piano per implementare e iterare su Mirror Smoker.

## Milestone 1 — Foundations
- [x] SwiftData models: Cigarette, Tag, UserProfile, Product
- [x] CloudKit SwiftData configuration
- [x] Tagging UI (TagPicker) con create/select e palette colori
- [x] Mostra i tag nella lista di oggi come chip colorati
- [x] Swipe right (leading) su una riga per aggiungere/modificare tag
- [x] Eliminazione entry con swipe left (trailing)
- [x] Realtime sync (iOS ↔︎ watchOS) per add/delete e tag upsert via ConnectivityManager
- [x] Advanced Analytics (weekday/hour/tag)
- [x] Localizzazione EN/IT (chiavi iniziali; da espandere)
- [x] App Intents (AddCigaretteIntent)
- [x] Widget (conteggio odierno + pulsante aggiungi)
- [x] Watch app target (wire existing WatchContentView)

Note:
- Sincronizzazione tag: ConnectivityManager esegue upsert all’arrivo di CigaretteDTO, risolvendo/creando tag per nome e assegnando le relazioni.
- La creazione di Tag persiste immediatamente via SwiftData ed è riflessa da @Query in ContentView.
- WidgetStore gestisce snapshot (today count + last time) e inbox per quick add.

Open tasks residui su M1:
- [ ] Espandere localizzazione per nuove stringhe UI (TagPicker: “Create New Tag”, “Select Tags”, “Add Tag”, “Cancel”, “Done”; AdvancedAnalytics; WatchContentView)
- [ ] Verifica end-to-end della sync bidirezionale con tag su device reali (iOS ↔︎ watchOS)

## Milestone 2 — Profile & Catalog
- [ ] ProfileView (birthdate, sex, preferred products)
- [ ] ProductPicker con dataset curato; elementi custom
- [ ] Asset immagini per prodotti comuni
- [ ] Sign in with Apple (binding profilo)

## Milestone 3 — Siri & Shortcuts Enhancements
- [ ] Frasi più naturali (EN/IT) e parametri per tag
- [ ] Shortcut donations su azioni chiave
- [ ] Intent per aggiunta rapida con tag multipli e nota

## Milestone 4 — Gamification & Insights
- [ ] Motivation Engine: dataset iniziale (messaggi/scenari)
- [ ] Motivation Engine: logica base di selezione messaggi
- [ ] Streaks, trend, obiettivi di riduzione
- [ ] Raccomandazioni e reminder basati sui tag

## Milestone 5 — Widget & Watch Improvements
- [ ] Widget: parametri/azioni con tag dal widget
- [ ] Widget: ottimizzazioni snapshot/timeline su cambi dati
- [ ] watchOS: complication (facoltativo)
- [ ] watchOS: quick stats e micro-interazioni aggiuntive

## Milestone 6 — Polish & QA
- [ ] Accessibility pass (VoiceOver, Dynamic Type, colori)
- [ ] Performance tuning (query, rendering liste, Charts)
- [ ] Test (Swift Testing): unit e UI smoke tests
- [ ] Store metadata (se distribuzione prevista)

## Test & Quality (trasversale)
- [ ] Test ConnectivityManager: upsert/merge con tag (Swift Testing)
- [ ] Test WidgetStore: snapshot/inbox e round-trip con ContentView
- [ ] Test TagPicker: creazione tag, selezione/deselezione, persistenza
- [ ] Test AdvancedAnalytics: aggregazioni orarie/settimanali/tag

Open Tasks / Next Steps
- [ ] Verificare la sincronizzazione realtime bidirezionale inclusi i tag su iOS e watchOS (device fisici)
- [ ] Espandere le chiavi di localizzazione per le nuove stringhe UI (es. “Aggiungi tag”, “Select Tags”, “Create New Tag”, “Advanced Analytics”, Watch strings)
- [ ] Aggiungere test per la logica di upsert/merge di ConnectivityManager con tag usando Swift Testing
- [ ] Valutare complication su watchOS e intent/widget con parametri tag
- [ ] Pianificare Sign in with Apple e binding profilo (Milestone 2)
