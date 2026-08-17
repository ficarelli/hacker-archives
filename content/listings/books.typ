// Hatches the books as ideas. Every record here gets its own `ideas/<id>.html`
// page, minted by rookery, and a row in the search index; the home page only
// ever shows windows onto them.
#import "../site.typ": listing-page, template
#import "../data/books.typ": books

#show: template.with(current-page: "listings:books")

#listing-page(
  "Books",
  [Long-form accounts of hacking, its people, and the law that chased them.],
  books,
)
