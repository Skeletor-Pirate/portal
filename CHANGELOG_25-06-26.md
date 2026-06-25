# Changelog

## [25-06-2026] - AI Tools Module Enhancements

### Added
- **Worksheet Module**: Added an interactive "Submit Answers" button that evaluates student responses via a new backend AI endpoint (`/api/v1/evaluate_worksheet/`). Shows visual grading, scores, and specific feedback for each question answered.

### Fixed
- **Quiz Module**: Replaced the static quiz rendering where answers were pre-selected. Quizzes are now fully interactive, meaning users must choose an answer first, after which they will receive immediate Correct/Incorrect feedback alongside an explanation.
- **Notes Module**: Fixed practice problems raw JSON formatting to clearly display the Problem and Solution context correctly formatted rather than rendering plain JSON.
- **Question Paper Module**: Cleaned up the JSON representation of section arrays inside question papers so it now displays clear textual output in a readable format.
