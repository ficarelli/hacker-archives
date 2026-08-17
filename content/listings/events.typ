#import "../site.typ": listing-page, template
#import "../data/events.typ": events

#show: template.with(current-page: "listings:events")

#listing-page(
  "Conferences & Events",
  [Gatherings where this work gets argued out in person.],
  events,
)
