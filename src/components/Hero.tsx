import React from 'react';
import WorldMap from './WorldMap';

const Hero = () => {
  return (
    <section className="relative min-h-screen flex flex-col items-center justify-center text-center px-4 overflow-hidden bg-gradient-to-b from-[#111] via-[#111]/95 to-[#111]">
      <WorldMap />
      <div className="relative z-10">
        <h1 className="text-7xl md:text-8xl font-bold mb-6">
          Multi Region Infrastructure
        </h1>
        <p className="text-gray-400 text-xl md:text-2xl max-w-3xl">
          Enterprise-grade infrastructure deployment across multiple AWS regions
          for maximum reliability and global reach.
        </p>
      </div>
    </section>
  );
};

export default Hero;