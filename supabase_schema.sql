-- Supabase schema for Epic Attribute Tracker (attributes table)
-- Paste this into Supabase SQL editor for your project at https://app.supabase.com

-- Enable uuid generation extension if not already enabled
create extension if not exists pgcrypto;

-- Attributes table: one row per (app_id, user_id)
create table if not exists public.attributes (
  id uuid primary key default gen_random_uuid(),
  app_id text not null,
  user_id text not null,
  level integer not null default 1,
  mind integer not null default 0,
  spirit integer not null default 0,
  constitution integer not null default 0,
  strength integer not null default 0,
  speed integer not null default 0,
  updated_at timestamptz not null default now()
);

-- Ensure a single attributes row per app_id + user_id (so upsert works)
create unique index if not exists attributes_app_user_idx on public.attributes(app_id, user_id);

-- Optional: Row Level Security (RLS) examples
-- NOTE: Carefully review RLS rules before enabling them. If you enable RLS, you must create policies that allow the intended access for authenticated users.
-- ALTER TABLE public.attributes ENABLE ROW LEVEL SECURITY;

-- Example RLS policy templates (commented out):
-- CREATE POLICY select_own ON public.attributes
--   FOR SELECT USING (auth.role() = 'authenticated' AND auth.uid() = user_id);
-- CREATE POLICY insert_own ON public.attributes
--   FOR INSERT WITH CHECK (auth.role() = 'authenticated' AND auth.uid() = user_id);
-- CREATE POLICY update_own ON public.attributes
--   FOR UPDATE USING (auth.role() = 'authenticated' AND auth.uid() = user_id)
--   WITH CHECK (auth.role() = 'authenticated' AND auth.uid() = user_id);

-- Reminder: If you use the anon public key in the browser, ensure policies or a proxy protect write/read operations appropriately.
