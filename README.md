# Takehome

## Running this project
- Be on a macOS machine
- Be using Xcode 15
- Clone the project
- Open `EverythingButTheBagel.xcodeproj`
- Packages will start downloading automatically
- Run the project on an iOS 17 device or simulator

## Project Structure
- The project is broken up into modules in the form of Swift Packages. Each feature gets two modules, one for business logic and one for UI Components.
- There are also three packages with shared resources used by the other modules.
  - `EverythingButTheBagelCore` contains utilities and general purpose reducers.
  - `Sprinkles` contains general purpose UI components.
  - `GarlicTestUtils` (within `EverythingButTheBagelCore`) contains utilities for unit and integration testing.
- Business logic packages have high test coverage.
- This structure helps with build time as the project scales because developers can work within a single package, and the compiler can more effectively cache for incremental builds.

## UI
- During loading, a spinner is displayed and shimmering placeholders are shown to the user.
- Example app icon and launch screen are included

## Architecture Notes
- This project uses [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) which is similar to other unidirectional dataflow architectures like [Redux](https://redux.js.org/). It makes use of reducers, stores, and state machines with a focus on testability.
- The core set of reducers are split into `ViewModel`s and `DataSource`s so that views can rely exclusively from `ViewModel`s. There are a range of benefits to this setup, a primary one being that previews become very easy configure.
- Full app state is cached to and read from disk on startup. As the app expands there would be additional security and performance concerns with this setup that are not addressed here.
  - Because `ViewModel`s are used, in addition to the data model, view state is also cached including small things like scroll position. When the user opens the app, we want them to be able to pick up right where they left off.
  - Out of the box, SwiftUI doesn't allow developers to track and set absolute scroll position programatically, so I created [a package for that](https://github.com/twof/ControllableScrollView).

## Networking
- HTTP fetches are performed by `HTTPDataSourceReducer` which is optimized for reusability. Any reducer which has some HTTP dependency would be expected to use it.
  - It uses the built-in `URLCache`. `URLCache` has some downsides (documented in code) and I'd expect to replace it with something else eventually.
  - It handles error logging for networking related activities.
  - It performs expotential backoff retries up to a configured maximum number and is responsive to task cancellation.

## Logging
- [Sentry](https://sentry.io/welcome/) is being used as the remote logging service. There are many other services that do effectively the same thing, but this is one I've liked in the past.
- I've found remote logging useful for debugging problems that happen in the field. There were many instances at Pronto and Yelp where remote logging was used to identify bugs before they were reported by users and to help us determine their prevelance.
- Locally, [OSLog](https://www.avanderlee.com/debugging/oslog-unified-logging/) is used as recommened by Apple.

## Testing
- A [dependency container](https://github.com/pointfreeco/swift-dependencies) is used for injection. The way it's configured prevents any live dependencies from being exercised in unit tests, and any attempt causes the test to immediately fail.
- There is another target for integration tests which exercise live dependencies. This target would not be run on a regular basis and never in CI. It's primarily to give developers an easy way to exercise live dependencies (ie network requests) without needing to navigate a full app.
- I'm also using a library I wrote called [FunctionSpy](https://github.com/twof/FunctionSpy?tab=readme-ov-file), which allows me to test against the usage of dependencies. It was inspired by some features I missed from Pytest.

## Development Environment
- Code is hosted on Github.
- When a PR is opened, Github Actions are triggered that run the unit test target of the core package.
  - Build artifacts are cached to allow for faster subsequent builds to save time and money.
  - Github actions run on a macOS instance because The Composable Architecture relies on Combine which has not been ported to Linux yet. Once that happens, unit tests could be run on a Linux instance which is much cheaper.
- Additionally, an Xcode Cloud pipeline is set up to archive the app and release to TestFlight
- Locally, swiftlint presents warnings in Xcode to enforce a consistent coding style in the project.
- Pre-commit hooks are installed.
  - Swiftlint is also run on commit to catch edits performed outside of Xcode and to ensure committed code meets style standards.
  - A tool I created called [Downstream](https://github.com/twof/Downstream) is run on commit. Downstream alerts users when changes might indicate a need for docs to be updated. For example, changes to `Package.swift` could indicate a new dependency has been added and I should probably talk about it in the README.

## Future Directions
- The UI is very simple. A lot of opportunity for design improvement there.
