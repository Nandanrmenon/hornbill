import { useState } from 'react'

function ButtonPreview() {
  const [count, setCount] = useState(0)
  return (
    <button className="hb-preview-button" type="button" onClick={() => setCount((v) => v + 1)}>
      Tap me ({count})
    </button>
  )
}

function TextFieldPreview() {
  const [value, setValue] = useState('')
  return (
    <label className="hb-preview-field">
      <span>Email</span>
      <input value={value} onChange={(event) => setValue(event.target.value)} placeholder="you@hornbill.dev" />
    </label>
  )
}

function DialogPreview() {
  const [open, setOpen] = useState(false)
  return (
    <div>
      <button className="hb-preview-button" type="button" onClick={() => setOpen((v) => !v)}>
        {open ? 'Close Dialog' : 'Open Dialog'}
      </button>
      {open ? <div className="hb-preview-dialog">Hornbill dialog placeholder content.</div> : null}
    </div>
  )
}

const previewRegistry = {
  HButton: ButtonPreview,
  HTextField: TextFieldPreview,
  HDialog: DialogPreview,
}

export function WidgetPreview({ widget, title, code, children }) {
  const PreviewComponent = previewRegistry[widget]

  return (
    <section className="widget-preview">
      <header className="widget-preview__header">
        <h3>{title ?? widget ?? 'Widget preview'}</h3>
      </header>
      <div className="widget-preview__panel">
        {PreviewComponent ? <PreviewComponent /> : <p>Preview placeholder for {widget ?? 'this widget'}.</p>}
      </div>
      {code ? (
        <pre>
          <code>{code}</code>
        </pre>
      ) : (
        children
      )}
    </section>
  )
}
