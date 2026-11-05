# tests/testthat/helper-quarto-render.R
#
# Runs `quarto render` in `dir` with environment variables set for that call
# alone. system2(env = ) prefixes the command with VAR=value, which Windows
# does not read, so Quarto got the pair as an argument and stopped with
# 'Unknown option "--to"' (CI run 41994727848). The variables are set with
# Sys.setenv() and restored after. Returns Quarto's output lines.
quarto_render_in <- function(dir, to, env = character(0)) {
  old_env <- Sys.getenv(names(env), unset = NA, names = TRUE)
  on.exit({
    for (v in names(env)) {
      if (is.na(old_env[[v]])) Sys.unsetenv(v) else do.call(Sys.setenv, as.list(old_env[v]))
    }
  }, add = TRUE)
  if (length(env)) do.call(Sys.setenv, as.list(env))
  old_wd <- setwd(dir)
  on.exit(setwd(old_wd), add = TRUE)
  suppressWarnings(system2("quarto", c("render", "report.qmd", "--to", to),
                           stdout = TRUE, stderr = TRUE))
}
