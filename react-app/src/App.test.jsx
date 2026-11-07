import { afterEach, expect, test } from 'vitest';
import { cleanup, render, screen } from '@testing-library/react';
import App from './App';

afterEach(cleanup);

test('renders the page heading', () => {
  render(<App />);
  expect(screen.getByRole('heading', { name: /react on aws/i })).toBeInTheDocument();
});
