export const calculateAttendance = (records) => {
    if (!records || records.length === 0) return 0;
    const present = records.filter(r => r.status === 'Present').length;
    return ((present / records.length) * 100).toFixed(0);
};

export const calculateGPA = (grades) => {
    if (!grades || grades.length === 0) return "0.0";
    const total = grades.reduce((acc, g) => acc + (g.marks_obtained / g.max_marks * 4), 0);
    return (total / grades.length).toFixed(2);
};


export const getMonthName = (monthNumber) => {
    const date = new Date();
    date.setMonth(monthNumber);
    return date.toLocaleString('en-US', { month: 'long' });
}

export const calculateMonthlyTrends = (records) => {
  const labels = ["DEC", "JAN", "FEB", "MAR", "APR", "MAY"];
  
  return labels.map((label) => {
    const monthIndex = new Date(`${label} 1, 2026`).getMonth(); 

    const monthRecords = records.filter(r => {
      const recordDate = new Date(r.date);
      return recordDate.getMonth() === monthIndex;
    });

    if (monthRecords.length === 0) return 0;
    
    // Calculate percentage
    const presentCount = monthRecords.filter(r => r.status === 'Present').length;
    return Math.round((presentCount / monthRecords.length) * 100);
  });
};

export const getPastSixMonths = () => {
  const months = [];
  for (let i = 5; i >= 0; i--) {
    const d = new Date();
    d.setMonth(d.getMonth() - i);
    months.push(d.toLocaleString('default', { month: 'short' }).toUpperCase());
  }
  return months;
};