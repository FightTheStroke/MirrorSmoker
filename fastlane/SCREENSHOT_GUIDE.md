# 📱 Screenshot Management Guide

## 🎯 Struttura Corretta

La struttura degli screenshot è ora organizzata correttamente:

```
fastlane/screenshots/
├── iPhone/
│   ├── it/         # Screenshot iPhone in italiano
│   ├── fr/         # Screenshot iPhone in francese  
│   ├── de/         # Screenshot iPhone in tedesco
│   ├── es/         # Screenshot iPhone in spagnolo
│   └── en/         # Screenshot iPhone in inglese
└── Watch/
    ├── it/         # Screenshot Apple Watch in italiano
    ├── fr/         # Screenshot Apple Watch in francese
    ├── de/         # Screenshot Apple Watch in tedesco  
    ├── es/         # Screenshot Apple Watch in spagnolo
    └── en/         # Screenshot Apple Watch in inglese
```

## 🚀 Come Usare

### 1. Aggiungi i tuoi screenshot
Metti i screenshot dal simulatore nelle cartelle appropriate:
- iPhone screenshots → `iPhone/{lingua}/`
- Apple Watch screenshots → `Watch/{lingua}/`

### 2. Esegui la conversione
```bash
./convert_screenshots.sh
```

### 3. Upload ad App Store Connect  
```bash
fastlane upload_screenshots
```

## 📐 Dimensioni Supportate

### iPhone (Portrait)
- **1290×2796** - iPhone 14/15/16 Pro Max (6.7")
- **1179×2556** - iPhone 14/15/16 Pro (6.1") 
- **1284×2778** - iPhone 12/13 Pro Max (6.7")
- **1170×2532** - iPhone 12/13 Pro (6.1")
- **1242×2688** - iPhone XS Max (6.5")
- **1125×2436** - iPhone X/XS (5.8")

### Apple Watch
- **558×452** - Series 10 (49mm)
- **502×410** - Series 8/9 (45mm)
- **484×396** - Series 7 (45mm)
- **430×352** - Series 8/9 (41mm)

## ✅ Funzionalità dello Script

- ✅ **Conversione automatica** alle dimensioni App Store corrette
- ✅ **Crop intelligente** per mantenere aspect ratio  
- ✅ **Backup automatico** dei file originali
- ✅ **Validazione finale** delle dimensioni
- ✅ **Report colorato** con dettagli

## 📋 Processo Completo

1. **Prendi screenshot** con i simulatori iPhone e Apple Watch
2. **Organizza per lingua** mettendo i file nelle cartelle corrette
3. **Esegui conversione** con `./convert_screenshots.sh`
4. **Verifica risultato** nel report finale
5. **Upload ad App Store** con `fastlane upload_screenshots`

---

🎉 **Sistema screenshot pronto per App Store submission!**