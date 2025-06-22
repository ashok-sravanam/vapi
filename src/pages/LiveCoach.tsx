import React from 'react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { PhoneCall, MessageCircle, Mic, Target, Clock, Volume2, Headphones, Settings } from 'lucide-react';

const LiveCoach: React.FC = () => {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900 relative overflow-hidden">
      {/* Animated background elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/4 left-1/4 w-64 h-64 bg-green-500/10 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-blue-500/10 rounded-full blur-3xl animate-pulse" style={{ animationDelay: '2s' }}></div>
        <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-48 h-48 bg-purple-500/10 rounded-full blur-3xl animate-pulse" style={{ animationDelay: '4s' }}></div>
      </div>

      <div className="relative z-10 flex flex-col items-center justify-center min-h-screen px-6">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center max-w-6xl mx-auto w-full"
        >
          {/* Main Title */}
          <h1 className="text-4xl md:text-5xl font-bold text-white mb-4">
            AI Voice Coach
          </h1>
          <p className="text-xl text-gray-300 mb-8 max-w-2xl mx-auto">
            Have a natural conversation with your AI vocal coach for personalized guidance and feedback
          </p>

          {/* Main CTA Button */}
          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            onClick={() => navigate('/voice-assistant')}
            className="px-12 py-6 bg-gradient-to-r from-green-500 to-green-600 text-white font-semibold rounded-full hover:shadow-lg transition-all flex items-center space-x-3 text-xl mx-auto mb-16"
          >
            <PhoneCall size={28} />
            <span>Start Voice Chat</span>
          </motion.button>

          {/* What You Can Ask Section */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="mb-16"
          >
            <h2 className="text-2xl font-bold text-white mb-8">What You Can Ask Your AI Coach</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              <div className="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700/50">
                <div className="w-12 h-12 bg-blue-500/20 rounded-lg flex items-center justify-center mb-4 mx-auto">
                  <MessageCircle size={24} className="text-blue-400" />
                </div>
                <h3 className="text-lg font-semibold text-white mb-3">Vocal Technique Questions</h3>
                <ul className="text-gray-400 text-sm space-y-2">
                  <li>"How can I improve my breath control?"</li>
                  <li>"What exercises help with pitch accuracy?"</li>
                  <li>"How do I develop better vibrato?"</li>
                </ul>
              </div>

              <div className="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700/50">
                <div className="w-12 h-12 bg-purple-500/20 rounded-lg flex items-center justify-center mb-4 mx-auto">
                  <Target size={24} className="text-purple-400" />
                </div>
                <h3 className="text-lg font-semibold text-white mb-3">Performance Feedback</h3>
                <ul className="text-gray-400 text-sm space-y-2">
                  <li>"Analyze my recent practice session"</li>
                  <li>"What should I focus on improving?"</li>
                  <li>"How is my vocal progress?"</li>
                </ul>
              </div>

              <div className="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700/50">
                <div className="w-12 h-12 bg-green-500/20 rounded-lg flex items-center justify-center mb-4 mx-auto">
                  <Mic size={24} className="text-green-400" />
                </div>
                <h3 className="text-lg font-semibold text-white mb-3">Song & Style Guidance</h3>
                <ul className="text-gray-400 text-sm space-y-2">
                  <li>"What songs suit my voice type?"</li>
                  <li>"Help me with this specific song"</li>
                  <li>"Tips for different music genres"</li>
                </ul>
              </div>

              <div className="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700/50">
                <div className="w-12 h-12 bg-orange-500/20 rounded-lg flex items-center justify-center mb-4 mx-auto">
                  <Clock size={24} className="text-orange-400" />
                </div>
                <h3 className="text-lg font-semibold text-white mb-3">Goal Setting & Progress</h3>
                <ul className="text-gray-400 text-sm space-y-2">
                  <li>"Create a practice schedule for me"</li>
                  <li>"Set vocal improvement goals"</li>
                  <li>"Track my weekly progress"</li>
                </ul>
              </div>
            </div>
          </motion.div>

          {/* Tips Section */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
            className="bg-gray-800/30 backdrop-blur-sm rounded-2xl p-8 border border-gray-700/50"
          >
            <h2 className="text-2xl font-bold text-white mb-6">Tips for Best Experience</h2>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div className="text-center">
                <div className="w-16 h-16 bg-blue-500/20 rounded-full flex items-center justify-center mx-auto mb-4">
                  <Headphones size={28} className="text-blue-400" />
                </div>
                <h3 className="text-lg font-semibold text-white mb-2">Audio Setup</h3>
                <p className="text-gray-400 text-sm">Use headphones and find a quiet environment for the best voice chat experience.</p>
              </div>

              <div className="text-center">
                <div className="w-16 h-16 bg-green-500/20 rounded-full flex items-center justify-center mx-auto mb-4">
                  <Volume2 size={28} className="text-green-400" />
                </div>
                <h3 className="text-lg font-semibold text-white mb-2">Speak Clearly</h3>
                <p className="text-gray-400 text-sm">Speak naturally and clearly. Ask specific questions for more targeted coaching advice.</p>
              </div>

              <div className="text-center">
                <div className="w-16 h-16 bg-purple-500/20 rounded-full flex items-center justify-center mx-auto mb-4">
                  <Settings size={28} className="text-purple-400" />
                </div>
                <h3 className="text-lg font-semibold text-white mb-2">Be Patient</h3>
                <p className="text-gray-400 text-sm">Allow a moment for the AI to process your questions and provide thoughtful responses.</p>
              </div>
            </div>
          </motion.div>
        </motion.div>
      </div>
    </div>
  );
};

export default LiveCoach;