export default function Home() {
  return (
    <main className="container">
      <div className="hero">
        <h1>🎯 GitHub Workflow Blueprint</h1>
        <p className="subtitle">Web Example - Next.js Application</p>
      </div>

      <section className="card">
        <h2>✅ Setup Complete!</h2>
        <p>
          This is a minimal Next.js application pre-configured with the GitHub
          Workflow Blueprint for demonstration purposes.
        </p>
      </section>

      <section className="card">
        <h2>📝 Next Steps</h2>
        <ol>
          <li>
            <strong>Setup the blueprint:</strong> Run{' '}
            <code>./setup/wizard.sh</code> from repository root
          </li>
          <li>
            <strong>Convert plan to issues:</strong> Use the included{' '}
            <code>plan.json</code> file
          </li>
          <li>
            <strong>Follow the workflow:</strong> See <code>README.md</code>{' '}
            for step-by-step guide
          </li>
          <li>
            <strong>Test the automation:</strong> Create PRs and watch the
            magic happen!
          </li>
        </ol>
      </section>

      <section className="card">
        <h2>🧪 Quality Checks</h2>
        <p>Run these commands to verify everything works:</p>
        <pre>
          <code>{`pnpm run lint      # ESLint validation
pnpm run type-check # TypeScript check
pnpm run test       # Jest tests
pnpm run build      # Production build`}</code>
        </pre>
      </section>

      <section className="card">
        <h2>📚 Documentation</h2>
        <ul>
          <li>
            <a href="../../docs/QUICK_START.md">Quick Start Guide</a>
          </li>
          <li>
            <a href="../../docs/WORKFLOWS.md">Workflows Reference</a>
          </li>
          <li>
            <a href="../../docs/COMMANDS.md">Slash Commands</a>
          </li>
          <li>
            <a href="../../tests/scenarios.md">Test Scenarios</a>
          </li>
        </ul>
      </section>

      <footer className="footer">
        <p>
          Generated with{' '}
          <a
            href="https://claude.com/claude-code"
            target="_blank"
            rel="noopener noreferrer"
          >
            Claude Code
          </a>
        </p>
      </footer>
    </main>
  );
}
