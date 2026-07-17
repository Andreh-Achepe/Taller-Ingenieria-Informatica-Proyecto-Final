import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      "/api": {
        target:
          "http://ulagos-tin-lab3-alb-2074507711.us-east-1.elb.amazonaws.com",
        changeOrigin: true,
      },
    },
  },
});
