# mcdm-paper/openalex_mcdm_query.R
# Query OpenAlex API for MCDM methods to confirm 0.4.0 core selection
# and rank alternatives for 0.4.2+ expansion. Outputs ranked results by
# work and citation count to CSV.
#
# Note: this script queries the free OpenAlex API. API rate limits may
# apply. If all queries fail, the script stops with an error rather than
# substituting placeholder numbers.

library(jsonlite)

# Define the 10 core methods in surveyframe 0.4.0
core_methods <- c(
  "AHP", "ANP", "DEMATEL", "VIKOR", "MOORA",
  "SMART", "WASPAS", "PROMETHEE", "ELECTRE", "TOPSIS"
)

# Define the additional RMCDA methods (~41 extras)
# Source: RMCDA package (CRAN 0.3.1) and related MCDM literature
rmcda_extras <- c(
  "ARAS", "COPRAS", "CODAS", "EDAS", "MARCOS", "MABAC",
  "MULTIMOORA", "OCRA", "REGIME", "SAW", "WSM", "WPM",
  "CRITIC", "ENTROPY", "SWARA", "MAIRCA", "RAFSI", "ARWU",
  "COMET", "FOCAAL", "FUCOM", "LBWA", "PIPRECIA", "RIM",
  "TODIM", "WINGS", "CRADIS", "CILOS", "RRASER", "LOPCOW",
  "IDOCRIW", "MEREC", "MAGDM", "ACOSOA", "ADAM", "AISM",
  "ALMELA", "AMOC", "BORDA", "COPELAND", "CZOPF", "DOAA",
  "GAIA"
)

all_methods <- c(core_methods, rmcda_extras)

# No hardcoded reference/fallback numbers here: if the API queries fail,
# the script stops rather than substituting placeholder data (see the
# stop() below).

# Function to query OpenAlex for a single method using system curl
query_openalex_method <- function(method_name) {
  # Construct the URL
  base_url <- "https://api.openalex.org/works"
  search_term <- URLencode(method_name)
  url_string <- paste0(
    base_url, "?search=", search_term,
    "&per_page=200&sort=-cited_by_count"
  )

  # Create a temporary file for curl output
  temp_file <- tempfile(fileext = ".json")

  tryCatch({
    # Use system curl to fetch the data
    curl_cmd <- paste("curl -s", shQuote(url_string), ">", shQuote(temp_file))
    system(curl_cmd, ignore.stderr = TRUE)

    # Read and parse the JSON response
    if (file.exists(temp_file) && file.size(temp_file) > 0) {
      response <- fromJSON(temp_file)

      # Check if there's an error in the response
      if (!is.null(response$error)) {
        message(sprintf("API returned error for %s: %s", method_name, response$message))
        return(NULL)
      }

      # Extract relevant fields
      if (!is.null(response$results) && length(response$results) > 0) {
        works <- response$results

        # Count total works and citations
        total_works <- response$meta$count
        total_citations <- sum(sapply(works, function(w) {
          ifelse(is.null(w$cited_by_count), 0, w$cited_by_count)
        }))
        avg_citations <- if (total_works > 0) total_citations / total_works else 0

        return(data.frame(
          method = method_name,
          category = if (method_name %in% core_methods) "Core (0.4.0)" else "Extra (0.4.2+)",
          total_works = total_works,
          top_work_citations = if (length(works) > 0) {
            ifelse(is.null(works[[1]]$cited_by_count), 0, works[[1]]$cited_by_count)
          } else 0,
          total_citations = total_citations,
          avg_citations_per_work = round(avg_citations, 2),
          most_cited_title = if (length(works) > 0) works[[1]]$title else "N/A",
          data_source = "OpenAlex API",
          stringsAsFactors = FALSE
        ))
      } else {
        return(NULL)
      }
    } else {
      return(NULL)
    }
  }, error = function(e) {
    return(NULL)
  }, finally = {
    # Clean up temp file
    if (file.exists(temp_file)) {
      unlink(temp_file)
    }
  })
}

# Query all methods (with rate limiting to be respectful)
message("Querying OpenAlex API for MCDM methods...")
message("Total methods to query: ", length(all_methods))
message("Note: queries may be rate-limited; a total failure stops the script rather than substituting invented data.\n")

results_list <- list()
api_success_count <- 0

for (i in seq_along(all_methods)) {
  method <- all_methods[i]
  message(sprintf("[%d/%d] Querying %s...", i, length(all_methods), method))

  result <- query_openalex_method(method)

  if (!is.null(result)) {
    results_list[[length(results_list) + 1]] <- result
    api_success_count <- api_success_count + 1
  }

  # Rate limiting
  Sys.sleep(0.2)
}

message(sprintf("\nAPI queries succeeded for: %d / %d methods", api_success_count, length(all_methods)))

# If API queries failed, stop rather than substitute placeholder numbers.
# Method selection is meant to be verified against real evidence, so a
# failed run must fail visibly rather than write a CSV that looks like a
# completed query.
if (api_success_count == 0) {
  stop(
    "OpenAlex API queries all failed (0/", length(all_methods),
    " succeeded), most likely rate-limiting or a network/proxy budget ",
    "limit. OpenAlex itself is free and unmetered, so persistent 429s ",
    "point to a local network or proxy constraint. Re-run from a network ",
    "with real OpenAlex access. No results file is written."
  )
} else {
  # Combine results into a data frame
  results_df <- do.call(rbind, results_list)
  rownames(results_df) <- NULL
}

# Sort by total citations (descending), then by total works
results_df <- results_df[order(
  -results_df$total_citations,
  -results_df$total_works,
  na.last = TRUE
), ]

# Add rank column (excluding NAs)
results_df$rank_by_citations <- NA
results_df$rank_by_citations[!is.na(results_df$total_citations)] <-
  seq_len(sum(!is.na(results_df$total_citations)))

# Reorder columns for readability
results_df <- results_df[, c(
  "rank_by_citations", "method", "category", "total_works",
  "total_citations", "avg_citations_per_work", "top_work_citations",
  "most_cited_title", "data_source"
)]

# Print summary statistics
message("\n=== OpenAlex MCDM Query Results ===")
message(sprintf("Query date: %s", Sys.Date()))
message(sprintf("Total methods analysed: %d", nrow(results_df)))
message(sprintf("Methods with citation data: %d", sum(!is.na(results_df$total_citations))))

# Print top 20 methods
message("\n=== Top 20 methods by total citations ===")
top_20 <- head(results_df[!is.na(results_df$total_citations), ], 20)
print(top_20[, c(1:4, 5, 7)], quote = FALSE)

# Save results to CSV
output_dir <- "/home/maxx/Documents/GitHub/surveyframe-dev/mcdm-paper"
output_file <- file.path(output_dir, sprintf("openalex_mcdm_results_%s.csv", Sys.Date()))

write.csv(results_df, file = output_file, row.names = FALSE)
message(sprintf("\nResults saved to: %s", output_file))

# Summary comparing core vs extras
message("\n=== Summary: Core Methods vs Extras ===")
core_summary <- results_df[results_df$category == "Core (0.4.0)" & !is.na(results_df$total_citations), ]
extra_summary <- results_df[results_df$category == "Extra (0.4.2+)" & !is.na(results_df$total_citations), ]

message(sprintf("Core methods in dataset: %d / %d", nrow(core_summary), length(core_methods)))
if (nrow(core_summary) > 0) {
  core_total <- sum(core_summary$total_citations, na.rm = TRUE)
  core_avg <- mean(core_summary$total_citations, na.rm = TRUE)
  core_median <- median(core_summary$total_citations, na.rm = TRUE)
  message(sprintf("  Total citations (all): %d", core_total))
  message(sprintf("  Average citations per method: %.1f", core_avg))
  message(sprintf("  Median citations per method: %.0f", core_median))
}

message(sprintf("\nExtras in dataset: %d / %d", nrow(extra_summary), length(rmcda_extras)))
if (nrow(extra_summary) > 0) {
  extra_total <- sum(extra_summary$total_citations, na.rm = TRUE)
  extra_avg <- mean(extra_summary$total_citations, na.rm = TRUE)
  extra_median <- median(extra_summary$total_citations, na.rm = TRUE)
  message(sprintf("  Total citations (all): %d", extra_total))
  message(sprintf("  Average citations per method: %.1f", extra_avg))
  message(sprintf("  Median citations per method: %.0f", extra_median))
}

# Expansion ranking
message("\n=== Expansion Priority Order (Top 25, 0.4.2+) ===")
expansion_ranked <- results_df[
  results_df$category == "Extra (0.4.2+)" & !is.na(results_df$total_citations),
]
if (nrow(expansion_ranked) > 0) {
  print(head(expansion_ranked[, c(1:4, 5, 7)], 25), quote = FALSE)
}

# Core methods verification
message("\n=== Core Method Rankings (should all be top performers) ===")
core_ranked <- results_df[
  results_df$category == "Core (0.4.0)" & !is.na(results_df$total_citations),
]
if (nrow(core_ranked) > 0) {
  print(core_ranked[, c(1:4, 5, 7)], quote = FALSE)
}

message("\nDone.")
