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

Generate screenshots for all device types and languages

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
