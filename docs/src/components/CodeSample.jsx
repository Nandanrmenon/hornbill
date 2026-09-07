export function CodeSample({ language = 'dart', code = '' }) {
  return (
    <section className="code-sample">
      <div className="code-sample__header">{language}</div>
      <pre>
        <code>{code}</code>
      </pre>
    </section>
  )
}
