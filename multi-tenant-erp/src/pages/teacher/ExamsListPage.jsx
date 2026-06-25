import React from 'react';
import { Link } from 'react-router-dom';
import MainLayout from "../../components/erp/teacher/MainLayout";
import Card from "../../components/erp/teacher/Card";


const examsData = [
  { id: 1, name: 'Midterm Mathematics', desc: 'Standard Mid-Semester Assessment', class: '10-A', subject: 'Mathematics', date: 'Oct 30, 2023', marks: 100, status: 'Scheduled', statusColor: 'secondary' },
  { id: 2, name: 'Physics Practical Quiz', desc: 'Lab Assessment Cycle B', class: '10-A', subject: 'Physics', date: 'Nov 05, 2023', marks: 25, status: 'Scheduled', statusColor: 'secondary' },
  { id: 3, name: 'English Literature Final', desc: 'Term-End Examination', class: '10-B', subject: 'English', date: 'Dec 12, 2023', marks: 100, status: 'Draft', statusColor: 'slate' },
  { id: 4, name: 'Chemistry Unit Test 2', desc: 'Monthly Progress Evaluation', class: '11-C', subject: 'Chemistry', date: 'Oct 25, 2023', marks: 50, status: 'Rescheduled', statusColor: 'red' },
];

const ExamsListPage = () => {
  return (
    <MainLayout title="Teacher Portal">
      {/* Header Section */}
      <div className="flex flex-col sm:flex-row sm:items-end justify-between mb-10 gap-4">
        <div>
          <h2 className="text-4xl font-extrabold font-display text-on-surface tracking-tight mb-2">Exams</h2>
          <p className="text-on-surface-variant text-sm flex items-center gap-2">
            <span className="material-symbols-outlined text-sm">calendar_month</span>
            Showing examination schedules for Academic Year 2023-24
          </p>
        </div>
        <Link to="/exams/create" className="bg-gradient-to-br from-primary to-primary-container text-white px-6 py-3 rounded-md font-semibold flex items-center justify-center gap-2 shadow-lg shadow-primary/20 hover:scale-[0.98] transition-all duration-150 whitespace-nowrap">
          <span className="material-symbols-outlined text-lg">add</span>
          Create Exam
        </Link>
      </div>

      {/* Intelligent Filters Bar */}
      <div className="bg-surface-container-low p-5 rounded-lg mb-8 flex flex-wrap items-center gap-4">
        <div className="flex-1 min-w-[280px]">
          <div className="relative group">
            <span className="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-on-surface-variant group-focus-within:text-primary transition-colors">search</span>
            <input className="w-full bg-surface-container-lowest border-none rounded-md py-3 pl-12 pr-4 text-sm focus:ring-2 focus:ring-primary/40 shadow-sm transition-all outline-none" placeholder="Search by Exam Name or Subject..." type="text" />
          </div>
        </div>
        <div className="flex flex-wrap items-center gap-3 w-full sm:w-auto">
          <select className="bg-surface-container-lowest border-none rounded-md py-3 pl-4 pr-10 text-sm focus:ring-2 focus:ring-primary/40 shadow-sm outline-none flex-1 sm:flex-none">
            <option>All Classes</option>
            <option>10-A</option>
            <option>10-B</option>
            <option>11-C</option>
          </select>
          <select className="bg-surface-container-lowest border-none rounded-md py-3 pl-4 pr-10 text-sm focus:ring-2 focus:ring-primary/40 shadow-sm outline-none flex-1 sm:flex-none">
            <option>All Subjects</option>
            <option>Mathematics</option>
            <option>Physics</option>
            <option>Chemistry</option>
          </select>
          <select className="bg-surface-container-lowest border-none rounded-md py-3 pl-4 pr-10 text-sm focus:ring-2 focus:ring-primary/40 shadow-sm outline-none flex-1 sm:flex-none">
            <option>Exam Type</option>
            <option>Unit Test</option>
            <option>Midterm</option>
            <option>Final Exam</option>
          </select>
          <button className="bg-surface-container-high text-primary px-4 py-3 rounded-md font-medium text-sm flex items-center justify-center gap-2 hover:bg-surface-variant transition-colors outline-none border-none cursor-pointer w-full sm:w-auto mt-2 sm:mt-0">
            <span className="material-symbols-outlined text-lg">filter_list</span>
            More Filters
          </button>
        </div>
      </div>

      {/* Exams Table */}
      <Card className="p-0 shadow-sm overflow-hidden border border-outline-variant/15">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse min-w-[800px]">
            <thead>
              <tr className="bg-surface-container-low/50 border-b border-surface-container">
                <th className="px-6 py-5 text-xs font-bold text-on-surface-variant uppercase tracking-widest">Exam Name</th>
                <th className="px-6 py-5 text-xs font-bold text-on-surface-variant uppercase tracking-widest">Class</th>
                <th className="px-6 py-5 text-xs font-bold text-on-surface-variant uppercase tracking-widest">Subject</th>
                <th className="px-6 py-5 text-xs font-bold text-on-surface-variant uppercase tracking-widest">Date</th>
                <th className="px-6 py-5 text-xs font-bold text-on-surface-variant uppercase tracking-widest">Marks</th>
                <th className="px-6 py-5 text-xs font-bold text-on-surface-variant uppercase tracking-widest">Status</th>
                <th className="px-6 py-5 text-xs font-bold text-on-surface-variant uppercase tracking-widest text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-surface-container/50">
              {examsData.map((exam) => {
                let statusBg, statusText, dotColor;
                if (exam.statusColor === 'secondary') {
                  statusBg = 'bg-[#e9ddff]'; statusText = 'text-[#23005c]'; dotColor = 'bg-[#6b38d4]';
                } else if (exam.statusColor === 'slate') {
                  statusBg = 'bg-slate-100'; statusText = 'text-slate-600'; dotColor = 'bg-slate-500';
                } else if (exam.statusColor === 'red') {
                  statusBg = 'bg-red-50'; statusText = 'text-red-700'; dotColor = 'bg-red-500';
                }
                
                return (
                  <tr key={exam.id} className="hover:bg-blue-50/30 transition-colors group">
                    <td className="px-6 py-6">
                      <div className="flex flex-col">
                        <span className="font-display font-bold text-on-surface">{exam.name}</span>
                        <span className="text-xs text-on-surface-variant font-medium">{exam.desc}</span>
                      </div>
                    </td>
                    <td className="px-6 py-6 text-sm font-medium text-on-surface">{exam.class}</td>
                    <td className="px-6 py-6 text-sm">
                      <span className="bg-primary/5 text-primary px-3 py-1 rounded-full text-xs font-semibold whitespace-nowrap">{exam.subject}</span>
                    </td>
                    <td className="px-6 py-6 text-sm text-on-surface-variant whitespace-nowrap">{exam.date}</td>
                    <td className="px-6 py-6 text-sm font-semibold text-on-surface">{exam.marks}</td>
                    <td className="px-6 py-6">
                      <span className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-bold ${statusBg} ${statusText} whitespace-nowrap`}>
                        <span className={`w-1.5 h-1.5 rounded-full ${dotColor} mr-2`}></span>
                        {exam.status}
                      </span>
                    </td>
                    <td className="px-6 py-6 text-right">
                      <div className="flex justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                        <button className="p-2 hover:bg-white rounded-md text-primary transition-all shadow-sm outline-none cursor-pointer border-none" title="View Exam">
                          <span className="material-symbols-outlined text-lg block">visibility</span>
                        </button>
                        <button className="p-2 hover:bg-white rounded-md text-on-surface-variant transition-all shadow-sm outline-none cursor-pointer border-none" title="Edit Exam">
                          <span className="material-symbols-outlined text-lg block">edit</span>
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
        {/* Pagination */}
        <div className="px-6 py-4 bg-surface-container-lowest border-t border-surface-container flex flex-col sm:flex-row items-center justify-between gap-4">
          <span className="text-xs font-medium text-on-surface-variant">Showing 4 of 24 examinations</span>
          <div className="flex items-center gap-1">
            <button className="p-1 rounded hover:bg-surface-container-low transition-colors disabled:opacity-30 border-none outline-none cursor-pointer" disabled>
              <span className="material-symbols-outlined block">chevron_left</span>
            </button>
            <button className="w-8 h-8 rounded bg-primary text-white text-xs font-bold border-none outline-none cursor-pointer">1</button>
            <button className="w-8 h-8 rounded hover:bg-surface-container-low text-on-surface text-xs font-medium border-none outline-none cursor-pointer">2</button>
            <button className="w-8 h-8 rounded hover:bg-surface-container-low text-on-surface text-xs font-medium border-none outline-none cursor-pointer">3</button>
            <button className="p-1 rounded hover:bg-surface-container-low transition-colors border-none outline-none cursor-pointer text-on-surface">
              <span className="material-symbols-outlined block">chevron_right</span>
            </button>
          </div>
        </div>
      </Card>

      {/* AI Insights (Bento Grid Style) */}
      <div className="mt-12 grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="col-span-1 md:col-span-2 bg-gradient-to-br from-primary-container to-primary p-8 rounded-lg text-white relative overflow-hidden shadow-sm">
          <div className="relative z-10">
            <div className="flex items-center gap-2 mb-4">
              <span className="material-symbols-outlined">psychology</span>
              <span className="text-sm font-bold tracking-widest uppercase opacity-80">AI Proactive Insight</span>
            </div>
            <h3 className="text-2xl font-bold font-display mb-4 max-w-md">Predictive workload analysis suggests a cluster of exams on Nov 15th.</h3>
            <p className="text-blue-100 text-sm max-w-lg mb-6 leading-relaxed">System has detected that 10-A students have 3 major submissions due on the same day. Would you like to reschedule the Physics Practical?</p>
            <button className="bg-white text-primary px-5 py-2.5 rounded-md font-bold text-sm shadow-xl shadow-black/10 hover:bg-blue-50 transition-colors outline-none border-none cursor-pointer">
              Manage Schedule Conflicts
            </button>
          </div>
          <div className="absolute -right-12 -bottom-12 opacity-10 hidden md:block">
            <span className="material-symbols-outlined text-[240px]" style={{ fontVariationSettings: "'FILL' 1" }}>auto_awesome</span>
          </div>
        </div>
        <div className="bg-surface-container-high p-6 rounded-lg flex flex-col justify-between border-l-4 border-[#924700] shadow-sm">
          <div>
            <span className="text-xs font-bold text-[#924700] tracking-widest uppercase">Exam Efficiency</span>
            <h4 className="text-3xl font-extrabold font-display text-on-surface mt-2">84%</h4>
            <p className="text-sm text-on-surface-variant mt-1 leading-tight">Average completion rate for digital unit tests in Class 10-A.</p>
          </div>
          <div className="mt-6 pt-4 border-t border-outline-variant/30">
            <button className="text-primary text-xs font-bold flex items-center gap-1 hover:underline outline-none border-none cursor-pointer bg-transparent">
              View Detailed Analytics
              <span className="material-symbols-outlined text-sm">arrow_forward</span>
            </button>
          </div>
        </div>
      </div>
    </MainLayout>
  );
};

export default ExamsListPage;
