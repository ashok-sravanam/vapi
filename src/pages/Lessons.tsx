import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Filter, Clock, BarChart, BookOpen, Mic } from 'lucide-react';
import { useVocalProfile } from '../context/VocalProfileContext';

const Lessons: React.FC = () => {
  const { profile } = useVocalProfile();
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [selectedLevel, setSelectedLevel] = useState<string>('all');
  
  const categories = [
    { id: 'all', name: 'All Lessons' },
    { id: 'pitch', name: 'Pitch Training' },
    { id: 'breath', name: 'Breath Control' },
    { id: 'rhythm', name: 'Rhythm' },
    { id: 'range', name: 'Vocal Range' },
    { id: 'tone', name: 'Tone Quality' },
  ];
  
  const levels = [
    { id: 'all', name: 'All Levels' },
    { id: 'beginner', name: 'Beginner' },
    { id: 'intermediate', name: 'Intermediate' },
    { id: 'advanced', name: 'Advanced' },
  ];
  
  const lessons = [
    {
      id: 1,
      title: 'Breath Control Fundamentals',
      description: 'Learn the basics of diaphragmatic breathing and breath control techniques.',
      category: 'breath',
      level: 'beginner',
      duration: 15,
      rating: 4.8,
      completionRate: 0,
      image: 'https://images.pexels.com/photos/3775126/pexels-photo-3775126.jpeg?auto=compress&cs=tinysrgb&w=600'
    },
    {
      id: 2,
      title: 'Pitch Accuracy Training',
      description: 'Improve your ability to hit and maintain correct pitch with these exercises.',
      category: 'pitch',
      level: 'intermediate',
      duration: 20,
      rating: 4.6,
      completionRate: 0,
      image: 'https://images.pexels.com/photos/4149303/pexels-photo-4149303.jpeg?auto=compress&cs=tinysrgb&w=600'
    },
    {
      id: 3,
      title: 'Rhythm and Timing Practice',
      description: 'Master rhythmic precision and timing with specialized vocal exercises.',
      category: 'rhythm',
      level: 'beginner',
      duration: 18,
      rating: 4.5,
      completionRate: 0,
      image: 'https://images.pexels.com/photos/7594461/pexels-photo-7594461.jpeg?auto=compress&cs=tinysrgb&w=600'
    },
    {
      id: 4,
      title: 'Expanding Your Vocal Range',
      description: 'Safe techniques to gradually extend your vocal range without strain.',
      category: 'range',
      level: 'intermediate',
      duration: 25,
      rating: 4.9,
      completionRate: 0,
      image: 'https://images.pexels.com/photos/4046847/pexels-photo-4046847.jpeg?auto=compress&cs=tinysrgb&w=600'
    },
  ];
  
  const filteredLessons = lessons.filter(lesson => {
    const categoryMatch = selectedCategory === 'all' || lesson.category === selectedCategory;
    const levelMatch = selectedLevel === 'all' || lesson.level === selectedLevel;
    return categoryMatch && levelMatch;
  });

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="page-transition max-w-7xl mx-auto"
    >
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-8">
        <div>
          <h2 className="text-2xl font-bold gradient-text">Lessons Library</h2>
          <p className="text-gray-300">Personalized vocal training exercises to improve your singing</p>
        </div>
      </div>
      
      <div className="flex flex-col md:flex-row gap-4 mb-8">
        <div className="flex overflow-x-auto pb-2 md:pb-0 hide-scrollbar">
          {categories.map(category => (
            <button
              key={category.id}
              onClick={() => setSelectedCategory(category.id)}
              className={`flex-shrink-0 px-4 py-2 rounded-full mr-2 text-sm font-medium transition-colors ${
                selectedCategory === category.id
                  ? 'bg-gradient-primary text-white'
                  : 'bg-dark-lighter text-gray-300 hover:bg-dark-accent hover:text-white'
              }`}
            >
              {category.name}
            </button>
          ))}
        </div>
        
        <div className="flex-shrink-0">
          <div className="relative">
            <select
              value={selectedLevel}
              onChange={(e) => setSelectedLevel(e.target.value)}
              className="appearance-none pl-10 pr-8 py-2 rounded-lg bg-dark border border-dark-accent text-gray-100 focus:outline-none focus:ring-2 focus:ring-purple-accent focus:border-transparent text-sm"
            >
              {levels.map(level => (
                <option key={level.id} value={level.id}>
                  {level.name}
                </option>
              ))}
            </select>
            <Filter className="absolute left-3 top-2.5 text-gray-500" size={16} />
          </div>
        </div>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {filteredLessons.map((lesson, index) => (
          <motion.div 
            key={lesson.id}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1 }}
            className="card hover:border-purple-accent/50 transition-all cursor-pointer group"
          >
            <div className="h-40 overflow-hidden rounded-lg mb-4">
              <img 
                src={lesson.image} 
                alt={lesson.title}
                className="w-full h-full object-cover transform group-hover:scale-105 transition-transform duration-300"
              />
            </div>
            
            <div className="flex items-center justify-between mb-3">
              <div className={`text-xs px-2 py-1 rounded-full ${
                lesson.category === 'pitch' ? 'bg-purple-accent/20 text-purple-light' :
                lesson.category === 'breath' ? 'bg-blue-accent/20 text-blue-light' :
                lesson.category === 'rhythm' ? 'bg-red-accent/20 text-red-light' :
                lesson.category === 'range' ? 'bg-yellow-500/20 text-yellow-400' :
                'bg-green-500/20 text-green-400'
              }`}>
                {lesson.category.charAt(0).toUpperCase() + lesson.category.slice(1)}
              </div>
              <div className={`text-xs px-2 py-1 rounded-full ${
                lesson.level === 'beginner' ? 'bg-green-500/20 text-green-400' :
                lesson.level === 'intermediate' ? 'bg-yellow-500/20 text-yellow-400' :
                'bg-red-accent/20 text-red-light'
              }`}>
                {lesson.level.charAt(0).toUpperCase() + lesson.level.slice(1)}
              </div>
            </div>
            
            <h3 className="text-lg font-semibold mb-2 text-white">{lesson.title}</h3>
            <p className="text-gray-300 text-sm mb-4 line-clamp-2">{lesson.description}</p>
            
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center text-gray-400 text-sm">
                <Clock size={14} className="mr-1" />
                <span>{lesson.duration} min</span>
              </div>
              <div className="flex items-center text-yellow-400 text-sm">
                <span className="mr-1">★</span>
                <span>{lesson.rating}</span>
              </div>
            </div>
            
            <button className="w-full py-2 bg-gradient-primary text-white font-medium rounded-lg hover:opacity-90 transition-all">
              Start Lesson
            </button>
          </motion.div>
        ))}
      </div>
      
      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="card"
      >
        <h3 className="text-lg font-semibold text-white mb-4">Recommended Learning Path</h3>
        
        <div className="relative">
          <div className="absolute left-8 top-0 bottom-0 w-1 bg-purple-accent/30"></div>
          
          <div className="space-y-6">
            {[
              { 
                icon: <BookOpen size={20} />, 
                title: 'Fundamentals', 
                description: 'Master the basics of breathing and pitch',
                current: true,
                courses: ['Breath Control Fundamentals', 'Pitch Accuracy Basics']
              },
              { 
                icon: <Mic size={20} />, 
                title: 'Technique Building', 
                description: 'Develop core techniques for better singing',
                current: false,
                courses: ['Rhythm and Timing Practice', 'Tone Production']
              },
              { 
                icon: <BarChart size={20} />, 
                title: 'Advanced Skills', 
                description: 'Refine your skills and expand your abilities',
                current: false,
                courses: ['Expanding Your Vocal Range', 'Advanced Tone Quality']
              }
            ].map((phase, index) => (
              <div key={index} className="relative ml-12">
                <div className={`absolute -left-16 w-8 h-8 rounded-full flex items-center justify-center ${
                  phase.current 
                    ? 'bg-purple-accent text-white'
                    : 'bg-dark-lighter text-purple-accent border border-purple-accent/30'
                }`}>
                  {phase.icon}
                </div>
                
                <div className={`p-4 rounded-lg ${
                  phase.current
                    ? 'bg-purple-accent/10 border border-purple-accent/30'
                    : 'bg-dark-lighter border border-dark-accent'
                }`}>
                  <h4 className="font-medium text-white">{phase.title}</h4>
                  <p className="text-sm text-gray-300 mb-3">{phase.description}</p>
                  
                  <div className="space-y-2">
                    {phase.courses.map((course, i) => (
                      <div key={i} className="flex items-center">
                        <div className={`w-2 h-2 rounded-full mr-2 ${
                          phase.current ? 'bg-purple-accent' : 'bg-gray-500'
                        }`}></div>
                        <span className="text-sm text-gray-300">{course}</span>
                      </div>
                    ))}
                  </div>
                  
                  {phase.current && (
                    <button className="mt-3 text-sm font-medium text-purple-accent hover:text-purple-light transition-colors">
                      Continue Learning
                    </button>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      </motion.div>
    </motion.div>
  );
};

export default Lessons;