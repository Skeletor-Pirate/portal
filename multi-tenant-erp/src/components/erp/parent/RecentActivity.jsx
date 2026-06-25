import React from 'react';

const RecentActivity = () => {
  return (
    <div className="bg-surface-container-lowest p-8 rounded-lg border border-outline-variant/10 shadow-sm">
      <div className="flex justify-between items-center mb-6">
        <h3 className="text-xl font-bold font-headline">Recent Activity</h3>
        <a className="text-sm font-bold text-primary hover:underline" href="#">View All</a>
      </div>
      <div className="space-y-6 relative">
        {/* Timeline Line */}
        <div className="absolute left-4 top-2 bottom-2 w-px bg-outline-variant/30"></div>

        {/* Activity Item 1 */}
        <div className="flex gap-6 relative">
          <div className="w-8 h-8 rounded-full bg-primary-container flex items-center justify-center z-10">
            <span className="material-symbols-outlined text-sm text-white">description</span>
          </div>
          <div>
            <h4 className="font-bold text-on-surface text-sm">Calculus Worksheet submitted</h4>
            <p className="text-xs text-on-surface-variant mt-1">Academic Section • 2 hours ago</p>
          </div>
        </div>

        {/* Activity Item 2 */}
        <div className="flex gap-6 relative">
          <div className="w-8 h-8 rounded-full bg-secondary-container flex items-center justify-center z-10">
            <span className="material-symbols-outlined text-sm text-white">grading</span>
          </div>
          <div>
            <h4 className="font-bold text-on-surface text-sm">Physics Quiz graded</h4>
            <p className="text-xs text-on-surface-variant mt-1">Result: 94/100 • 5 hours ago</p>
          </div>
        </div>

        {/* Activity Item 3 */}
        <div className="flex gap-6 relative">
          <div className="w-8 h-8 rounded-full bg-tertiary-container flex items-center justify-center z-10">
            <span className="material-symbols-outlined text-sm text-white">chat_bubble</span>
          </div>
          <div>
            <h4 className="font-bold text-on-surface text-sm">Teacher feedback on Chemistry</h4>
            <p className="text-xs text-on-surface-variant mt-1">Mrs. Henderson • Yesterday</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default RecentActivity;
