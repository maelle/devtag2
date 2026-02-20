# Rbuild ignores dev topics

This adds topic whose title starts with "An internal function: " to
`.Rbuildignore`, then removes the suffix from the title.

## Usage

``` r
rbuild_ignore(topic, base_path)
```

## Arguments

- topic:

  A roxygen2 topic

- base_path:

  Path on which roxygenize is run

## Value

No idea, the Rd roclet uses it happily.
