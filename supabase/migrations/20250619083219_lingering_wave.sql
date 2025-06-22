/*
  # Clean up voice analysis parameters

  1. Remove unnecessary columns from profiles table:
    - vocal_range (keeping voice_type instead)
    - pitch_accuracy
    - breath_control
    - rhythm_accuracy
    - tone_quality
    - preferred_genres
    - skill_level

  2. Keep only essential voice analysis columns:
    - lowest_note
    - highest_note
    - mean_pitch
    - vibrato_rate
    - jitter
    - shimmer
    - dynamics
    - voice_type

  3. Update constraints and triggers accordingly
*/

-- Remove unnecessary columns from profiles table
DO $$
BEGIN
  -- Remove vocal_range column (we'll use voice_type instead)
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'vocal_range'
  ) THEN
    ALTER TABLE profiles DROP COLUMN vocal_range;
  END IF;

  -- Remove pitch_accuracy column
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'pitch_accuracy'
  ) THEN
    ALTER TABLE profiles DROP COLUMN pitch_accuracy;
  END IF;

  -- Remove breath_control column
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'breath_control'
  ) THEN
    ALTER TABLE profiles DROP COLUMN breath_control;
  END IF;

  -- Remove rhythm_accuracy column
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'rhythm_accuracy'
  ) THEN
    ALTER TABLE profiles DROP COLUMN rhythm_accuracy;
  END IF;

  -- Remove tone_quality column
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'tone_quality'
  ) THEN
    ALTER TABLE profiles DROP COLUMN tone_quality;
  END IF;

  -- Remove preferred_genres column
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'preferred_genres'
  ) THEN
    ALTER TABLE profiles DROP COLUMN preferred_genres;
  END IF;

  -- Remove skill_level column
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'skill_level'
  ) THEN
    ALTER TABLE profiles DROP COLUMN skill_level;
  END IF;
END $$;

-- Remove unnecessary columns from vocal_analysis_history table
DO $$
BEGIN
  -- Remove vocal_range column (we'll use voice_type instead)
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vocal_analysis_history' AND column_name = 'vocal_range'
  ) THEN
    ALTER TABLE vocal_analysis_history DROP COLUMN vocal_range;
  END IF;

  -- Remove pitch_accuracy column
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vocal_analysis_history' AND column_name = 'pitch_accuracy'
  ) THEN
    ALTER TABLE vocal_analysis_history DROP COLUMN pitch_accuracy;
  END IF;

  -- Remove breath_control column
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vocal_analysis_history' AND column_name = 'breath_control'
  ) THEN
    ALTER TABLE vocal_analysis_history DROP COLUMN breath_control;
  END IF;

  -- Remove rhythm_accuracy column
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vocal_analysis_history' AND column_name = 'rhythm_accuracy'
  ) THEN
    ALTER TABLE vocal_analysis_history DROP COLUMN rhythm_accuracy;
  END IF;

  -- Remove tone_quality column
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vocal_analysis_history' AND column_name = 'tone_quality'
  ) THEN
    ALTER TABLE vocal_analysis_history DROP COLUMN tone_quality;
  END IF;

  -- Remove preferred_genres column
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vocal_analysis_history' AND column_name = 'preferred_genres'
  ) THEN
    ALTER TABLE vocal_analysis_history DROP COLUMN preferred_genres;
  END IF;

  -- Remove skill_level column
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vocal_analysis_history' AND column_name = 'skill_level'
  ) THEN
    ALTER TABLE vocal_analysis_history DROP COLUMN skill_level;
  END IF;
END $$;

-- Drop old constraints that are no longer needed
DO $$
BEGIN
  -- Drop vocal_range constraint
  BEGIN
    ALTER TABLE profiles DROP CONSTRAINT IF EXISTS valid_vocal_range;
  EXCEPTION
    WHEN undefined_object THEN
      NULL;
  END;

  -- Drop pitch_accuracy constraint
  BEGIN
    ALTER TABLE profiles DROP CONSTRAINT IF EXISTS pitch_accuracy_range;
  EXCEPTION
    WHEN undefined_object THEN
      NULL;
  END;

  -- Drop breath_control constraint
  BEGIN
    ALTER TABLE profiles DROP CONSTRAINT IF EXISTS breath_control_range;
  EXCEPTION
    WHEN undefined_object THEN
      NULL;
  END;

  -- Drop rhythm_accuracy constraint
  BEGIN
    ALTER TABLE profiles DROP CONSTRAINT IF EXISTS rhythm_accuracy_range;
  EXCEPTION
    WHEN undefined_object THEN
      NULL;
  END;

  -- Drop tone_quality constraint
  BEGIN
    ALTER TABLE profiles DROP CONSTRAINT IF EXISTS tone_quality_range;
  EXCEPTION
    WHEN undefined_object THEN
      NULL;
  END;

  -- Drop skill_level constraint
  BEGIN
    ALTER TABLE profiles DROP CONSTRAINT IF EXISTS valid_skill_level;
  EXCEPTION
    WHEN undefined_object THEN
      NULL;
  END;
END $$;

-- Update the handle_new_user function to only include essential columns
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  -- Insert a new profile for the user with only essential fields
  INSERT INTO public.profiles (
    id,
    username,
    updated_at,
    lowest_note,
    highest_note,
    voice_recorded,
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

-- Recreate the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO service_role;