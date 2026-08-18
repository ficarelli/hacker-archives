---
name: sync-google-doc
description: Pull the latest content from the Hacker Archives Google Doc and reconcile it into the local Typst site, one site page per doc tab. Use when asked to sync/refresh/update the site from the Google Doc, pull the latest doc content, check the doc for new links or new comments, or when told the doc has changed.
---

# Sync the site from the Google Doc

Collaborators curate this catalog in a Google Doc; the Typst sources under `content/`
are the rendered form of it. **Each tab of the doc is one page of the site.**

Source doc: `1HK55hKECKDxbm7sqb5qPFrUM5Qu5bP7ytWv1jNfLSnk`
(<https://docs.google.com/document/d/1HK55hKECKDxbm7sqb5qPFrUM5Qu5bP7ytWv1jNfLSnk/>,
titled `existing-hacker-archives`, owned by mgoerzen@g.harvard.edu and shared with us)

The doc is the authority on *what is listed* and *where each link points*. The repo is
the authority on *presentation* — descriptions, canonical URL form, and category
ordering that has already been curated here.

## 1. Read the doc — Google Drive connector first

The Drive MCP connector is the primary path: it authenticates as the user, returns all
tabs in one call as markdown with links already inline, and can carry comments.

Its tool names are prefixed with a per-session server id (`mcp__<server-id>__...`), so
never hardcode them — load the schemas by suffix:

```
ToolSearch  query: "+read_file_content drive google"
```

Then call `read_file_content` with `fileId` set to the id above and
`includeComments: true`. Pass the id directly; it is verified, so there is no need to
run `search_files` first. If the id ever stops resolving, find the doc by its title
with `search_files` and report the new id.

**Tab boundaries.** The response is one markdown string in which each tab starts with
its title as an H1, and then usually repeats that title as an H3:

```
# Hacker Archives          <- tab 1 begins
### Hacker Archives
#### Some Interesting Archiving / Preservation / Emulation Tools and Projects:
...
# Resources                <- tab 2 begins
```

Split on H1. This is a heuristic — H1 is also a heading level an author could use
inside a tab. Sanity-check the split against the tab titles you expect (below); if the
H1s do not delimit cleanly, or if the content looks truncated (the tool warns that very
large files may come back incomplete), switch to the fallback, which gets authoritative
tab ids from Google.

**Fallback — no connector (headless/cron runs, or connector unavailable):**

```bash
.claude/skills/sync-google-doc/scripts/fetch-doc.sh <scratchpad-dir>
```

Pass a scratchpad directory, never a path inside the repo. This scrapes the public
export endpoints with `curl`, so it needs the doc to stay link-shared ("anyone with the
link"), and it cannot see comments. It writes one `NN-<slug>.txt` per tab — real tab
ids, `### Tab title` / `#### Section heading`, `- item`, and links as
`link text @@https://target@@` — plus `tabs.tsv` and the raw HTML. If it fails, say
sharing was probably tightened and stop; do not fall back to `WebFetch` on `/edit`,
which returns only the editor chrome.

**Derive the tab list every run.** Tabs get renamed, reordered, added, and sections
move between tabs. As of the last sync: `Hacker Archives`, `Resources`, `Contribute`,
`About`.

## 2. Reading the connector's markdown

The doc's own markup is sloppy in ways that will corrupt entries if parsed literally:

- **Link spans swallow neighbouring text.** `[**Unauthorized Access** (1994)  \n](url)Director: Annaliza Savage`
  puts the year *and* the line break inside the link text. Take the URL, then re-derive
  `name` / `year` / `director` from the visible text — do not trust the link boundary.
- **Stray punctuation escapes the link**: `“[Complete” List of Movies…](url)` — the
  opening quote sits outside. Reconstruct the real title.
- **Markdown escapes are literal**: `hacked\_pages`, `Apple \]\[`, `days\!`, and the
  collaborators' `\*` annotation markers. Unescape before writing Typst; drop the `\*`
  markers entirely.
- **Bold is decoration.** `#### **Books by or about Hackers**` and `**The Great Hack**`
  — strip `**`, it carries no meaning here.
- **Sub-bullets** arrive indented (`  - [The Activists' Guide…](url)`) and belong to the
  item above them.

## 3. Map tabs to pages

| Tab | Page file | Kind |
| --- | --- | --- |
| first tab | `content/index.typ` | catalog |
| any other tab | `content/<slug>.typ` (slug = lowercased, hyphenated title) | catalog or prose |

A **catalog** tab is one whose sections are lists of resources; it renders through
`category-section` from `content/site.typ`. A **prose** tab (short body text, no
resource sections — e.g. `About`, `Contribute`) renders as ordinary Typst prose.

For each tab:

- Create the page if it does not exist; update it in place if it does.
- A catalog page declares its own `filters` and `sections` lists and calls
  `search-block(filters)` from `content/site.typ`; pills name only that page's
  categories. Copy the pattern in `content/index.typ` or `content/resources.typ`.
- Add every page to the nav in `content/site.typ` in tab order, and pass
  `current-page` when calling `template`.
- Add new non-index pages to the `pdf.spine`/`epub.spine` `exclude` lists in
  `rheo.toml` only if they are site furniture (like `about.typ`); catalog pages belong
  in the print spine.
- Link the page from the footer nav in `content/site.typ` (`footer-item`); a page with
  no content yet is passed `none` for its href and renders as "coming soon".
- If a tab disappears from the doc, do not delete its page silently — ask first.

## 4. Map doc sections to data files

Resource entries live in `content/data/*.typ`, one file per category, regardless of
which page renders them. Match by section heading:

| Doc section heading | Data file | Category slug |
| --- | --- | --- |
| Some Interesting Archiving / Preservation / Emulation Tools and Projects | `data/tools.typ` | `tools` |
| Some interesting Digital Archives | `data/digital-archives.typ` | `digital-archives` |
| Inspiration for Hacker Archives | `data/digital-archives.typ` | `digital-archives` |
| Hacker-specific Archives / Historical projects | `data/hacker-archives.typ` | `hacker-archives` |
| Some interesting examples of preserving particular artifacts | `data/artifacts.typ` | `artifacts` |
| Hacker Documentaries or Shows | `data/documentaries.typ` | `documentaries` |
| Magazines/News by or about Hackers | `data/magazines.typ` | `magazines` |
| Books by or about Hackers | `data/books.typ` | `books` |
| Archival Practice Overviews | `data/practice.typ` | `practice` |
| Conferences and Events | `data/events.typ` | `events` |
| Funding Sources | `data/funding.typ` | `funding` |
| People | `data/people.typ` | `people` |

Notes on this table:

- Headings carry editorial asides in the doc ("(all) and if you can find more
  wonderful", the note about ChatGPT under Documentaries). Match on the leading phrase;
  those asides are not part of the section name and never reach the site.
- "Inspiration for Hacker Archives" is bold body text, not a heading, so it arrives as
  `**Inspiration for Hacker Archives**` rather than `####`. Treat it as a section anyway.
- When a new heading appears, create its data file, import it in the page for its tab,
  add it to that page's `sections` and `filters` lists, and add it to all three
  `exclude` lists in `rheo.toml` (every `data/*.typ` file is excluded from every spine).
  If those entries currently sit in another category, move them.
- Category slugs follow the repo, not this table's wording, where the two differ —
  `events` rather than `conferences`, because the filter pill was already named that.
- An unmapped heading is a decision, not a guess: propose a category and file, and ask
  before creating it.

## 5. Entry schema

`content/site.typ` renders these fields; `name` is the only required one.

```typst
(
  name: "Display name",          // required
  url: "https://...",            // omit entirely if the doc has no link
  description: [Sentence.],       // content block, not a string
  year: 2016,                     // integer
  authors: "A, B",               // books
  director: "A, B",              // documentaries
)
```

Reading the doc's item lines:

- `(YYYY)` after a title is `year`, not part of `name`.
- `Director:` / `Directors:` / `Author:` / `Authors:` / `Creators:` on the following
  line belongs to the item above it, as `director` or `authors`.
- A bare URL as the item label means no display name was given; write a readable `name`
  and keep the URL.
- Text after `-` or `|` in an item line is usually an annotation ("- Importance of
  appraisal…", "| Society of American Archivists") — fold it into `description`, not
  `name`.
- Secondary links inside one bullet (e.g. "Ruffle c/o Rhizome", "BitCurator, the
  BitCurator Consortium") stay **one** entry; mention the secondary thing in the
  description. Split into a second entry only when the doc lists it as its own bullet.

## 6. Reconcile

Work category by category. For each:

- **In doc, not in repo** → add it. Keep the doc's order.
- **In both, different URL** → the doc wins, with one exception: when the doc's URL and
  the repo's differ only in depth on the same resource (root vs. a deep link,
  `?sort=` query junk, `#fragment`, `www.`/`http`), keep the repo's cleaner canonical
  form. When they point at *different* resources, take the doc's.
- **In both, same URL** → leave the entry alone. Preserve existing hand-written
  descriptions; do not rewrite them to match doc annotations.
- **In repo, not in doc** → do not delete. List it in the report and ask.
- **Never invent a URL.** If the doc has no link for an item, add the entry with no
  `url` field, or use the resource's obvious official home only when you are certain of
  it — and say which you did in the report.
- Fix a name only when the doc shows the repo has the wrong thing entirely (a past sync
  had "Where Wizards Stay Up Late", a book, in place of the doc's "Where Warlocks Stay
  Up Late", an interview series).
- Descriptions you write must be verifiable — fetch the page rather than guessing what
  a project is.

Escape `"` inside Typst strings (`name: "\"Complete\" List of Movies…"`), and keep
`---` for em dashes inside content blocks.

## 7. Comments pass

Comments are where curators flag broken links and argue about inclusion, and they are
invisible to the fallback path. With `includeComments: true` the connector inlines them
with a mapping to their threads.

- Comments are **intent, not content**: never treat one as an approved entry. A comment
  asking for a link is a proposal — apply it only if it is unambiguous, and say so.
- Anything unresolved (a curator reporting a dead link, a disagreement, a "verify
  this") becomes a beads issue, not a silent decision.
- Note in the report which comment threads you acted on, so a later run does not redo
  them.

## 8. Verify

```bash
rheo compile .
```

Must reach `compilation complete` with no error lines; it builds HTML, PDF, and EPUB.
Then link-check every URL you added or changed:

```bash
curl -s -o /dev/null -w "%{http_code} %{url_effective}\n" -L --max-time 20 \
  -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/120 Safari/537.36" "$URL"
```

- `403`/`429`/`000` are usually bot-blocking or sandbox DNS, not breakage — spot-check
  one in a browser-shaped fetch before believing it.
- A real `404` needs a decision: find the live replacement on the same site and use it,
  or fall back to a Wayback snapshot
  (`https://archive.org/wayback/available?url=<url-without-scheme>`), or drop the `url`
  field. Never ship a known-404 link without saying so.
- Confirm the item count changed as expected:
  `grep -o 'class="resource-item"' build/html/index.html | wc -l`

`build/` is gitignored; leave the compiled output uncommitted.

## 9. Report and file follow-ups

Summarize, grouped: entries added, links updated (with what changed and why), entries
in the repo but not the doc, comment threads acted on, and links that are dead or that
you could not resolve. Say which path you read the doc through (connector or fallback),
since the fallback saw no comments.

Per `CLAUDE.md`, use beads for anything left open — never markdown TODOs:

```bash
bd create "Dead link: <name>" -t bug -p 2 --json
```

Commit and push only if asked; follow the git conventions in `CLAUDE.md`.
