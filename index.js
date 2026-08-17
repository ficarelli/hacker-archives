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

  /* Any number of pills can be live at once, kept in two lists because the two
     rows combine differently:

       OR within a row, AND across the two.

     So `Books + Films` widens — both groupings show — while `Books + Malware`
     narrows to books about malware. The other two readings are both worse:
     AND everywhere makes `Books + Films` empty, since nothing is filed as both,
     and OR everywhere makes `Books + Malware` mean "all books, plus everything
     about malware", which is not a question anyone asked.

     Which list a pill joins comes from the same `is-category`/`is-subject`
     class the stylesheet colours it with, so the rows, the colours and the
     combining rule cannot disagree. */
  var activeCategories = [];
  var activeSubjects = [];

  function tagsOf(el) {
    return (el.getAttribute("data-tags") || "").split(/\s+/);
  }

  function kindOf(pill) {
    if (pill.classList.contains("is-category")) return "category";
    if (pill.classList.contains("is-subject")) return "subject";
    return "all";
  }

  function sharesAny(tags, wanted) {
    for (var i = 0; i < wanted.length; i++) {
      if (tags.indexOf(wanted[i]) !== -1) return true;
    }
    return false;
  }

  /* An empty list is not a filter — it means that row is asking nothing. */
  function matchesFilter(el) {
    var tags = tagsOf(el);
    if (activeCategories.length && !sharesAny(tags, activeCategories)) return false;
    if (activeSubjects.length && !sharesAny(tags, activeSubjects)) return false;
    return true;
  }

  function selected() {
    return activeCategories.concat(activeSubjects);
  }

  function toggle(list, tag) {
    var at = list.indexOf(tag);
    if (at === -1) {
      list.push(tag);
    } else {
      list.splice(at, 1);
    }
  }

  /* Paint every pill from the lists rather than toggling the clicked one, so the
     buttons cannot drift out of step with the filter they describe — this is
     also what lets a deep link light several pills at once. */
  function syncPills() {
    var live = selected();
    for (var i = 0; i < pills.length; i++) {
      var pill = pills[i];
      var on =
        kindOf(pill) === "all"
          ? live.length === 0
          : live.indexOf(pill.getAttribute("data-filter")) !== -1;
      pill.classList.toggle("active", on);
      pill.setAttribute("aria-pressed", on ? "true" : "false");
    }
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
      var live = selected();
      if (live.length === 0) {
        countEl.textContent = "";
      } else if (visible === 0) {
        countEl.textContent = "No entries tagged " + live.join(" + ");
      } else {
        countEl.textContent =
          "Showing " + visible + " of " + items.length + " entries · " + live.join(" + ");
      }
    }
  }

  /* `replaceState`, not a plain hash write: a filter is a view of this page, not
     a place, so stacking one history entry per pill click would turn Back into
     an undo button for filtering and strand the reader on the page they arrived
     from. The url still updates, so a filtered view stays linkable. */
  function writeHash() {
    if (!window.history || !window.history.replaceState) return;
    var live = selected();
    var url = window.location.pathname + window.location.search;
    window.history.replaceState(null, "", live.length ? url + "#" + live.join(",") : url);
  }

  function apply(categories, subjects) {
    activeCategories = categories;
    activeSubjects = subjects;
    syncPills();
    update();
  }

  for (var p = 0; p < pills.length; p++) {
    pills[p].addEventListener("click", function () {
      var kind = kindOf(this);
      var tag = this.getAttribute("data-filter");
      if (kind === "all") {
        activeCategories = [];
        activeSubjects = [];
      } else if (kind === "category") {
        toggle(activeCategories, tag);
      } else {
        toggle(activeSubjects, tag);
      }
      syncPills();
      update();
      writeHash();
    });
  }

  /* `index.html#malware` or `#books,films,1990s` opens on those tags, so a
     filtered view can be linked to. Names that match no pill are dropped rather
     than failing the whole fragment — and if none match, this is an ordinary
     same-page anchor and belongs to the browser, so nothing is touched. */
  function applyHash() {
    var raw = (window.location.hash || "").replace(/^#/, "");
    if (!raw) return;
    var wanted = decodeURIComponent(raw).split(",");
    var categories = [];
    var subjects = [];

    for (var i = 0; i < pills.length; i++) {
      var pill = pills[i];
      var tag = pill.getAttribute("data-filter");
      if (wanted.indexOf(tag) === -1) continue;
      if (kindOf(pill) === "category") {
        categories.push(tag);
      } else if (kindOf(pill) === "subject") {
        subjects.push(tag);
      }
    }

    if (categories.length || subjects.length) apply(categories, subjects);
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
