# tests/testthat/helper-references-fixture.R
#
# No bundled .sframe has references, so the citation picker and the builder's
# reference tests use this instrument. Its 4 references cover the author
# shapes the picker displays: 1 personal author, 3 authors (et al.), an
# organisation, and a work with no year.

sframe_references_fixture <- function() {
  ins <- sframe_instrument(
    "Citing sources", version = "1.0.0",
    components = list(
      sframe_item("sat", "How satisfied are you?", type = "likert",
                  choice_set = "agree5"),
      sframe_item("group", "Group", type = "single_choice", choice_set = "yn"),
      sframe_choice_set("agree5", 1:5, c("SD", "D", "N", "A", "SA")),
      sframe_choice_set("yn", c("0", "1"), c("No", "Yes"))),
    analysis_plan = list(list(
      id = "rq1", research_question = "Does satisfaction differ by group?",
      family = "group_comparison", method = "t_test_ind", test = "t_test_ind",
      roles = list(outcome = "sat", group = "group"),
      variables = c("sat", "group"))))
  sframe_add_references(ins,
    sframe_reference("likert_1932", "A technique for the measurement of attitudes",
                     author = "Likert, R.", year = 1932,
                     container = "Archives of Psychology", cited_by = "item:sat"),
    sframe_reference("parasuraman_1988", "SERVQUAL: A multiple-item scale",
                     author = c("Parasuraman, A.", "Zeithaml, V. A.", "Berry, L. L."),
                     year = 1988, container = "Journal of Retailing",
                     cited_by = "plan:rq1"),
    sframe_reference("rcore_2024", "R: A language and environment for statistical computing",
                     author = "{R Core Team}", year = 2024, type = "software"),
    sframe_reference("max_nd", "An undated working paper on survey frames",
                     author = "Max, A.", type = "report"))
}
