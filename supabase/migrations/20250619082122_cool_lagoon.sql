/*
  # Remove Avatar Columns from Database

  1. Changes
    - Remove `avatar_url` column from profiles table
    - Remove any avatar-related constraints or indexes

  2. Security
    - Maintain existing RLS policies
    - No impact on other functionality
*/

-- Remove avatar_url column from profiles table if it exists
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'avatar_url'
  ) THEN
    ALTER TABLE profiles DROP COLUMN avatar_url;
  END IF;
END $$;

-- Remove avatar_url column from vocal_analysis_history table if it exists
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vocal_analysis_history' AND column_name = 'avatar_url'
  ) THEN
    ALTER TABLE vocal_analysis_history DROP COLUMN avatar_url;
  END IF;
END $$;