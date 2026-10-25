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

A named list of class `sframe_branding`, suitable for
`sf_instrument(render = )`: the display `mode`, the `theme` colour, the
`submit_label`, and the `welcome`, `thankyou` and `header` blocks.
Printing it shows each setting as a respondent meets it.
[`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md)
and
[`sframe_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo.md)
store it as a plain list.

## See also

[`preview_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/preview_demo.md)
to see the branding applied to a demo.

## Examples

``` r
branding <- sframe_demo_branding()
branding
#> <sframe demo branding>
#>   Theme:         #2563eb
#>   Mode:          standard
#>   Header:        Riverside Conference Centre, progress bar shown
#>   Welcome:       "Thank you for coming"
#>                  This takes about 3 minutes. Your answers help us plan next year's event.
#>   Consent:       "I am happy for my answers to be used in the event report.", required
#>   Start button:  "Start"
#>   Submit button: "Send my feedback"
#>   Thank you:     "Thank you. Your feedback has been recorded."
#> 
#> A render block for sf_instrument(render = ). See it applied with
#> preview_demo("two_group"), or use sframe_demo(name, branded = TRUE).
branding$welcome$title
#> [1] "Thank you for coming"
branding$theme
#> [1] "#2563eb"
```
