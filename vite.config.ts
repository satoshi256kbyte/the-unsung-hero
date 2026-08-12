import { defineConfig } from "vite";

export default defineConfig({
  resolve: {
    alias: {
      "@game": "/src/game",
      "@scenes": "/src/scenes",
      "@ui": "/src/ui",
    },
  },
  build: {
    target: "es2022",
    outDir: "dist",
  },
  server: {
    port: 5173,
  },
});
