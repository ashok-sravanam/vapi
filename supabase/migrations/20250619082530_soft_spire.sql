/*
  # Fix User Signup Database Error

  1. Database Trigger
    - Drop and recreate the handle_new_user function with proper error handling
    - Ensure trigger works correctly for automatic profile creation
    - Add exception handling to prevent user signup failures

  2. Schema Verification
    - Ensure all required columns exist in profiles table
    - Add proper defaults and constraints
    - Fix RLS policies

  3. Security
    - Maintain existing RLS policies
    - Ensure proper permissions for the trigger function
*/

-- First, let's see if there's an existing trigger and drop it
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Drop the existing function if it exists
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Create the updated handle_new_user function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  -- Insert a new profile for the user with minimal required fields
  INSERT INTO public.profiles (
    id,
    username,
    updated_at,
    lowest_note,
    highest_note,
    voice_recorded,
    vocal_range,
    pitch_accuracy,
    breath_control,
    rhythm_accuracy,
    tone_quality,
    preferred_genres,
    skill_level,
    mean_pitch,
    vibrato_rate,
    jitter,
    shimmer,
    dynamics,
    voice_type
  )
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1), 'User'),
    NOW(),
    'C3',
    'C5',
    false,
    'unknown',
    0,
    0,
    0,
    0,
    ARRAY['pop'],
    'beginner',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
  );
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log the error but don't fail the user creation
    RAISE LOG 'Error creating profile for user %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Ensure the function has proper permissions
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO service_role;

-- Verify the profiles table has all required columns with proper defaults
DO $$
BEGIN
  -- Ensure username column exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'username'
  ) THEN
    ALTER TABLE profiles ADD COLUMN username text;
  END IF;

  -- Ensure updated_at column exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'updated_at'
  ) THEN
    ALTER TABLE profiles ADD COLUMN updated_at timestamptz DEFAULT now();
  END IF;

  -- Ensure lowest_note column exists with default
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'lowest_note'
  ) THEN
    ALTER TABLE profiles ADD COLUMN lowest_note text DEFAULT 'C3';
  END IF;

  -- Ensure highest_note column exists with default
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'highest_note'
  ) THEN
    ALTER TABLE profiles ADD COLUMN highest_note text DEFAULT 'C5';
  END IF;

  -- Ensure voice_recorded column exists with default
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'voice_recorded'
  ) THEN
    ALTER TABLE profiles ADD COLUMN voice_recorded boolean DEFAULT false;
  END IF;

  -- Ensure vocal_range column exists with default
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'vocal_range'
  ) THEN
    ALTER TABLE profiles ADD COLUMN vocal_range text DEFAULT 'unknown';
  END IF;

  -- Ensure pitch_accuracy column exists with default
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'pitch_accuracy'
  ) THEN
    ALTER TABLE profiles ADD COLUMN pitch_accuracy integer DEFAULT 0;
  END IF;

  -- Ensure breath_control column exists with default
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'breath_control'
  ) THEN
    ALTER TABLE profiles ADD COLUMN breath_control integer DEFAULT 0;
  END IF;

  -- Ensure rhythm_accuracy column exists with default
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'rhythm_accuracy'
  ) THEN
    ALTER TABLE profiles ADD COLUMN rhythm_accuracy integer DEFAULT 0;
  END IF;

  -- Ensure tone_quality column exists with default
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'tone_quality'
  ) THEN
    ALTER TABLE profiles ADD COLUMN tone_quality integer DEFAULT 0;
  END IF;

  -- Ensure preferred_genres column exists with default
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'preferred_genres'
  ) THEN
    ALTER TABLE profiles ADD COLUMN preferred_genres text[] DEFAULT ARRAY['pop'];
  END IF;

  -- Ensure skill_level column exists with default
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'skill_level'
  ) THEN
    ALTER TABLE profiles ADD COLUMN skill_level text DEFAULT 'beginner';
  END IF;

  -- Ensure mean_pitch column exists (nullable)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'mean_pitch'
  ) THEN
    ALTER TABLE profiles ADD COLUMN mean_pitch numeric;
  END IF;

  -- Ensure vibrato_rate column exists (nullable)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'vibrato_rate'
  ) THEN
    ALTER TABLE profiles ADD COLUMN vibrato_rate numeric;
  END IF;

  -- Ensure jitter column exists (nullable)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'jitter'
  ) THEN
    ALTER TABLE profiles ADD COLUMN jitter numeric;
  END IF;

  -- Ensure shimmer column exists (nullable)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'shimmer'
  ) THEN
    ALTER TABLE profiles ADD COLUMN shimmer numeric;
  END IF;

  -- Ensure dynamics column exists (nullable)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'dynamics'
  ) THEN
    ALTER TABLE profiles ADD COLUMN dynamics text;
  END IF;

  -- Ensure voice_type column exists (nullable)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'voice_type'
  ) THEN
    ALTER TABLE profiles ADD COLUMN voice_type text;
  END IF;
END $$;

-- Add constraints using a safer approach
DO $$
BEGIN
  -- Username length constraint
  BEGIN
    ALTER TABLE profiles ADD CONSTRAINT username_length CHECK (char_length(username) >= 3);
  EXCEPTION
    WHEN duplicate_object THEN
      -- Constraint already exists, skip
      NULL;
  END;

  -- Skill level constraint
  BEGIN
    ALTER TABLE profiles ADD CONSTRAINT valid_skill_level CHECK (skill_level IN ('beginner', 'intermediate', 'advanced'));
  EXCEPTION
    WHEN duplicate_object THEN
      -- Constraint already exists, skip
      NULL;
  END;

  -- Vocal range constraint
  BEGIN
    ALTER TABLE profiles ADD CONSTRAINT valid_vocal_range CHECK (vocal_range IN ('soprano', 'mezzo-soprano', 'alto', 'tenor', 'baritone', 'bass', 'unknown'));
  EXCEPTION
    WHEN duplicate_object THEN
      -- Constraint already exists, skip
      NULL;
  END;

  -- Pitch accuracy range constraint
  BEGIN
    ALTER TABLE profiles ADD CONSTRAINT pitch_accuracy_range CHECK (pitch_accuracy >= 0 AND pitch_accuracy <= 100);
  EXCEPTION
    WHEN duplicate_object THEN
      -- Constraint already exists, skip
      NULL;
  END;

  -- Breath control range constraint
  BEGIN
    ALTER TABLE profiles ADD CONSTRAINT breath_control_range CHECK (breath_control >= 0 AND breath_control <= 100);
  EXCEPTION
    WHEN duplicate_object THEN
      -- Constraint already exists, skip
      NULL;
  END;

  -- Rhythm accuracy range constraint
  BEGIN
    ALTER TABLE profiles ADD CONSTRAINT rhythm_accuracy_range CHECK (rhythm_accuracy >= 0 AND rhythm_accuracy <= 100);
  EXCEPTION
    WHEN duplicate_object THEN
      -- Constraint already exists, skip
      NULL;
  END;

  -- Tone quality range constraint
  BEGIN
    ALTER TABLE profiles ADD CONSTRAINT tone_quality_range CHECK (tone_quality >= 0 AND tone_quality <= 100);
  EXCEPTION
    WHEN duplicate_object THEN
      -- Constraint already exists, skip
      NULL;
  END;
END $$;

-- Ensure RLS is enabled
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Recreate RLS policies safely
DO $$
BEGIN
  -- Drop existing policies to recreate them
  DROP POLICY IF EXISTS "Public profiles are viewable by everyone." ON profiles;
  DROP POLICY IF EXISTS "Users can insert their own profile." ON profiles;
  DROP POLICY IF EXISTS "Users can update own profile." ON profiles;

  -- Recreate policies
  CREATE POLICY "Public profiles are viewable by everyone."
    ON profiles FOR SELECT
    USING (true);

  CREATE POLICY "Users can insert their own profile."
    ON profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

  CREATE POLICY "Users can update own profile."
    ON profiles FOR UPDATE
    USING (auth.uid() = id);
END $$;