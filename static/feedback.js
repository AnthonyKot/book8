/* Book 8 — reader signal.
 * One file: consent gate, GA4 loader, audio milestones, per-chapter vote widget.
 * Renders its own markup, so a page only needs the <script> tag.
 * Set MEASUREMENT_ID before this does anything. */
(function () {
  "use strict";
  var MEASUREMENT_ID = "G-VLGYJCPJ1K";      // Book 8 GA4 property
  var FORM_ACTION    = "";                   // TODO: Google Form formResponse URL (optional note)
  var FORM_FIELD_NOTE = "entry.000000000";   // TODO: the form's note field id
  var FORM_FIELD_CHAP = "entry.000000001";   // TODO: the form's chapter field id
  var CONSENT_KEY = "b8-consent", VOTE_KEY = "b8-vote-";

  var slug = (location.pathname.split("/").pop() || "index").replace(/\.html$/, "");
  function store(k, v) { try { v === undefined ? null : localStorage.setItem(k, v); } catch (e) {} }
  function read(k) { try { return localStorage.getItem(k); } catch (e) { return null; } }

  /* ---- GA4, consent-gated -------------------------------------------- */
  window.dataLayer = window.dataLayer || [];
  function gtag() { dataLayer.push(arguments); }
  window.gtag = gtag;
  gtag("consent", "default", {
    ad_storage: "denied", ad_user_data: "denied", ad_personalization: "denied",
    analytics_storage: "denied", wait_for_update: 500
  });

  var loaded = false;
  function loadGA() {
    if (loaded || MEASUREMENT_ID.indexOf("X") > -1) return;
    loaded = true;
    var s = document.createElement("script");
    s.async = true;
    s.src = "https://www.googletagmanager.com/gtag/js?id=" + MEASUREMENT_ID;
    document.head.appendChild(s);
    gtag("js", new Date());
    gtag("config", MEASUREMENT_ID);
  }
  function grant() {
    gtag("consent", "update", { analytics_storage: "granted" });
    loadGA();
  }
  function track(name, params) {
    if (read(CONSENT_KEY) === "yes") gtag("event", name, params || {});
  }
  if (read(CONSENT_KEY) === "yes") grant();

  /* ---- consent banner ------------------------------------------------- */
  function banner() {
    if (read(CONSENT_KEY)) return;
    var b = document.createElement("div");
    b.className = "consent";
    b.innerHTML =
      '<p>This page can record anonymous counts: how far you read, whether you play the episode, ' +
      'and which way you vote. Nothing identifies you.</p>' +
      '<div class="consent-buttons">' +
      '<button type="button" data-c="yes">Allow</button>' +
      '<button type="button" data-c="no">No thanks</button></div>';
    b.addEventListener("click", function (e) {
      var c = e.target.getAttribute && e.target.getAttribute("data-c");
      if (!c) return;
      store(CONSENT_KEY, c);
      if (c === "yes") grant();
      b.remove();
    });
    document.body.appendChild(b);
  }

  /* ---- audio milestones ----------------------------------------------- */
  function audio() {
    var a = document.querySelector(".episode audio");
    if (!a) return;
    var hit = {};
    a.addEventListener("play", function () {
      if (!hit.start) { hit.start = 1; track("episode_play", { chapter: slug }); }
    });
    a.addEventListener("timeupdate", function () {
      if (!a.duration) return;
      var pct = a.currentTime / a.duration;
      [25, 50, 75].forEach(function (m) {
        if (pct >= m / 100 && !hit[m]) {
          hit[m] = 1;
          track("episode_progress", { chapter: slug, percent: m });
        }
      });
    });
    a.addEventListener("ended", function () {
      if (!hit.end) { hit.end = 1; track("episode_complete", { chapter: slug }); }
    });
  }

  /* ---- vote widget ----------------------------------------------------- */
  function vote() {
    var main = document.querySelector("main");
    if (!main || !document.querySelector(".episode, section")) return;
    var prior = read(VOTE_KEY + slug);
    var w = document.createElement("div");
    w.className = "vote";
    w.innerHTML = prior
      ? '<p class="vote-thanks">Thanks — noted.</p>'
      : '<p class="vote-ask">Was this chapter worth your time?</p>' +
        '<div class="vote-buttons">' +
        '<button type="button" data-v="up">Yes</button>' +
        '<button type="button" data-v="down">Not really</button></div>';
    w.addEventListener("click", function (e) {
      var v = e.target.getAttribute && e.target.getAttribute("data-v");
      if (!v) return;
      store(VOTE_KEY + slug, v);
      track("chapter_vote", { chapter: slug, vote: v });
      w.innerHTML =
        '<p class="vote-thanks">Thanks. Anything you would tell me in one line?</p>' +
        '<form class="vote-note"><input type="text" maxlength="280" ' +
        'placeholder="Optional — what landed, or what did not"><button type="submit">Send</button></form>';
      w.querySelector("form").addEventListener("submit", function (ev) {
        ev.preventDefault();
        var text = w.querySelector("input").value.trim();
        if (text && FORM_ACTION) {
          var body = new URLSearchParams();
          body.append(FORM_FIELD_NOTE, text);
          body.append(FORM_FIELD_CHAP, slug + " / " + v);
          fetch(FORM_ACTION, { method: "POST", mode: "no-cors", body: body }).catch(function () {});
        }
        w.innerHTML = '<p class="vote-thanks">Thank you.</p>';
      });
    });
    main.appendChild(w);
  }

  function init() { banner(); audio(); vote(); }
  document.readyState === "loading"
    ? document.addEventListener("DOMContentLoaded", init)
    : init();
})();
