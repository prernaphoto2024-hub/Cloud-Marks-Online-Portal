-- Cloud Computing Marks Portal: Supabase SQL setup
-- Run this in Supabase Dashboard > SQL Editor.
-- Faculty accounts must be created/invited in Authentication > Users.
-- No public/anonymous read or write access is granted.

create table if not exists public.cc_students (
  regn text primary key,
  name text not null,
  batch text not null default '',
  email text not null default '',
  type text not null default '',
  day text not null default '',
  mid_term numeric(5,2) not null default 0 check (mid_term >= 0 and mid_term <= 20),
  labs jsonb not null default '[{"attendance":0,"execution":0,"viva":0},{"attendance":0,"execution":0,"viva":0},{"attendance":0,"execution":0,"viva":0},{"attendance":0,"execution":0,"viva":0},{"attendance":0,"execution":0,"viva":0},{"attendance":0,"execution":0,"viva":0},{"attendance":0,"execution":0,"viva":0},{"attendance":0,"execution":0,"viva":0},{"attendance":0,"execution":0,"viva":0},{"attendance":0,"execution":0,"viva":0}]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint cc_students_labs_array check (jsonb_typeof(labs) = 'array' and jsonb_array_length(labs) = 10)
);

alter table public.cc_students enable row level security;
revoke all on public.cc_students from anon;
grant select, insert, update, delete on public.cc_students to authenticated;

drop policy if exists "Authenticated faculty can view students" on public.cc_students;
create policy "Authenticated faculty can view students"
  on public.cc_students for select to authenticated using (auth.uid() is not null);
drop policy if exists "Authenticated faculty can add students" on public.cc_students;
create policy "Authenticated faculty can add students"
  on public.cc_students for insert to authenticated with check (auth.uid() is not null);
drop policy if exists "Authenticated faculty can update students" on public.cc_students;
create policy "Authenticated faculty can update students"
  on public.cc_students for update to authenticated using (auth.uid() is not null) with check (auth.uid() is not null);
drop policy if exists "Authenticated faculty can delete students" on public.cc_students;
create policy "Authenticated faculty can delete students"
  on public.cc_students for delete to authenticated using (auth.uid() is not null);

create or replace function public.cc_validate_student_marks()
returns trigger language plpgsql as $$
declare
  i integer;
  lab jsonb;
  a numeric;
  e numeric;
  v numeric;
begin
  if new.mid_term < 0 or new.mid_term > 20 then
    raise exception 'Mid-Term marks must be between 0 and 20';
  end if;
  if jsonb_typeof(new.labs) <> 'array' or jsonb_array_length(new.labs) <> 10 then
    raise exception 'Exactly 10 lab assessments are required';
  end if;
  for i in 0..9 loop
    lab := new.labs -> i;
    a := coalesce((lab->>'attendance')::numeric,0);
    e := coalesce((lab->>'execution')::numeric,0);
    v := coalesce((lab->>'viva')::numeric,0);
    if a < 0 or a > 1 then raise exception 'Lab % Attendance must be between 0 and 1', i+1; end if;
    if e < 0 or e > 1 then raise exception 'Lab % Execution must be between 0 and 1', i+1; end if;
    if v < 0 or v > 2 then raise exception 'Lab % Viva must be between 0 and 2', i+1; end if;
  end loop;
  new.updated_at := now();
  return new;
end; $$;

drop trigger if exists cc_validate_student_marks_trigger on public.cc_students;
create trigger cc_validate_student_marks_trigger
before insert or update on public.cc_students
for each row execute function public.cc_validate_student_marks();

-- IMPORTANT: The policies above allow any authenticated account in this Supabase project.
-- For a strict named-faculty allowlist, create a public.cc_faculty_allowlist table keyed by auth.uid(),
-- populate it only for approved faculty, and change each policy to require an allowlist match.
