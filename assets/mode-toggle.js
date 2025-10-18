(function() {
  const THEME_KEY = 'theme';
  const DARK_THEME = 'dark';
  const LIGHT_THEME = 'light';

  function getStoredTheme() {
    return localStorage.getItem(THEME_KEY);
  }

  function setStoredTheme(theme) {
    localStorage.setItem(THEME_KEY, theme);
  }

  function getPreferredTheme() {
    const storedTheme = getStoredTheme();
    if (storedTheme) {
      return storedTheme;
    }
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? DARK_THEME : LIGHT_THEME;
  }

  function setTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
  }

  function toggleTheme() {
    const currentTheme = document.documentElement.getAttribute('data-theme') || LIGHT_THEME;
    const newTheme = currentTheme === DARK_THEME ? LIGHT_THEME : DARK_THEME;
    setTheme(newTheme);
    setStoredTheme(newTheme);
  }

  function init() {
    const theme = getPreferredTheme();
    setTheme(theme);

    const button = document.getElementById('mode-toggle');
    if (button) {
      button.addEventListener('click', toggleTheme);
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
    if (!getStoredTheme()) {
      setTheme(e.matches ? DARK_THEME : LIGHT_THEME);
    }
  });
})();
