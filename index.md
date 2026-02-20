# devtag2

The goal of devtag2 is to help you get Rd manual pages for your internal
functions, without making those manual pages accessible to users.

When you use devtag2, you use `@dev` instead of `@export` for internal
functions.

It follows the same principles as its inspiration
[devtag](https://github.com/moodymudskipper/devtag/) by Antoine Fabri:

- Manual pages are added to `.Rbuildignore` so users don’t see them.
- Manual pages are **not** added to `.gitignore` so collaborators see
  them.

## Installation

You can install the development version of devtag2 like so:

``` r
pak::pak("maelle/devtag2")
```

Then in each package where you use devtag2 you need to register its
roclet in `DESCRIPTION`:

    Roxygen: list(markdown = TRUE, roclets = c("collate", "devtag2::super_rd", "namespace"))

And you probably should add this line as well, so collaborators know
where to get devtag2 from:

    Config/Needs/build: maelle/devtag2

## Example

I added the `@dev` tag to the documentation of the internal function
[`rbuild_ignore()`](reference/rbuild_ignore.md). You can see its manual
pages in `man/rbuild_ignore.Rd` in the package source.

## Why a new package?!

I was annoyed at devtag’s re-creating the internal manual pages every
time `devtools::document()` was run, even if they hadn’t changed. I
wanted to try creating the roclet as an extension of the Rd roclet
rather than a brand-new roclet, because I assumed this would prevent the
aforementioned annoyance. This is the strategy that was used in
[roxygenlabs](https://github.com/gaborcsardi/roxygenlabs), the former
incubator of roxygen2’s features. Piggy-backing on the Rd roclet makes
the experience nicer and seems more natural to me.

I was also hoping the code would be simpler but I’m not so sure it
really is: - The Rbuildignoring needs to happen in the output method
where we have access to the filename of the Rd file. But at that stage
we no longer have access to tags, only to the contents of the Rd file. -
Therefore in the process method I “mark” the block as a dev block by
changing its title, adding “Internal function:” before the title. Then
in the output method I remove the mark. This feels a bit hacky still!

In my current understanding, to make the implementation of `@dev`
simpler it’d have to live within roxygen2. The [RoxyTopic
objects](https://github.com/r-lib/roxygen2/blob/main/R/topic.R) would
get an “internal” field, that the process method of the Rd roclet would
fill, and that the output method of the Rd roclet would use to decide
whether to `.Rbuildignore` a topic.

A drawback to devtag2’s roclet being a roclet to use **instead of** the
Rd roclet means you can’t use it in combination with a roclet that also
extends the Rd roclet. For instance, this would be problematic in igraph
where we use both devtag and
[igraph.r2cdocs](https://github.com/igraph/igraph.r2cdocs/) that
implements an extension of the Rd roclet.
