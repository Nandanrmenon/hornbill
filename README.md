Hornbill UI is a lightweight Flutter component package starter for building a consistent design system. Check out the [example app](https://hornbill-example.vercel.app/) for a demo of the components in action. Documentation coming soon.

## Features

- Material 3 theme helper with a seeded color palette.
- Reusable button variants for primary, secondary, and text-style actions.
- A simple card wrapper for content sections and surfaces.

### Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  hornbill: ^1.1.0
```

## Components

### Buttons

You can use normal buttons, icon buttons, or buttons with icons and text. The buttons are designed to be consistent with Material 3 design principles.

### Cards

The `HornbillCard` widget is a simple wrapper for content sections and surfaces. It provides a consistent look and feel for your app's UI.

### ListView

Material 3 ListView with headers and spacing. The `MListHeader` widget can be used to create section headers in your list.
`MListView` is a wrapper around `ListView` that provides a consistent look and feel for your app's UI.

### TextInputField
The `TextInputField` widget provides a simpler way to create text input fields with consistent styling and behavior. It supports various input types, validation, and customization options.

### Scaffold
The `HornbillScaffold` widget is a wrapper around the standard `Scaffold` widget which uses CustomScrollView and Slivers to provide a consistent look and feel for your app's UI. It also provides a simple way to create a consistent app bar and bottom navigation bar.

> [!CAUTION]
> You have to use Sliver based widgets inside the `HornbillScaffold` body. For example, you can use `SliverToBoxAdapter` to wrap non-sliver widgets.


## Additional information

The package is intentionally small so you can extend it with your own tokens, widgets, and layout primitives.
