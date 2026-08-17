#import "../site.typ": listing-page, template
#import "../data/funding.typ": funding

#show: template.with(current-page: "listings:funding")

#listing-page(
  "Funding Sources",
  [Money that has gone to community-based archives before.],
  funding,
)
