// Simple function to get region info
export const getRegion = async () => {
  try {
    const response = await fetch('https://checkip.amazonaws.com/');
    // For demo purposes, we'll return a hardcoded region
    // In production, you would determine the region based on the IP or from your backend
    return 'us-east-1';
  } catch (error) {
    console.error('Error fetching region:', error);
    return null;
  }
};