fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Generate screenshots for iPhone and Apple Watch with iOS 26 features

### ios screenshots_marketing

```sh
[bundle exec] fastlane ios screenshots_marketing
```

Genera screenshots + frame con titoli marketing

### ios screenshots_marketing_ai

```sh
[bundle exec] fastlane ios screenshots_marketing_ai
```

Screenshots + frame + badge AI Powered

### ios store_assets_full

```sh
[bundle exec] fastlane ios store_assets_full
```

Pipeline completa: screenshots (iPhone+Watch), normalizza, frame, badge, validazione

### ios fix_screenshot_sizes

```sh
[bundle exec] fastlane ios fix_screenshot_sizes
```

Solo normalizza dimensioni screenshot (senza rigenerarli)

### ios screenshots_quick

```sh
[bundle exec] fastlane ios screenshots_quick
```

Generate screenshots quickly for development

### ios screenshots_and_upload

```sh
[bundle exec] fastlane ios screenshots_and_upload
```

Generate screenshots and upload to App Store Connect

### ios upload_metadata

```sh
[bundle exec] fastlane ios upload_metadata
```

Upload metadata and screenshots to App Store Connect

### ios upload_ready_for_submission

```sh
[bundle exec] fastlane ios upload_ready_for_submission
```

Upload app binary and metadata without screenshots - ready for manual submission

### ios upload_to_app_store

```sh
[bundle exec] fastlane ios upload_to_app_store
```

Upload built app and metadata to App Store Connect (ready for manual submission)

### ios submit_for_review

```sh
[bundle exec] fastlane ios submit_for_review
```

Complete App Store submission ready for review - builds, uploads binary and metadata

### ios test

```sh
[bundle exec] fastlane ios test
```

Run tests and build the app

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build and upload to TestFlight

### ios release

```sh
[bundle exec] fastlane ios release
```

Build and release to App Store

### ios cleanup

```sh
[bundle exec] fastlane ios cleanup
```

Clean up build artifacts and old screenshots

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
