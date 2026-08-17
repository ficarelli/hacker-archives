#import "../site.typ": listing-page, template
#import "../data/hacker-archives.typ": hacker-archives

#show: template.with(current-page: "listings:archives")

#listing-page(
  "Hacker-specific Archives",
  [Collections built by and about the scene: text files, mailing lists, defacements, leaks, malware.],
  hacker-archives,
)
