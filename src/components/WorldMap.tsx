import React, { useEffect, useState } from 'react';
import { getRegion } from '../api/region';

const WorldMap = () => {
  const [currentRegion, setCurrentRegion] = useState<string | null>(null);

  useEffect(() => {
    const fetchRegion = async () => {
      const region = await getRegion();
      setCurrentRegion(region);
    };
    fetchRegion();
  }, []);

  // World map coordinates (1 represents a dot, 0 represents empty space)
  const worldMap = [
    // North America
    { startX: 50, startY: 50, data: [
      [0,0,1,1,1,1,1,1,1,1,1,0,0],
      [0,1,1,1,1,1,1,1,1,1,1,1,0],
      [1,1,1,1,1,1,1,1,1,1,1,1,1],
      [1,1,1,1,1,1,1,1,1,1,1,1,1],
      [1,1,1,1,1,1,1,1,1,1,1,1,0],
      [0,1,1,1,1,1,1,1,1,1,0,0,0],
      [0,0,1,1,1,1,1,0,0,0,0,0,0],
    ]},
    // South America
    { startX: 120, startY: 120, data: [
      [0,0,0,1,1,1,1,0],
      [0,0,1,1,1,1,1,1],
      [0,1,1,1,1,1,1,1],
      [1,1,1,1,1,1,1,0],
      [1,1,1,1,1,1,0,0],
      [0,1,1,1,1,0,0,0],
      [0,0,1,1,0,0,0,0],
    ]},
    // Europe
    { startX: 200, startY: 50, data: [
      [0,0,1,1,1,1,1,0],
      [0,1,1,1,1,1,1,1],
      [1,1,1,1,1,1,1,1],
      [0,1,1,1,1,1,1,0],
      [0,0,1,1,1,1,0,0],
    ]},
    // Africa
    { startX: 200, startY: 100, data: [
      [0,0,1,1,1,1,1,1,0],
      [0,1,1,1,1,1,1,1,1],
      [1,1,1,1,1,1,1,1,1],
      [1,1,1,1,1,1,1,1,0],
      [1,1,1,1,1,1,1,0,0],
      [0,1,1,1,1,1,0,0,0],
      [0,0,1,1,1,0,0,0,0],
    ]},
    // Asia
    { startX: 250, startY: 50, data: [
      [0,1,1,1,1,1,1,1,1,1,1,1,1,1],
      [1,1,1,1,1,1,1,1,1,1,1,1,1,1],
      [1,1,1,1,1,1,1,1,1,1,1,1,1,0],
      [1,1,1,1,1,1,1,1,1,1,1,1,0,0],
      [0,1,1,1,1,1,1,1,1,1,1,0,0,0],
      [0,0,1,1,1,1,1,1,1,1,0,0,0,0],
    ]},
    // Australia
    { startX: 300, startY: 150, data: [
      [0,1,1,1,1,1,0],
      [1,1,1,1,1,1,1],
      [1,1,1,1,1,1,0],
      [0,1,1,1,1,0,0],
    ]},
  ];

  const createDots = () => {
    const dots = [];
    const dotSize = 4;
    const spacing = 6;

    worldMap.forEach((continent, continentIndex) => {
      continent.data.forEach((row, rowIndex) => {
        row.forEach((cell, cellIndex) => {
          if (cell === 1) {
            const x = continent.startX + (cellIndex * spacing);
            const y = continent.startY + (rowIndex * spacing);
            dots.push(
              <circle
                key={`${continentIndex}-${rowIndex}-${cellIndex}`}
                cx={x}
                cy={y}
                r={dotSize / 2}
                fill="#fff"
                opacity="0.8"
              />
            );
          }
        });
      });
    });
    return dots;
  };

  // AWS Regions data
  const awsRegions = [
    { name: 'us-east-1', x: 100, y: 80, label: 'N. Virginia' },
    { name: 'us-west-2', x: 60, y: 75, label: 'Oregon' },
    { name: 'eu-west-1', x: 200, y: 65, label: 'Ireland' },
    { name: 'eu-central-1', x: 215, y: 70, label: 'Frankfurt' },
    { name: 'ap-southeast-1', x: 300, y: 120, label: 'Singapore' },
    { name: 'ap-northeast-1', x: 320, y: 80, label: 'Tokyo' },
    { name: 'ap-southeast-2', x: 320, y: 170, label: 'Sydney' },
    { name: 'sa-east-1', x: 130, y: 140, label: 'São Paulo' },
  ];

  return (
    <div className="absolute inset-0 w-full h-full opacity-80 pointer-events-none">
      <svg
        viewBox="0 0 400 200"
        className="w-full h-full"
        preserveAspectRatio="xMidYMid meet"
        style={{ background: 'transparent' }}
      >
        {/* World Map Dots */}
        <g className="world-map-dots">
          {createDots()}
        </g>

        {/* AWS Regions */}
        {awsRegions.map((region) => (
          <g key={region.name} className={currentRegion === region.name ? 'animate-pulse' : ''}
            transform={`translate(${region.x},${region.y})`}>
            
            {/* Region marker */}
            <circle
              r={currentRegion === region.name ? '3' : '2'}
              fill={currentRegion === region.name ? '#ff6b6b' : '#ff8c42'}
              opacity={currentRegion === region.name ? '1' : '0.8'}
            />
            
            {/* Region Label */}
            <text
              x="5"
              y="2"
              fill={currentRegion === region.name ? '#ff6b6b' : '#ff8c42'}
              opacity={currentRegion === region.name ? '1' : '0.8'}
              fontSize="6"
              fontFamily="Arial"
              fontWeight="500"
            >
              {region.label}
            </text>

            {/* Pulse Animation for Current Region */}
            {currentRegion === region.name && (
              <>
                <circle
                  r="4"
                  fill="none"
                  stroke="#ff6b6b"
                  strokeWidth="1"
                  opacity="0.5"
                >
                  <animate
                    attributeName="r"
                    from="4"
                    to="8"
                    dur="1.5s"
                    repeatCount="indefinite"
                  />
                  <animate
                    attributeName="opacity"
                    from="0.5"
                    to="0"
                    dur="1.5s"
                    repeatCount="indefinite"
                  />
                </circle>
              </>
            )}
          </g>
        ))}

        {/* Connection Lines */}
        <g stroke="#ff8c42" strokeWidth="0.5" opacity="0.3">
          {awsRegions.map((region, index) => {
            if (index === 0) return null;
            return (
              <line
                key={`line-${index}`}
                x1={awsRegions[0].x}
                y1={awsRegions[0].y}
                x2={region.x}
                y2={region.y}
              />
            );
          })}
        </g>
      </svg>
    </div>
  );
};

export default WorldMap;