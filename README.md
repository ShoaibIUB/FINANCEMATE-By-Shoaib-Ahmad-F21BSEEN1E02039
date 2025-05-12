# ![Financemate logo](logo@32.png) Financemate

## Preface

Financemate is a free, open-source, personal finance tracking app.

### Features

* Multiple accounts
* Multiple currencies
* Fully-offline
* Full export/backup
  * JSON for backup
  * CSV for external software use (i.e., Google Sheets)

## Supported platforms

* Android
* iOS

### Prerequisites

* [Flutter](https://flutter.dev/) (stable)

Other:

* JDK 21 if you're gonna build for Android
* [XCode](https://developer.apple.com/xcode/) if you're gonna build for iOS/macOS
* To run tests on your machine, see [Testing](#testing)

Building for Windows, and Linux-based systems requires the same dependencies
as Flutter. Read more on <https://docs.flutter.dev/platform-integration>

### Running
`flutter clean`
`flutter pub get`
`flutter run`

See more on <https://flutter.dev/>

### Testing

If you plan to run tests on your machine, ensure you've installed ObjectBox
dynamic libraries.

Install ObjectBox dynamic libraries[^2]:

`bash <(curl -s https://raw.githubusercontent.com/objectbox/objectbox-dart/main/install.sh)`

Testing:

`flutter test`

[^1]: Will be available on macOS, Windows, and Linux-based systems, but no plan
to enhance the UI for desktop experience for now.

[^2]: Please double-check from the official website, may be outdated. Visit
<https://docs.objectbox.io/getting-started#add-objectbox-to-your-project>
(make sure to choose Flutter to see the script).