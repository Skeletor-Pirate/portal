import Layout from "../../components/erp/global/Layout";
import { useNavigate } from "react-router-dom";

export default function PaymentInfrastructure() {

const navigate = useNavigate();

return (

<Layout>

<div className="min-h-screen bg-[#f8f9ff]">

<div className="max-w-6xl mx-auto px-8 py-10">

{/* header */}

<div className="flex items-start justify-between mb-10">

<div>

<h1 className="text-4xl font-extrabold text-[#0b1c30] leading-tight">
Payment Infrastructure
</h1>

<p className="text-[#424754] mt-2 max-w-2xl">
Manage global payment gateways, webhooks, and transactional behavior for ScholarFlow Pro.
</p>

</div>


<button
onClick={()=>navigate("/global-admin/settings")}
className="flex items-center gap-2 px-4 py-2 rounded-md bg-[#dce9ff] text-[#0058be] font-semibold text-sm hover:bg-[#d3e4fe] transition-all active:scale-[0.98]"
>

<span className="material-symbols-outlined text-sm">
arrow_back
</span>

Go Back

</button>

</div>


{/* GRID */}

<div className="grid md:grid-cols-12 gap-6">

{/* LEFT COLUMN */}

<div className="md:col-span-8 space-y-6">

{/* Connected Gateways */}

<div className="bg-white rounded-lg p-6 shadow-[0_12px_32px_rgba(11,28,48,0.06)]">

<h3 className="text-lg font-bold mb-6 flex items-center gap-2">

<span className="material-symbols-outlined text-[#0058be]">
hub
</span>

Connected Gateways

</h3>


{/* Stripe */}

<div className="flex justify-between items-center p-4 bg-[#eff4ff] rounded-md mb-4">

<div className="flex items-center gap-4">

<div className="w-12 h-12 bg-white rounded-md flex items-center justify-center">

<span className="material-symbols-outlined text-indigo-600 text-3xl">
payments
</span>

</div>

<div>

<p className="font-bold">
Stripe
</p>

<div className="flex items-center gap-1">

<div className="w-2 h-2 bg-green-500 rounded-full"></div>

<span className="text-xs font-semibold text-green-600">
CONNECTED
</span>

</div>

</div>

</div>

<button className="text-[#0058be] font-semibold text-sm hover:underline">
Manage Settings
</button>

</div>


{/* Razorpay */}

<div className="flex justify-between items-center p-4 bg-[#eff4ff] rounded-md">

<div className="flex items-center gap-4">

<div className="w-12 h-12 bg-white rounded-md flex items-center justify-center">

<span className="material-symbols-outlined text-blue-500 text-3xl">
account_balance_wallet
</span>

</div>

<div>

<p className="font-bold">
Razorpay
</p>

<p className="text-xs text-[#424754]">
Not configured
</p>

</div>

</div>

<button className="px-5 py-2 bg-gradient-to-br from-[#0058be] to-[#2170e4] text-white rounded-md text-sm font-semibold hover:opacity-90">
Connect
</button>

</div>

</div>



{/* Transaction Summary */}

<div className="bg-white rounded-lg p-6 shadow-[0_12px_32px_rgba(11,28,48,0.06)]">

<div className="flex justify-between mb-6">

<h3 className="font-bold text-lg">
Transaction Summary
</h3>

<button className="text-[#0058be] font-semibold text-sm">
View Ledger
</button>

</div>


<table className="w-full text-sm">

<thead className="text-xs text-gray-500 uppercase">

<tr>

<th className="pb-4">Transaction ID</th>

<th className="pb-4">Institution</th>

<th className="pb-4">Amount</th>

<th className="pb-4 text-right">Status</th>

</tr>

</thead>


<tbody className="divide-y">

<tr>

<td className="py-4 font-mono text-xs">#TXN-90210-A</td>

<td className="py-4 font-semibold">Greenwood Academy</td>

<td className="py-4">$4,200.00</td>

<td className="py-4 text-right">

<span className="px-2 py-1 bg-green-100 text-green-700 text-[10px] font-bold rounded">
SUCCESS
</span>

</td>

</tr>


<tr>

<td className="py-4 font-mono text-xs">#TXN-88432-B</td>

<td className="py-4 font-semibold">St. Mary's High</td>

<td className="py-4">$1,150.00</td>

<td className="py-4 text-right">

<span className="px-2 py-1 bg-green-100 text-green-700 text-[10px] font-bold rounded">
SUCCESS
</span>

</td>

</tr>


<tr>

<td className="py-4 font-mono text-xs">#TXN-77219-C</td>

<td className="py-4 font-semibold">Riverside College</td>

<td className="py-4">$980.00</td>

<td className="py-4 text-right">

<span className="px-2 py-1 bg-amber-100 text-amber-700 text-[10px] font-bold rounded">
PENDING
</span>

</td>

</tr>

</tbody>

</table>

</div>

</div>



{/* RIGHT COLUMN */}

<div className="md:col-span-4 space-y-6">

{/* Global Config */}

<div className="bg-white rounded-lg p-6 shadow-[0_12px_32px_rgba(11,28,48,0.06)]">

<h3 className="text-lg font-bold mb-6 flex items-center gap-2">

<span className="material-symbols-outlined text-[#6b38d4]">
settings_input_component
</span>

Global Config

</h3>


<label className="text-xs font-bold uppercase text-gray-500">
Webhook URL
</label>


<div className="flex gap-2 mt-2 mb-3">

<input
readOnly
value="https://api.scholarflow.pro/webhooks/v1/payments"
className="flex-1 bg-[#eff4ff] rounded-md px-3 py-2 text-sm font-mono"
/>

<button className="p-2 bg-[#dce9ff] rounded-md text-[#0058be]">

<span className="material-symbols-outlined text-sm">
content_copy
</span>

</button>

</div>


<p className="text-[10px] text-gray-500 mb-4">
System-generated endpoint for receiving real-time gateway events.
</p>


<label className="text-xs font-bold uppercase text-gray-500">
Currency
</label>


<select className="w-full bg-[#eff4ff] rounded-md px-3 py-2 mt-2 font-semibold">

<option>USD - United States Dollar</option>
<option>EUR - Euro</option>
<option>GBP - British Pound</option>
<option>INR - Indian Rupee</option>

</select>


<div className="pt-5 space-y-3">

<button
onClick={()=>navigate("/global-admin/settings")}
className="w-full py-3 bg-gradient-to-br from-[#0058be] to-[#2170e4] text-white font-bold rounded-md shadow"
>
Save Configuration
</button>


<button className="w-full py-3 bg-[#dce9ff] text-[#0058be] font-bold rounded-md flex items-center justify-center gap-2">

<span className="material-symbols-outlined text-sm">
vibration
</span>

Test Webhook

</button>

</div>

</div>



{/* Insight Card */}

<div className="relative rounded-lg overflow-hidden">

<img
src="https://lh3.googleusercontent.com/aida-public/AB6AXuDSOy9nrnjgcgZz6sAo1-zUbYfJ27HZglKN89tQ4AjackGyE21qq_d-CFZxwDNtiWgRGOzxzCR8z6gVwBklJ6xktWkFPAeM7yxxGqEY30kv1OAepIQlzOiDeoC03cxlAZ7zTbL7WjLMX8fOeXbGtiIEH5QdVEvsc9tbb7pVzRUssGMkPo-SnxxMiMmaueYOIpYtwudSLjIc0VtQTuc0LoJn6HaqqJHBW3uLOK6qKiU-T1HhFWzMfQvwtUUM0or7gZE-5Yn4Huw8aw"
className="w-full h-48 object-cover"
/>


<div className="absolute inset-0 bg-gradient-to-t from-black/70 to-transparent flex flex-col justify-end p-4 text-white">

<p className="font-bold">
Intelligent Insight
</p>

<p className="text-xs opacity-90">
Auto-reconciliation is active.
</p>

</div>

</div>

</div>



</div>

</div>

</div>

</Layout>

);

}