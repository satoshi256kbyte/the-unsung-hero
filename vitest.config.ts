import { defineConfig } from "vitest/config";

export default defineConfig({
  resolve: {
    alias: {
      "@game": "/src/game",
      "@scenes": "/src/scenes",
      "@ui": "/src/ui",
    },
  },
  test: {
    globals: true,
    environment: "node",
    include: ["src/**/*.test.ts", "tests/unit/**/*.test.ts"],
    exclude: ["tests/e2e/**"],
    coverage: {
      provider: "v8",
      reporter: ["text", "lcov"],
      include: ["src/game/**"],
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 75,
      },
    },
  },
});
