/*
  # Fix vocal_analysis_history table schema

  1. Problem Analysis
    - The table has incorrect foreign key constraints
    - The `id` field should not reference `users(id)`
    - The `user_id` field should reference `auth.users(id)` or `profiles(id)`
    - Need to fix the table structure for proper practice session storage

  2. Solution
    - Drop incorrect foreign key constraints
    - Fix the table structure
    - Add proper foreign key constraint for user_id
    - Ensure RLS policies work correctly

  3. Security
    - Maintain RLS policies
    - Ensure users can only access their own data
*/

-- First, drop the problematic foreign key constraints
DO $$
BEGIN
  -- Drop the incorrect foreign key constraint on id
  IF EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'vocal_analysis_history_id_fkey' 
    AND table_name = 'vocal_analysis_history'
  ) THEN
    ALTER TABLE vocal_analysis_history DROP CONSTRAINT vocal_analysis_history_id_fkey;
  END IF;

  -- Drop the foreign key constraint on user_id if it references profiles
  IF EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'vocal_analysis_history_user_id_fkey' 
    AND table_name = 'vocal_analysis_history'
  ) THEN
    ALTER TABLE vocal_analysis_history DROP CONSTRAINT vocal_analysis_history_user_id_fkey;
  END IF;
END $$;

-- Ensure the table has the correct structure
DO $$
BEGIN
  -- Make sure id is a proper UUID primary key (not a foreign key)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vocal_analysis_history' AND column_name = 'id'
  ) THEN
    ALTER TABLE vocal_analysis_history ADD COLUMN id uuid PRIMARY KEY DEFAULT gen_random_uuid();
  END IF;

  -- Ensure user_id exists and is properly typed
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vocal_analysis_history' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE vocal_analysis_history ADD COLUMN user_id uuid;
  END IF;

  -- Ensure created_at exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vocal_analysis_history' AND column_name = 'created_at'
  ) THEN
    ALTER TABLE vocal_analysis_history ADD COLUMN created_at timestamptz DEFAULT now();
  END IF;

  -- Ensure username exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vocal_analysis_history' AND column_name = 'username'
  ) THEN
    ALTER TABLE vocal_analysis_history ADD COLUMN username text;
  END IF;

  -- Ensure voice_recorded exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vocal_analysis_history' AND column_name = 'voice_recorded'
  ) THEN
    ALTER TABLE vocal_analysis_history ADD COLUMN voice_recorded boolean DEFAULT false;
  END IF;

  -- Ensure voice_type exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vocal_analysis_history' AND column_name = 'voice_type'
  ) THEN
    ALTER TABLE vocal_analysis_history ADD COLUMN voice_type text;
  END IF;

  -- Ensure lowest_note exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vocal_analysis_history' AND column_name = 'lowest_note'
  ) THEN
    ALTER TABLE vocal_analysis_history ADD COLUMN lowest_note text;
  END IF;

  -- Ensure highest_note exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vocal_analysis_history' AND column_name = 'highest_note'
  ) THEN
    ALTER TABLE vocal_analysis_history ADD COLUMN highest_note text;
  END IF;

  -- Ensure mean_pitch exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vocal_analysis_history' AND column_name = 'mean_pitch'
  ) THEN
    ALTER TABLE vocal_analysis_history ADD COLUMN mean_pitch double precision;
  END IF;

  -- Ensure vibrato_rate exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vocal_analysis_history' AND column_name = 'vibrato_rate'
  ) THEN
    ALTER TABLE vocal_analysis_history ADD COLUMN vibrato_rate double precision;
  END IF;

  -- Ensure jitter exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vocal_analysis_history' AND column_name = 'jitter'
  ) THEN
    ALTER TABLE vocal_analysis_history ADD COLUMN jitter double precision;
  END IF;

  -- Ensure shimmer exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vocal_analysis_history' AND column_name = 'shimmer'
  ) THEN
    ALTER TABLE vocal_analysis_history ADD COLUMN shimmer double precision;
  END IF;

  -- Ensure dynamics exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vocal_analysis_history' AND column_name = 'dynamics'
  ) THEN
    ALTER TABLE vocal_analysis_history ADD COLUMN dynamics text;
  END IF;
END $$;

-- Add the correct foreign key constraint for user_id referencing auth.users
DO $$
BEGIN
  -- Add foreign key constraint for user_id to reference auth.users(id)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'vocal_analysis_history_user_id_fkey' 
    AND table_name = 'vocal_analysis_history'
  ) THEN
    ALTER TABLE vocal_analysis_history 
    ADD CONSTRAINT vocal_analysis_history_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END $$;

-- Add constraints for data validation
DO $$
BEGIN
  -- Username length constraint
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.check_constraints
    WHERE constraint_name = 'username_length' AND table_name = 'vocal_analysis_history'
  ) THEN
    ALTER TABLE vocal_analysis_history ADD CONSTRAINT username_length CHECK (char_length(username) >= 3);
  END IF;
END $$;

-- Ensure RLS is enabled
ALTER TABLE vocal_analysis_history ENABLE ROW LEVEL SECURITY;

-- Drop existing policies and recreate them
DROP POLICY IF EXISTS "Users can view their own vocal analysis history" ON vocal_analysis_history;
DROP POLICY IF EXISTS "Users can insert their own vocal analysis history" ON vocal_analysis_history;
DROP POLICY IF EXISTS "Users can update their own vocal analysis history" ON vocal_analysis_history;

-- Create correct RLS policies
CREATE POLICY "Users can view their own vocal analysis history"
  ON vocal_analysis_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own vocal analysis history"
  ON vocal_analysis_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own vocal analysis history"
  ON vocal_analysis_history FOR UPDATE
  USING (auth.uid() = user_id);