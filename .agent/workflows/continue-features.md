---
description: Continue implementing features from feature_list.json
---

# Continue Feature Implementation

When the user says "continue features" or "continue working on mysched", follow these steps:

## 1. Read Current State
// turbo
Read `.agent/feature_list.json` to see current feature status

## 2. Check Session Notes
// turbo
Read `.agent/session_notes.md` to see what was done last session

## 3. Find Next Feature
Look for features with status `approved` or `in_progress`:
- If `in_progress` exists, continue that one
- If only `approved`, start the highest priority one
- If none approved, ask user which to implement

## 4. Implement Feature
For the selected feature:
1. Update status to `in_progress` in feature_list.json
2. Create/modify files listed in `files_to_modify`
3. Test the implementation
4. Mark as `completed` when all acceptance criteria met

## 5. Update Tracking
After each feature:
1. Update `feature_list.json` status and summary counts
2. Add entry to `session_notes.md` with what was done
3. Git commit with message: `feat: [feature name]`

## 6. Continue or Wait
If time permits, move to next approved feature. Otherwise, update session notes with stopping point.
