import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    include: [
      'src/**/*.test.js',
      'src/**/*.test.mjs',
      'backend/test/**/*.test.js',
    ],
    exclude: [
      '**/node_modules/**',
      '**/claude-code-starter-kit/**',
      '**/mafia_game/**',
      '**/dist/**',
    ],
  },
});
