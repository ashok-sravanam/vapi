/*
  # Fix vocal_analysis_history table structure

  1. Problem Analysis
    - The table has conflicting foreign key constraints
    - The `id` column should NOT reference auth.users (unlike profiles)
    - The `user_id` should be the only foreign key to auth.users
    - Username should NOT be unique (users can have multiple practice sessions)

  2. Solution
    - Drop and recreate table with correct structure
    - Make `id` a simple UUID primary key (not foreign key)
    - Make `user_id` the only foreign key to auth.users
    - Remove unique constraint on username
    - Match the working pattern from profiles table

  3. Security
    - Enable RLS with proper policies
    - Users can only access their own practice sessions
*/

-- Drop the existing table completely to start fresh
DROP TABLE IF EXISTS vocal_analysis_history CASCADE;

-- Create the table with the correct structure
CREATE TABLE vocal_analysis_history (
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
  user_id uuid NOT NULL
);

-- Add the ONLY foreign key constraint (user_id -> auth.users.id)
ALTER TABLE vocal_analysis_history 
ADD CONSTRAINT vocal_analysis_history_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- Add username length constraint (but NOT unique - users can have multiple sessions)
ALTER TABLE vocal_analysis_history 
ADD CONSTRAINT vocal_analysis_username_length 
CHECK (char_length(username) >= 3);

-- Enable RLS
ALTER TABLE vocal_analysis_history ENABLE ROW LEVEL SECURITY;

-- Create RLS policies that match the working profiles pattern
CREATE POLICY "Users can view their own vocal analysis history"
  ON vocal_analysis_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own vocal analysis history"
  ON vocal_analysis_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own vocal analysis history"
  ON vocal_analysis_history FOR UPDATE
  USING (auth.uid() = user_id);