/* Theme toggle. Runs in <head> before paint so a dark-mode reader never gets
   flashed a white page on navigation. No dependencies, no external requests. */
(function () {
  var KEY = 'yaif-theme';

  function stored() {
    try { return localStorage.getItem(KEY); } catch (e) { return null; }
  }

  function apply(mode) {
    // Absent attribute means "follow the OS", which the stylesheet handles via
    // prefers-color-scheme. Only an explicit choice stamps the root.
    if (mode === 'dark' || mode === 'light') {
      document.documentElement.setAttribute('data-theme', mode);
    } else {
      document.documentElement.removeAttribute('data-theme');
    }
  }

  function isDark() {
    var s = stored();
    if (s) return s === 'dark';
    return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
  }

  apply(stored());

  document.addEventListener('DOMContentLoaded', function () {
    var btn = document.querySelector('.theme-toggle');
    if (!btn) return;

    function label() {
      btn.textContent = isDark() ? '☀ Light' : '☾ Dark';
      btn.setAttribute('aria-label', isDark() ? 'Switch to light theme' : 'Switch to dark theme');
    }

    label();
    btn.addEventListener('click', function () {
      var next = isDark() ? 'light' : 'dark';
      try { localStorage.setItem(KEY, next); } catch (e) {}
      apply(next);
      label();
    });
  });
})();
