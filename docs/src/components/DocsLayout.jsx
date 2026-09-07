import { MDXProvider } from '@mdx-js/react'
import { NavLink, useParams } from 'react-router-dom'
import { CodeSample } from './CodeSample'
import { WidgetPreview } from './WidgetPreview'
import { docs, docsByCategory, docsBySlug } from '../lib/docsIndex'

const mdxComponents = {
  WidgetPreview,
  CodeSample,
}

const categoryOrder = ['Getting Started', 'Widgets']

export function DocsLayout() {
  const defaultDoc = docs[0]
  const params = useParams()
  const slug = params['*'] || defaultDoc.slug
  const page = docsBySlug[slug] ?? defaultDoc
  const Content = page.component

  return (
    <div className="docs-shell">
      <aside className="docs-sidebar">
        <div className="brand">
          <strong>Hornbill UI</strong>
          <p>Flutter widget frame docs</p>
        </div>

        <nav>
          {categoryOrder.map((category) => {
            const entries = docsByCategory[category] ?? []
            if (!entries.length) {
              return null
            }

            return (
              <section key={category} className="nav-group">
                <h2>{category}</h2>
                {entries.map((entry) => (
                  <NavLink
                    key={entry.slug}
                    to={`/docs/${entry.slug}`}
                    className={({ isActive }) => (isActive ? 'active' : '')}
                  >
                    {entry.title}
                  </NavLink>
                ))}
              </section>
            )
          })}
        </nav>
      </aside>

      <main className="docs-content">
        <header className="docs-content__header">
          <p className="eyebrow">Widget details</p>
          <h1>{page.title}</h1>
          {page.description ? <p>{page.description}</p> : null}
        </header>

        <MDXProvider components={mdxComponents}>
          <article>
            <Content />
          </article>
        </MDXProvider>
      </main>
    </div>
  )
}
