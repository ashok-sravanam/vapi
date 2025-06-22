# Vocal Coach AI - FastAPI Backend

A FastAPI backend service for the Vocal Coach AI application that analyzes voice recordings and provides vocal feedback.

## 🚀 Features

- **Voice Analysis Endpoint**: `/analyze-voice` - Accepts audio files and returns vocal analysis
- **Health Checks**: `/health` - Service health monitoring
- **CORS Support**: Configured for frontend integration
- **File Validation**: Audio file type and size validation
- **Temporary File Handling**: Secure temporary file processing
- **Simulated Analysis**: Realistic voice analysis simulation (ready for VibratoScope integration)

## 🏗️ Architecture

```
Frontend (React) → FastAPI Backend → Voice Analysis → Response
```

## 📋 Prerequisites

- Python 3.11+
- Docker (for containerized deployment)
- Google Cloud Platform account (for Cloud Run deployment)

## 🛠️ Local Development

### 1. Setup Python Environment

```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### 2. Run Locally

```bash
# Run with uvicorn
uvicorn main:app --reload --host 0.0.0.0 --port 8080

# Or run directly
python main.py
```

### 3. Test the API

The API will be available at `http://localhost:8080`

- **Health Check**: `GET http://localhost:8080/health`
- **API Documentation**: `GET http://localhost:8080/docs`
- **Voice Analysis**: `POST http://localhost:8080/analyze-voice`

## 🐳 Docker Development

### Build and Run with Docker

```bash
# Build the image
docker build -t vocal-coach-ai-api .

# Run the container
docker run -p 8080:8080 vocal-coach-ai-api

# Test the API
curl http://localhost:8080/health
```

## ☁️ Google Cloud Run Deployment

### 1. Setup Google Cloud Project

```bash
# Install Google Cloud SDK
# https://cloud.google.com/sdk/docs/install

# Authenticate
gcloud auth login

# Set project
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
```

### 2. Deploy with Cloud Build

```bash
# Deploy using Cloud Build (automated CI/CD)
gcloud builds submit --config cloudbuild.yaml

# Or deploy manually
gcloud run deploy vocal-coach-ai-api \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --memory 512Mi \
  --cpu 1 \
  --max-instances 10
```

### 3. Continuous Deployment

1. Connect your GitHub repository to Cloud Build
2. Set up a trigger for automatic deployment on push to main branch
3. The `cloudbuild.yaml` file will handle the build and deployment process

## 📡 API Endpoints

### POST /analyze-voice

Analyzes uploaded voice recording and returns vocal analysis results.

**Request:**
- Content-Type: `multipart/form-data`
- Body:
  - `audio`: Audio file (required)
  - `user_id`: User ID (optional)
  - `session_id`: Session ID (optional)

**Response:**
```json
{
  "success": true,
  "message": "Voice analysis completed successfully",
  "data": {
    "vocal_range": "tenor",
    "pitch_accuracy": 0.85,
    "breath_control": 4,
    "rhythm_accuracy": 5,
    "tone_quality": 3,
    "lowest_note": "C3",
    "highest_note": "C5",
    "preferred_genres": ["pop", "rock", "jazz"],
    "skill_level": 3,
    "vibrato_rate": 5.8,
    "jitter": 0.012,
    "shimmer": 0.017,
    "dynamics": "stable",
    "voice_type": "tenor",
    "confidence_score": 0.92,
    "analysis_timestamp": 1703123456.789,
    "processing_time_ms": 2456
  },
  "metadata": {
    "file_name": "recording.webm",
    "file_size": 1024000,
    "file_type": "audio/webm",
    "user_id": "user123",
    "session_id": "session456"
  }
}
```

### GET /health

Returns service health status.

**Response:**
```json
{
  "status": "healthy",
  "service": "vocal-coach-ai-api"
}
```

## 🔧 Configuration

### Environment Variables

- `PORT`: Server port (default: 8080)
- `LOG_LEVEL`: Logging level (default: INFO)

### File Upload Limits

- Maximum file size: 50MB
- Supported audio formats: All audio/* MIME types
- Temporary file cleanup: Automatic

## 🧪 Testing

### Manual Testing with curl

```bash
# Test health endpoint
curl http://localhost:8080/health

# Test voice analysis (replace with actual audio file)
curl -X POST http://localhost:8080/analyze-voice \
  -F "audio=@test_audio.webm" \
  -F "user_id=test_user" \
  -F "session_id=test_session"
```

### Automated Testing

```bash
# Install test dependencies
pip install pytest pytest-asyncio httpx

# Run tests
pytest
```

## 🔮 Future Enhancements

- [ ] Integrate VibratoScope for real voice analysis
- [ ] Add authentication and authorization
- [ ] Implement audio file storage in Google Cloud Storage
- [ ] Add database integration for analysis history
- [ ] Implement real-time WebSocket connections
- [ ] Add rate limiting and request throttling

## 📝 Development Notes

### VibratoScope Integration

The current implementation includes a `simulate_voice_analysis()` function that generates realistic voice analysis data. To integrate with VibratoScope:

1. Install VibratoScope dependencies in `requirements.txt`
2. Replace the simulation function with actual VibratoScope calls
3. Update the analysis results structure as needed

### Security Considerations

- CORS is currently set to allow all origins (`*`) - update for production
- File upload validation prevents malicious file types
- Temporary files are automatically cleaned up
- Non-root user in Docker container for security

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is part of the Vocal Coach AI application. 