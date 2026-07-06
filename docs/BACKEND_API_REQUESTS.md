# Backend — What the App Still Needs

Short list, most important first. The app is fully connected to the current API;
these are the missing pieces that block features.

---

## 1. Sensors endpoint (Sensors screen is empty without it)
`GET /sensors`
```json
{
  "success": true,
  "data": {
    "sensors": [
      { "type": "temperature", "currentValue": 24.5, "unit": "°C", "status": "normal" }
    ],
    "alerts": [
      { "id": "...", "type": "temperature", "message": "...", "timestamp": "ISO-date" }
    ]
  }
}
```
`type`: temperature | humidity | soil_moisture | light · `status`: normal | warning | critical

## 2. Add `scanId` to the heal plan (needed for Recovery / rescan)
`GET /heal-plans/:id` should include the scan it was created from:
```json
{ "_id": "...", "disease": "...", "status": "active", "scanId": "THE_ORIGINAL_SCAN_ID", "tasks": [] }
```

## 3. List a scan's rescans (needed for Recovery progress)
`GET /scans/:id/rescans` → the follow-up scans with their comparison
(`improved`, `severityDelta`). Right now we can create a rescan but can't read them back.

## 4. Add a link id to notifications (so tapping opens the right screen)
Add `relatedId` (e.g. the heal-plan id) to each notification:
```json
{ "_id": "...", "type": "task_reminder", "title": "...", "relatedId": "HEAL_PLAN_ID", "read": false }
```

---

### Quick confirmations (one-word answers are fine)
- Heal-plan `progress`: is it `0–100` or `0.0–1.0`?
- Task toggle `PATCH /heal-plans/:planId/tasks/:taskIndex`: just a toggle, no body? Index matches the `tasks` order?
- `GET /heal-plans` list key: is it `healPlans` or `plans`?
- Token expiry returns `401`?

**Priority for us:** #1 (Sensors) and #2 + #3 (Recovery).
