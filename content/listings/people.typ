#import "../site.typ": listing-page, template
#import "../data/people.typ": people

#show: template.with(current-page: "listings:people")

#listing-page(
  "People",
  [Named in the source doc without links; kept as leads for the archive.],
  people,
)
