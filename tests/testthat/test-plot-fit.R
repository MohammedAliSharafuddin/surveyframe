# tests/testthat/test-plot-fit.R
# Charts exported at the default 6.5 by 4 inches clipped long titles,
# subtitles, choice labels and legends at the edges (CX-23). The shared
# finishing step wraps the text to the export width.

long_title <- paste("Distribution of the very long variable name that describes",
                    "how satisfied customers felt about delivery and returns")
long_choices <- c("Strongly dissatisfied with the delivery service overall",
                  "Somewhat dissatisfied with the delivery service overall",
                  "Neither satisfied nor dissatisfied with the service",
                  "Somewhat satisfied with the delivery service overall",
                  "Strongly satisfied with the delivery service overall")

# Widest drawn extent in inches of the named grobs in a 6.5 by 4 render.
fit_extents <- function(p, width = 6.5, height = 4) {
  grDevices::pdf(NULL, width = width, height = height)
  on.exit(grDevices::dev.off(), add = TRUE)
  g <- ggplot2::ggplotGrob(p)
  w <- function(nm) {
    idx <- which(g$layout$name %in% nm)
    if (!length(idx)) return(0)
    max(vapply(g$grobs[idx], function(x)
      grid::convertWidth(grid::grobWidth(x), "in", valueOnly = TRUE), numeric(1)))
  }
  fixed <- vapply(seq_along(g$widths), function(i) {
    if (grid::unitType(g$widths[i]) == "null") 0
    else grid::convertWidth(g$widths[i], "in", valueOnly = TRUE)
  }, numeric(1))
  list(title = w("title"), subtitle = w("subtitle"), caption = w("caption"),
       guide = w("guide-box-bottom"), fixed = sum(fixed), width = width)
}

test_that("a long title, subtitle and caption wrap to the export width", {
  skip_if_not_installed("ggplot2")
  res <- list(test = "frequency", variable = long_title,
              table = data.frame(Value = long_choices, Frequency = c(3, 5, 9, 12, 7)))
  p <- sframe_plot_for_result(res, NULL)
  p <- p + ggplot2::labs(subtitle = paste(long_title, long_title),
                         caption = paste(long_title, long_title))
  p <- sframe_fit_plot(p)
  labs <- ggplot2::get_labs(p)
  expect_match(labs$title, "\n", fixed = TRUE)
  expect_match(labs$subtitle, "\n", fixed = TRUE)
  expect_match(labs$caption, "\n", fixed = TRUE)
  e <- fit_extents(p)
  expect_lte(e$title, e$width)
  expect_lte(e$subtitle, e$width)
  expect_lte(e$caption, e$width)
})

test_that("the default builder output already fits at 6.5 by 4 inches", {
  skip_if_not_installed("ggplot2")
  res <- list(test = "frequency", variable = long_title,
              table = data.frame(Value = long_choices, Frequency = c(3, 5, 9, 12, 7)))
  p <- sframe_plot_for_result(res, NULL)
  expect_match(ggplot2::get_labs(p)$title, "\n", fixed = TRUE)
  e <- fit_extents(p)
  expect_lte(e$title, e$width)
  expect_lte(e$fixed, e$width)
})

test_that("a long legend wraps its keys onto rows within the width", {
  skip_if_not_installed("ggplot2")
  d <- data.frame(x = rep(1:2, each = 5), y = 1:10,
                  g = factor(rep(long_choices, 2), levels = long_choices))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, fill = g)) + ggplot2::geom_col() +
    theme_surveyframe()
  before <- fit_extents(p)
  expect_gt(before$guide, before$width)
  e <- fit_extents(sframe_fit_plot(p))
  expect_lte(e$guide, e$width)
})

test_that("fitting honours a narrower or wider figure width and short text is untouched", {
  skip_if_not_installed("ggplot2")
  p <- ggplot2::ggplot(data.frame(x = 1, y = 1), ggplot2::aes(x, y)) +
    ggplot2::geom_point() + ggplot2::labs(title = "Short")
  expect_identical(ggplot2::get_labs(sframe_fit_plot(p))$title, "Short")
  q <- p + ggplot2::labs(title = long_title)
  n_narrow <- lengths(regmatches(ggplot2::get_labs(sframe_fit_plot(q, width = 4))$title,
                                 gregexpr("\n", ggplot2::get_labs(sframe_fit_plot(q, width = 4))$title)))
  n_wide <- lengths(regmatches(ggplot2::get_labs(sframe_fit_plot(q, width = 12))$title,
                               gregexpr("\n", ggplot2::get_labs(sframe_fit_plot(q, width = 12))$title)))
  expect_gt(n_narrow, n_wide)
})

test_that("fitting leaves a hidden legend hidden and the caller's plot alone", {
  skip_if_not_installed("ggplot2")
  d <- data.frame(g = c("a", "b"), h = c("x", "y"))
  p1 <- ggplot2::ggplot(d, ggplot2::aes(g, fill = h)) + ggplot2::geom_bar() +
    ggplot2::theme(legend.position = "none")
  expect_identical(sframe_fit_plot(p1)$theme$legend.position, "none")
  p2 <- ggplot2::ggplot(d, ggplot2::aes(g, fill = h)) + ggplot2::geom_bar() +
    ggplot2::guides(fill = "none")
  expect_true(sframe_guide_hidden(sframe_fit_plot(p2), "fill"))
  p3 <- ggplot2::ggplot(d, ggplot2::aes(g, fill = h)) + ggplot2::geom_bar() +
    ggplot2::scale_fill_manual(values = c("red", "blue"))
  invisible(sframe_fit_plot(p3))
  expect_true(inherits(p3$scales$get_scales("fill")$labels, "waiver"))
})
