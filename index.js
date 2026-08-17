(function () {
  /* --------------------------------------------
     Tag pills.

     Searching is `@rheo/rookery-search`'s job now — its bar matches ids and
     titles across the whole rookery and navigates to an idea's page, so the
     text field this file used to filter with is gone. What is left is the one
     thing the package's bar cannot do: narrow what is already on the page.

     Each window is wrapped in a `.listing-window` carrying `data-tags`, because
     `.idea-window` — the element rookery emits — carries no tag classes of its
     own. Reading the wrapper is what lets a pill select a tag that cuts across
     sections (`malware`, `1990s`) and not just a whole section.
     -------------------------------------------- */
  var pills = document.querySelectorAll(".pill");
  var items = document.querySelectorAll(".listing-window");
  var sections = document.querySelectorAll("[data-section]");
  var countEl = document.getElementById("results-count");
  var activeFilter = "all";

  function tagsOf(el) {
    return (el.getAttribute("data-tags") || "").split(/\s+/);
  }

  function matchesFilter(el) {
    return activeFilter === "all" || tagsOf(el).indexOf(activeFilter) !== -1;
  }

  function update() {
    var visible = 0;

    for (var i = 0; i < items.length; i++) {
      var show = matchesFilter(items[i]);
      items[i].hidden = !show;
      if (show) visible++;
    }

    /* A section with nothing left in it goes away rather than leaving a bare
       heading behind. */
    for (var j = 0; j < sections.length; j++) {
      var kids = sections[j].querySelectorAll(".listing-window");
      var any = false;
      for (var k = 0; k < kids.length; k++) {
        if (!kids[k].hidden) {
          any = true;
          break;
        }
      }
      sections[j].hidden = !any;
    }

    if (countEl) {
      if (activeFilter === "all") {
        countEl.textContent = "";
      } else if (visible === 0) {
        countEl.textContent = "No entries tagged " + activeFilter;
      } else {
        countEl.textContent =
          "Showing " + visible + " of " + items.length + " entries tagged " + activeFilter;
      }
    }
  }

  /* One selection across BOTH pill rows — the groupings and the subjects — so
     clicking a subject clears the grouping and vice versa. */
  function select(pill) {
    for (var q = 0; q < pills.length; q++) {
      pills[q].classList.remove("active");
    }
    pill.classList.add("active");
    activeFilter = pill.getAttribute("data-filter");
    update();
  }

  for (var p = 0; p < pills.length; p++) {
    pills[p].addEventListener("click", function () {
      select(this);
    });
  }

  /* `index.html#malware` opens on that tag, so a filtered view can be linked
     to. Ignored when the fragment names no pill — it is then an ordinary
     same-page anchor and belongs to the browser. */
  function applyHash() {
    var want = (window.location.hash || "").replace(/^#/, "");
    if (!want) return;
    for (var i = 0; i < pills.length; i++) {
      if (pills[i].getAttribute("data-filter") === want) {
        select(pills[i]);
        return;
      }
    }
  }

  if (pills.length) {
    applyHash();
    window.addEventListener("hashchange", applyHash);
  }

  /* --------------------------------------------
     Wordmark: every cell scrambles once, holds a beat, then the letters of
     "Hacker Archives" lock in one at a time in random order, turning black as
     they land. Holds legible, then scrambles again.
     -------------------------------------------- */
  /* Symbols only — no digits, no letters, and no underscore (the caret owns it) */
  var CHARSET = "@^?!;:%-=/&$*<>+#\\|~".split("");
  var LOGO_TEXT = "Hacker Archives";
  var SCRAMBLED_HOLD_MS = 900; /* beat with everything scrambled */
  var LOCK_STEP_MS = 240; /* pause between one letter landing and the next */
  var RESOLVED_HOLD_MS = 3000; /* legible before it scrambles again */

  var reduceMotion =
    window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var allCells = document.querySelectorAll(".logo-glyphs .glyph");

  /* The caret cell is the space in "Hacker Archives" and never scrambles, so
     the cell count has to match the text for the targets to line up. */
  var aligned = allCells.length === LOGO_TEXT.length;
  var cells = [];
  for (var c = 0; c < allCells.length; c++) {
    if (!allCells[c].classList.contains("cursor")) {
      cells.push({ node: allCells[c], target: LOGO_TEXT.charAt(c) });
    }
  }

  /* Fisher-Yates, in place. */
  function shuffle(list) {
    for (var i = list.length - 1; i > 0; i--) {
      var k = Math.floor(Math.random() * (i + 1));
      var swap = list[i];
      list[i] = list[k];
      list[k] = swap;
    }
    return list;
  }

  /* A locked cell shows its letter and, via CSS, turns black. */
  function lock(cell) {
    cell.node.textContent = cell.target;
    cell.node.classList.add("locked");
  }

  function unlock(cell, glyph) {
    cell.node.textContent = glyph;
    cell.node.classList.remove("locked");
  }

  function resolveLogo() {
    for (var i = 0; i < cells.length; i++) {
      lock(cells[i]);
    }
  }

  /* One pass, no flicker: cells deal from a shuffled pool, so a symbol never
     appears twice in the same scramble. Wraps only if the charset is ever
     shorter than the wordmark, where repeats are unavoidable. */
  function scrambleAll() {
    var pool = shuffle(CHARSET.slice());
    for (var i = 0; i < cells.length; i++) {
      unlock(cells[i], pool[i % pool.length]);
    }
  }

  /* A fresh reveal order each cycle. */
  function shuffledIndices(n) {
    var order = [];
    for (var i = 0; i < n; i++) {
      order.push(i);
    }
    return shuffle(order);
  }

  /* Hidden tabs throttle timers, so wait rather than advance while backgrounded. */
  function step(fn, delay) {
    window.setTimeout(function () {
      if (document.hidden) {
        step(fn, delay);
        return;
      }
      fn();
    }, delay);
  }

  function cycle() {
    scrambleAll();
    var order = shuffledIndices(cells.length);
    var at = 0;

    function lockNext() {
      lock(cells[order[at]]);
      at++;
      if (at < order.length) {
        step(lockNext, LOCK_STEP_MS);
      } else {
        step(cycle, RESOLVED_HOLD_MS);
      }
    }

    step(lockNext, SCRAMBLED_HOLD_MS);
  }

  if (cells.length && aligned) {
    if (reduceMotion) {
      /* No motion: show the wordmark plainly rather than a frozen scramble. */
      resolveLogo();
    } else {
      cycle();
    }
  }
})();
