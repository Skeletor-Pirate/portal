import Layout from "../../components/erp/global/Layout";
import { useNavigate } from "react-router-dom";
import { useState } from "react";
export default function CreatePlan(){
const [saving,setSaving] = useState(false);
const navigate = useNavigate();

return(

<Layout>

<div className="max-w-6xl mx-auto space-y-8">

{/* header */}

<div className="flex justify-between items-center">

<div>

<h1 className="text-xl font-bold text-[#0b1c30]">

New Subscription Plan

</h1>

<p className="text-sm text-gray-500">

Configure pricing, features and limits

</p>

</div>

<button
onClick={()=>navigate("/global-admin/subscriptions")}
className="text-sm text-gray-500 hover:text-blue-600 flex items-center gap-1"
>

<span className="material-symbols-outlined text-[18px]">
arrow_back
</span>

Back

</button>

</div>



<div className="grid lg:grid-cols-12 gap-8">

{/* LEFT SIDE */}

<div className="lg:col-span-8 space-y-8">


{/* plan configuration */}

<div className="bg-white rounded-lg p-8 shadow-sm">

<div className="flex items-center gap-3 mb-8">

<span className="material-symbols-outlined text-blue-600">

edit_note

</span>

<h2 className="text-xl font-bold">

Plan Configuration

</h2>

</div>



<div className="grid md:grid-cols-2 gap-6">


{/* name */}

<div>

<label className="text-sm font-semibold text-gray-500">

Plan Name

</label>

<input
placeholder="e.g. Enterprise Elite"
className="w-full mt-2 bg-[#f3f6ff] px-4 py-3 rounded-md outline-none"
/>

</div>



{/* price */}

<div>

<label className="text-sm font-semibold text-gray-500">

Base Price (USD)

</label>

<div className="relative mt-2">

<span className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400">

$

</span>

<input
placeholder="999"
type="number"
className="w-full bg-[#f3f6ff] pl-8 pr-4 py-3 rounded-md outline-none"
/>

</div>

</div>



{/* billing */}

<div>

<label className="text-sm font-semibold text-gray-500">

Billing Cycle

</label>

<select className="w-full mt-2 bg-[#f3f6ff] px-4 py-3 rounded-md outline-none">

<option>Monthly</option>

<option>Yearly</option>

<option>Quarterly</option>

</select>

</div>



{/* users */}

<div>

<label className="text-sm font-semibold text-gray-500">

Max Users

</label>

<input
placeholder="500"
type="number"
className="w-full mt-2 bg-[#f3f6ff] px-4 py-3 rounded-md outline-none"
/>

</div>



{/* ai */}

<div>

<label className="text-sm font-semibold text-gray-500">

AI Credits / Month

</label>

<input
placeholder="10000"
type="number"
className="w-full mt-2 bg-[#f3f6ff] px-4 py-3 rounded-md outline-none"
/>

</div>



{/* storage */}

<div>

<label className="text-sm font-semibold text-gray-500">

Storage Limit (GB)

</label>

<input
placeholder="50"
type="number"
className="w-full mt-2 bg-[#f3f6ff] px-4 py-3 rounded-md outline-none"
/>

</div>

</div>

</div>



{/* features */}

<div className="space-y-6">

<div className="flex items-center gap-3">

<span className="material-symbols-outlined text-blue-600">

apps

</span>

<h2 className="text-xl font-bold">

Modules & Features

</h2>

</div>



<div className="grid md:grid-cols-3 gap-4">


{/* feature */}

<label className="cursor-pointer">

<input type="checkbox" defaultChecked className="hidden peer"/>

<div className="p-5 bg-[#f3f6ff] rounded-lg border-2 border-transparent peer-checked:border-blue-600 peer-checked:bg-white transition">

<div className="flex justify-between">

<span className="material-symbols-outlined text-blue-600">

calendar_today

</span>

<span className="material-symbols-outlined text-blue-600 opacity-0 peer-checked:opacity-100">

check_circle

</span>

</div>

<h4 className="font-bold mt-3">

Attendance Module

</h4>

<p className="text-xs text-gray-500">

Automated tracking and parent alerts

</p>

</div>

</label>



<label className="cursor-pointer">

<input type="checkbox" className="hidden peer"/>

<div className="p-5 bg-[#f3f6ff] rounded-lg border-2 border-transparent peer-checked:border-blue-600 peer-checked:bg-white">

<div className="flex justify-between">

<span className="material-symbols-outlined text-blue-600">

quiz

</span>

<span className="material-symbols-outlined text-blue-600 opacity-0 peer-checked:opacity-100">

check_circle

</span>

</div>

<h4 className="font-bold mt-3">

Exam Module

</h4>

<p className="text-xs text-gray-500">

Digital assessments

</p>

</div>

</label>



<label className="cursor-pointer">

<input type="checkbox" className="hidden peer"/>

<div className="p-5 bg-[#f3f6ff] rounded-lg border-2 border-transparent peer-checked:border-blue-600 peer-checked:bg-white">

<div className="flex justify-between">

<span className="material-symbols-outlined text-blue-600">

payments

</span>

<span className="material-symbols-outlined text-blue-600 opacity-0 peer-checked:opacity-100">

check_circle

</span>

</div>

<h4 className="font-bold mt-3">

Finance Module

</h4>

<p className="text-xs text-gray-500">

Payments & reports

</p>

</div>

</label>



<label className="cursor-pointer">

<input type="checkbox" defaultChecked className="hidden peer"/>

<div className="p-5 bg-[#f3f6ff] rounded-lg border-2 border-transparent peer-checked:border-purple-600 peer-checked:bg-white">

<div className="flex justify-between">

<span className="material-symbols-outlined text-purple-600">

smart_toy

</span>

<span className="material-symbols-outlined text-purple-600 opacity-0 peer-checked:opacity-100">

check_circle

</span>

</div>

<h4 className="font-bold mt-3">

AI Assistant

</h4>

<p className="text-xs text-gray-500">

AI powered help

</p>

</div>

</label>



<label className="cursor-pointer">

<input type="checkbox" defaultChecked className="hidden peer"/>

<div className="p-5 bg-[#f3f6ff] rounded-lg border-2 border-transparent peer-checked:border-blue-600 peer-checked:bg-white">

<div className="flex justify-between">

<span className="material-symbols-outlined text-blue-600">

insights

</span>

<span className="material-symbols-outlined text-blue-600 opacity-0 peer-checked:opacity-100">

check_circle

</span>

</div>

<h4 className="font-bold mt-3">

Analytics Dashboard

</h4>

<p className="text-xs text-gray-500">

Reports & charts

</p>

</div>

</label>



<label className="cursor-pointer">

<input type="checkbox" defaultChecked className="hidden peer"/>

<div className="p-5 bg-[#f3f6ff] rounded-lg border-2 border-transparent peer-checked:border-orange-600 peer-checked:bg-white">

<div className="flex justify-between">

<span className="material-symbols-outlined text-orange-600">

psychology

</span>

<span className="material-symbols-outlined text-orange-600 opacity-0 peer-checked:opacity-100">

check_circle

</span>

</div>

<h4 className="font-bold mt-3">

Recommendation Engine

</h4>

<p className="text-xs text-gray-500">

AI learning insights

</p>

</div>

</label>

</div>

</div>

</div>



{/* RIGHT SIDE */}

<div className="lg:col-span-4">

<div className="sticky top-24 space-y-6">


{/* summary */}

<div className="bg-white rounded-lg p-8 shadow-sm relative overflow-hidden">

<div className="absolute -top-10 -right-10 w-32 h-32 bg-blue-100 rounded-full blur-3xl"></div>

<h3 className="font-bold mb-6">

Plan Summary

</h3>



<div className="space-y-6 relative">

<div className="flex items-baseline gap-2">

<h2 className="text-4xl font-extrabold text-blue-600">

$999

</h2>

<span className="text-gray-500">

/mo

</span>

</div>



<div className="pt-6 space-y-3 border-t">

<div className="flex justify-between text-sm">

<span className="text-gray-500">

Features

</span>

<span className="font-bold text-blue-600">

4 selected

</span>

</div>



<div className="flex justify-between text-sm">

<span className="text-gray-500">

Users

</span>

<span className="font-bold">

500

</span>

</div>



<div className="flex justify-between text-sm">

<span className="text-gray-500">

AI credits

</span>

<span className="font-bold">

10k

</span>

</div>

</div>



<button

onClick={()=>{

setSaving(true);

setTimeout(()=>{

navigate("/global-admin/subscriptions");

},1200);

}}

className="w-full bg-gradient-to-r from-[#0058be] to-[#2170e4] text-white font-bold py-4 rounded-md shadow-lg hover:scale-[1.02] transition"

>

{saving ? "Creating..." : "Create Plan"}

</button>

</div>

</div>



{/* tip */}

<div className="bg-[#eef2ff] p-6 rounded-lg">

<div className="flex gap-3">

<div className="bg-orange-100 p-2 rounded-md">

<span className="material-symbols-outlined text-orange-600">

lightbulb

</span>

</div>

<div>

<h4 className="text-sm font-bold">

Pro Tip

</h4>

<p className="text-xs text-gray-500">

Yearly plans increase retention by 35%

</p>

</div>

</div>

</div>

</div>

</div>

</div>

</div>

</Layout>

)

}