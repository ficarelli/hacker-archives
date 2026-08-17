// Site chrome, and the one place `@rheo/rookery` is configured.
//
// `#show: rookery` has to be applied in EVERY vertebra that uses the package —
// Typst imports are per-file, so no one file can install it for the others.
// Wrapping it in `template` is how that requirement gets met once: a page
// writes `#show: template.with(...)` and gets the chrome, the theme and the
// `ref` rule together.
#import "@rheo/rookery:0.2.0": idea, rookery, window
// Search ships as its own package, and BOTH imports have to be written here in
// the site's own files: rheo scans only a project's own `.typ` files for
// package imports, so a package reached transitively through another one
// contributes nothing — no stylesheet, no script, and (for rookery) no minted
// idea pages at all, which would leave the search index with nothing to link
// to. Being excluded from the spine does not exclude this file from that scan.
#import "@rheo/rookery-search:0.2.0": search-modal

// Rookery's default light-blue/purple pair, replaced with pinks drawn from the
// wordmark and the h_a mark. ONE document-wide value: every vertebra has to ask
// for the same thing, which is why it is set in this one file.
//
// `fold-color` is the one that shows most: rookery paints it behind an
// `.idea-window` on hover, so it is what makes a listing go pink under the
// mouse. It is set well above rookery's own 0.05 default — at that alpha a pink
// this light is invisible on white, which is why the fill did not read as pink
// before.
//
// `link-color` is the fill behind an internal link on hover, and `border-color`
// the solid rule down the left of every window; a window's left edge and its
// hover fill are the same gesture, so they are the same hue at two strengths.
#let THEME = (
  link-color: "rgba(214, 100, 150, 0.18)",
  fold-color: "rgba(224, 130, 170, 0.18)",
  border-color: rgb("#dfa3c0"),
  id-color: rgb("#bb8ca2"),
  date-color: rgb("#b07f95"),
)

// The id of the one search index on every page, named in three places — the
// modal that emits it, the nav trigger, and the landing page's field — so it is
// bound once here. Two spellings of it would drift silently and a trigger would
// simply stop opening anything.
#let SEARCH-INDEX-ID = "rookery-search-index"

// The grouping tags, as against the ones that cut across them. Only used to tell
// the two apart when rendering: a category and a subject are the same pill, and
// colour is the whole of the difference.
#let CATEGORY-TAGS = (
  "books",
  "magazines",
  "films",
  "tools",
  "archives",
  "events",
  "practice",
  "artifacts",
  "collections",
  "funding",
  "people",
)

// Glyph cells for the animated wordmark. index.js scrambles these, then resolves
// them into "Hacker Archives" before dissolving again — so there must be exactly
// one cell per character of that title, and `cursor-index` must sit where its
// space falls. The caret cell stays put and stands in for that space.
#let logo-glyphs = ("\\", "+", "#", "$", ">", "*", "_", "<", "!", "-", ";", "&", "=", "|", "%")
#let cursor-index = 6

// Every internal link goes through `link(label(handle))` rather than a written
// href, because rheo rewrites exactly that form into a DEPTH-RELATIVE url. That
// matters now that the site is more than one level deep: the same nav emits
// `./index.html` on the landing page, `../index.html` from `listings/books.html`
// and from every `ideas/*.html` page rookery mints. A hand-written
// `./index.html` — which a flat site can get away with — would 404 from both.
//
// Only Typst can compute those hrefs, so the CSS hook is a wrapping element
// carrying the class with Typst's `link` inside it: `.site-logo a`, not the
// anchor itself.
//
// The glyphs are decorative, so they are hidden from assistive tech and the
// link takes its accessible name from a visually-hidden span instead.
#let site-logo = {
  html.elem("span", attrs: (class: "site-logo"), link(label("index"))[
    #html.elem("span", attrs: (class: "logo-glyphs", "aria-hidden": "true"))[
      #for (i, g) in logo-glyphs.enumerate() {
        html.elem(
          "span",
          attrs: (class: if i == cursor-index { "glyph cursor" } else { "glyph" }),
        )[#g]
      }
    ]
    #html.elem("span", attrs: (class: "visually-hidden"))[Hacker Archives]
  ])
}

// The leading slash is decoration, so it stays out of the accessible name.
// `handle` is rheo's own name for a vertebra — the same string a page passes as
// `current-page`. Nested vertebrae are colon-separated: `listings/books.typ` is
// the handle `listings:books`.
#let nav-item(caption, handle) = {
  html.elem("span", attrs: (class: "nav-item"), link(label(handle))[
    #html.elem("span", attrs: (class: "nav-slash", "aria-hidden": "true"))[/]
    #html.elem("span", attrs: (class: "nav-label"))[#caption]
  ])
}

// The package's own magnifier path, bound once because both triggers use it and
// two copies would drift apart.
#let search-icon = html.elem(
  "svg",
  attrs: (class: "rookery-search-icon", viewBox: "0 0 24 24", "aria-hidden": "true"),
  html.elem("path", attrs: (
    d: "M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3"
      + " 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49"
      + " 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z",
  )),
)

// A black slash, the magnifier, and the Ctrl-K rectangle, sitting at the end of
// the nav row. The slash is the same decorative one the page links carry, so the
// control reads as a member of that row rather than an icon parked beside it.
//
// Hand-written all the same, so that it can live INSIDE `.site-links` and take
// that row's size and gap: the package emits its trigger, the JSON island and
// the `<dialog>` together at one call site, and putting all three inside a
// `<nav>` to get the trigger there would be the wrong home for the other two.
// Hence `trigger: false` on the modal below.
//
// Both children are decorative — the icon is a picture and the key names a
// shortcut — so the accessible name comes from `aria-label`.
//
// The key hint stays on THIS trigger and not on the landing page's field: it is
// the terse one, where a shortcut belongs. The package's own stylesheet hides
// the key below 600px, which leaves the magnifier as the control on a touch
// screen, where "Ctrl K" would mean nothing.
#let nav-search-item = {
  html.elem(
    "button",
    attrs: (
      class: "rookery-search-trigger nav-search",
      type: "button",
      "data-rookery-search-modal": SEARCH-INDEX-ID,
      "aria-label": "Search the archive",
    ),
    html.elem("span", attrs: (class: "nav-slash", "aria-hidden": "true"))[/]
      + search-icon
      + html.elem("kbd", attrs: (class: "rookery-search-key", "aria-hidden": "true"))[Ctrl K],
  )
}

// The search entry sits in the same element as the page links so it inherits the
// row's gap and size rather than having them restated — hence the wider label.
#let site-links = {
  html.elem("nav", attrs: (class: "site-links", "aria-label": "Site sections and search"))[
    #nav-item("about", "about")
    #nav-item("contribute", "contribute")
    #nav-item("resources", "resources")
    #nav-search-item
  ]
}

// Round mark in the footer. The label is decorative — screen readers get the
// visually-hidden name. Internal marks take a handle, external ones a url,
// since only an internal link needs rheo's depth-relative rewriting.
#let footer-mark-page(caption, handle, aria: none) = {
  html.elem("span", attrs: (class: "footer-mark"), link(label(handle))[
    #html.elem("span", attrs: ("aria-hidden": "true"))[#caption]
    #html.elem("span", attrs: (class: "visually-hidden"))[#aria]
  ])
}

// Hand-emitted rather than via `link()`, which cannot set target/rel.
// noopener/noreferrer because target="_blank" otherwise hands the opened page a
// reference back to this one.
#let footer-mark-external(caption, url, aria: none) = {
  html.elem("span", attrs: (class: "footer-mark"))[
    #html.elem("a", attrs: (
      href: url,
      target: "_blank",
      rel: "noopener noreferrer",
    ))[
      #html.elem("span", attrs: ("aria-hidden": "true"))[#caption]
      #html.elem("span", attrs: (class: "visually-hidden"))[#aria]
    ]
  ]
}

#let site-footer = {
  html.elem("footer", attrs: (class: "site-footer"))[
    #html.elem("div", attrs: (class: "footer-marks"))[
      #footer-mark-page("h_a", "index", aria: "Hacker Archives home")
      #footer-mark-external(
        "h_c",
        "https://hackcur.io/",
        aria: "Hackcurio, our sister site",
      )
    ]
    #html.elem("p", attrs: (class: "footer-tagline"))[Archiving the Cultures of Hacking]
  ]
}

// ---- Listings as ideas ----------------------------------------------------
//
// One `#idea` per record, which is what gives every listing its own standalone
// `ideas/<id>.html` page (minted by rookery), its own backlinks, and a place in
// the search index. `id` is the slug and `name` is the title — rookery-search
// matches on exactly those two and never on the body, so both have to read the
// way someone would type them.
//
// The record's `tags` go on the idea verbatim. They are what the home page
// selects sections with, and rookery also stamps each one onto the rendered
// idea as an `idea-tag-<tag>` class.

// Only HTML needs target/rel, and only `html.elem` can set them; a paged target
// gets Typst's own `link`.
#let external-link(url, body) = {
  context if target() == "html" {
    html.elem("a", attrs: (
      href: url,
      target: "_blank",
      rel: "noopener noreferrer",
    ), body)
  } else {
    link(url, body)
  }
}

// The url is shown as its own text rather than hidden behind the title. An
// archive's readers want to see where a link goes, and it survives into the PDF
// and EPUB, where a bare hyperlink would lose its destination entirely.
#let listing(rec) = {
  let meta-parts = ()
  if "authors" in rec { meta-parts.push(rec.authors) }
  if "director" in rec { meta-parts.push("Dir: " + rec.director) }
  if "year" in rec { meta-parts.push(str(rec.year)) }

  idea(label(rec.id), title: [#rec.name], tags: rec.tags)[
    // PLAIN CONTENT, not a `context`-guarded `html.elem` like the url and tags
    // below, and this is load-bearing rather than a style choice.
    //
    // `@rheo/rookery-search` from 0.2.0 also matches an idea's BODY, and the
    // body it matches is a plain-text extraction that walks an element's
    // `children`/`body`. A `context` block has neither, so anything wrapped in
    // one is invisible to it — MEASURED: with the meta line inside `context`,
    // the ten books that carry `authors` but no `description` indexed an empty
    // body and could only be found by title. Authors, directors and years are
    // exactly what someone searches an archive like this by ("Poitras",
    // "Sterling", "1984"), so this line has to stay extractable.
    //
    // `emph` rather than a classed paragraph because plain content is the whole
    // point, and it renders in a paged target too; style.css styles the `em`.
    #if meta-parts.len() > 0 {
      emph(meta-parts.join(" · "))
      linebreak()
    }
    #if "description" in rec { rec.description }
    #if "url" in rec {
      context if target() == "html" {
        html.elem("p", attrs: (class: "listing-url"))[
          #external-link(rec.url)[#rec.url]
        ]
      } else {
        linebreak()
        link(rec.url)[#rec.url]
      }
    }
    // Plain labels, not links: an idea's body is rendered at three different
    // depths (its own page, the listings page that hatched it, and a window on
    // the home page), and a fragment url cannot be made depth-relative the way
    // `link(label(..))` can. The home page's pills are what filters by tag.
    #if rec.tags.len() > 0 {
      context if target() == "html" {
        html.elem("p", attrs: (class: "listing-tags"))[
          // Same pill for every tag; the second class only carries the colour,
          // which is the whole of the difference between a grouping and a
          // subject.
          #for t in rec.tags {
            let kind = if t in CATEGORY-TAGS { "is-category" } else { "is-subject" }
            html.elem("span", attrs: (class: "listing-tag " + kind))[#t]
          }
        ]
      }
    }
  ]
}

// A whole grouping, hatched. Called by the vertebrae under `listings/`.
#let listing-page(heading, blurb, items) = {
  [= #heading]
  if blurb != none {
    context if target() == "html" {
      html.elem("p", attrs: (class: "site-intro"))[#blurb]
    } else {
      blurb
    }
  }
  for rec in items { listing(rec) }
}

// ---- Home-page views ------------------------------------------------------

// Search field and filter pills. The field itself is rookery-search's, which
// matches ids and titles across the whole rookery and navigates to an idea's
// page; the pills are this site's own and filter what is already on the page.
// The landing page's search field. NOT a second search: a `.rookery-search-
// trigger` carrying `data-rookery-search-modal` is what rookery-search's script
// binds to `open()`, so this button and the entry in the nav are two doors onto
// one dialog, one index and one ranking.
//
// A button rather than an input, deliberately. An input here would be a second
// place to type with its own results, and the two would drift; it would also
// swallow Ctrl-K, which the package suppresses while focus sits in a field.
// Clicking this opens the modal with its input already focused, so a reader who
// starts at the big field and a reader who hits Ctrl-K land in the same place.
#let search-field = {
  html.elem(
    "button",
    attrs: (
      class: "rookery-search-trigger hero-search",
      type: "button",
      "data-rookery-search-modal": SEARCH-INDEX-ID,
      "aria-label": "Search the archive",
    ),
    search-icon
      + html.elem("span", attrs: (class: "hero-search-label"))[search the archive],
    // No key hint here. This is the wide, primary field, and the shortcut
    // belongs on the terse nav entry instead.
  )
}

// `filters` and `subjects` are each a sequence of (label, tag) pairs, rendered
// as two rows: the grouping tags that name the page's own sections, and the
// tags that cut across them. Two rows because they answer different questions —
// "show me the films" and "show me everything about malware" — but ONE
// selection between them, since a pill that narrowed an already-narrowed set
// would need a second active state and a way to clear it.
//
// The pills are not search. They narrow what is already on the page, which is
// the one thing the modal cannot do — it ranks the whole rookery and navigates
// away to an idea's own page.
#let search-block(filters, subjects: ()) = {
  // One pill shape throughout. A grouping and a subject differ by colour only,
  // so the extra class carries nothing but that; `all` takes neither, being the
  // control that clears the others rather than a tag.
  //
  // `is-category`/`is-subject` are read by index.js as well as by the
  // stylesheet: several pills can be live at once, and which of the two rows a
  // pill belongs to is what decides whether it widens the selection or narrows
  // it (see the note there).
  //
  // `aria-pressed` because these are toggles now, not a one-of-many choice. It
  // starts `true` on `All`, which is the state of a page with nothing selected.
  let pill(caption, value) = {
    let kind = if value == "all" {
      "pill active"
    } else if value in CATEGORY-TAGS {
      "pill is-category"
    } else {
      "pill is-subject"
    }
    html.elem(
      "button",
      attrs: (
        type: "button",
        class: kind,
        "data-filter": value,
        "aria-pressed": if value == "all" { "true" } else { "false" },
      ),
    )[#caption]
  }

  context if target() == "html" {
    html.elem("div", attrs: (class: "search-block"))[
      #html.elem("div", attrs: (class: "search-container"))[
        #search-field
      ]
      // ONE container for both lists, not one per row. They no longer differ in
      // colour or size, so a second container bought nothing but a seam: the
      // space between two sibling divs is a margin, which cannot share the
      // flex `gap` that separates pills everywhere else, so the join between
      // groupings and subjects always read as wider than a plain wrap. Emitted
      // in order, the two simply flow into each other.
      #html.elem("div", attrs: (class: "filter-pills", id: "filters"))[
        #for (caption, value) in filters { pill(caption, value) }
        #for (caption, value) in subjects { pill(caption, value) }
      ]
      #html.elem("div", attrs: (id: "results-count", role: "status", "aria-live": "polite"))[]
    ]
  }
}

// A section of the front page: every listing carrying `tag`, as a folded window
// onto the idea itself.
//
// The windows are emitted ONE AT A TIME from the same records the ideas were
// hatched from, rather than with a single `#window(tags: tag)`. Both select by
// exactly the same tag, but one call emits all its windows as bare siblings,
// and `.idea-window` carries no tag classes of its own — so per-item wrappers
// are the only way the pills can filter on a tag that cuts across sections
// (`malware`, `1990s`) rather than only on whole sections.
// `handle` is the vertebra that hatched these ideas, and the heading links to
// it — otherwise the pages under `listings/` would be reachable only by search,
// since nothing else on the site points at them.
#let tag-section(slug, heading, tag, groups, handle: none) = {
  let matches = groups.filter(rec => tag in rec.tags)
  context if target() == "html" {
    html.elem("section", attrs: ("data-section": slug))[
      #html.elem("h2", attrs: (id: slug))[
        #if handle == none { heading } else { link(label(handle))[#heading] }
      ]
      #for rec in matches {
        html.elem("div", attrs: (
          class: "listing-window",
          "data-tags": rec.tags.join(" "),
        ))[#window(rec.id, folded: true)]
      }
    ]
  } else {
    [
      = #heading
      #for rec in matches { window(rec.id, folded: true) }
    ]
  }
}

// ---- Chrome and templates -------------------------------------------------

// The chrome alone, with no `#show: rookery` in it. Split out from `template`
// below because BOTH a vertebra and a minted idea page need it, and only a
// vertebra needs the package configured: a minted page is spliced in after
// every vertebra has already set the theme and window depth, so re-applying
// `rookery` there would append a second round of identical state updates for no
// gain.
//
// The accent rule is the header's own bottom border, so it stays put with the
// header when it sticks rather than scrolling away as a separate <hr>.
#let chrome(current-page: none, doc) = {
  context if target() == "html" {
    html.elem("header", attrs: (class: "site-nav"))[
      #site-logo
      #site-links
      // On every page, minted idea pages included, so the whole rookery is
      // always one keystroke away. Emits the JSON index island and the
      // `<dialog>`; `trigger: false` because this site draws its own two
      // triggers — `nav-search-item` above and `search-field` on the landing
      // page — and the package's icon-and-key button would be a third.
      //
      // `limit: 30` rather than the modal's own default, and it is not
      // arbitrary: the modal shows a preview pane beside its result list, so the
      // list scrolls rather than truncating the page, and 30 is a real slice of
      // a 112-idea rookery instead of a keyhole.
      #search-modal(
        placeholder: "search the archive",
        limit: 30,
        trigger: false,
        elem-id: SEARCH-INDEX-ID,
      )
    ]
  }
  doc
  context if target() == "html" { site-footer }
}

// The template for the standalone page rookery mints per idea. `id` is the
// idea's full id, so nothing in the nav is marked active — an idea page belongs
// to no section, which is the honest answer.
//
// A NAMED top-level binding, deliberately: the package stores this on a
// document-wide state, and an inline closure written inside `template` would be
// a different value in every vertebra that applies it. `note` (the idea's
// registry record) goes unused here, but is available for a richer idea-page
// header without querying.
#let idea-page(id: none, note: (:), doc) = {
  show: chrome.with(current-page: id)
  doc
}

#let template(current-page: none, doc) = {
  show: rookery.with(
    theme: THEME,
    idea-page-template: idea-page,
    window-depth: 0,
  )
  show: chrome.with(current-page: current-page)
  doc
}
