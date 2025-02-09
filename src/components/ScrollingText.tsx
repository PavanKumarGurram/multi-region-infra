import React, { useEffect, useState } from 'react';
import { getRegion } from '../api/region';

const ScrollingText = () => {
  const [region, setRegion] = useState<string | null>(null);
  const [visibleIndex, setVisibleIndex] = useState(0);

  useEffect(() => {
    const fetchRegion = async () => {
      const regionData = await getRegion();
      setRegion(regionData);
    };
    fetchRegion();
  }, []);

  useEffect(() => {
    const handleScroll = () => {
      const scrollableHeight = document.documentElement.scrollHeight - window.innerHeight;
      const scrollPercentage = (window.scrollY / scrollableHeight) * 1.5;
      const totalWords = document.querySelectorAll('.scroll-word').length;
      const newIndex = Math.floor(scrollPercentage * (totalWords * 0.7));
      setVisibleIndex(newIndex);
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const textContent = [
    ['Designed', 'for', 'global'],
    ['scale,', 'built', 'for'],
    ['enterprise', 'needs.'],
    ['Our', 'infrastructure'],
    ['spans', 'multiple'],
    ['AWS', 'regions,'],
    ['currently', 'hosted', 'in'],
    [region || 'loading...'],
    ['ensuring', 'maximum'],
    ['uptime', 'and'],
    ['reliability', 'with'],
    ['automated', 'failover'],
    ['capabilities,'],
    ['24/7', 'availability.']
  ];

  let wordCounter = 0;

  return (
    <section className="px-6">
      <div className="max-w-6xl mx-auto">
        <div className="space-y-8 text-7xl md:text-8xl font-bold leading-tight tracking-tight">
          {textContent.map((line, lineIndex) => (
            <p key={lineIndex} className="mb-16">
              {line.map((word, wordIndex) => {
                const isRegion = word === region;
                const currentWordIndex = wordCounter++;
                
                return (
                  <React.Fragment key={wordIndex}>
                    <span 
                      className={`
                        scroll-word
                        transition-colors duration-300
                        ${isRegion ? 'text-orange-500' : 
                          currentWordIndex <= visibleIndex ? 'text-white' : 'text-gray-800'
                        }
                      `}
                    >
                      {word}
                    </span>
                    {wordIndex < line.length - 1 && ' '}
                  </React.Fragment>
                );
              })}
            </p>
          ))}
        </div>
      </div>
    </section>
  );
};

export default ScrollingText;