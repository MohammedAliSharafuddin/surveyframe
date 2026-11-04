# R/studio_amend_dialog.R
#
# SurveyStudio's 1 amendment dialog (session 8a, UX-06 and UX-19). Every
# change Studio records as an amendment opens it: a save from Design on an
# instrument with a history, a revised file imported on the Amendments
# screen, and later the Drop from scale, Put back, Quality and Responses and
# plan-change starts. Before anything is applied it shows what the change
# touches, from sframe_amendment_preview(), and the version suggested, from
# sframe_suggest_version(). Its verbs are "Record amendment" and "Cancel",
# with "Save as a new instrument" where the start allows it. No screen
# applies a change itself: they all call open() and get the amended
# instrument back.

sframe_studio_reason_choices <- c(
  "Data correction" = "data_correction",
  "Bot or fraudulent-response removal" = "bot_removal",
  "Model respecification" = "model_respecification",
  "Instrument revision" = "instrument_revision",
  "Other" = "other"
)

# A dialog button. Each click sends 1 event input, `action`, naming the
# button. An actionButton would not do: the dialog is drawn again for each
# opening, each new button counts from 0, and a click that repeats a count
# the server already saw does not reach the observer.
sframe_studio_amend_button <- function(ns, what, label, class) {
  shiny::tags$button(id = ns(what), type = "button", class = paste("btn", class),
    onclick = sprintf(paste0("Shiny.setInputValue('%s', {what: '%s', at: Date.now()}, ",
                             "{priority: 'event'})"), ns("action"), what),
    label)
}

# What the change touches, as plain lines for the dialog.
sframe_studio_amend_summary <- function(preview) {
  lines <- character(0)
  if (!isTRUE(preview$changed)) {
    return("Nothing recorded in the instrument has changed.")
  }
  lines <- c(lines, paste0("Changed: ", paste(preview$changed_fields, collapse = ", "), "."))
  if (length(preview$scales)) {
    lines <- c(lines, paste0("Scales whose scoring changes: ",
                             paste(preview$scales, collapse = ", "), "."))
  }
  if (length(preview$models)) {
    lines <- c(lines, paste0("Models: ", paste(sprintf("%s (%s)", preview$models,
      unlist(preview$model_detail[preview$models])), collapse = ", "), "."))
  }
  if (length(preview$plan_blocks)) {
    lines <- c(lines, paste0("Plan blocks: ", paste(sprintf("%s (%s)", preview$plan_blocks,
      unlist(preview$plan_detail[preview$plan_blocks])), collapse = ", "), "."))
  }
  if (isTRUE(preview$design_forced)) {
    lines <- c(lines, paste0("This changes ", paste(preview$design_changes, collapse = " and "),
      ", so it is a design amendment and needs a deviation report."))
  }
  lines
}

# A long text field that takes the shared format toolbar and citation
# picker in Studio: its textarea carries data-cite, the field's name.
sframe_studio_cite_field <- function(tag, label) {
  htmltools::tagQuery(tag)$find("textarea")$addAttrs(`data-cite` = label)$allTags()
}

# The dialog itself. `defaults` may hold reason_code, reason_text and
# deviation_report, which a start fills in (Drop from scale fills the reason
# from sframe_item_flags()).
sframe_studio_amend_modal <- function(ns, preview, start_label, defaults = list(),
                                      allow_new = FALSE) {
  code <- defaults$reason_code %||% "instrument_revision"
  tier <- if (isTRUE(preview$design_forced)) "design" else sframe_amendment_default_tier(code)
  tiers <- c("Pipeline (data or wording)" = "pipeline",
             "Design (what is measured or analysed)" = "design")
  if (isTRUE(preview$design_forced)) tiers <- tiers["Design (what is measured or analysed)"]
  sug <- preview$suggest[[tier]]
  why <- vapply(c("design", "pipeline"), function(t) {
    s <- preview$suggest[[t]]
    if (is.null(s$version)) s$reason else sprintf("%s: %s. %s", t, s$version, s$reason)
  }, character(1))
  shiny::modalDialog(
    title = "Record an amendment",
    size = "l",
    easyClose = FALSE,
    shiny::tags$p(class = "hint", start_label),
    shiny::tags$div(class = "plan-msg", id = ns("summary"),
                    lapply(sframe_studio_amend_summary(preview), shiny::tags$div)),
    shiny::selectInput(ns("reason_code"), "Reason", choices = sframe_studio_reason_choices,
                       selected = code),
    shiny::textAreaInput(ns("reason_text"), "What changed and why", rows = 2,
                         value = defaults$reason_text %||% "",
                         placeholder = "Required."),
    shiny::selectInput(ns("tier"), "Tier", choices = tiers, selected = tier),
    shiny::conditionalPanel(
      condition = "input.tier == 'design'", ns = ns,
      sframe_studio_cite_field(shiny::textAreaInput(ns("deviation_report"), "Deviation report", rows = 3,
        value = defaults$deviation_report %||% "",
        placeholder = "What changed in the research question, method or model, and why."), "Deviation report")),
    shiny::fluidRow(
      shiny::column(6, shiny::textInput(ns("author"), "Author (optional)")),
      shiny::column(6, shiny::textInput(ns("signoff"), "Second reviewer sign-off (optional)"))
    ),
    shiny::textInput(ns("version"), "Version after the amendment",
                     value = sug$version %||% (preview$version %||% "")),
    shiny::tags$p(class = "hint", id = ns("version_why"),
                  paste0("Currently ", preview$version %||% "", ". Suggested, ",
                         paste(why, collapse = " "))),
    footer = shiny::tagList(
      sframe_studio_amend_button(ns, "cancel", "Cancel", "btn-default"),
      if (isTRUE(allow_new)) sframe_studio_amend_button(ns, "as_new", "Save as a new instrument", "btn-default"),
      sframe_studio_amend_button(ns, "record", "Record amendment", "btn-primary")
    )
  )
}

# The module. open(before, after, start_label, on_apply, on_cancel, defaults,
# allow_new) shows the dialog. on_apply(instrument, how) receives the amended
# instrument, with how = "amendment", or the new instrument, with how = "new".
sframe_studio_amend_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    pending <- NULL
    open <- function(before, after, start_label, on_apply, on_cancel = NULL,
                     defaults = list(), allow_new = FALSE) {
      preview <- sframe_amendment_preview(before, after)
      pending <<- list(before = before, after = after, preview = preview,
                       on_apply = on_apply, on_cancel = on_cancel)
      shiny::showModal(sframe_studio_amend_modal(session$ns, preview, start_label,
                                                 defaults, allow_new))
    }
    shiny::observeEvent(input$reason_code, {
      p <- pending
      if (is.null(p) || isTRUE(p$preview$design_forced)) return()
      t <- sframe_amendment_default_tier(input$reason_code)
      shiny::updateSelectInput(session, "tier", selected = t)
    }, ignoreInit = TRUE)
    shiny::observeEvent(input$tier, {
      p <- pending
      if (is.null(p) || !input$tier %in% names(p$preview$suggest)) return()
      v <- p$preview$suggest[[input$tier]]$version
      if (!is.null(v)) shiny::updateTextInput(session, "version", value = v)
    }, ignoreInit = TRUE)
    shiny::observeEvent(input$action, {
      switch(input$action$what %||% "",
             cancel = do_cancel(), record = do_record(), as_new = do_as_new())
    })
    do_cancel <- function() {
      p <- pending
      pending <<- NULL
      shiny::removeModal()
      if (!is.null(p$on_cancel)) p$on_cancel()
    }
    do_record <- function() {
      p <- pending
      if (is.null(p)) return()
      version <- trimws(input$version %||% "")
      amended <- tryCatch(suppressMessages(amend_sframe(
        p$before, p$after,
        reason_code = input$reason_code,
        reason_text = input$reason_text %||% "",
        tier = if (isTRUE(p$preview$design_forced)) "design" else input$tier,
        author = sframe_empty_to_null(trimws(input$author %||% "")),
        deviation_report = sframe_empty_to_null(trimws(input$deviation_report %||% "")),
        second_signoff = sframe_empty_to_null(trimws(input$signoff %||% "")),
        version = if (nzchar(version)) version else NULL
      )), error = function(e) {
        shiny::showNotification(paste("Not recorded:", conditionMessage(e)),
                                type = "error", duration = 10)
        NULL
      })
      if (is.null(amended)) return()
      pending <<- NULL
      shiny::removeModal()
      p$on_apply(amended, "amendment")
    }
    do_as_new <- function() {
      p <- pending
      if (is.null(p)) return()
      version <- trimws(input$version %||% "")
      if (!nzchar(version) || (identical(version, p$before$meta$version %||% "") &&
          identical(p$after$meta$title %||% "", p$before$meta$title %||% ""))) {
        shiny::showNotification(
          "A new instrument needs a new version or title. Nothing was saved.",
          type = "error", duration = 10)
        return()
      }
      fresh <- p$after
      fresh$amendments <- list()
      fresh$meta$version <- version
      attr(fresh, "sframe_origin") <- NULL
      attr(fresh, "sframe_verified") <- NULL
      pending <<- NULL
      shiny::removeModal()
      p$on_apply(fresh, "new")
    }
    list(open = open)
  })
}

# The version and the amendment count, as Studio's status line and Open card
# show them: "1.1.0, 2 amendments".
sframe_studio_version_label <- function(instrument) {
  n <- length(instrument$amendments %||% list())
  paste0(instrument$meta$version %||% "no version", ", ",
         if (n == 0) "no amendments" else if (n == 1) "1 amendment"
         else paste(n, "amendments"))
}

# The full amendment history for the Amendments screen, oldest first: date,
# tier, reason, what changed, and the content hashes before and after. An
# entry records no version, so the screen gives the current version in its
# heading instead.
sframe_studio_amendment_history <- function(instrument) {
  log <- sframe_get_amendments(instrument)
  if (nrow(log) == 0) return(NULL)
  codes <- stats::setNames(names(sframe_studio_reason_choices),
                           unname(sframe_studio_reason_choices))
  reason <- ifelse(log$reason_code %in% names(codes), codes[log$reason_code],
                   log$reason_code)
  short <- function(h) ifelse(is.na(h) | !nzchar(h), "", substr(h, 1, 12))
  data.frame(
    Date = substr(log$timestamp, 1, 10),
    Tier = tools::toTitleCase(log$tier),
    Reason = paste0(reason, ": ", log$reason_text),
    `What changed` = log$changed_fields,
    `Deviation report` = ifelse(is.na(log$deviation_report), "", log$deviation_report),
    `Hash before` = short(log$previous_hash),
    `Hash after` = short(log$new_hash),
    check.names = FALSE, stringsAsFactors = FALSE
  )
}
