# Session CF-B (0.4.3): run 1 analysis plan block on a small instrument built
# from the components given, as Fable's sitting 2 probes did. Returns the
# block's result. `scored = FALSE` so no scale scoring runs first.
cfb_block <- function(data, method, roles, ..., options = NULL, alpha = NULL,
                      family = "inferential") {
  ins <- sframe_instrument("CF-B", components = list(...))
  b <- list(id = "B1", research_question = "q", family = family,
            method = method, roles = roles)
  b$alpha <- alpha
  if (!is.null(options)) b$options <- options
  sframe_plan(ins) <- list(b)
  suppressWarnings(run_analysis_plan(data, ins, scored = FALSE))$B1
}
cfb_num <- function(id) sframe_item(id, id, type = "numeric")
