## 1.5.2

- Fixed all of `HListView` and similar widgets to use `dense` property for better spacing and layout control.

## 1.5.1

- Fixed vercel build command to include `--no-tree-shake-icons` flag for proper icon rendering in the example app.

## 1.5.0

- Example app updated to docs in https://hornbill-example.vercel.app/
- Added `HDialog` with support child, title, actions, and onDismiss callback.
- Improvements to `HSideBarItem` to support better tint, which is better system status visibility.
- Added Icon browser in example app.
- Fixed weird size issues in `HButton` and `HIconButton`.
- Example app has now color changer.

## 1.4.5

- Fixes `HTextField` to include inputFormatters, maxLength, onEditingComplete, and onChanged

## 1.4.4

- Added `HToast` widget for displaying toast messages.
- Renamed all widgets to remove `Hornbill` prefix and replace it with `H` for consistency and clarity.

## 1.4.3

- Improved `HAppBar` to be responsive for both mobile and desktop with extensive features.
- Improved `HScaffold` to accomodate floating and pinned `HAppBar`.

## 1.4.2

- Added `HSideBarAccountTile` widget for sidebar

## 1.4.1

- Migrate to `material_ui` package as a part of Flutter 3.47 upgrade.

## 1.4.0

- Added `HSideBar` widget for sidebar with navrail support.
- Added `HChip` widget for displaying chips/labels.
- Improved `example` app to include a sidebar and a new chip page.

## 1.3.3

- Update `pubsec.yaml`

## 1.3.2

- Added `HColourScheme` for easily switching between different color schemes in the app.

## 1.3.1

- Use `RadioGroup` to avoid deprecated member.
- Code Cleanup.

## 1.3.0

- Added `HButton` and `HIconButton` widgets for creating buttons.
- Added `HNavigationBar` widget for creating a navigation bar with customizable items and actions.
- Added `HAppBar`. (buggy)
- New `HProgressIndicator` widget for displaying progress in a linear format.
- New `HornbillSwitch` widget for toggling between two states.
- The example app can now copy code snippets to the clipboard for easy integration into your own projects (beta).

## 1.2.0

- Added `HornbillDataTable` widget for displaying tabular data with sorting with customisation options.
- Added `HornbillPageNavigation` to navigate through pages of data in a paginated view.
- Renamed a bunch of widgets to remove the `M` prefix and replace it with `H` for consistency and clarity.

## 1.1.0

- Theme improvements: Updated the theme to use a seeded color palette for better consistency and customization.
- Improved ListView
- Added `HornbilScaffold` widget for consistent app structure and layout.

## 1.0.2

- Fix theme issue with seed color not being applied correctly.
- Update the description in pubspec.yaml to provide a more detailed overview of the package's purpose and features.

## 1.0.1

- Change `RSExtendedDataTable` to `ExtendedDataTable` and update the import path for constants.
- Change `HornbillUiTheme` to `HornbillTheme` and update the import path for constants.

## 0.0.1

- Intial release.
