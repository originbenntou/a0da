import React, { useEffect, useState } from 'react';
import Loading from "./Loading";

const CustomImage = ({ src, alt, width, height, token }) => {
  const [imageSrc, setImageSrc] = useState(null);
  
  useEffect(() => {
    const fetchImage = async () => {
      try {
        const response = await fetch(src, {
          method: 'GET',
          headers: {
            Authorization: `Bearer ${token}`,
          },
          mode: "cors"
        });
        
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        
        const blob = await response.blob();
        const imageUrl = URL.createObjectURL(blob);
        setImageSrc(imageUrl);
      } catch (error) {
        console.error('Error fetching the image:', error);
      }
    };
    
    fetchImage();
  }, [src, token]);
  
  const handleDownload = () => {
    const link = document.createElement('a');
    link.href = imageSrc;
    link.download = alt;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };
  
  if (!imageSrc) {
    return <Loading />;
  }
  
  return (
    <div>
      <img src={imageSrc} alt={alt} width={width} height={height} />
      <button onClick={handleDownload}>Download</button>
    </div>
  );
};

export default CustomImage;
