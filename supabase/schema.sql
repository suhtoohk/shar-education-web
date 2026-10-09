create table if not exists public.profiles (
    id uuid primary key references auth.users (id) on delete cascade,
    role text not null default 'student' check (role in ('student', 'teacher')),
    display_name text not null default '',
    created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

revoke all on table public.profiles from anon, authenticated;
grant select on table public.profiles to authenticated;

drop policy if exists "Users can read their own profile" on public.profiles;
create policy "Users can read their own profile"
    on public.profiles
    for select
    to authenticated
    using ((select auth.uid()) = id);

create or replace function public.create_profile_for_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
    insert into public.profiles (id, role, display_name)
    values (
        new.id,
        'student',
        coalesce(
            nullif(new.raw_user_meta_data ->> 'display_name', ''),
            split_part(coalesce(new.email, ''), '@', 1)
        )
    )
    on conflict (id) do nothing;

    return new;
end;
$$;

drop trigger if exists create_profile_after_signup on auth.users;
create trigger create_profile_after_signup
    after insert on auth.users
    for each row execute function public.create_profile_for_new_user();

insert into public.profiles (id, role, display_name)
select
    id,
    'student',
    coalesce(
        nullif(raw_user_meta_data ->> 'display_name', ''),
        split_part(coalesce(email, ''), '@', 1)
    )
from auth.users
on conflict (id) do nothing;