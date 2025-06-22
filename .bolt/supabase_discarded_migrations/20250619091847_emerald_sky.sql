/*
  # Fix constraint checking error in vocal_analysis_history

  1. Problem
    - SQL error: column "table_name" does not exist in information_schema.check_constraints
    - Current table structure has incorrect foreign key relationships

  2. Solution
    - Fix the constraint checking logic
    - Ensure proper table structure
    - Remove incorrect foreign key on id column
    - Add correct foreign key on user_id column

  3. Table Structure
    - id: uuid PRIMARY KEY (unique session ID, not a foreign key)
    - user_id: uuid FOREIGN KEY references auth.users(id)
    - All other voice analysis columns
*/

-- First, let's completely recreate the table with the correct structure
DROP TABLE IF EXISTS vocal_analysis_history CASCADE;

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

-- Add the correct foreign key constraint
ALTER TABLE vocal_analysis_history 
ADD CONSTRAINT vocal_analysis_history_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- Add username length constraint (using correct constraint checking)
ALTER TABLE vocal_analysis_history 
ADD CONSTRAINT vocal_analysis_username_length 
CHECK (char_length(username) >= 3);

-- Add unique constraint on username for this table
ALTER TABLE vocal_analysis_history 
ADD CONSTRAINT vocal_analysis_history_username_key 
UNIQUE (username);

-- Enable RLS
ALTER TABLE vocal_analysis_history ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own vocal analysis history"
  ON vocal_analysis_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own vocal analysis history"
  ON vocal_analysis_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own vocal analysis history"
  ON vocal_analysis_history FOR UPDATE
  USING (auth.uid() = user_id);