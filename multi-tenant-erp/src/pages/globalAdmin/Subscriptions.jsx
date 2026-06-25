import Layout from "../../components/erp/global/Layout";
import { useNavigate } from "react-router-dom";

export default function Subscriptions(){
const navigate = useNavigate();
return(

<Layout>

<div className="space-y-10">

{/* HEADER */}

<div className="flex justify-between items-end">

<div>

<p className="text-[11px] font-bold tracking-widest text-[#924700] uppercase">
PLATFORM MANAGEMENT
</p>

<h1 className="text-4xl font-extrabold">
Subscription Architecture
</h1>

<p className="text-gray-500 max-w-xl mt-2">
Configure institutional tiers, resource limits, and AI credit allocation for the current academic cycle.
</p>

</div >


<button
onClick={()=>navigate("/global-admin/create-plan")}
className="bg-gradient-to-r from-[#0058be] to-[#2170e4] text-white px-6 py-3 rounded-xl font-semibold flex items-center gap-2 shadow-lg hover:opacity-90 transition"
>

<span className="material-symbols-outlined">
add
</span>

Create Plan

</button>

</div>



{/* STATS */}

<div className="grid grid-cols-12 gap-6">

{/* institutions */}

<div className="col-span-4 bg-white p-6 rounded-xl">

<div className="flex justify-between mb-4">

<div className="bg-blue-100 p-2 rounded-lg text-blue-700">

<span className="material-symbols-outlined">
trending_up
</span>

</div>

<span className="text-xs text-blue-600 font-bold">
MONTHLY GROWTH
</span>

</div>

<p className="text-gray-500 text-sm">
Active Institutions
</p>

<h2 className="text-3xl font-bold mt-1">
1,284
</h2>

</div>



{/* revenue */}

<div className="col-span-8 bg-[#2170e4] text-white p-6 rounded-xl relative overflow-hidden">

<h3 className="text-xl font-bold mb-2">
Annual Revenue Projection
</h3>

<p className="text-white/80 text-sm max-w-md">
Revenue is currently trending 14% higher than last quarter due to Enterprise tier upgrades.
</p>

<div className="mt-4 flex items-baseline gap-2">

<span className="text-4xl font-bold">
$4.2M
</span>

<span className="text-white/70 text-sm">
Estimated ARR
</span>

</div>

</div>

</div>



{/* TABLE */}

<div className="bg-white rounded-xl overflow-hidden">

<table className="w-full text-left">

<thead>

<tr className="bg-[#eef2ff] text-sm text-gray-500">

<th className="px-8 py-5">
PLAN NAME
</th>

<th className="px-6 py-5">
MONTHLY PRICE
</th>

<th className="px-6 py-5">
KEY FEATURES
</th>

<th className="px-6 py-5">
MAX USERS
</th>

<th className="px-6 py-5">
AI CREDITS
</th>

<th className="px-8 py-5 text-right">
ACTIONS
</th>

</tr>

</thead>



<tbody>

{/* basic */}

<tr className="border-t">

<td className="px-8 py-6">

<div className="flex items-center gap-3">

<div className="w-10 h-10 bg-gray-100 rounded-lg flex items-center justify-center">

<span className="material-symbols-outlined">
school
</span>

</div>


<div>

<p className="font-bold">
Basic
</p>

<p className="text-xs text-gray-500">
For small academies
</p>

</div>

</div>

</td>


<td className="px-6 py-6 font-bold text-blue-700">
$499/mo
</td>


<td className="px-6 py-6">

<div className="flex gap-2 flex-wrap">

<span className="px-3 py-1 bg-gray-100 rounded-full text-xs">
Smart Attendance
</span>

<span className="px-3 py-1 bg-gray-100 rounded-full text-xs">
LMS Core
</span>

</div>

</td>


<td className="px-6 py-6">
500
</td>


<td className="px-6 py-6">
1,000 / mo
</td>


<td className="px-8 py-6 text-right">

<button>

<span className="material-symbols-outlined text-blue-700">
edit
</span>

</button>

</td>

</tr>



{/* pro */}

<tr className="border-t bg-blue-50/20">

<td className="px-8 py-6">

<div className="flex items-center gap-3">

<div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center text-blue-700">

<span className="material-symbols-outlined">
auto_awesome
</span>

</div>


<div>

<p className="font-bold flex gap-2 items-center">

Pro

<span className="bg-purple-600 text-white text-[10px] px-2 rounded-full">
POPULAR
</span>

</p>

<p className="text-xs text-gray-500">
Standard institutional tier
</p>

</div>

</div>

</td>


<td className="px-6 py-6 font-bold text-blue-700">
$1,299/mo
</td>


<td className="px-6 py-6">

<div className="flex gap-2 flex-wrap">

<span className="px-3 py-1 bg-gray-100 rounded-full text-xs">
AI Grade
</span>

<span className="px-3 py-1 bg-gray-100 rounded-full text-xs">
Parent App
</span>

<span className="px-3 py-1 bg-gray-100 rounded-full text-xs">
+3 more
</span>

</div>

</td>


<td className="px-6 py-6">
2,500
</td>


<td className="px-6 py-6">
10,000 / mo
</td>


<td className="px-8 py-6 text-right">

<button>

<span className="material-symbols-outlined text-blue-700">
edit
</span>

</button>

</td>

</tr>



{/* enterprise */}

<tr className="border-t">

<td className="px-8 py-6">

<div className="flex items-center gap-3">

<div className="w-10 h-10 bg-orange-100 rounded-lg flex items-center justify-center text-orange-700">

<span className="material-symbols-outlined">
corporate_fare
</span>

</div>


<div>

<p className="font-bold">
Enterprise
</p>

<p className="text-xs text-gray-500">
Multi-campus ecosystems
</p>

</div>

</div>

</td>


<td className="px-6 py-6 font-bold text-blue-700">
Custom
</td>


<td className="px-6 py-6">

<div className="flex gap-2 flex-wrap">

<span className="px-3 py-1 bg-gray-100 rounded-full text-xs">
Multi-campus
</span>

<span className="px-3 py-1 bg-gray-100 rounded-full text-xs">
Priority Support
</span>

<span className="px-3 py-1 bg-gray-100 rounded-full text-xs">
White-label
</span>

</div>

</td>


<td className="px-6 py-6">
Unlimited
</td>


<td className="px-6 py-6">
Custom Limit
</td>


<td className="px-8 py-6 text-right">

<button>

<span className="material-symbols-outlined text-blue-700">
edit
</span>

</button>

</td>

</tr>

</tbody>

</table>

</div>



{/* INSIGHT */}

<div className="grid md:grid-cols-2 gap-8">

<div className="bg-white p-8 rounded-xl flex gap-6 items-center">

<img
className="w-32 h-32 rounded-lg"
src="https://lh3.googleusercontent.com/aida-public/AB6AXuDr5a3jqKR-hRiqclzAdV6OLh0mukTvNwX917cEBbI3pM9fhuidLQaz1T-1wn3_3EPBZK9Q_jX_kPFXlYLJ2cRFWI8BYy0h1d5U9koa_qz8VdMqCy-Q62y-L_KB2mtolSY-RdnI0lteOdBtVdMDs7_9rpDZLL2JG-Usp0EF-a8AHcWcz3vN7wfB9qnbsulwUKaf6oQO0xzJcx5TSqkNB6bcF_18jtB-6tEz2xwTKPmHVCWlu4CRparzrx-jE057w0m3WEchk-9oKw"
/>


<div>

<h4 className="font-bold">
Architecture Audit
</h4>

<p className="text-sm text-gray-500">
Ensure your tiered features align with standard requirements.
</p>

<p className="text-blue-700 text-sm font-semibold mt-2">
View Compliance Report →
</p>

</div>

</div>



<div className="bg-white/70 backdrop-blur p-8 rounded-xl">

<p className="text-xs font-bold text-orange-700">
AI INSIGHT
</p>

<h4 className="font-bold mt-2">
Utilization Warning
</h4>

<p className="text-sm text-gray-500 mt-2">
Enterprise users are consuming AI credits 20% faster than predicted.
</p>


<div className="mt-4 flex gap-4">

<button className="bg-black text-white text-xs px-4 py-2 rounded-md">
Adjust Limits
</button>

<button className="text-xs px-4 py-2">
Ignore
</button>

</div>

</div>

</div>



{/* footer */}

<div className="border-t pt-6 text-sm text-gray-400 flex justify-between">

<p>
© 2024 Academic Architect Platform. Tier Management v4.2.0
</p>

<div className="flex gap-6">

<span>System Status</span>

<span>API Docs</span>

<span>Security</span>

</div>

</div>



</div>

</Layout>

)

}

