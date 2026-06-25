import Layout from "../../components/erp/global/Layout";
import { useNavigate } from "react-router-dom";
export default function Schools(){
const navigate = useNavigate();
return(

<Layout>

<div className="space-y-8">

{/* page header */}

<div className="flex flex-col md:flex-row justify-between md:items-end gap-6">

<div className="max-w-2xl">

<h1 className="text-4xl font-extrabold tracking-tight">
School Network
</h1>

<p className="text-gray-500 mt-2">
Manage institutional registrations, monitor subscription health,
and oversee administrative access across the global network.
</p>

</div>



<div className="flex gap-4">

<button className="px-6 py-3 bg-[#e5eeff] text-[#0058be] font-semibold rounded-md flex items-center gap-2">

<span className="material-symbols-outlined">
ios_share
</span>

Export List

</button>



<button
onClick={()=>navigate("/global-admin/add-school")}
className="px-6 py-3 bg-gradient-to-r from-[#0058be] to-[#2170e4] text-white font-semibold rounded-md shadow-lg flex items-center gap-2"
>
<span className="material-symbols-outlined">
add_business
</span>

Add School
</button>

</div>

</div>



{/* stats */}

<div className="grid md:grid-cols-3 gap-6">

<div className="bg-white p-6 rounded-lg relative">

<p className="text-sm text-gray-500">
Total Institutions
</p>

<p className="text-3xl font-bold">
1,284
</p>

<span className="absolute top-4 right-4 text-xs font-bold text-[#0058be] bg-white px-3 py-1 rounded-full border">

+12% vs last month

</span>

</div>



<div className="bg-white p-6 rounded-lg">

<p className="text-sm text-gray-500">
Enterprise Partners
</p>

<p className="text-3xl font-bold">
42
</p>

<div className="mt-2 h-1 bg-gray-200 rounded-full overflow-hidden">

<div className="h-full bg-gradient-to-r from-[#0058be] to-[#2170e4] w-3/4"></div>

</div>

</div>



<div className="bg-white p-6 rounded-lg">

<p className="text-sm text-gray-500">
Active Subscriptions
</p>

<p className="text-3xl font-bold">
98.2%
</p>

<p className="text-xs text-orange-600 mt-1">
4 accounts require attention
</p>

</div>

</div>



{/* filters */}

<div className="bg-[#eff4ff] p-4 rounded-xl flex flex-wrap gap-4 items-center">

<div className="relative flex-grow max-w-md">

<span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">

search

</span>

<input
placeholder="Search school name or admin..."
className="w-full pl-10 pr-4 py-2 bg-white rounded-md text-sm outline-none"
/>

</div>



<select className="bg-white px-4 py-2 rounded-md text-sm">

<option>All Subscription Plans</option>
<option>Enterprise</option>
<option>Premium</option>
<option>Basic</option>

</select>



<select className="bg-white px-4 py-2 rounded-md text-sm">

<option>All Statuses</option>
<option>Active</option>
<option>Inactive</option>

</select>



<button className="text-[#0058be] font-semibold text-sm">

Clear Filters

</button>

</div>



{/* table */}

<div className="bg-white rounded-lg overflow-hidden">

<table className="w-full text-left">

<thead>

<tr className="bg-[#f5f7ff] text-xs uppercase text-gray-400">

<th className="px-6 py-4">
School Details
</th>

<th className="px-6 py-4">
Admin Contact
</th>

<th className="px-6 py-4">
Plan
</th>

<th className="px-6 py-4">
Status
</th>

<th className="px-6 py-4">
Joined Date
</th>

<th className="px-6 py-4 text-right">
Actions
</th>

</tr>

</thead>



<tbody>


{/* Oxford */}

<tr className="hover:bg-blue-50/30">

<td className="px-6 py-5">

<div className="flex items-center gap-4">

<div className="w-12 h-12 bg-blue-100 rounded-md"></div>

<div>

<p className="font-bold">
Oxford International
</p>

<p className="text-xs text-gray-500">
Higher Ed • London, UK
</p>

</div>

</div>

</td>


<td className="px-6 py-5">

<p className="text-sm">
Dr. Julian Thorne
</p>

<p className="text-xs text-gray-500">
j.thorne@oxford-intl.edu
</p>

</td>


<td className="px-6 py-5">

<span className="px-3 py-1 text-xs font-bold bg-purple-100 text-purple-700 rounded-full">

Enterprise

</span>

</td>


<td className="px-6 py-5">

<div className="flex items-center gap-2">

<div className="w-2 h-2 bg-green-500 rounded-full"></div>

<p className="text-sm text-green-700">
Active
</p>

</div>

</td>


<td className="px-6 py-5 text-sm text-gray-500">
Oct 12, 2021
</td>


<td className="px-6 py-5 text-right">

<button className="p-2 hover:bg-gray-100 rounded-full">

<span className="material-symbols-outlined">
more_vert
</span>

</button>

</td>

</tr>



{/* St Mary */}

<tr className="hover:bg-blue-50/30">

<td className="px-6 py-5">

<div className="flex items-center gap-4">

<div className="w-12 h-12 bg-purple-100 rounded-md"></div>

<div>

<p className="font-bold">
St. Mary's Academy
</p>

<p className="text-xs text-gray-500">
Secondary • Dublin, IE
</p>

</div>

</div>

</td>


<td className="px-6 py-5">

<p className="text-sm">
Elena Rodriguez
</p>

<p className="text-xs text-gray-500">
e.rodriguez@stmarys.ie
</p>

</td>


<td className="px-6 py-5">

<span className="px-3 py-1 text-xs font-bold bg-blue-100 text-blue-700 rounded-full">

Premium

</span>

</td>


<td className="px-6 py-5">

<div className="flex items-center gap-2">

<div className="w-2 h-2 bg-green-500 rounded-full"></div>

<p className="text-sm text-green-700">
Active
</p>

</div>

</td>


<td className="px-6 py-5 text-sm text-gray-500">
Jan 05, 2022
</td>


<td className="px-6 py-5 text-right">

<button className="p-2 hover:bg-gray-100 rounded-full">

<span className="material-symbols-outlined">
more_vert
</span>

</button>

</td>

</tr>



{/* Lighthouse */}

<tr className="hover:bg-blue-50/30">

<td className="px-6 py-5">

<div className="flex items-center gap-4">

<div className="w-12 h-12 bg-orange-100 rounded-md"></div>

<div>

<p className="font-bold">
Lighthouse Elementary
</p>

<p className="text-xs text-gray-500">
Primary • Portland, US
</p>

</div>

</div>

</td>


<td className="px-6 py-5">

<p className="text-sm">
Samuel Whitaker
</p>

<p className="text-xs text-gray-500">
s.whitaker@lighthouse.edu
</p>

</td>


<td className="px-6 py-5">

<span className="px-3 py-1 text-xs font-bold bg-gray-100 text-gray-600 rounded-full">

Basic

</span>

</td>


<td className="px-6 py-5">

<div className="flex items-center gap-2">

<div className="w-2 h-2 bg-gray-300 rounded-full"></div>

<p className="text-sm text-gray-500">
Inactive
</p>

</div>

</td>


<td className="px-6 py-5 text-sm text-gray-500">
Mar 19, 2023
</td>


<td className="px-6 py-5 text-right">

<button className="p-2 hover:bg-gray-100 rounded-full">

<span className="material-symbols-outlined">
more_vert
</span>

</button>

</td>

</tr>


</tbody>

</table>



{/* pagination */}

<div className="px-6 py-4 border-t flex justify-between items-center">

<p className="text-sm text-gray-500">

Showing 1-4 of 1,284 institutions

</p>


<div className="flex gap-2">

<button className="text-gray-400 text-sm">

Previous

</button>


<button className="px-3 py-1 bg-blue-50 text-blue-600 rounded text-sm">
1
</button>


<button className="px-3 py-1 text-gray-500 text-sm">
2
</button>


<button className="px-3 py-1 text-gray-500 text-sm">
3
</button>


<button className="text-blue-600 text-sm">

Next

</button>

</div>

</div>



</div>

</div>

</Layout>

)

}