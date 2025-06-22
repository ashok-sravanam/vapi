/*
  # Add Voice Profile Columns to Profiles Table

  1. New Columns
    - `voice_recorded` (boolean) - Tracks if user has completed voice onboarding
    - `vocal_range` (text) - User's vocal range (soprano, alto, tenor, etc.)
    - `pitch_accuracy` (integer) - Pitch accuracy percentage (0-100)
    - `breath_control` (integer) - Breath control score (0-100)
    - `rhythm_accuracy` (integer) - Rhythm accuracy percentage (0-100)
    - `tone_quality` (integer) - Tone quality score (0-100)
    - `lowest_note` (text) - Lowest note in user's range
    - `highest_note` (text) - Highest note in user's range
    - `preferred_genres` (text array) - User's preferred music genres
    - `skill_level` (text) - User's skill level (beginner, intermediate, advanced)

  2. Security
    - Maintain existing RLS policies
    - Add default values for new columns
*/

-- Add voice recording and vocal analysis columns
DO $$
BEGIN
  -- Add voice_recorded column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'voice_recorded'
  ) THEN
    ALTER TABLE profiles ADD COLUMN voice_recorded boolean DEFAULT false;
  END IF;

  -- Add vocal_range column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'vocal_range'
  ) THEN
    ALTER TABLE profiles ADD COLUMN vocal_range text DEFAULT 'unknown';
  END IF;

  -- Add pitch_accuracy column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'pitch_accuracy'
  ) THEN
    ALTER TABLE profiles ADD COLUMN pitch_accuracy integer DEFAULT 0;
  END IF;

  -- Add breath_control column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'breath_control'
  ) THEN
    ALTER TABLE profiles ADD COLUMN breath_control integer DEFAULT 0;
  END IF;

  -- Add rhythm_accuracy column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'rhythm_accuracy'
  ) THEN
    ALTER TABLE profiles ADD COLUMN rhythm_accuracy integer DEFAULT 0;
  END IF;

  -- Add tone_quality column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'tone_quality'
  ) THEN
    ALTER TABLE profiles ADD COLUMN tone_quality integer DEFAULT 0;
  END IF;

  -- Add lowest_note column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'lowest_note'
  ) THEN
    ALTER TABLE profiles ADD COLUMN lowest_note text DEFAULT 'C3';
  END IF;

  -- Add highest_note column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'highest_note'
  ) THEN
    ALTER TABLE profiles ADD COLUMN highest_note text DEFAULT 'C5';
  END IF;

  -- Add preferred_genres column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'preferred_genres'
  ) THEN
    ALTER TABLE profiles ADD COLUMN preferred_genres text[] DEFAULT ARRAY['pop'];
  END IF;

  -- Add skill_level column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'skill_level'
  ) THEN
    ALTER TABLE profiles ADD COLUMN skill_level text DEFAULT 'beginner';
  END IF;
END $$;

-- Add constraints for data validation
DO $$
BEGIN
  -- Add check constraint for pitch_accuracy if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.check_constraints
    WHERE constraint_name = 'pitch_accuracy_range'
  ) THEN
    ALTER TABLE profiles ADD CONSTRAINT pitch_accuracy_range CHECK (pitch_accuracy >= 0 AND pitch_accuracy <= 100);
  END IF;

  -- Add check constraint for breath_control if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.check_constraints
    WHERE constraint_name = 'breath_control_range'
  ) THEN
    ALTER TABLE profiles ADD CONSTRAINT breath_control_range CHECK (breath_control >= 0 AND breath_control <= 100);
  END IF;

  -- Add check constraint for rhythm_accuracy if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.check_constraints
    WHERE constraint_name = 'rhythm_accuracy_range'
  ) THEN
    ALTER TABLE profiles ADD CONSTRAINT rhythm_accuracy_range CHECK (rhythm_accuracy >= 0 AND rhythm_accuracy <= 100);
  END IF;

  -- Add check constraint for tone_quality if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.check_constraints
    WHERE constraint_name = 'tone_quality_range'
  ) THEN
    ALTER TABLE profiles ADD CONSTRAINT tone_quality_range CHECK (tone_quality >= 0 AND tone_quality <= 100);
  END IF;

  -- Add check constraint for skill_level if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.check_constraints
    WHERE constraint_name = 'valid_skill_level'
  ) THEN
    ALTER TABLE profiles ADD CONSTRAINT valid_skill_level CHECK (skill_level IN ('beginner', 'intermediate', 'advanced'));
  END IF;

  -- Add check constraint for vocal_range if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.check_constraints
    WHERE constraint_name = 'valid_vocal_range'
  ) THEN
    ALTER TABLE profiles ADD CONSTRAINT valid_vocal_range CHECK (vocal_range IN ('soprano', 'mezzo-soprano', 'alto', 'tenor', 'baritone', 'bass', 'unknown'));
  END IF;
END $$;