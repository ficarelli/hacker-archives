// Every record carries an `id` — the slug of the idea it is hatched as, and
// half of what rookery-search matches on (id and title, never the body), so it
// is written to read like something a person would type.
//
// `tags` always leads with the grouping tag, which is what the home page's
// sections select on; the rest cut across groupings.
#let books = (
  (
    id: "cult-of-the-dead-cow",
    name: "Cult of The Dead Cow",
    url: "https://search.worldcat.org/title/1056778895",
    authors: "Joseph Menn",
    tags: ("books", "hacktivism", "security", "2010s"),
  ),
  (
    id: "space-rogue",
    name: "Space Rogue: How the Hackers Known as L0pht Changed the World",
    url: "https://search.worldcat.org/title/1379294303",
    authors: "Cris Thomas",
    tags: ("books", "security", "hacktivism", "2020s"),
  ),
  (
    id: "underground",
    name: "Underground",
    authors: "Suelette Dreyfus, Julian Assange",
    url: "https://search.worldcat.org/title/1479801406",
    tags: ("books", "hacktivism", "phreaking", "1990s"),
  ),
  (
    id: "masters-of-deception",
    name: "Masters of Deception: The Gang that Ruled Cyberspace",
    url: "https://search.worldcat.org/title/34482185",
    authors: "Michelle Slatalla, Joshua Quittner",
    tags: ("books", "phreaking", "1990s"),
  ),
  (
    id: "cyber-crimes",
    name: "Cyber Crimes",
    url: "https://search.worldcat.org/title/41096194",
    authors: "Gina De Angelis",
    tags: ("books", "security", "1990s"),
  ),
  (
    id: "hacker-crackdown",
    name: "The Hacker Crackdown: Law and Disorder on the Electronic Frontier",
    authors: "Bruce Sterling",
    url: "https://search.worldcat.org/title/25914955",
    tags: ("books", "phreaking", "security", "1990s"),
  ),
  (
    id: "cyberpunk-outlaws-and-hackers",
    name: "Cyberpunk: Outlaws and Hackers on the Computer Frontier",
    url: "https://search.worldcat.org/title/33235343",
    authors: "Katie Hafner, John Markoff",
    tags: ("books", "security", "phreaking", "1990s"),
  ),
  (
    id: "crime-in-the-digital-sublime",
    name: "Hackers: Crime in the Digital Sublime",
    url: "https://search.worldcat.org/title/40862226",
    authors: "Paul A. Taylor",
    tags: ("books", "scholarship", "1990s"),
  ),
  (
    id: "poc-or-gtfo",
    name: "PoC||GTFO (Proof of Concept or Get the Fuck Out)",
    url: "https://www.penguinrandomhouse.ca/books/572874/poc-or-gtfo-by-manul-laphroaig/9781593278984",
    authors: "Manul Laphroaig",
    tags: ("books", "security", "zines", "2010s"),
  ),
  (
    id: "cuckoos-egg",
    name: "The Cuckoo's Egg",
    year: 1989,
    authors: "Clifford Stoll",
    tags: ("books", "security", "1980s"),
  ),
)
