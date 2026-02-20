# Mark dev blocks as dev blocks

This function "marks" blocks with a dev tag by adding "An internal
function: " at the beginning of their title. This is needed because
there is no other way to let the output method of the roclet know which
topics "are" dev, because the output method of the Rd roclet no longer
has access to the tags.

## Usage

``` r
mark_dev_block(block, env, base_path)
```

## Arguments

- block:

  The block, a sort of list of tags

- env:

  No idea

- base_path:

  Path on which roxygenize is run
