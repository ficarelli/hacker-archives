#import "../site.typ": listing-page, template
#import "../data/artifacts.typ": artifacts

#show: template.with(current-page: "listings:artifacts")

#listing-page(
  "Preserving Particular Artifacts",
  [Single objects kept running — a virus, a door game, a Lisp machine, a sit-in.],
  artifacts,
)
