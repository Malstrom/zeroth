<!-- frameworks/daneel/templates/issue_comment_close.md -->
<!-- Template for the closing comment posted by close_task scenario. -->
<!-- This comment is the permanent record of how the task was resolved. -->
<!-- It is read by recall and ingest_task (prior art search). -->
<!-- Tracking code = the client's own external tracker code (e.g. TORMED-389), -->
<!-- carried over from the issue body's tracker_code field. Only issues with a -->
<!-- non-none tracking code are eligible for generate_time_tracking_report. -->

## Task closed

**Resolved:** {{YYYY-MM-DD}}

**Tracking code:** {{tracker_code | none}}

**How it was resolved:**
{{2-3 lines. What was done, what was delivered, how the problem was solved.
No raw log — distilled summary only.}}

**Output delivered:**
{{What was sent or delivered to the client — document name, email sent, PR merged, etc. | none}}

**Playbook:**
{{Playbook used: clients/{slug}/playbooks/{filename} | none}}
{{Playbook created this session: yes | no}}
{{Promoted to root: yes | no | not evaluated}}
