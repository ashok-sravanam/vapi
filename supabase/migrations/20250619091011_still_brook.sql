/*
  # Fix RLS policies for vocal_analysis_history table

  1. Problem Analysis
    - Current RLS policies are incorrectly configured
    - INSERT policy uses wrong WITH CHECK condition (uid() = id) instead of (auth.uid() = user_id)
    - UPDATE policy uses wrong condition (uid() = id) instead of (auth.uid() = user_id)
    - Functions should use auth.uid() not uid()

  2. Solution
    - Drop existing incorrect policies
    - Create correct RLS policies that match the table structure
    - Ensure policies use auth.uid() and correct column references

  3. Security
    - Users can only insert their own practice sessions
    - Users can only view their own practice sessions
    - Users can only update their own practice sessions
*/

-- Drop existing incorrect policies
DROP POLICY IF EXISTS "Public profiles are viewable by everyone." ON vocal_analysis_history;
DROP POLICY IF EXISTS "Users can insert their own profile." ON vocal_analysis_history;
DROP POLICY IF EXISTS "Users can update own profile." ON vocal_analysis_history;

-- Create correct RLS policies for vocal_analysis_history
CREATE POLICY "Users can view their own vocal analysis history"
  ON vocal_analysis_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own vocal analysis history"
  ON vocal_analysis_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own vocal analysis history"
  ON vocal_analysis_history FOR UPDATE
  USING (auth.uid() = user_id);

-- Ensure RLS is enabled
ALTER TABLE vocal_analysis_history ENABLE ROW LEVEL SECURITY;