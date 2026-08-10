(function () {
  var input = document.getElementById("search");
  var pills = document.querySelectorAll(".pill");
  var sections = document.querySelectorAll("[data-section]");
  var countEl = document.getElementById("results-count");
  var activeFilter = ["all"];

  function normalize(str) {
    return str.toLowerCase().replace(/[^\w\s]/g, "");
  }

  function matchesSearch(el, query) {
    if (!query) return true;
    var text = normalize(el.textContent);
    var words = normalize(query).split(/\s+/).filter(Boolean);
    var idx = 0;
    for (var i = 0; i < words.length; i++) {
      var found = text.indexOf(words[i], idx);
      if (found === -1) return false;
      idx = found + words[i].length;
    }
    return true;
  }

  function matchesFilter(el) {
    if (activeFilter[0] === "all") return true;
    return activeFilter.indexOf(el.getAttribute("data-category")) !== -1;
  }

  function update() {
    var query = input.value.trim();
    var visible = 0;
    var total = 0;

    var items = document.querySelectorAll(".resource-item");
    for (var i = 0; i < items.length; i++) {
      total++;
      var show = matchesSearch(items[i], query) && matchesFilter(items[i]);
      items[i].style.display = show ? "" : "none";
      if (show) visible++;
    }

    for (var j = 0; j < sections.length; j++) {
      var sectionItems = sections[j].querySelectorAll(".resource-item");
      var anyVisible = false;
      for (var k = 0; k < sectionItems.length; k++) {
        if (sectionItems[k].style.display !== "none") {
          anyVisible = true;
          break;
        }
      }
      sections[j].style.display = anyVisible ? "" : "none";
    }

    if (countEl) {
      var filtering = query || activeFilter[0] !== "all";
      if (!filtering) {
        countEl.textContent = "";
      } else if (visible === 0) {
        countEl.textContent = "No entries yet";
      } else {
        countEl.textContent = "Showing " + visible + " of " + total + " resources";
      }
    }
  }

  if (input) {
    input.addEventListener("input", update);
  }

  for (var p = 0; p < pills.length; p++) {
    pills[p].addEventListener("click", function () {
      for (var q = 0; q < pills.length; q++) {
        pills[q].classList.remove("active");
      }
      this.classList.add("active");
      activeFilter = this.getAttribute("data-filter").split(/\s+/);
      update();
    });
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
