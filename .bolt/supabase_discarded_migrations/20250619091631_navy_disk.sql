/*
  # Fix vocal_analysis_history table constraints and structure

  1. Problem
    - Previous migration had incorrect table_name reference in constraint check
    - Foreign key constraints were incorrectly configured
    - Table structure needs to be properly defined

  2. Solution
    - Fix constraint checking logic
    - Properly configure foreign key relationships
    - Ensure all required columns exist with correct data types
    - Set up proper RLS policies

  3. Security
    - Enable RLS on vocal_analysis_history table
    - Users can only access their own practice session data
*/

-- First, ensure the table exists with basic structure
CREATE TABLE IF NOT EXISTS vocal_analysis_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  username text,
  voice_recorded boolean DEFAULT false,
  voice_type text,
  lowest_note text,
  highest_note text,
  mean_pitch double precision,
  vibrato_rate double precision,
  jitter double precision,
  shimmer double precision,
  dynamics text,
  user_id uuid
);

-- Drop any existing incorrect foreign key constraints
DO $$
BEGIN
  -- Drop the incorrect foreign key constraint on id if it exists
  IF EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'vocal_analysis_history_id_fkey' 
    AND table_name = 'vocal_analysis_history'
  ) THEN
    ALTER TABLE vocal_analysis_history DROP CONSTRAINT vocal_analysis_history_id_fkey;
  END IF;

  -- Drop existing user_id foreign key to recreate it correctly
  IF EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'vocal_analysis_history_user_id_fkey' 
    AND table_name = 'vocal_analysis_history'
  ) THEN
    ALTER TABLE vocal_analysis_history DROP CONSTRAINT vocal_analysis_history_user_id_fkey;
  END IF;
END $$;

-- Add the correct foreign key constraint for user_id
ALTER TABLE vocal_analysis_history 
ADD CONSTRAINT vocal_analysis_history_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- Add username constraint (checking the correct table this time)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.check_constraints
    WHERE constraint_name = 'vocal_analysis_username_length' 
    AND table_name = 'vocal_analysis_history'
  ) THEN
    ALTER TABLE vocal_analysis_history 
    ADD CONSTRAINT vocal_analysis_username_length 
    CHECK (char_length(username) >= 3);
  END IF;
END $$;

-- Add unique constraint on username for vocal_analysis_history
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'vocal_analysis_history_username_key' 
    AND table_name = 'vocal_analysis_history'
  ) THEN
    ALTER TABLE vocal_analysis_history 
    ADD CONSTRAINT vocal_analysis_history_username_key 
    UNIQUE (username);
  END IF;
END $$;

-- Ensure RLS is enabled
ALTER TABLE vocal_analysis_history ENABLE ROW LEVEL SECURITY;

-- Drop existing policies and recreate them correctly
DROP POLICY IF EXISTS "Users can view their own vocal analysis history" ON vocal_analysis_history;
DROP POLICY IF EXISTS "Users can insert their own vocal analysis history" ON vocal_analysis_history;
DROP POLICY IF EXISTS "Users can update their own vocal analysis history" ON vocal_analysis_history;

-- Create proper RLS policies
CREATE POLICY "Users can view their own vocal analysis history"
  ON vocal_analysis_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own vocal analysis history"
  ON vocal_analysis_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own vocal analysis history"
  ON vocal_analysis_history FOR UPDATE
  USING (auth.uid() = user_id);