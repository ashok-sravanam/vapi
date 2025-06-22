import React from 'react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { PhoneCall } from 'lucide-react';

const LiveCoach: React.FC = () => {
  const navigate = useNavigate();

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-900">
      <motion.button
        whileHover={{ scale: 1.05 }}
        whileTap={{ scale: 0.95 }}
        onClick={() => navigate('/voice-assistant')}
        className="px-8 py-4 bg-gradient-to-r from-green-500 to-green-600 text-white font-semibold rounded-full hover:shadow-lg transition-all flex items-center space-x-3 text-lg"
      >
        <PhoneCall size={24} className="mr-3" />
        Start Voice Chat
      </motion.button>
    </div>
  );
};

export default LiveCoach;