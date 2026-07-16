import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      "/api": {
        target:
          "http://ULAGOS-TIN-LAB3-ALB-81384851.us-east-1.elb.amazonaws.com",
        changeOrigin: true,
      },
    },
  },
});
