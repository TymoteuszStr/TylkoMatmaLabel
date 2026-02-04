// https://nuxt.com/docs/api/configuration/nuxt-config
import { fileURLToPath } from "url";
import { resolve, dirname } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

export default defineNuxtConfig({
  compatibilityDate: "2025-07-15",

  app: {
    head: {
      title: "TylkoMatmaOnline - Nauka matematyki online",
      htmlAttrs: {
        lang: "pl",
      },
      meta: [
        {
          name: "description",
          content:
            "Kompleksowa platforma edukacyjna do nauki matematyki. Materiały, testy i śledzenie postępów dla uczniów liceum.",
        },
        { name: "viewport", content: "width=device-width, initial-scale=1" },
      ],
      link: [{ rel: "icon", type: "image/x-icon", href: "/favicon.ico" }],
    },
  },

  devtools: { enabled: true },

  modules: [
    "@nuxt/content",
    "@nuxt/eslint",
    "@nuxt/hints",
    "@nuxt/image",
    "@nuxt/scripts",
    "@nuxt/ui",
    "@nuxtjs/supabase",
    "@pinia/nuxt",
  ],

  css: ["~/assets/css/main.css"],

  ssr: true,

  // Color mode configuration (dark mode)
  colorMode: {
    preference: "light",
    fallback: "light",
    classSuffix: "",
  },

  alias: {
    "@": "..",
  },

  vite: {
    resolve: {
      alias: {
        "@": resolve(__dirname, "."),
      },
    },
  },

  // IMPORTANT: Disable automatic Supabase redirects
  supabase: {
    redirect: false,
  },

  // Runtime config for environment variables
  runtimeConfig: {
    public: {
      supabaseUrl: process.env.SUPABASE_URL,
      supabaseKey: process.env.SUPABASE_KEY,
    },
  },
});
