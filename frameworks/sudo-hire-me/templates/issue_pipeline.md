# frameworks/sudo-hire-me/templates/issue_pipeline.md

# {{company}} — {{role.title}}

**Location:** {{role.location}}
**Source:** {{role.source}}

---

## 📌 Status

- **Stage:** {{status.stage}}
- **Last event:** {{status.last_event}}
- **Last updated:** {{status.last_updated}}
- **Main issue:** #{{main_issue}}

---

## 🗓️ Rounds

| Round | Status | Date | Interviewer | Sub-issue |
|---|---|---|---|---|
{{rounds_list}}

---

## 🔧 Open gaps

{{open_gaps}}
