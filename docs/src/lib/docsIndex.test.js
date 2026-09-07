import { describe, expect, it } from 'vitest'
import { normalizeDocs } from './docsIndex'

describe('normalizeDocs', () => {
  it('builds sorted docs metadata from mdx modules', () => {
    const result = normalizeDocs({
      '../content/widgets/hbutton.mdx': {
        meta: { title: 'HButton', category: 'Widgets', order: 2 },
        default: () => null,
      },
      '../content/guides/getting-started.mdx': {
        meta: { title: 'Getting Started', category: 'Getting Started', order: 1 },
        default: () => null,
      },
    })

    expect(result.map((entry) => entry.slug)).toEqual(['guides/getting-started', 'widgets/hbutton'])
    expect(result[0].category).toBe('Getting Started')
  })
})
