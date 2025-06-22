"""
Fetch AI service for generating vocal analysis reports
"""
import os
import logging
from typing import Dict, Any, List, Optional, Tuple
from datetime import datetime, timedelta
import asyncio
from dataclasses import dataclass
import json
import statistics
from enum import Enum
import requests

# Supabase client for database access
from supabase import create_client, Client

logger = logging.getLogger(__name__)

class TrendDirection(Enum):
    UP = "up"
    DOWN = "down"
    STABLE = "baseline"

@dataclass
class SessionMetrics:
    """Data class for a single session's metrics"""
    timestamp: datetime
    mean_pitch: float
    vibrato_rate: float
    jitter: float
    shimmer: float
    dynamics: str
    voice_type: str
    lowest_note: str
    highest_note: str

@dataclass
class DailyMetrics:
    """Data class for aggregated daily metrics"""
    date: str
    session_count: int
    mean_pitch_avg: float
    vibrato_rate_avg: float
    jitter_avg: float
    shimmer_avg: float
    dynamics_mode: str
    voice_type_mode: str
    lowest_note: str  # lowest across all sessions
    highest_note: str  # highest across all sessions
    pitch_stability: float  # standard deviation of mean_pitch
    practice_consistency: float  # time spread of sessions

@dataclass
class MetricComparison:
    """Data class for metric comparison"""
    current: float
    previous: Optional[float]
    change: Optional[float]
    trend: str  # 'up', 'down', 'baseline'
    improvement_percentage: Optional[float]

@dataclass
class FetchAiReport:
    """Data class for Fetch AI report"""
    date: str
    id: str
    summary: str
    metrics: Dict[str, MetricComparison]
    insights: List[str]
    recommendations: List[str]
    practice_sessions: int
    total_practice_time: float  # in minutes
    best_time_of_day: str

class FetchAiVocalCoach:
    """Fetch AI vocal coaching service with ASI-1 integration"""
    
    def __init__(self):
        # Initialize Supabase client
        supabase_url = os.getenv("SUPABASE_URL")
        supabase_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
        
        if not supabase_url or not supabase_key:
            logger.warning("Supabase credentials not found. Using mock data.")
            self.supabase: Optional[Client] = None
        else:
            self.supabase = create_client(supabase_url, supabase_key)
            logger.info("Supabase client initialized successfully")
        
        # Initialize Fetch AI ASI-1 client
        self.asi1_api_key = os.getenv("ASI_1_API_KEY")
        self.asi1_url = "https://api.asi1.ai/v1/chat/completions"
        
        if not self.asi1_api_key:
            logger.warning("ASI-1 API key not found. Using mock AI responses.")
            self.use_ai = False
        else:
            self.use_ai = True
            logger.info("ASI-1 API initialized successfully")
    
    async def _get_ai_insights(self, metrics_data: str, user_context: str) -> Tuple[List[str], List[str]]:
        """Get AI-powered insights using Fetch AI's ASI-1"""
        if not self.use_ai:
            # Return mock insights
            return [
                "Your pitch stability has improved by 15% this week!",
                "Consider practicing in the morning for better vocal clarity.",
                "Your vibrato rate is within optimal range for your voice type."
            ], [
                "Try vocal warm-ups before each practice session.",
                "Focus on breath control exercises for better dynamics.",
                "Practice scales in your comfortable range daily."
            ]
        
        try:
            prompt = f"""
            As a professional vocal coach, analyze this vocal performance data and provide:
            
            VOCAL DATA:
            {metrics_data}
            
            USER CONTEXT:
            {user_context}
            
            Please provide:
            1. 3 specific insights about their vocal performance
            2. 3 personalized recommendations for improvement
            
            Format as JSON:
            {{
                "insights": ["insight1", "insight2", "insight3"],
                "recommendations": ["rec1", "rec2", "rec3"]
            }}
            """
            
            headers = {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': f'bearer {self.asi1_api_key}'
            }
            
            payload = {
                "model": "asi1-mini",
                "messages": [
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                "temperature": 0.7,
                "stream": False,
                "max_tokens": 500
            }
            
            response = requests.post(self.asi1_url, headers=headers, json=payload, timeout=30)
            
            if response.status_code == 200:
                result = response.json()
                content = result["choices"][0]["message"]["content"]
                
                # Try to parse JSON response
                try:
                    ai_data = json.loads(content)
                    insights = ai_data.get("insights", [])
                    recommendations = ai_data.get("recommendations", [])
                    return insights, recommendations
                except json.JSONDecodeError:
                    # Fallback: extract insights from text
                    lines = content.split('\n')
                    insights = [line for line in lines if 'insight' in line.lower() or 'improved' in line.lower()]
                    recommendations = [line for line in lines if 'recommend' in line.lower() or 'try' in line.lower()]
                    return insights[:3], recommendations[:3]
            else:
                logger.error(f"ASI-1 API error: {response.status_code}")
                return self._get_fallback_insights()
                
        except Exception as e:
            logger.error(f"Error getting AI insights: {str(e)}")
            return self._get_fallback_insights()
    
    def _get_fallback_insights(self) -> Tuple[List[str], List[str]]:
        """Fallback insights when AI is unavailable"""
        return [
            "Your vocal practice shows consistent improvement patterns.",
            "Maintaining regular practice sessions will enhance your progress.",
            "Your pitch accuracy is developing well with continued practice."
        ], [
            "Continue with daily vocal warm-ups for 10-15 minutes.",
            "Practice breathing exercises to improve vocal control.",
            "Record yourself regularly to track your progress."
        ]
    
    async def _get_daily_sessions(self, user_id: str, date: str) -> List[SessionMetrics]:
        """Get all practice sessions for a specific day"""
        if not self.supabase:
            # Return mock data for demo
            return [
                SessionMetrics(
                    timestamp=datetime.now(),
                    mean_pitch=220.5,
                    vibrato_rate=5.8,
                    jitter=0.012,
                    shimmer=0.017,
                    dynamics="stable",
                    voice_type="tenor",
                    lowest_note="C3",
                    highest_note="A4"
                ),
                SessionMetrics(
                    timestamp=datetime.now() - timedelta(hours=2),
                    mean_pitch=225.1,
                    vibrato_rate=6.2,
                    jitter=0.011,
                    shimmer=0.016,
                    dynamics="stable",
                    voice_type="tenor",
                    lowest_note="D3",
                    highest_note="B4"
                )
            ]
            
        try:
            # Query for all sessions in the given day
            start_date = f"{date}T00:00:00"
            end_date = f"{date}T23:59:59"
            
            response = self.supabase.table('vocal_analysis_history').select('*').eq(
                'user_id', user_id
            ).gte('created_at', start_date).lte('created_at', end_date).execute()
            
            if not response.data:
                return []
                
            return [
                SessionMetrics(
                    timestamp=datetime.fromisoformat(session['created_at'].replace('Z', '+00:00')),
                    mean_pitch=session.get('mean_pitch', 0),
                    vibrato_rate=session.get('vibrato_rate', 0),
                    jitter=session.get('jitter', 0),
                    shimmer=session.get('shimmer', 0),
                    dynamics=session.get('dynamics', 'stable'),
                    voice_type=session.get('voice_type', 'unknown'),
                    lowest_note=session.get('lowest_note', 'C3'),
                    highest_note=session.get('highest_note', 'C5')
                )
                for session in response.data
            ]
        except Exception as e:
            logger.error(f"Error fetching daily sessions: {str(e)}")
            return []

    def _aggregate_daily_metrics(self, sessions: List[SessionMetrics]) -> Optional[DailyMetrics]:
        """Aggregate metrics from multiple sessions into daily metrics"""
        if not sessions:
            return None
            
        # Basic aggregations
        mean_pitches = [s.mean_pitch for s in sessions]
        vibrato_rates = [s.vibrato_rate for s in sessions]
        jitters = [s.jitter for s in sessions]
        shimmers = [s.shimmer for s in sessions]
        
        # Get mode for categorical data
        dynamics = max(set(s.dynamics for s in sessions), 
                      key=lambda x: sum(1 for s in sessions if s.dynamics == x))
        voice_type = max(set(s.voice_type for s in sessions), 
                        key=lambda x: sum(1 for s in sessions if s.voice_type == x))
        
        # Find vocal range
        lowest_note = min(sessions, key=lambda x: self._note_to_frequency(x.lowest_note)).lowest_note
        highest_note = max(sessions, key=lambda x: self._note_to_frequency(x.highest_note)).highest_note
        
        # Calculate practice consistency (time spread)
        timestamps = [s.timestamp for s in sessions]
        time_spread = (max(timestamps) - min(timestamps)).total_seconds() / 3600  # in hours
        
        return DailyMetrics(
            date=sessions[0].timestamp.strftime("%Y-%m-%d"),
            session_count=len(sessions),
            mean_pitch_avg=statistics.mean(mean_pitches),
            vibrato_rate_avg=statistics.mean(vibrato_rates),
            jitter_avg=statistics.mean(jitters),
            shimmer_avg=statistics.mean(shimmers),
            dynamics_mode=dynamics,
            voice_type_mode=voice_type,
            lowest_note=lowest_note,
            highest_note=highest_note,
            pitch_stability=statistics.stdev(mean_pitches) if len(mean_pitches) > 1 else 0,
            practice_consistency=time_spread
        )

    def _calculate_improvement(self, current: float, previous: float) -> Tuple[float, str]:
        """Calculate improvement percentage and trend"""
        if previous == 0:
            return (0, TrendDirection.STABLE.value)
            
        change_pct = ((current - previous) / previous) * 100
        if abs(change_pct) < 1:
            return (change_pct, TrendDirection.STABLE.value)
        return (change_pct, TrendDirection.UP.value if change_pct > 0 else TrendDirection.DOWN.value)

    async def generate_daily_report(self, user_id: str, date: str) -> FetchAiReport:
        """Generate comprehensive daily vocal analysis report"""
        try:
            # Get sessions for the day
            sessions = await self._get_daily_sessions(user_id, date)
            
            if not sessions:
                return self._generate_fallback_report(user_id, date)
            
            # Aggregate daily metrics
            daily_metrics = self._aggregate_daily_metrics(sessions)
            if not daily_metrics:
                return self._generate_fallback_report(user_id, date)
            
            # Get previous day's metrics for comparison
            previous_date = (datetime.strptime(date, "%Y-%m-%d") - timedelta(days=1)).strftime("%Y-%m-%d")
            previous_sessions = await self._get_daily_sessions(user_id, previous_date)
            previous_metrics = self._aggregate_daily_metrics(previous_sessions) if previous_sessions else None
            
            # Calculate metrics with comparisons
            metrics = {}
            
            # Vocal metrics
            metrics["mean_pitch"] = MetricComparison(
                current=daily_metrics.mean_pitch_avg,
                previous=previous_metrics.mean_pitch_avg if previous_metrics else None,
                change=daily_metrics.mean_pitch_avg - (previous_metrics.mean_pitch_avg if previous_metrics else daily_metrics.mean_pitch_avg),
                trend=self._calculate_improvement(daily_metrics.mean_pitch_avg, previous_metrics.mean_pitch_avg if previous_metrics else daily_metrics.mean_pitch_avg)[1],
                improvement_percentage=self._calculate_improvement(daily_metrics.mean_pitch_avg, previous_metrics.mean_pitch_avg if previous_metrics else daily_metrics.mean_pitch_avg)[0]
            )
            
            metrics["vibrato_rate"] = MetricComparison(
                current=daily_metrics.vibrato_rate_avg,
                previous=previous_metrics.vibrato_rate_avg if previous_metrics else None,
                change=daily_metrics.vibrato_rate_avg - (previous_metrics.vibrato_rate_avg if previous_metrics else daily_metrics.vibrato_rate_avg),
                trend=self._calculate_improvement(daily_metrics.vibrato_rate_avg, previous_metrics.vibrato_rate_avg if previous_metrics else daily_metrics.vibrato_rate_avg)[1],
                improvement_percentage=self._calculate_improvement(daily_metrics.vibrato_rate_avg, previous_metrics.vibrato_rate_avg if previous_metrics else daily_metrics.vibrato_rate_avg)[0]
            )
            
            metrics["jitter"] = MetricComparison(
                current=daily_metrics.jitter_avg,
                previous=previous_metrics.jitter_avg if previous_metrics else None,
                change=daily_metrics.jitter_avg - (previous_metrics.jitter_avg if previous_metrics else daily_metrics.jitter_avg),
                trend=self._calculate_improvement(daily_metrics.jitter_avg, previous_metrics.jitter_avg if previous_metrics else daily_metrics.jitter_avg)[1],
                improvement_percentage=self._calculate_improvement(daily_metrics.jitter_avg, previous_metrics.jitter_avg if previous_metrics else daily_metrics.jitter_avg)[0]
            )
            
            metrics["shimmer"] = MetricComparison(
                current=daily_metrics.shimmer_avg,
                previous=previous_metrics.shimmer_avg if previous_metrics else None,
                change=daily_metrics.shimmer_avg - (previous_metrics.shimmer_avg if previous_metrics else daily_metrics.shimmer_avg),
                trend=self._calculate_improvement(daily_metrics.shimmer_avg, previous_metrics.shimmer_avg if previous_metrics else daily_metrics.shimmer_avg)[1],
                improvement_percentage=self._calculate_improvement(daily_metrics.shimmer_avg, previous_metrics.shimmer_avg if previous_metrics else daily_metrics.shimmer_avg)[0]
            )
            
            # Practice metrics
            metrics["total_sessions"] = MetricComparison(
                current=daily_metrics.session_count,
                previous=previous_metrics.session_count if previous_metrics else None,
                change=daily_metrics.session_count - (previous_metrics.session_count if previous_metrics else 0),
                trend=self._calculate_improvement(daily_metrics.session_count, previous_metrics.session_count if previous_metrics else 0)[1],
                improvement_percentage=self._calculate_improvement(daily_metrics.session_count, previous_metrics.session_count if previous_metrics else 0)[0]
            )
            
            # Prepare data for AI analysis
            metrics_data = f"""
            Date: {date}
            Sessions: {daily_metrics.session_count}
            Mean Pitch: {daily_metrics.mean_pitch_avg:.2f} Hz
            Vibrato Rate: {daily_metrics.vibrato_rate_avg:.2f} Hz
            Jitter: {daily_metrics.jitter_avg:.4f}
            Shimmer: {daily_metrics.shimmer_avg:.4f}
            Voice Type: {daily_metrics.voice_type_mode}
            Vocal Range: {daily_metrics.lowest_note} to {daily_metrics.highest_note}
            Pitch Stability: {daily_metrics.pitch_stability:.2f}
            Practice Consistency: {daily_metrics.practice_consistency:.1f} hours
            """
            
            user_context = f"User {user_id} practicing vocal techniques with {daily_metrics.session_count} sessions on {date}"
            
            # Get AI-powered insights
            insights, recommendations = await self._get_ai_insights(metrics_data, user_context)
            
            # Generate summary
            summary = self._generate_summary(daily_metrics, previous_metrics)
            
            # Calculate practice time (estimate 15 minutes per session)
            total_practice_time = daily_metrics.session_count * 15
            
            # Determine best time of day (mock for now)
            best_time_of_day = "Morning (9-11 AM)"
            
            return FetchAiReport(
                date=date,
                id=f"report_{user_id}_{date}",
                summary=summary,
                metrics=metrics,
                insights=insights,
                recommendations=recommendations,
                practice_sessions=daily_metrics.session_count,
                total_practice_time=total_practice_time,
                best_time_of_day=best_time_of_day
            )
            
        except Exception as e:
            logger.error(f"Error generating daily report: {str(e)}")
            return self._generate_fallback_report(user_id, date)

    def _calculate_note_range(self, lowest: str, highest: str) -> float:
        """Calculate the range between two notes in semitones"""
        lowest_freq = self._note_to_frequency(lowest)
        highest_freq = self._note_to_frequency(highest)
        return 12 * (highest_freq / lowest_freq) if lowest_freq > 0 else 0

    def _note_to_frequency(self, note: str) -> float:
        """Convert note name to frequency"""
        note_names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
        if len(note) < 2:
            return 0
        
        note_name = note[:-1]
        octave = int(note[-1])
        
        if note_name not in note_names:
            return 0
        
        note_index = note_names.index(note_name)
        # A4 = 440 Hz
        return 440 * (2 ** ((note_index - 9) / 12 + (octave - 4)))

    def _generate_summary(self, current: DailyMetrics, previous: Optional[DailyMetrics]) -> str:
        """Generate a summary of the daily performance"""
        if previous:
            if current.session_count > previous.session_count:
                return f"Excellent progress today! You completed {current.session_count} practice sessions, showing increased dedication to your vocal development."
            elif current.session_count == previous.session_count:
                return f"Consistent practice maintained with {current.session_count} sessions today. Your vocal technique continues to develop steadily."
            else:
                return f"Completed {current.session_count} practice sessions today. Consider increasing practice frequency for optimal progress."
        else:
            return f"Great start! You completed {current.session_count} practice sessions today. Keep up the momentum!"

    def _generate_fallback_report(self, user_id: str, date: str) -> FetchAiReport:
        """Generate a fallback report when no data is available"""
        return FetchAiReport(
            date=date,
            id=f"fallback_{user_id}_{date}",
            summary="No practice sessions recorded for this date. Start practicing to see your vocal analysis!",
            metrics={},
            insights=["Begin with daily vocal warm-ups", "Practice breathing exercises", "Record your sessions to track progress"],
            recommendations=["Start with 10-minute daily sessions", "Focus on proper breathing technique", "Use the practice feature regularly"],
            practice_sessions=0,
            total_practice_time=0,
            best_time_of_day="Morning"
        )

# Create global instance
fetch_ai_coach = FetchAiVocalCoach() 