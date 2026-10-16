# Cloud Computing Marks Management Portal

## Included
- `index.html`: browser-based portal preview and Supabase-connected starter UI.
- `supabase_schema.sql`: database table, marks validation trigger, and row-level security policies.

## Features
- Add, edit, and delete student records.
- Import student data from CSV; export student details, marks, and full backups to CSV.
- Search and filter by batch, type, and lab day.
- Ten labs per student; each lab has Attendance (max 1), Execution (max 1), Viva (max 2).
- Automatically calculates each lab total, CLE out of 40, Mid-Term out of 20, and combined recorded marks out of 60.
- Validates marks in the browser and database.
- Student-wise marks summary.

## Important limitation
The page starts in **local demo mode**. Local demo records stay in the current browser and do not sync across devices. Do not use local demo mode as the official shared marks store. For online use, configure Supabase as described below. This is a starter implementation, not a deployed production service.

## Configure online storage
1. Create a Supabase project at https://supabase.com/.
2. Open the project's SQL Editor and run `supabase_schema.sql`.
3. In Supabase Authentication, create or invite the intended faculty account(s). Disable public sign-ups if not needed.
4. For strict faculty-only access, implement the allowlist approach noted at the bottom of the SQL file. The included basic policies permit all authenticated accounts in that project, so do not invite unintended users.
5. Open `index.html` in a browser with internet access. Go to **Storage & Setup**, enter the project URL and anon/public key, and click **Connect and sign in**.
6. Sign in with the faculty account. The portal then loads and saves records in the shared database.
7. Host the page on an HTTPS site for convenient access across devices. Do not place a Supabase service-role key in the browser.

## CSV import format
Required headers are `Regn. No.` and `Student Name`. Optional headers: `Batch`, `Email`, `Type`, `Day of Lab`. Use **Download CSV Template** to obtain an example. Import matches on registration number; matching students have their student metadata updated, while existing marks are retained.

## Marks model
- Lab total = Attendance + Execution + Viva (maximum 4).
- CLE = sum of the 10 lab totals (maximum 40).
- Mid-Term = separate mark (maximum 20).
- Combined recorded marks = CLE + Mid-Term (maximum 60).

## Before official use
- Configure a strict faculty allowlist and review institutional privacy/security requirements.
- Test import/export, duplicate registration numbers, all marks boundaries, backup recovery, and access from another device.
- Consider adding audit history and a controlled marks-lock/finalization process if required by the examination office.
