export default function DashboardCards(){

return(

<div className="grid grid-cols-1 md:grid-cols-4 gap-6">

{/* total schools */}

<div className="bg-white p-6 rounded-lg">

<p className="text-sm text-gray-500">
Total Schools
</p>

<div className="flex justify-between items-end">

<h2 className="text-4xl font-extrabold text-blue-700">
128
</h2>

<span className="text-emerald-600 text-sm font-semibold bg-emerald-50 px-2 py-1 rounded-md flex items-center gap-1">

<span className="material-symbols-outlined text-sm">
trending_up
</span>

12%

</span>

</div>

</div>


{/* active users */}

<div className="bg-white p-6 rounded-lg">

<p className="text-sm text-gray-500">
Active Users
</p>

<div className="flex justify-between items-end">

<h2 className="text-4xl font-extrabold">
42k
</h2>

<span className="text-gray-500 text-sm">
Daily
</span>

</div>

</div>


{/* subscriptions */}

<div className="bg-white p-6 rounded-lg">

<p className="text-sm text-gray-500">
Active Subscriptions
</p>

<div className="flex justify-between items-end">

<h2 className="text-4xl font-extrabold">
112
</h2>

<span className="text-blue-600 text-sm">
Elite Plan
</span>

</div>

</div>


{/* revenue */}

<div className="bg-gradient-to-r from-[#0058be] to-[#2170e4] p-6 rounded-lg text-white shadow-lg">

<p className="text-blue-100 text-sm">
Monthly Revenue
</p>

<h2 className="text-4xl font-extrabold">
$854k
</h2>

<p className="text-blue-200 text-xs">
+4.2% from last month
</p>

</div>

</div>

)

}