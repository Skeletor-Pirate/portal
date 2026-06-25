import Layout from "../../components/erp/global/Layout";
import { useNavigate } from "react-router-dom";
import { useState } from "react";

export default function SecurityAccess(){

const navigate = useNavigate();

const [twoFA,setTwoFA] = useState(true);

return(

<Layout>

<div className="min-h-screen bg-[#f8f9ff]">

<div className="max-w-6xl mx-auto px-8 py-10">

{/* header */}

<div className="flex items-start justify-between mb-10">

<div>

<h1 className="text-4xl font-extrabold text-[#0b1c30]">
Security & Access
</h1>

<p className="text-[#424754] mt-2 max-w-2xl">
Configure institutional security protocols and administrative access control.
</p>

</div>


<button
onClick={()=>navigate("/global-admin/settings")}
className="flex items-center gap-2 px-4 py-2 bg-[#dce9ff] text-[#0058be] rounded-md font-semibold text-sm hover:bg-[#d3e4fe]"
>

<span className="material-symbols-outlined text-sm">
arrow_back
</span>

Go Back

</button>

</div>



<div className="grid lg:grid-cols-3 gap-8">

{/* LEFT */}

<div className="lg:col-span-2 space-y-8">

{/* 2FA */}

<div className="bg-white p-6 rounded-lg shadow-sm flex justify-between items-center">

<div className="flex gap-4">

<div className="bg-[#d8e2ff] p-3 rounded-xl">

<span className="material-symbols-outlined text-[#0058be]">
verified_user
</span>

</div>


<div>

<h3 className="font-bold text-lg">
Two-Factor Authentication
</h3>

<p className="text-sm text-gray-500">
Enable Two-Factor Authentication for all Admin accounts
</p>

</div>

</div>


<input
type="checkbox"
checked={twoFA}
onChange={()=>setTwoFA(!twoFA)}
className="w-5 h-5 accent-[#0058be]"
/>

</div>



{/* IP whitelist */}

<div className="bg-white p-8 rounded-lg shadow-sm">

<div className="flex justify-between mb-6">

<div className="flex gap-2 items-center">

<span className="material-symbols-outlined text-[#0058be]">
lan
</span>

<h3 className="font-bold text-xl">
IP Whitelist
</h3>

</div>


<button className="px-4 py-2 bg-[#dce9ff] text-[#0058be] rounded-md text-sm font-semibold">
Add IP
</button>

</div>



<table className="w-full text-sm">

<thead className="text-xs uppercase text-gray-400">

<tr>

<th className="pb-4">
IP Address
</th>

<th className="pb-4">
Label
</th>

<th className="pb-4 text-right">
Action
</th>

</tr>

</thead>



<tbody className="divide-y">

<tr>

<td className="py-4 font-mono">
192.168.1.105
</td>

<td className="py-4 text-gray-500">
Head Office - Gateway
</td>

<td className="py-4 text-right">

<span className="material-symbols-outlined text-red-500 cursor-pointer">
delete
</span>

</td>

</tr>



<tr>

<td className="py-4 font-mono">
10.0.4.22
</td>

<td className="py-4 text-gray-500">
Cloud VPC Proxy
</td>

<td className="py-4 text-right">

<span className="material-symbols-outlined text-red-500 cursor-pointer">
delete
</span>

</td>

</tr>

</tbody>

</table>

</div>



{/* session */}

<div className="bg-white p-8 rounded-lg shadow-sm">

<div className="flex items-center gap-2 mb-6">

<span className="material-symbols-outlined text-[#0058be]">
timer
</span>

<h3 className="text-xl font-bold">
Session Management
</h3>

</div>



<label className="text-sm font-semibold text-gray-500">
Idle Timeout
</label>


<select className="w-full mt-2 px-4 py-3 bg-[#eff4ff] rounded-md">

<option>
30m
</option>

<option selected>
1h
</option>

<option>
4h
</option>

</select>


<p className="text-xs text-gray-400 mt-2">
Automatically log out users after periods of inactivity.
</p>

</div>

</div>



{/* RIGHT */}

<div className="space-y-8">

{/* insight */}

<div className="bg-gradient-to-br from-[#8455ef] to-[#6b38d4] p-6 rounded-lg text-white">

<p className="text-xs uppercase font-bold opacity-70 mb-3">
AI Insight
</p>


<h3 className="font-bold mb-2">
Anomaly Detected
</h3>


<p className="text-sm opacity-90">

Recent login attempts from Dublin, IE deviate from your usual admin location.

</p>


<button className="mt-4 w-full bg-white/20 py-2 rounded-md font-bold">
Review Activity
</button>

</div>



{/* health */}

<div className="bg-[#eff4ff] p-6 rounded-lg border-l-4 border-[#0058be]">

<p className="text-xs uppercase font-bold text-gray-400">
Security Health
</p>


<div className="flex justify-between items-center mt-3">

<h3 className="text-4xl font-bold text-[#0058be]">
98%
</h3>


<span className="bg-white px-3 py-1 text-xs font-bold rounded-full text-[#0058be]">

STABLE

</span>

</div>


<p className="text-xs text-gray-500 mt-3">

System integrity verified by ScholarFlow Cloud Shield 2.0

</p>

</div>



<img
src="https://lh3.googleusercontent.com/aida-public/AB6AXuAPLqxB0SjtsOP1bopm6UoQCa27q1aWEACwZ0QqXJfhgYxu3bVJBK7seoOdL-4RlYsjj7CXYHtadxz-nlVuIPHe_fA_2AdpxgzgIVCyrt62O839hmTQsKKg74bvB6qulf2MDY5TpCfWqdKkI7eX3naVDPLEPuKxWKsnB2BEW0EFrTb5U3a-5NyTYnEKQBDwvV6WIr_zGAlx3W4knxugOjf05Wk9j4rrdRgg2SPjPUcW4k0N98663Q4vkJt_NzaySw-aT17AAvogdg"
className="rounded-lg grayscale opacity-60 hover:opacity-100 transition"
/>

</div>

</div>



{/* buttons */}

<div className="flex justify-end gap-4 mt-12">

<button
onClick={()=>navigate("/global-admin/settings")}
className="px-6 py-3 text-gray-500 font-bold hover:bg-[#eff4ff] rounded-md"
>

Cancel

</button>



<button
onClick={()=>navigate("/global-admin/settings")}
className="px-8 py-3 bg-gradient-to-br from-[#0058be] to-[#2170e4] text-white font-bold rounded-md shadow"
>

Update Security Policy

</button>

</div>

</div>

</div>

</Layout>

);

}