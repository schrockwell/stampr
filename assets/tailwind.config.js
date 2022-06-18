// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration
module.exports = {
  content: ["./js/**/*.js", "../lib/*_web.ex", "../lib/*_web/**/*.*ex"],
  theme: {
    colors: {
      flamingo: {
        DEFAULT: "#EF4444",
        50: "#F8DCAE",
        100: "#F7D1A2",
        200: "#F5B78A",
        300: "#F39673",
        400: "#F1705B",
        500: "#EF4444",
        600: "#E71431",
        700: "#B30F3D",
        800: "#800B3B",
        900: "#4C072D",
      },
    },
    extend: {},
  },
  plugins: [require("@tailwindcss/forms")],
};
