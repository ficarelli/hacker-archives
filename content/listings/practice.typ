#import "../site.typ": listing-page, template
#import "../data/practice.typ": practice

#show: template.with(current-page: "listings:practice")

#listing-page(
  "Archival Practice Overviews",
  [Reading on how archives are appraised, described, funded, cared for, and given away.],
  practice,
)
