import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { WidgetPreview } from './WidgetPreview'

describe('WidgetPreview', () => {
  it('shows a placeholder when widget preview is not registered', () => {
    render(<WidgetPreview widget="HUnknown" />)

    expect(screen.getByText('Preview placeholder for HUnknown.')).toBeInTheDocument()
  })
})
