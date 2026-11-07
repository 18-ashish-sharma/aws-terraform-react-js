import { render, screen } from '@testing-library/react';
import App from './App';

test('renders the page heading', () => {
  render(<App />);
  expect(screen.getByRole('heading', { name: /react on aws/i })).toBeInTheDocument();
});
