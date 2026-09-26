#import "../site.typ": listing-page, template
#import "../data/documentaries.typ": documentaries

#show: template.with(current-page: "listings:films", title: "Films & TV Shows")

#listing-page(
  "Films & TV Shows",
  [Documentaries and dramatisations, from 1980s public television to streaming exposés.],
  documentaries,
)
