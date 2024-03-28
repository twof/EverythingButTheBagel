# Takehome

## Running this project
- Be on a macOS machine
- Be using Xcode 15
- Clone the project
- Open `EverythingButTheBagel.xcodeproj`
- Packages will start downloading automatically
- Run the project on an iOS 17 device or simulator

## Architecture Notes
- This project uses The Composable Architecture which is similar to other unidirectional dataflow architectures like Redux. It makes use of reducers, stores, and state machines with a focus on testability.
- Full app state is cached to and read from disk on startup. As the app expands there would be additional security and performance concerns with this setup that are not addressed here.
- Code is separated into a core, platform agnostic package to contain all business logic and tests, and a parent project that contains platform-specific and UI code.
  - It's expected that as much logic as possible is put into the core package and that UI code is never put in the core package to optimize for testability and coverage.
- The selected architecture is good regardless of the UI framework in use, but as you can see from the amount and quality of the code, it's much more cleanly integrated into SwiftUI.

## Logging
- Sentry is being used as the remote logging service. There are many other services that do effectively the same thing, but this is one I've liked in the past.
- I've found remote logging useful for debugging problems that happen in the field. There were many instances at Pronto and Yelp where remote logging was used to identify bugs before they were reported by users, and to help us determine their prevelance.

## Testing
- A dependency container is used for injection. The way it's configured prevents any live dependencies from being exercised in unit tests, and any attempt causes the test to immediately fail.
- There is another target for integration tests which exercise live dependencies. This target would not be run on a regular basis and never in CI. It's primarily to give developers an easy way to exercise live dependencies (ie the websocket connection) without needing to navigate a full app.
- I'm also using a library I wrote called [FunctionSpy](https://github.com/twof/FunctionSpy?tab=readme-ov-file), which allows me to test against the usage of dependencies.

## Future Directions
- The UI is very simple. A lot of opportunity for design improvement there.
- Loading is super quick on localhost, but with more latency we're going to want some sort of loading indicator
- All of the standard infrastructure: CI, automated releases, etc
