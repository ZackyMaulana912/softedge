# RoundedCorners

A small macOS menu bar app that makes the bottom corners of a MacBook's built-in screen look rounded, similar to the curved display corners on newer OLED laptops.

It works by drawing a pure black overlay in the two bottom corners. On a mini-LED or OLED panel, black pixels blend into the bezel, so the screen appears to have rounded corners. This is a visual effect only: the physical panel stays square.

## Features

- Black overlay in the two bottom corners of the built-in display only, never on external monitors
- Apple style continuous curve (squircle)
- Corners stay visible while swiping between desktops and over full screen apps
- Menu bar popover with an on/off switch, a corner radius slider (8 to 40 pt) with live preview, launch at login, and an option to hide the menu bar icon
- Very light: about 340 KB on disk, 0% CPU while idle, around 15 MB of memory at start and around 35 MB after the settings have been opened

## Requirements

- Mac with Apple Silicon and macOS 15 or later
- Made for MacBooks with a notch and a mini-LED display. Tested on a 14 inch MacBook Pro (M5). Other Apple Silicon MacBooks should work, but on LCD screens the black corners can look slightly grey.

## Install

1. Download `RoundedCorners-<version>.dmg` from the [Releases](../../releases) page.
2. Open the DMG and drag `RoundedCorners` into `Applications`.
3. Open the app. macOS will block it the first time, because it is not signed with a paid Apple Developer ID. To allow it:
   - Open **System Settings > Privacy & Security**, scroll down and click **Open Anyway** next to the RoundedCorners message, or
   - run this once in Terminal:

     ```bash
     xattr -dr com.apple.quarantine /Applications/RoundedCorners.app
     ```

The app has no Dock icon. Click its icon in the menu bar to change settings or quit.

If you hide the menu bar icon, open RoundedCorners again from Spotlight or Launchpad to bring the settings back.

On a crowded menu bar, macOS hides icons that do not fit next to the notch. If the icon seems to be missing, close a few other menu bar apps.

## Build from source

Requires Xcode with Swift 6 and [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`). The Xcode project is generated from `project.yml` and is not checked in.

```bash
xcodegen generate
xcodebuild -project RoundedCorners.xcodeproj -scheme RoundedCorners -configuration Debug -derivedDataPath build build
open build/Build/Products/Debug/RoundedCorners.app
```

To create the DMG for a release:

```bash
./scripts/make-dmg.sh
```

The DMG is written to `build/RoundedCorners-<version>.dmg`. The version comes from `CFBundleShortVersionString` in `project.yml`.

## How it works

- Each corner is a tiny borderless window that ignores mouse clicks and sits above other windows. There is no full-screen window.
- The curve comes from SwiftUI's `RoundedRectangle(cornerRadius:style: .continuous)`, so it matches the shape Apple uses. Because a continuous curve starts bending earlier than a circle, each window is about 1.53 times the radius.
- The windows ask macOS to keep them out of screenshots and screen recordings.
- The overlay only appears on the built-in display, detected with `CGDisplayIsBuiltin`, and follows resolution and scaling changes.
- Settings are stored in `UserDefaults`. Launch at login uses `SMAppService` and its state is read from the system.

Constants for comparing variants:

| Constant | File | Effect |
| --- | --- | --- |
| `CornerStyle.current` | `Sources/Overlay/CornerStyle.swift` | `.continuous` or `.circular` |
| `OverlaySpace.isEnabled` | `Sources/Overlay/OverlaySpace.swift` | Use the dedicated space described below |

## Known limitations

- **Private API.** By default, macOS briefly hides windows that appear on all desktops while you swipe between them. To avoid this, the corner windows are placed in a dedicated window server space created with private SkyLight functions (`CGSSpaceCreate` and related). These are undocumented and may stop working in a future macOS update. They are loaded at runtime, so if they go missing the app keeps running and the corners simply flicker again during swipes.
- **Not notarized.** Without a paid Apple Developer account the app cannot be notarized, so macOS asks for permission on first launch (see Install).
- **Launch at login points to one copy.** It registers the copy of the app that turned it on. If you move to a different copy, turn the option off in the old one first, or remove the old entry in System Settings > General > Login Items.
- **Hidden icon with launch at login.** If the icon is hidden and launch at login is on, opening the app from Spotlight while it is not running starts it silently. Open it a second time to see the settings.
- **Screenshot exclusion is not guaranteed.** Recent macOS versions do not always honor the request to hide windows from screenshots.
- **Top corners are not covered.** On notched MacBooks the top corners are already rounded by the panel.

## Project layout

```
project.yml          XcodeGen spec (source of truth for the Xcode project)
scripts/
  make-dmg.sh        Release build packed into a DMG
Sources/
  App/               entry point, app delegate, observation helper
  Overlay/           corner windows, drawing, and the dedicated space
  MenuBar/           menu bar item, settings popover, custom on/off switch
  Settings/          stored settings and launch at login
Resources/
  Info.plist         generated by XcodeGen from project.yml
  Assets.xcassets
```
