# The standard demo branding

The `render` block
[`sframe_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo.md)
splices in when `branded = TRUE`. Read it, change a colour, and paste it
into your own instrument.

## Usage

``` r
sframe_demo_branding()
```

## Value

A named list suitable for `sf_instrument(render = )`: the display
`mode`, the `theme` colour, the `submit_label`, and the `welcome`,
`thankyou` and `header` blocks.

## Examples

``` r
branding <- sframe_demo_branding()
branding$welcome$title
#> [1] "Thank you for coming"
branding$theme
#> [1] "#2563eb"
```
