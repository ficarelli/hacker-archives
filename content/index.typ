// The front page: a collection of windows onto ideas hatched under `listings/`.
// Nothing is defined here — every entry is an `#idea` living on its own page,
// and each section below is a tag selecting from the same pool.
#import "site.typ": search-block, tag-section, template
#import "data/tools.typ": tools
#import "data/hacker-archives.typ": hacker-archives
#import "data/documentaries.typ": documentaries
#import "data/magazines.typ": magazines
#import "data/books.typ": books
#import "data/events.typ": events

#show: template.with(current-page: "index")

// One pool for the whole page, so a subject pill reaches every entry shown here
// rather than only the ones inside its own section.
#let pool = tools + hacker-archives + documentaries + magazines + books + events

// Pill label paired with the tag it selects. The first row names the sections;
// the second cuts across them.
#let filters = (
  ("All", "all"),
  ("Books", "books"),
  ("Magazines", "magazines"),
  ("Films & TV Shows", "films"),
  ("Tools", "tools"),
  ("Conferences & Events", "events"),
  ("Archives", "archives"),
)

#let subjects = (
  ("Phreaking", "phreaking"),
  ("Hacktivism", "hacktivism"),
  ("Malware", "malware"),
  ("Surveillance", "surveillance"),
  ("Leaks", "leaks"),
  ("Security", "security"),
  ("BBS", "bbs"),
  ("Zines", "zines"),
  ("Free Software", "free-software"),
  ("Emulation", "emulation"),
  ("Retrocomputing", "retrocomputing"),
  ("Oral History", "oral-history"),
  ("1980s", "1980s"),
  ("1990s", "1990s"),
  ("2000s", "2000s"),
  ("2010s", "2010s"),
  ("2020s", "2020s"),
)

// (section slug, heading, the tag that selects it, the page that hatched them)
#let sections = (
  ("tools", "Tools & Projects", "tools", "listings:tools"),
  ("archives", "Hacker-specific Archives", "archives", "listings:archives"),
  ("films", "Films & TV Shows", "films", "listings:films"),
  ("magazines", "Magazines & Zines", "magazines", "listings:magazines"),
  ("books", "Books", "books", "listings:books"),
  ("events", "Conferences & Events", "events", "listings:events"),
)

#search-block(filters, subjects: subjects)

// The wordmark carries the title on the web; print targets still need a heading.
#context if target() != "html" [
  = Hacker Archives
]

#context if target() == "html" {
  html.elem("div", attrs: (id: "archive-grid"))[
    #for (slug, heading, tag, handle) in sections {
      tag-section(slug, heading, tag, pool, handle: handle)
    }
  ]
} else {
  for (slug, heading, tag, handle) in sections {
    tag-section(slug, heading, tag, pool)
  }
}
