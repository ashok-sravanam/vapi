# Vocal Analysis Web App - Project Context

## Project Overview
A full-stack vocal analysis web app with React frontend and FastAPI backend, designed to analyze user voice recordings and provide detailed vocal metrics.

## Architecture
- **Frontend**: React + TypeScript + Vite, deployed on Netlify
- **Backend**: FastAPI + Python, deployed on Google Cloud Run
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth with Google OAuth

## Current Implementation Status

### Frontend (React/TypeScript)
- **Core Components**: Dashboard, Onboarding, Practice, Progress, Settings, Community
- **Authentication**: Google Sign-in, protected routes, auth context
- **Voice Recording**: Real-time pitch detection using Pitchy library
- **Custom Hook**: `useVoiceAnalysis` - reusable hook for recording and analysis
- **UI Framework**: Tailwind CSS with modern, responsive design
- **State Management**: React Context for auth and vocal profile

### Backend (FastAPI)
- **Main Endpoint**: `/analyze-voice` - accepts audio files and returns analysis results
- **Voice Analyzer**: Custom implementation using librosa, numpy, scipy, and other audio libraries
- **Analysis Metrics**:
  - Mean pitch (Hz)
  - Vibrato rate (Hz)
  - Jitter (%)
  - Shimmer (%)
  - Dynamics (categorized: low, medium, high)
  - Voice type (soprano, alto, tenor, bass, baritone)
- **File Handling**: Temporary audio file storage and cleanup
- **Error Handling**: Comprehensive error responses and logging

### Key Features Implemented
1. **Real-time Pitch Detection**: Frontend uses Pitchy for live pitch monitoring
2. **Audio Recording**: Browser-based audio recording with Web Audio API
3. **Voice Analysis**: Backend processes audio files and extracts vocal metrics
4. **User Authentication**: Google OAuth integration with Supabase
5. **Responsive UI**: Modern, mobile-friendly interface
6. **Cloud Deployment**: Frontend on Netlify, backend on Google Cloud Run

### Technical Stack Details
- **Frontend Dependencies**: React 18, TypeScript, Vite, Tailwind CSS, Pitchy, Supabase client
- **Backend Dependencies**: FastAPI, librosa, numpy, scipy, soundfile, pydub, python-multipart
- **Infrastructure**: Docker containers, Google Cloud Run, Netlify
- **CI/CD**: Cloud Build for backend deployment

### Recent Changes
- Removed coaching/gamification fields to focus on core audio analysis
- Implemented custom voice analyzer replacing VibratoScope integration
- Created reusable `useVoiceAnalysis` hook for cross-component voice recording
- Updated backend to handle real audio analysis with proper error handling
- Configured Docker and deployment for Google Cloud Run

### Current File Structure
```
testing/
├── src/                    # React frontend
│   ├── components/         # UI components
│   ├── pages/             # Main app pages
│   ├── context/           # React contexts
│   ├── hooks/             # Custom hooks (useVoiceAnalysis)
│   └── lib/               # Utilities (Supabase client)
├── backend/               # FastAPI backend
│   ├── main.py           # FastAPI app with /analyze-voice endpoint
│   ├── voice_analyzer.py # Custom voice analysis implementation
│   ├── Dockerfile        # Container configuration
│   └── requirements.txt  # Python dependencies
├── supabase/             # Database migrations
└── [config files]        # Various config files
```

### Integration Points
- Frontend sends audio files and mean pitch to backend `/analyze-voice` endpoint
- Backend returns structured analysis results including all vocal metrics
- Supabase handles user authentication and profile data
- Google Cloud Run provides scalable backend processing

### Next Steps/Considerations
- The app is fully functional with real voice analysis
- Backend can be deployed to Google Cloud Run for production
- Frontend is ready for Netlify deployment
- Consider adding more advanced analysis features or UI improvements
- May want to add error handling for edge cases in audio processing

## Development Notes
- The custom voice analyzer provides similar functionality to VibratoScope
- Audio processing is computationally intensive, hence the separate backend
- The full-stack approach enables real-time analysis and professional demo capabilities
- All core vocal analysis metrics are implemented and working 

I'm working on a vocal analysis web app with the following context. Please read the PROJECT_CONTEXT.md file in my workspace to understand the current state of the project, then help me with any questions or improvements.

The app is a full-stack solution with:
- React/TypeScript frontend (deployed on Netlify)
- FastAPI Python backend (deployed on Google Cloud Run) 
- Supabase for authentication and database
- Custom voice analysis implementation using librosa/numpy/scipy

Key features implemented:
- Real-time pitch detection with Pitchy
- Audio recording and analysis
- Google OAuth authentication
- Custom useVoiceAnalysis hook
- Voice metrics: pitch, vibrato, jitter, shimmer, dynamics, voice type

The app is currently functional with real voice analysis capabilities. Please help me with any improvements, bug fixes, or new features you'd like to add. 