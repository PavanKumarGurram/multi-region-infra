import React from 'react';

const Footer = () => {
  return (
    <footer className="fixed bottom-0 left-0 right-0 px-6 pb-2 bg-[#111]">
      <div className="max-w-6xl mx-auto">
        <p className="text-[#ff6b6b] text-sm font-semibold mb-1">Pavan Gurram</p>
        <p className="text-gray-400 text-sm">
          <a 
            href="https://pavangurram.com" 
            target="_blank" 
            rel="noopener noreferrer"
            className="hover:text-white transition-colors duration-300"
          >
            pavangurram.com
          </a>
        </p>
      </div>
    </footer>
  );
};

export default Footer;