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

### ios update_metadata

```sh
[bundle exec] fastlane ios update_metadata
```

📝 Update App Store metadata and descriptions

### ios upload_screenshots

```sh
[bundle exec] fastlane ios upload_screenshots
```

📱 Upload screenshots to App Store Connect

### ios build

```sh
[bundle exec] fastlane ios build
```

🔨 Build app for release

### ios beta

```sh
[bundle exec] fastlane ios beta
```

🚀 Submit to TestFlight

### ios release

```sh
[bundle exec] fastlane ios release
```

🏪 Submit to App Store

### ios clean

```sh
[bundle exec] fastlane ios clean
```

🧹 Clean up build artifacts

### ios info

```sh
[bundle exec] fastlane ios info
```

📊 Generate app info report

### ios deploy

```sh
[bundle exec] fastlane ios deploy
```

🔄 Complete deployment workflow

### ios deploy_simple

```sh
[bundle exec] fastlane ios deploy_simple
```

📝 Deploy SIMPLE version metadata

### ios deploy_full

```sh
[bundle exec] fastlane ios deploy_full
```

📝 Deploy FULL version metadata

### ios show_config

```sh
[bundle exec] fastlane ios show_config
```

🔍 Show configuration for version

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
