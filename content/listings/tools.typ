#import "../site.typ": listing-page, template
#import "../data/tools.typ": tools

#show: template.with(current-page: "listings:tools")

#listing-page(
  "Tools & Projects",
  [Software for capturing, emulating, describing and keeping what would otherwise rot.],
  tools,
)
