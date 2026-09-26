#import "../site.typ": listing-page, template
#import "../data/digital-archives.typ": digital-archives

#show: template.with(current-page: "listings:collections", title: "Digital Archives")

#listing-page(
  "Digital Archives",
  [Digital collections worth learning from, whether or not they are about hacking.],
  digital-archives,
)
