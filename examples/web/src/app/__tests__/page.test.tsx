import { render, screen } from '@testing-library/react';
import Home from '../page';

describe('Home Page', () => {
  it('renders the main heading', () => {
    render(<Home />);
    const heading = screen.getByRole('heading', {
      name: /github workflow blueprint/i,
    });
    expect(heading).toBeInTheDocument();
  });

  it('renders the setup complete message', () => {
    render(<Home />);
    expect(screen.getByText(/setup complete!/i)).toBeInTheDocument();
  });

  it('renders next steps section', () => {
    render(<Home />);
    expect(screen.getByText(/next steps/i)).toBeInTheDocument();
  });

  it('renders quality checks section', () => {
    render(<Home />);
    expect(screen.getByText(/quality checks/i)).toBeInTheDocument();
  });

  it('renders documentation links', () => {
    render(<Home />);
    expect(screen.getByText(/documentation/i)).toBeInTheDocument();
  });
});
