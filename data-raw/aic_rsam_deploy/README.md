# AIC-RSAM Google Sheets collector deployment (A7)

Five minutes of manual work in your Google account. Everything else in the
round trip is automated from this workspace.

1. Create a new, empty Google Sheet in your Drive. Any name works, for
   example "AIC-RSAM A7 test".
2. In that sheet open Extensions, then Apps Script. Delete the placeholder
   code and paste the full contents of `surveyframe_collector.gs` from this
   folder. Save the project.
3. Click Deploy, then New deployment, then choose type Web app. Set
   "Execute as" to Me and "Who has access" to Anyone. Click Deploy and
   authorise when prompted.
4. Copy the Web App URL. It ends in `/exec`.
5. Back in the sheet, click Share and set general access to "Anyone with the
   link" as Viewer. This lets the R read-back run without OAuth. The sheet
   will only ever hold fake test responses.
6. Reply in the session with both URLs: the sheet URL and the Web App URL.

What happens next on this side: the AIC-RSAM survey is exported with the
Web App URL as its collection endpoint, test responses are submitted through
the deployed survey in a real browser, and the rows are read back through
both `read_sheet_responses()` and SurveyStudio's import card.
