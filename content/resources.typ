// Page for the "Resources" tab of the source doc — the same windows-on-ideas
// shape as the front page, over the groupings that are about doing the work
// rather than about the scene.
#import "site.typ": search-block, tag-section, template
#import "data/practice.typ": practice
#import "data/artifacts.typ": artifacts
#import "data/digital-archives.typ": digital-archives
#import "data/funding.typ": funding
#import "data/people.typ": people

#show: template.with(current-page: "resources")

#let pool = practice + artifacts + digital-archives + funding + people

#let filters = (
  ("All", "all"),
  ("Archival Practice", "practice"),
  ("Artifacts", "artifacts"),
  ("Digital Archives", "collections"),
  ("Funding", "funding"),
  ("People", "people"),
)

#let subjects = (
  ("Preservation", "preservation"),
  ("Ethics", "ethics"),
  ("Metadata", "metadata"),
  ("Sustainability", "sustainability"),
  ("Acquisition", "acquisition"),
  ("Scholarship", "scholarship"),
  ("Emulation", "emulation"),
  ("Malware", "malware"),
  ("Net Art", "net-art"),
  ("Retrocomputing", "retrocomputing"),
  ("Usenet", "usenet"),
  ("Shadow Libraries", "shadow-library"),
)

#let sections = (
  ("practice", "Archival Practice Overviews", "practice", "listings:practice"),
  ("artifacts", "Preserving Particular Artifacts", "artifacts", "listings:artifacts"),
  ("collections", "Digital Archives", "collections", "listings:collections"),
  ("funding", "Funding Sources", "funding", "listings:funding"),
  ("people", "People", "people", "listings:people"),
)

#context if target() != "html" [
  = Resources
]

#let blurb = [
  Below is a list of materials that have inspired us. Find reading on archival
  practice, examples of preserved digital artifacts, and other digital archives to
  learn from, funding sources, and people to talk to.
]

#context if target() == "html" {
  html.elem("p", attrs: (class: "site-intro"))[#blurb]
} else {
  blurb
}

// #search-block(filters, subjects: subjects)

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
