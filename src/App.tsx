import React from 'react';
import Hero from './components/Hero';
import ScrollingText from './components/ScrollingText';

function App() {
  return (
    <div className="relative min-h-[400vh] bg-[#111]">
      <Hero />
      <ScrollingText />
    </div>
  );
}

export default App;