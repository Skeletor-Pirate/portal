import Layout from "../../components/erp/global/Layout";

export default function Notifications(){

return(

<Layout>

<div className="max-w-6xl mx-auto w-full">

{/* heading */}

<div className="mb-10">

<h1 className="text-4xl font-extrabold tracking-tight text-[#0b1c30]">
Notifications
</h1>

<p className="text-[#6b7280] mt-2">
Manage recent activities and administrative alerts across the global network.
</p>

</div>



<div className="space-y-6">

{/* notification 1 */}

<div className="bg-white rounded-xl p-6 flex items-start gap-6 hover:shadow-[0px_12px_32px_rgba(11,28,48,0.04)] transition">

<div className="w-14 h-14 rounded-2xl bg-[#d8e2ff] flex items-center justify-center text-[#0058be]">

<span className="material-symbols-outlined text-3xl">
school
</span>

</div>


<div className="flex-1">

<div className="flex justify-between mb-1">

<h3 className="text-lg font-bold text-[#0b1c30]">
New School Registered: Oakwood International Academy
</h3>

<span className="text-xs text-gray-400 uppercase tracking-widest">
2m ago
</span>

</div>


<p className="text-[#6b7280] text-sm mb-6 leading-relaxed">

A new institutional profile has been created and is awaiting administrative verification for regional deployment.

</p>


<div className="flex gap-3">

<button className="px-6 py-2.5 bg-gradient-to-br from-[#0058be] to-[#2170e4] text-white text-sm font-bold rounded-md">

Approve

</button>


<button className="px-6 py-2.5 bg-[#e5eeff] text-[#0058be] text-sm font-bold rounded-md">

Dismiss

</button>

</div>

</div>

</div>



{/* notification 2 */}

<div className="bg-white rounded-xl p-6 flex items-start gap-6 hover:shadow-[0px_12px_32px_rgba(11,28,48,0.04)] transition">

<div className="w-14 h-14 rounded-2xl bg-[#e9ddff] flex items-center justify-center text-[#6b38d4]">

<span className="material-symbols-outlined text-3xl">
check_circle
</span>

</div>


<div className="flex-1">

<div className="flex justify-between mb-1">

<h3 className="text-lg font-bold text-[#0b1c30]">
Domain Verification Success: edu.riverside.org
</h3>

<span className="text-xs text-gray-400 uppercase tracking-widest">
14m ago
</span>

</div>


<p className="text-[#6b7280] text-sm mb-4 leading-relaxed">

The custom domain has been successfully pointed to the ScholarFlow edge nodes. DNS propagation complete.

</p>


<button className="flex items-center gap-1.5 text-[#0058be] text-sm font-bold">

View Settings

<span className="material-symbols-outlined text-sm">
open_in_new
</span>

</button>

</div>

</div>



{/* notification 3 */}

<div className="bg-white rounded-xl p-6 flex items-start gap-6 hover:shadow-[0px_12px_32px_rgba(11,28,48,0.04)] transition">

<div className="w-14 h-14 rounded-2xl bg-[#ffdcc6] flex items-center justify-center text-[#924700]">

<span className="material-symbols-outlined text-3xl">
payments
</span>

</div>


<div className="flex-1">

<div className="flex justify-between mb-1">

<h3 className="text-lg font-bold text-[#0b1c30]">
Subscription Payment Received: $1,284.00
</h3>

<span className="text-xs text-gray-400 uppercase tracking-widest">
1h ago
</span>

</div>


<p className="text-[#6b7280] text-sm mb-4 leading-relaxed">

The monthly enterprise subscription for Northern Districts Consortium has been processed successfully.

</p>


<button className="flex items-center gap-2 px-4 py-2 border border-gray-200 rounded-lg text-gray-600 hover:bg-[#eff4ff]">

<span className="material-symbols-outlined text-lg">
download
</span>

Download Receipt

</button>

</div>

</div>



{/* insight cards */}

<div className="mt-8 grid md:grid-cols-3 gap-6">


{/* health */}

<div className="md:col-span-2 bg-[#0058be] text-white rounded-xl p-8 relative overflow-hidden">

<div className="relative z-10">

<h4 className="text-xl font-bold mb-2">
Notification Health
</h4>

<p className="text-white/80 text-sm max-w-sm">
94% of administrative alerts were resolved within the first hour today.
System efficiency is up 12% from last week.
</p>

</div>


<div className="mt-8 flex gap-6 relative z-10">

<div className="text-center">

<p className="text-2xl font-bold">
42
</p>

<p className="text-[10px] uppercase opacity-70">
Resolved
</p>

</div>


<div className="text-center">

<p className="text-2xl font-bold">
03
</p>

<p className="text-[10px] uppercase opacity-70">
Pending
</p>

</div>

</div>


<div className="absolute -right-10 -bottom-10 w-64 h-64 bg-white/10 rounded-full blur-3xl"></div>

</div>



{/* AI card */}

<div className="bg-[#dce9ff] rounded-xl p-8 flex flex-col items-center text-center gap-4">

<div className="w-16 h-16 rounded-full bg-white flex items-center justify-center shadow-sm">

<span className="material-symbols-outlined text-[#0058be] text-3xl">
auto_awesome
</span>

</div>


<div>

<p className="font-bold text-[#0b1c30]">
Auto-Digest
</p>

<p className="text-xs text-[#6b7280] px-4">
Generate an AI summary of today's events for the board report.
</p>

</div>


<button className="text-[#0058be] text-xs font-bold uppercase tracking-widest">

Configure AI

</button>

</div>


</div>


</div>

</div>

</Layout>

)

}