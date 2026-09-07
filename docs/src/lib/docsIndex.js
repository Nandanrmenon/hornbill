const modules = import.meta.glob('../content/**/*.mdx', { eager: true })

export function normalizeDocs(rawModules) {
  return Object.entries(rawModules)
    .map(([path, mod]) => {
      const slug = path
        .replace('../content/', '')
        .replace(/\.mdx$/, '')

      const meta = mod.meta ?? {}
      return {
        slug,
        title: meta.title ?? slug.split('/').pop(),
        description: meta.description ?? '',
        category: meta.category ?? 'Guides',
        order: meta.order ?? 999,
        widget: meta.widget ?? null,
        component: mod.default,
      }
    })
    .sort((a, b) => a.order - b.order || a.title.localeCompare(b.title))
}

export const docs = normalizeDocs(modules)

export const docsBySlug = docs.reduce((acc, doc) => {
  acc[doc.slug] = doc
  return acc
}, {})

export const docsByCategory = docs.reduce((acc, doc) => {
  if (!acc[doc.category]) {
    acc[doc.category] = []
  }

  acc[doc.category].push(doc)
  return acc
}, {})
