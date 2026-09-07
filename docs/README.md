# Hornbill UI Docs (React + MDX)

This workspace provides a Node.js + React documentation site for Hornbill UI.

## Commands

```bash
npm install
npm run dev
npm run build
npm run test
npm run lint
```

## Authoring docs

- Add documentation pages as `.mdx` files under `src/content/**`.
- Each MDX file should export `meta` with `title`, `description`, `category`, and `order`.
- Use `<WidgetPreview />` to embed a widget preview panel.
- Use `<CodeSample />` to show usage snippets.

Example:

```mdx
export const meta = {
  title: 'HButton',
  category: 'Widgets',
  order: 10,
}

<WidgetPreview widget="HButton" code={`HButton(text: 'Save', onPressed: () {})`} />
```
