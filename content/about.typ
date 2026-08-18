#import "site.typ": template

#show: template.with(current-page: "about")

= About

// Typst inlines the GIF into the HTML as a base64 data URI with its bytes
// untouched, so the animation plays without anything copying the file into
// build/html — which rheo does not do for images.
#context if target() == "html" {
  html.elem("p", attrs: (class: "coming-soon"))[
    Coming Soon
    #html.elem("span", attrs: (class: "nyan"))[
      // #image("img/nyan-cat.gif", alt: "Nyan Cat running, trailing a rainbow")
    ]
  ]
} else [
  Coming Soon
]


