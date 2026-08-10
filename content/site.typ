// Glyph cells for the animated wordmark. index.js scrambles these, then resolves
// them into "Hacker Archives" before dissolving again — so there must be exactly
// one cell per character of that title, and `cursor-index` must sit where its
// space falls. The caret cell stays put and stands in for that space.
#let logo-glyphs = ("\\", "+", "#", "$", ">", "*", "_", "<", "!", "-", ";", "&", "=", "|", "%")
#let cursor-index = 6

#let site-logo = {
  html.elem(
    "a",
    attrs: (href: "./index.html", class: "site-logo", "aria-label": "Hacker Archives"),
  )[
    #html.elem("span", attrs: (class: "logo-glyphs", "aria-hidden": "true"))[
      #for (i, g) in logo-glyphs.enumerate() {
        html.elem(
          "span",
          attrs: (class: if i == cursor-index { "glyph cursor" } else { "glyph" }),
        )[#g]
      }
    ]
  ]
}

// The leading slash is decoration, so it stays out of the accessible name.
#let nav-item(label, href) = {
  html.elem("a", attrs: (href: href, class: "nav-item"))[
    #html.elem("span", attrs: (class: "nav-slash", "aria-hidden": "true"))[/]
    #html.elem("span", attrs: (class: "nav-label"))[#label]
  ]
}

#let site-links = {
  html.elem("nav", attrs: (class: "site-links"))[
    #nav-item("about", "./about.html")
    #nav-item("contribute", "./contribute.html")
    #nav-item("resources", "./resources.html")
  ]
}

// Round mark in the footer. The label is decorative — screen readers get `aria`.
#let footer-mark(label, href, aria: none, external: false) = {
  let attrs = (href: href, class: "footer-mark", "aria-label": aria)
  if external {
    attrs.insert("target", "_blank")
    attrs.insert("rel", "noopener noreferrer")
  }
  html.elem("a", attrs: attrs)[
    #html.elem("span", attrs: ("aria-hidden": "true"))[#label]
  ]
}

#let site-footer = {
  html.elem("footer", attrs: (class: "site-footer"))[
    #html.elem("div", attrs: (class: "footer-marks"))[
      #footer-mark("h_a", "./index.html", aria: "Hacker Archives home")
      #footer-mark(
        "h_c",
        "https://hackcur.io/",
        aria: "Hackcurio, our sister site",
        external: true,
      )
    ]
    #html.elem("p", attrs: (class: "footer-tagline"))[Archiving the Cultures of Hacking]
  ]
}

// Search field, filter pills and results counter for a catalog page. `filters`
// is a sequence of (label, data-filter) pairs; a filter may name several
// space-separated categories.
#let search-block(filters) = {
  context if target() == "html" {
    html.elem("div", attrs: (class: "search-block"))[
      #html.elem("div", attrs: (class: "search-container"))[
        #html.elem("input", attrs: (
          type: "text",
          id: "search",
          placeholder: "search",
          "aria-label": "Search archives",
          autocomplete: "off",
        ))[]
      ]
      #html.elem("div", attrs: (class: "filter-pills", id: "filters"))[
        #for (label, value) in filters {
          html.elem(
            "button",
            attrs: (
              class: if value == "all" { "pill active" } else { "pill" },
              "data-filter": value,
            ),
          )[#label]
        }
      ]
      #html.elem("div", attrs: (id: "results-count", role: "status", "aria-live": "polite"))[]
    ]
  }
}

#let template(current-page: none, doc) = {
  context if target() == "html" {
    // The accent rule is the header's own bottom border, so it stays put with
    // the header when it sticks rather than scrolling away as a separate <hr>.
    html.elem("header", attrs: (class: "site-nav"))[
      #site-logo
      #site-links
    ]
  }
  doc
  context if target() == "html" {
    site-footer
    html.elem("script", attrs: (src: "index.js"))[]
  }
}

#let resource-item(category, item) = {
  context if target() == "html" {
    html.elem("div", attrs: (
      class: "resource-item",
      "data-category": category,
    ))[
      // Emitted by hand rather than via link(), which cannot set target/rel.
      // noopener/noreferrer because target="_blank" otherwise hands the opened
      // page a reference back to this one.
      #let title = if "url" in item and item.url != none {
        html.elem("a", attrs: (
          href: item.url,
          target: "_blank",
          rel: "noopener noreferrer",
        ))[#item.name]
      } else {
        item.name
      }
      #html.elem("strong", attrs: (class: "resource-name"))[#title]
      #let meta-parts = ()
      #if "authors" in item { meta-parts.push(item.authors) }
      #if "director" in item { meta-parts.push("Dir: " + item.director) }
      #if "year" in item { meta-parts.push(str(item.year)) }
      #if meta-parts.len() > 0 {
        html.elem("span", attrs: (class: "resource-meta"))[
          #meta-parts.join(" \u{00b7} ")
        ]
      }
      #if "description" in item {
        html.elem("p", attrs: (class: "resource-desc"))[#item.description]
      }
    ]
  } else {
    [
      #let title = if "url" in item and item.url != none {
        link(item.url)[#item.name]
      } else {
        item.name
      }
      *#title*
      #let meta-parts = ()
      #if "authors" in item { meta-parts.push(item.authors) }
      #if "director" in item { meta-parts.push("Dir: " + item.director) }
      #if "year" in item { meta-parts.push(str(item.year)) }
      #if meta-parts.len() > 0 { [\ #meta-parts.join(" · ")] }
      #if "description" in item { [\ #item.description] }
      #linebreak()
    ]
  }
}

#let category-section(slug, label, items) = {
  context if target() == "html" {
    html.elem("section", attrs: ("data-section": slug))[
      #html.elem("h2", attrs: (id: slug))[#label]
      #for item in items {
        resource-item(slug, item)
      }
    ]
  } else {
    [
      = #label
      #for item in items {
        resource-item(slug, item)
      }
    ]
  }
}
