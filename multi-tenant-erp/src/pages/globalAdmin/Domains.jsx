import Layout from "../../components/erp/global/Layout";
import { useNavigate } from "react-router-dom";

export default function Domains(){

const navigate = useNavigate();

return(

<Layout>

<div className="space-y-8">

{/* heading */}

<div className="flex justify-between items-center">

<div>

<p className="text-xs tracking-widest text-[#2563eb] font-semibold mb-2">
ARCHITECTURE
</p>

<h1 className="text-3xl font-extrabold">
Domain Management
</h1>

</div>


<button
onClick={()=>navigate("/global-admin/add-domain")}
className="bg-[#1d5fd0] text-white px-5 py-3 rounded-lg text-sm font-semibold flex items-center gap-2 shadow-md"
>

<span className="material-symbols-outlined text-[18px]">
add
</span>

Add Custom Domain

</button>

</div>



<div className="grid grid-cols-12 gap-8">

{/* LEFT */}

<div className="col-span-8 space-y-6">

{/* table */}

<div className="bg-white rounded-xl shadow-sm overflow-hidden">

<table className="w-full text-left">

<thead>

<tr className="bg-[#f1f4fb] text-sm text-gray-500">

<th className="px-6 py-4">
School Name
</th>

<th className="px-6 py-4">
Custom Domain
</th>

<th className="px-6 py-4">
Status
</th>

<th className="px-6 py-4">
SSL
</th>

<th className="px-6 py-4">
Created
</th>

</tr>

</thead>



<tbody className="text-sm">

{/* row */}

<tr className="border-t">

<td className="px-6 py-5 flex items-center gap-3">

<div className="w-9 h-9 rounded-lg bg-blue-100 text-blue-700 font-semibold flex items-center justify-center">

SV

</div>

St. Victors Academy

</td>


<td className="px-6 py-5">

<span className="bg-blue-50 text-blue-700 px-3 py-1 rounded-md text-xs font-medium">

portal.stvictors.edu

</span>

</td>


<td className="px-6 py-5">

<span className="bg-emerald-50 text-emerald-600 px-3 py-1 rounded-full text-xs font-semibold">

● Verified

</span>

</td>


<td className="px-6 py-5 text-emerald-600 font-semibold">

🔒 ACTIVE

</td>


<td className="px-6 py-5 text-gray-500">

Oct 12, 2023

</td>

</tr>



<tr className="border-t">

<td className="px-6 py-5 flex items-center gap-3">

<div className="w-9 h-9 rounded-lg bg-orange-100 text-orange-700 font-semibold flex items-center justify-center">

OL

</div>

Oakwood Learning

</td>


<td className="px-6 py-5">

<span className="bg-blue-50 text-blue-700 px-3 py-1 rounded-md text-xs font-medium">

learn.oakwood.com

</span>

</td>


<td className="px-6 py-5">

<span className="bg-orange-50 text-orange-600 px-3 py-1 rounded-full text-xs font-semibold">

● Pending

</span>

</td>


<td className="px-6 py-5 text-gray-500 font-semibold">

⏳ PROVISIONING

</td>


<td className="px-6 py-5 text-gray-500">

Nov 04, 2023

</td>

</tr>



<tr className="border-t">

<td className="px-6 py-5 flex items-center gap-3">

<div className="w-9 h-9 rounded-lg bg-purple-100 text-purple-700 font-semibold flex items-center justify-center">

BH

</div>

Beacon Hill High

</td>


<td className="px-6 py-5">

<span className="bg-blue-50 text-blue-700 px-3 py-1 rounded-md text-xs font-medium">

admin.beaconhill.org

</span>

</td>


<td className="px-6 py-5">

<span className="bg-red-50 text-red-600 px-3 py-1 rounded-full text-xs font-semibold">

● Failed

</span>

</td>


<td className="px-6 py-5 text-red-500 font-semibold">

⚠ NONE

</td>


<td className="px-6 py-5 text-gray-500">

Dec 01, 2023

</td>

</tr>



<tr className="border-t">

<td className="px-6 py-5 flex items-center gap-3">

<div className="w-9 h-9 rounded-lg bg-indigo-100 text-indigo-700 font-semibold flex items-center justify-center">

NC

</div>

North Campus Int.

</td>


<td className="px-6 py-5">

<span className="bg-blue-50 text-blue-700 px-3 py-1 rounded-md text-xs font-medium">

sis.northcampus.ac

</span>

</td>


<td className="px-6 py-5">

<span className="bg-emerald-50 text-emerald-600 px-3 py-1 rounded-full text-xs font-semibold">

● Verified

</span>

</td>


<td className="px-6 py-5 text-emerald-600 font-semibold">

🔒 ACTIVE

</td>


<td className="px-6 py-5 text-gray-500">

Dec 15, 2023

</td>

</tr>

</tbody>

</table>

</div>



{/* stats */}

<div className="grid grid-cols-3 gap-6">

<div className="bg-white p-6 rounded-xl">

<p className="text-gray-500 text-sm">
Total Domains
</p>

<h2 className="text-3xl font-bold mt-1">
42
</h2>

</div>


<div className="bg-white p-6 rounded-xl">

<p className="text-gray-500 text-sm">
Health Status
</p>

<h2 className="text-3xl font-bold text-emerald-600 mt-1">
98%
</h2>

</div>


<div className="bg-white p-6 rounded-xl">

<p className="text-gray-500 text-sm">
Pending SSL
</p>

<h2 className="text-3xl font-bold text-orange-500 mt-1">
03
</h2>

</div>

</div>


</div>



{/* RIGHT */}

<div className="col-span-4">

<div className="bg-white p-6 rounded-xl shadow-sm">

<div className="flex items-center gap-3 mb-4">

<div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">

<span className="material-symbols-outlined text-blue-700">

info

</span>

</div>


<h3 className="font-semibold">
DNS Configuration
</h3>

</div>


<p className="text-sm text-gray-500 mb-6">

To link your school's custom domain, please update your DNS provider settings with the records below. Verification usually takes 1-2 hours.

</p>



<p className="text-xs text-blue-600 font-semibold mb-2">

A RECORD (ROOT)

</p>


<div className="bg-gray-50 rounded-lg p-4 text-sm font-mono mb-5">

76.76.21.21

</div>



<p className="text-xs text-blue-600 font-semibold mb-2">

CNAME RECORD (SUBDOMAIN)

</p>


<div className="bg-gray-50 rounded-lg p-4 text-sm font-mono mb-5">

cname.academicarch.com

</div>


<p className="text-blue-600 text-sm font-medium cursor-pointer">

Read full setup guide →

</p>

</div>

</div>


</div>

</div>

</Layout>

)

}