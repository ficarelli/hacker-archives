#import "../site.typ": listing-page, template
#import "../data/magazines.typ": magazines

#show: template.with(current-page: "listings:magazines")

#listing-page(
  "Magazines & Zines",
  [Periodicals the scene wrote for itself, and the places their back issues live now.],
  magazines,
)
