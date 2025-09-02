# Data Migration Guide - MirrorSmokerStopper

## Overview
The app now implements automatic data migration from the original database schema to version 2, ensuring that all user data is preserved during the upgrade process.

## Migration Process

### What happens on app launch:

1. **New Container Creation**: The app attempts to create the new `MirrorSmokerModel_v2` database
2. **Migration Check**: If the new database is empty, it checks for data in the old `MirrorSmokerModel` database
3. **Automatic Migration**: If old data is found, it automatically migrates:
   - All cigarette records with timestamps and notes
   - All tags with names and colors
   - Tag-cigarette relationships
   - User profile settings and preferences
   - Product information
4. **Migration Flag**: Sets a UserDefaults flag to prevent re-migration

### Database Versions:
- **Original**: `MirrorSmokerModel` (contains InsightHistory - CloudKit incompatible)
- **Version 2**: `MirrorSmokerModel_v2` (without InsightHistory - CloudKit compatible)

### What gets migrated:
- ✅ **Cigarettes**: All smoking records with timestamps and notes
- ✅ **Tags**: All custom tags with colors and names
- ✅ **Tag Relationships**: Cigarette-tag associations
- ✅ **User Profile**: Quit date, reduction settings, preferences
- ✅ **Products**: Custom cigarette products and pricing
- ❌ **InsightHistory**: Not migrated (stored in UserDefaults instead)

### For Developers:

#### Migration Logs:
The migration process provides detailed console logs:
```
🔄 Checking for data migration...
📦 Migrating X cigarettes...
🏷️ Migrating X tags...
👤 Migrating user profile...
🚬 Migrating X products...
✅ Migration completed successfully!
```

#### Fallback Strategy:
If migration fails, the app falls back to:
1. In-memory database (`MirrorSmokerModel_v2_memory`)
2. Fatal error if even fallback fails

#### Migration Safety:
- Original database remains untouched
- Migration only runs once (UserDefaults flag)
- New installations skip migration entirely
- CloudKit sync works properly with new schema

## Technical Details

### Schema Changes:
- **Removed**: `InsightHistory` model (CloudKit incompatible)
- **Maintained**: All core models (Cigarette, Tag, UserProfile, Product)
- **Alternative**: Insights now stored in UserDefaults for privacy

### CloudKit Compatibility:
The new schema is fully CloudKit compatible, enabling:
- Cross-device synchronization
- Automatic backups
- Offline-first data access

### Performance Impact:
- Migration runs only once per user
- Process is asynchronous and non-blocking
- Typically completes in under 1 second for normal datasets

## User Experience

### For Existing Users:
- App launches normally
- All data preserved and available immediately
- CloudKit sync begins working automatically
- No user action required

### For New Users:
- Clean installation with v2 schema
- CloudKit sync enabled from day one
- No migration process needed

## Troubleshooting

### If Migration Fails:
1. Check console logs for specific error messages
2. App will continue to work with fallback in-memory database
3. User can manually re-enter data if needed
4. Contact support with migration logs for assistance

### Migration Status Check:
```swift
let migrationCompleted = UserDefaults.standard.bool(forKey: "DataMigrationCompleted_v2")
```

### Force Re-migration (Development Only):
```swift
UserDefaults.standard.removeObject(forKey: "DataMigrationCompleted_v2")
```