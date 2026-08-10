// Page for the "Hacker Archives" tab of the source doc.
#import "site.typ": template, category-section, search-block
#import "data/tools.typ": tools
#import "data/hacker-archives.typ": hacker-archives
#import "data/documentaries.typ": documentaries
#import "data/magazines.typ": magazines
#import "data/books.typ": books
#import "data/events.typ": events

#show: template.with(current-page: "index")

// Pill label paired with the data-category values it selects. A pill may span
// several sections.
#let filters = (
  ("All", "all"),
  ("Books", "books"),
  ("Magazines", "magazines"),
  ("Films & TV Shows", "documentaries"),
  ("Tools", "tools"),
  ("Conferences & Events", "events"),
  ("Archives", "hacker-archives"),
)

#let sections = (
  ("tools", "Tools & Projects", tools),
  ("hacker-archives", "Hacker-specific Archives", hacker-archives),
  ("documentaries", "Films & TV Shows", documentaries),
  ("magazines", "Magazines", magazines),
  ("books", "Books", books),
  ("events", "Conferences & Events", events),
)

#search-block(filters)

// The wordmark carries the title on the web; print targets still need a heading.
#context if target() != "html" [
  = Hacker Archives
]

#context if target() == "html" {
  html.elem("div", attrs: (id: "archive-grid"))[
    #for (slug, label, items) in sections {
      category-section(slug, label, items)
    }
  ]
} else {
  for (slug, label, items) in sections {
    category-section(slug, label, items)
  }
}
