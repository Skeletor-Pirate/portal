export default function ActivityTable(){

return(

<div className="bg-white rounded-xl overflow-hidden">

<div className="p-8 pb-4">

<h3 className="text-xl font-bold">
Global Activity Log
</h3>

<p className="text-sm text-gray-500">
Real-time infrastructure movements
</p>

</div>


<div className="px-8 pb-8">

<table className="w-full text-left">

<thead>

<tr className="text-xs uppercase text-gray-400">

<th className="py-4 border-b">
School Name
</th>

<th className="py-4 border-b">
Activity
</th>

<th className="py-4 border-b">
Status
</th>

<th className="py-4 border-b text-right">
Timestamp
</th>

</tr>

</thead>


<tbody className="text-sm">

<tr className="border-b">

<td className="py-5 font-semibold">
Oxford Academy
</td>

<td className="text-gray-500">
New institution onboarded
</td>

<td>

<span className="bg-blue-50 text-blue-700 px-3 py-1 rounded-full text-xs font-bold uppercase">
provisioning
</span>

</td>

<td className="text-right text-gray-400">
2 mins ago
</td>

</tr>


<tr className="border-b">

<td className="py-5 font-semibold">
St. Jude's International
</td>

<td className="text-gray-500">
Enterprise subscription renewed
</td>

<td>

<span className="bg-emerald-50 text-emerald-700 px-3 py-1 rounded-full text-xs font-bold uppercase">
active
</span>

</td>

<td className="text-right text-gray-400">
14 mins ago
</td>

</tr>


<tr className="border-b">

<td className="py-5 font-semibold">
Global Science Hub
</td>

<td className="text-gray-500">
Domain mapping updated
</td>

<td>

<span className="bg-gray-100 text-gray-600 px-3 py-1 rounded-full text-xs font-bold uppercase">
completed
</span>

</td>

<td className="text-right text-gray-400">
42 mins ago
</td>

</tr>


<tr>

<td className="py-5 font-semibold">
Riverside Preparatory
</td>

<td className="text-gray-500">
System-wide data backup
</td>

<td>

<span className="bg-orange-100 text-orange-600 px-3 py-1 rounded-full text-xs font-bold uppercase">
scheduled
</span>

</td>

<td className="text-right text-gray-400">
1 hour ago
</td>

</tr>

</tbody>

</table>

</div>

</div>

)

}