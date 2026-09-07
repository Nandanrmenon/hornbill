import { Navigate, Route, Routes } from 'react-router-dom'
import { DocsLayout } from './components/DocsLayout'
import { docs } from './lib/docsIndex'

function App() {
  const defaultSlug = docs[0]?.slug ?? 'guides/getting-started'

  return (
    <Routes>
      <Route path="/" element={<Navigate to={`/docs/${defaultSlug}`} replace />} />
      <Route path="/docs/*" element={<DocsLayout />} />
    </Routes>
  )
}

export default App
