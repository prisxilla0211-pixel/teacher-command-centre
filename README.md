# Teacher Command Centre — Private Cloud Edition (Email & Password)

This package is your updated Blush & Ivory planner with **email-and-password sign-in**, not Google. It includes the existing student directory, schedule, subject hubs, attendance, homework, learning progress, lesson plans, resources, tasks, meetings, unlimited-year calendar and JSON backups.

## Step 1 — Set up Supabase
1. Open https://supabase.com/dashboard and select your project.
2. Go to **Authentication → Sign In / Providers → Email** (the wording may differ slightly).
3. Enable the **Email** provider.
4. Go to **Authentication → Settings** (or **Sign In / Providers → User Signups**) and **disable new user signups** / **Allow new users to sign up**. Do not disable email authentication itself.
5. Google authentication is no longer needed; you may disable **Google** under Providers.
6. Open **SQL Editor → New query**, paste `supabase_schema.sql`, and run it. The script enables Row Level Security and explicitly restricts access to the approved account.
7. **Create your own account:** Under **Authentication → Users → Add user → Create new user**, enter your email and a strong, unique password. Choose **Auto Confirm User** / **Confirm email** if available. This is an administrator-created user, not a public sign-up.
8. Find your new user in **Authentication → Users** and copy the user's **UUID** (not their email address).
9. In **SQL Editor**, run the following with your actual UUID:
   ```sql
   insert into public.app_access (user_id)
   values ('YOUR-USER-UUID-HERE')
   on conflict (user_id) do nothing;
   ```
   Only add **your own** UUID. Anyone else who signs in will still be blocked by database RLS.

### Important
Never put your Supabase account password, the teacher's login password, database password, service-role key, or any secret key into `config.js`, Netlify, or ChatGPT. Only the **public Supabase URL and publishable/anon key** belong in `config.js`.

## Step 2 — Configure the website
1. Open `config.js` in a text editor.
2. Find your **Project URL** and **publishable/anon key** in Supabase **Project Settings → API** (or **API Keys**).
3. Replace the placeholders in `config.js` with those two values.
4. Save the file.

## Step 3 — Publish on Netlify
1. Open https://app.netlify.com/ and sign in.
2. Choose **Add new project → Deploy manually** (labels may vary).
3. Upload the **website files** `index.html`, `config.js`, `netlify.toml` together, as the root of a folder or ZIP. Do not need to publish `README.md` or `supabase_schema.sql`.
4. Open the assigned `https://...netlify.app` address.
5. Enter your email and password to sign in.

Unlike Google OAuth, **email-and-password sign-in does not need a Google Cloud project, OAuth Client ID, Client Secret or Google callback URL**. Supabase's **Site URL** is useful for future password recovery links but not needed for this initial sign-in flow.

## Step 4 — Verify privacy and synchronisation
1. Sign in on your laptop.
2. Create a test student with a fictitious name and wait for the indicator **✓ Synced to cloud**.
3. Open the site on your phone, sign in with the same credentials, and confirm the test record appears.
4. If you have old planner data, open your original local HTML planner on the device where it was used, click **Export backup**, then use **Import** on the new cloud website. Wait for **✓ Synced to cloud**.

## Backups and limitations
- Export JSON backups regularly and store them securely.
- Edits need an internet connection and successful cloud synchronisation.
- Avoid editing on multiple devices at the same time; the current system uses last-write-wins updates.
- Supabase free projects can pause after inactivity and provider quotas can change.
- There is **no self-service password recovery in this version**. If you forget your password, use **Authentication → Users** in your own Supabase dashboard to send a recovery email or update credentials through the supported dashboard workflow.
- The website uses a publicly visible Supabase publishable/anon key, which is normal. RLS and the approved-user table enforce access restrictions.
- Confirm your centre permits storing student records in your external cloud account before entering real student data.
- Verify provisional 2027 Malaysian public holidays before relying on them for scheduling.

## Troubleshooting
- **Invalid login credentials**: check the email and password, and that your account is confirmed in Supabase.
- **Account not yet approved**: add your own user UUID to `app_access` in SQL Editor.
- **Config missing**: update `config.js` and redeploy.
- **Sync failed**: check network, Supabase project status and that `supabase_schema.sql` was executed.
- **Empty cloud planner**: import your original JSON backup if needed.

## Calendar years
The calendar now supports any year from 1 to 9999. Use the Previous/Next month buttons, type a year directly, or select Today to jump back to the current month. Student lessons display in every year. **Public holiday labels are only bundled for 2026–2027** and do not automatically update for later years; those dates must be maintained separately.

## Automatic Kuala Lumpur holidays (new)
The calendar now automatically requests published public holidays for **Kuala Lumpur (KUL)** through the Malaysia Holiday API, via a Netlify Function at `/.netlify/functions/holidays?year=2028`. No API key or extra subscription is required by this provider. The site requests a year when first viewed, caches it during the session, and offers a **Refresh holidays** button. If the feed is unavailable, the built-in 2026–2027 reference dates remain available; for other years, the calendar still works and you can add your own holiday/centre-closure dates.

The calendar can navigate years 1–9999, but the holiday provider documents data only for years **2000–2100**, and only when dates have been published. Future dates may be absent or provisional. Always verify official Malaysian announcements before cancelling teaching sessions.

Custom holidays and centre closures are saved in your private Supabase planner record and synchronised between devices. These custom dates also appear alongside the API dates.

### Deploying the Netlify Function
Upload the **whole project folder** through a Netlify deployment method that supports functions, preferably connecting a Git repository and deploying with `netlify.toml` at the repository root. **Simple drag-and-drop static uploads may not deploy Netlify Functions.** If the function is missing, the calendar will show a holiday-fetch warning. The rest of the planner still works.

Check `https://YOUR-SITE.netlify.app/.netlify/functions/holidays?year=2026` after deployment. It should return a JSON object with `holidays`. If it returns 404, the function was not deployed; use a Git-based deployment.

The holiday API is a third-party service, not an official government source. See https://malaysia-holiday.dydxsoft.my/api/docs .
