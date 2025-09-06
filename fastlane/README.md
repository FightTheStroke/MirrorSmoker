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

Generate new localized screenshots

### ios test

```sh
[bundle exec] fastlane ios test
```

Run tests

### ios sync_signing

```sh
[bundle exec] fastlane ios sync_signing
```

Setup automatic code signing (Xcode managed)

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build and upload to TestFlight

### ios release

```sh
[bundle exec] fastlane ios release
```

Deploy to App Store

### ios create_app

```sh
[bundle exec] fastlane ios create_app
```

Create App Store Connect app

### ios download_metadata

```sh
[bundle exec] fastlane ios download_metadata
```

Download metadata from App Store Connect

### ios upload_metadata

```sh
[bundle exec] fastlane ios upload_metadata
```

Upload only metadata to App Store Connect

### ios validate

```sh
[bundle exec] fastlane ios validate
```

Validate app before submission

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
