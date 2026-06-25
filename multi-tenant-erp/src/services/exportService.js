export const handleShare = async (title, text) => {
  const url = window.location.href;
  
  if (navigator.share) {
    try {
      await navigator.share({ title, text, url });
    } catch (error) {
      if (error.name !== 'AbortError') {
        console.error('Share error:', error);
      }
    }
  } else {
    try {
      await navigator.clipboard.writeText(`${title}\n\n${text}\n\nLink: ${url}`);
      alert("Link and content copied to clipboard!");
    } catch (err) {
      console.error("Failed to copy to clipboard.", err);
    }
  }
};

export const downloadFromServer = async (apiEndpoint, payload, filename) => {
  try {
    const response = await fetch(apiEndpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      throw new Error(`Server responded with status: ${response.status}`);
    }

    const blob = await response.blob();
    const url = window.URL.createObjectURL(blob);
    
    const link = document.createElement('a');
    link.href = url;
    link.download = filename;
    
    document.body.appendChild(link);
    link.click();
    
    document.body.removeChild(link);
    window.URL.revokeObjectURL(url);
    
  } catch (error) {
    console.error(`Export Error:`, error);
    alert("Failed to export the file. Please try again.");
    throw error;
  }
};