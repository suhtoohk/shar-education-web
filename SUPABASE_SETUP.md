# Portal Accounts

The student/teacher portal is connected to the `shar-education-portal` Supabase project in Singapore. The profile table, signup trigger, row-level security, and GitHub Pages auth URLs are configured. The website uses the project's public publishable key; the database password is not used by the website.

Students can register from the Portal button by choosing **Student** and selecting **Create a student account**. If email confirmation is enabled, they must confirm their email before signing in.

There is no owner login on the website. To provision a teacher, create or invite the user in Supabase Authentication, then run this in SQL Editor with their email:

   ```sql
   update public.profiles
   set role = 'teacher'
   where id = (
       select id
       from auth.users
       where email = 'teacher@example.com'
   );
   ```

The signup trigger creates profiles as students, and this query promotes only the selected account. Teacher signup is not offered on the public website. Course editing and student-specific course data are a separate next phase.

Never put a Supabase `service_role` key or database password in `index.html`; only the public publishable key belongs in the browser.