import { render, screen } from '@testing-library/react'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { describe, expect, it } from 'vitest'
import { DocsLayout } from './DocsLayout'

describe('DocsLayout', () => {
  it('renders getting started mdx content with provided components', () => {
    render(
      <MemoryRouter initialEntries={['/docs/guides/getting-started']}>
        <Routes>
          <Route path="/docs/*" element={<DocsLayout />} />
        </Routes>
      </MemoryRouter>,
    )

    expect(screen.getByRole('heading', { level: 1, name: 'Getting Started' })).toBeInTheDocument()
    expect(screen.getByText('HButton preview')).toBeInTheDocument()
  })
})
