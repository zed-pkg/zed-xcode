# zed-xcode

Native Apple integration work for Zed Package Manager state, diagnostics, and confirmation-gated recommended actions.

The Swift package now contains:

- an injectable `zed inspect` process boundary with timeout, schema validation, redaction, and unsafe-action rejection;
- a multi-root workspace projection suitable for a SwiftUI companion dashboard;
- confirmation-gated command previews carrying exact executable, argv, and working directory;
- unit tests that run without launching or mutating a user's Xcode instance.

```sh
swift test
swift build -c release
```

The dedicated repository is established. Remaining distribution work is the SwiftUI companion app target, XcodeKit Source Editor Extension, App Group cache and entitlements, clean Xcode-instance tests, signing/notarization, and app/appex packaging.
