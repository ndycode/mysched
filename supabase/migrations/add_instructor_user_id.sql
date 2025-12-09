-- Migration: Add user_id to instructors table for login capability
-- Run this in Supabase SQL Editor

-- Add user_id column to instructors table
ALTER TABLE public.instructors 
ADD COLUMN IF NOT EXISTS user_id uuid UNIQUE REFERENCES auth.users(id);

-- Index for fast lookups during login
CREATE INDEX IF NOT EXISTS idx_instructors_user_id ON public.instructors(user_id);

-- Optional: Create a view for instructor schedule queries
CREATE OR REPLACE VIEW instructor_schedule AS
SELECT 
  c.id AS class_id,
  c.code,
  c.title,
  c.units,
  c.room,
  c.day,
  c.start,
  c.end,
  c.section_id,
  s.code AS section_code,
  s.section_number,
  i.id AS instructor_id,
  i.user_id,
  i.full_name AS instructor_name,
  i.email AS instructor_email,
  i.avatar_url AS instructor_avatar,
  i.title AS instructor_title,
  i.department AS instructor_department,
  sem.id AS semester_id,
  sem.name AS semester_name,
  sem.is_active AS semester_active
FROM public.classes c
JOIN public.sections s ON c.section_id = s.id
LEFT JOIN public.instructors i ON c.instructor_id = i.id
LEFT JOIN public.semesters sem ON s.semester_id = sem.id
WHERE c.archived_at IS NULL;
