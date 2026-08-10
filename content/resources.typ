// Page for the "Resources" tab of the source doc.
#import "site.typ": template, category-section
#import "data/practice.typ": practice
#import "data/artifacts.typ": artifacts
#import "data/digital-archives.typ": digital-archives
#import "data/funding.typ": funding
#import "data/people.typ": people

#show: template.with(current-page: "resources")

#let sections = (
  ("practice", "Archival Practice Overviews", practice),
  ("artifacts", "Preserving Particular Artifacts", artifacts),
  ("digital-archives", "Digital Archives", digital-archives),
  ("funding", "Funding Sources", funding),
  ("people", "People", people),
)

#context if target() != "html" [
  = Resources
]

#context if target() == "html" {
  html.elem("p", attrs: (class: "site-intro"))[
    Below is a list of materials that have inspired us. Find reading on archival
    practice, examples of preserved digital artifacts, and other digital archives to
    learn from, funding sources, and people to talk to.
  ]
} else [
  Below is a list of materials that have inspired us. Find reading on archival
  practice, examples of preserved digital artifacts, and other digital archives to
  learn from, funding sources, and people to talk to.
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
