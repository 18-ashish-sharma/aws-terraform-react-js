import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  build: {
    // build/ with hashed files under build/static/: the deploy step caches static/
    // for a year and serves everything else (index.html) with no-cache.
    outDir: 'build',
    assetsDir: 'static',
    sourcemap: false
  },
  test: {
    environment: 'jsdom',
    setupFiles: './src/setupTests.js'
  }
});
