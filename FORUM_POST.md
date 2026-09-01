# Draft forum post

**Subject: Letting AI assistants see the PDFs already in your Paperpile library (small CLI, MIT)**

I do a lot of literature work with AI coding assistants now, and hit a problem that I suspect is about to become common: **they can search PubMed perfectly well, but they cannot see the 2,100 PDFs already sitting in my Paperpile folder.**

It came to a head recently. I had an agent verify an argument against twelve primary papers. It searched, found them all online, and had me download eleven by hand. Every single one was already in my library. Nobody was at fault — the agent had no way to look, and I didn't think to check.

So I wrote three small tools to close that loop: https://github.com/david-priest/paperkit — MIT, unofficial, no affiliation with the Paperpile team.

```
paperfind Bannard 2013                  # is it already on disk?
paperget "Chou 2016 AP4 chronic viral"  # it isn't — one click to the PDF
papergap --pdfs ./refs --gaps           # what is this reading list missing?
```

**The workflow it enables.** Hand an agent a reading list. It runs `paperfind` on each, tells you which ones you actually lack, and `paperget` turns the remainder into a single page of links. You add them; the agent reads the ones you already had in full, rather than working from abstracts.

**A trap worth knowing about even if you never install this.** Writing these tools is how I discovered my own library had been broken for three months. At some point the Paperpile folder was moved out of Google Drive, and Paperpile quietly created a fresh empty one four hours later — so the synced folder held 83 papers while the real 2,112 sat in a stale copy elsewhere on disk. Everything looked fine in the app. If you have ever moved that folder, or had a sync hiccup, it is worth counting what is actually in it.

**The bit that surprised me.** I wanted a page of download links with a Paperpile button on each row. That does not work on a local HTML file — the extension only injects on sites it carries a parser for. But it works fine on a **PubMed results list**. So an OR-query over PMIDs gives you one tab, every paper you want, one Paperpile button each:

```
https://pubmed.ncbi.nlm.nih.gov/?term=12021782+OR+15300245+OR+27566939
```

Useful for bulk-adding a reference list by hand, with no tooling at all. One caveat found the hard way: adding a batch this way will rate-limit Paperpile's own PDF fetch (`menu_pdf.RATE_LIMITED`). Adding the references still works; for the PDFs, going straight to the PMC copy avoids the issue.

**Caveats.** Built against my own library, so the filename parsing assumes Paperpile's `<Surname> et al. <Year> - <Title>.pdf` convention. macOS and Linux, Python 3, nothing to install. `paperfind -m` reads the local Realm metadata cache read-only, which is handy for recovering a DOI when a PDF has gone missing.

The matching is fussier than you would expect, because every looser version confidently told me I owned a paper I did not. At one point "Shih 2002" matched an *Optics Letters* study of bismuth thin films — genuinely from 2002, genuinely with an author named Shih. Only the title separates them. Both resolvers carry regression suites of exactly these cases, because a confident wrong answer is worse than no answer.

Would be glad to hear if it breaks on someone else's setup, particularly anyone whose library is not on Google Drive — I have not been able to test that.
