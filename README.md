# paperkit

Three command-line tools for a local reference library: find what you already have, get one click to what you don't, and see what your reading is systematically missing.

```bash
paperfind Bannard 2013                    # already on disk?
paperget "Chou 2016 AP4 chronic viral"    # it isn't — give me one click to the PDF
papergap --pdfs ./refs --gaps             # what does this reading list omit?
```

macOS and Linux. Python 3 and a POSIX shell, no dependencies to install.

> Not affiliated with or endorsed by Paperpile. It reads a reference library that happens to be laid out the way that app lays one out; any folder of PDFs works.

## Why

Reference managers sync your PDFs into a cloud drive, so they are already on disk — but there is no way to search them from a terminal, and an agent or script has no idea they exist. So papers get re-downloaded, and the ones you *should* be reading never surface at all.

The bug that prompted this: a twelve-paper literature check ran with every paper already sitting in the library. Eleven were downloaded again by hand.

## Setup

Point it at your PDF folders, most authoritative first:

```bash
mkdir -p ~/.config/paperkit
cat > ~/.config/paperkit/stores <<'CFG'
# one path per line, best first; '#' comments allowed
~/Google Drive/My Drive/Paperpile/All Papers
~/Downloads
CFG
```

Or set `PAPERKIT_STORES` (colon-separated) for a one-off. With neither, it auto-discovers any `*/Paperpile/All Papers` under your home folder — including under `~/Library/CloudStorage/` — and ranks the largest first, which matters if a stalled sync has left you with several copies of the library in different states.

`./install.sh` symlinks the three tools into `~/bin`.

## paperfind — is it already here?

```bash
paperfind Bannard 2013              # surname + year
paperfind Shih 2002 BCR affinity    # extra words also search title-only filenames
paperfind Kuraoka 2016 -o           # open the top hit
paperfind --selftest                # regression suite
```

**Matching is deliberately fussy, because every loose version claimed a paper was owned when it was not.** Four real failures shaped it:

- a bare substring match returned `Long` for *long-lasting* and `Li` for *compared*, so the surname must sit where a surname sits — start of the basename, or after `/`, `- ` or ` and `
- the year was tested against the whole **path**, so a download folder named `2025-06/` satisfied a search for 2025 and returned a 2022 paper by the same author. Basename only now.
- `Victora and Nussenzweig 2022 - …` was invisible to a search for Nussenzweig
- a preprint filed under its bioRxiv year does not match the journal year, so recent work looked missing — hence ±1 tolerance, flagged `~year` in the output

Paperpile files PDFs as `<Surname> et al. <Year> - <Title>.pdf` by first letter of the first author's surname, eliding long titles **in the middle** with ` ... ` — so match on surname and year, never a full title. Files renamed by other tools sometimes carry no author at all, which is why extra arguments are searched against the filename as title words.

`-m` falls back to Paperpile's local Realm metadata cache, which still knows about papers whose PDF is long gone — enough to recover a DOI.

## paperget — one click per paper

Checks the library first, then resolves what is left to a direct PDF URL: PMC → Europe PMC → bioRxiv → Unpaywall (needs `UNPAYWALL_EMAIL`; skipped otherwise). It **never downloads anything** — publishers bot-wall direct requests, and defeating that is not something to automate.

`--page` writes one HTML page of links; `--open` skips it.

Both lead with a **single PubMed list containing exactly your papers**, built as an OR-query over the resolved PMIDs. Paperpile's browser extension renders its add-and-fetch button on every row of a results list, so one tab gives one button per paper. It cannot do that on this tool's own page: the extension only injects on sites it carries a parser for, and a local `file://` page runs no content script at all. Hand it a list page rather than trying to become one.

**Give it title words, not just `Surname Year`.** The title is a hard gate on *both* paths. It was not always — the library path passed surname and year to `paperfind` and returned the first line unchecked, so `"Singh 2026 BLIMP1 shapes germinal center…"` came back as owned, pointing at `Singh 2026, Dengue virus-specific memory B.pdf`. The selftest now covers that path, which is how the bug survived eight green runs.

Everything else it has got wrong, all real:

- a free-text fallback returned an iNKT paper for `Hagglof 2023` → field-tag author and year
- `Shih 2002` matched an *Optics Letters* study of bismuth thin films, genuinely 2002 with an author named Shih → only the title separates them
- verifying the title then gave a false *negative*: the right paper was at rank three and only the first hit was examined → score up to a dozen candidates per tier
- PubMed ANDs every term, so long queries return zero while a bare surname+year is a lottery — 275 papers match `Shih 2002` → `[Title]`-field queries first, degrading from there

An under-specified citation is reported `AMBIGUOUS` rather than answered. **A confident wrong answer is the worst thing this can do**, so every failure above is a case in `paperget --selftest`. Run it after touching the resolver.

## papergap — what is this reading list missing?

Seeds (a folder of PDFs, a citation list, or a BibTeX file) → their reference lists from the Semantic Scholar graph API → ranked by how many seeds cite each work → cross-checked against your library. A work cited by most of an expert-selected corpus is a landmark by consensus; one that is **not** in your library is the finding.

```bash
papergap --pdfs ./refs --min 4
papergap --list references.txt --gaps --seeds audit.tsv
papergap --bib library.bib --out report.md
```

Seeds resolve through Crossref's bibliographic query, which uses the journal, volume and pages a title search discards — that is what resolves short titles like "Germinal Centers", where a title search returns hundreds. `--seeds` dumps the identifier and route for every seed so the result is auditable.

Two things to know. **Counts are lower bounds**: Semantic Scholar's reference coverage is partial, and some papers resolve with none at all. And it keys on the *first listed author*, so a record with mangled author order shows up under the wrong name.

Structured API records, not regex over reference sections — an earlier version counted every author of an entry as a separate work, so five co-authors of one paper appeared as five distinct "landmarks".

## Licence

MIT.
