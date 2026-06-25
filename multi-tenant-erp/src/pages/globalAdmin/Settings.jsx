import Layout from "../../components/erp/global/Layout";
import { useNavigate } from "react-router-dom";

export default function Settings(){

const navigate = useNavigate();

return(

<Layout>

<div className="space-y-20">

{/* HEADER */}

<div className="flex justify-between items-center">

<div>

<h1 className="text-4xl font-extrabold text-[#0b1c30]">
Platform Settings
</h1>

<p className="text-[#424754] text-lg mt-2 max-w-2xl">
Manage global configurations for the entire multi-tenant ecosystem.
Changes here affect all institutional instances.
</p>

</div>


<button
onClick={()=>navigate("/global-admin")}
className="flex items-center gap-2 px-4 py-2 rounded-md bg-[#dce9ff] text-[#0058be] font-semibold text-sm hover:bg-[#d3e4fe] transition"
>

<span className="material-symbols-outlined text-sm">
arrow_back
</span>

Go Back to Dashboard

</button>

</div>



{/* SETTINGS GRID */}

<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">

{/* AI */}

<div className="group relative overflow-hidden bg-white rounded-xl p-8 shadow-[0_12px_32px_rgba(11,28,48,0.04)] hover:bg-[#eff4ff] transition">

<div>

<div className="w-12 h-12 rounded-xl bg-[#e9ddff] flex items-center justify-center mb-6 group-hover:scale-110 transition">

<span className="material-symbols-outlined text-[#6b38d4] text-2xl">
neurology
</span>

</div>


<h3 className="text-xl font-bold mb-3">
AI Settings
</h3>


<p className="text-[#424754] text-sm mb-6">
Configure AI models, token limits, and intelligence parameters.
</p>

</div>


<button
onClick={()=>navigate("/global-admin/ai-config")}
className="flex items-center gap-2 text-[#0058be] font-bold text-sm"
>

Manage Settings

<span className="material-symbols-outlined text-sm">
arrow_forward
</span>

</button>

</div>



{/* PAYMENT */}

<div className="group relative overflow-hidden bg-white rounded-xl p-8 shadow-[0_12px_32px_rgba(11,28,48,0.04)] hover:bg-[#eff4ff] transition">

<div>

<div className="w-12 h-12 rounded-xl bg-[#d8e2ff] flex items-center justify-center mb-6 group-hover:scale-110 transition">

<span className="material-symbols-outlined text-[#0058be] text-2xl">
account_balance_wallet
</span>

</div>


<h3 className="text-xl font-bold mb-3">
Payment Infrastructure
</h3>


<p className="text-[#424754] text-sm mb-6">
Connect Stripe or Razorpay and manage global billing workflows.
</p>

</div>


<button
onClick={()=>navigate("/global-admin/payment")}
className="flex items-center gap-2 text-[#0058be] font-bold text-sm"
>

Manage Infrastructure

<span className="material-symbols-outlined text-sm">
arrow_forward
</span>

</button>

</div>



{/* EMAIL */}

<div className="group relative overflow-hidden bg-white rounded-xl p-8 shadow-[0_12px_32px_rgba(11,28,48,0.04)] hover:bg-[#eff4ff] transition">

<div>

<div className="w-12 h-12 rounded-xl bg-[#ffdcc6] flex items-center justify-center mb-6 group-hover:scale-110 transition">

<span className="material-symbols-outlined text-[#924700] text-2xl">
mail
</span>

</div>


<h3 className="text-xl font-bold mb-3">
Email Configuration
</h3>


<p className="text-[#424754] text-sm mb-6">
Set up SMTP and transactional email templates.
</p>

</div>


<button
onClick={()=>navigate("/global-admin/email")}
className="flex items-center gap-2 text-[#0058be] font-bold text-sm"
>

Set up SMTP

<span className="material-symbols-outlined text-sm">
arrow_forward
</span>

</button>

</div>



{/* SECURITY */}

<div className="group relative overflow-hidden bg-white rounded-xl p-8 shadow-[0_12px_32px_rgba(11,28,48,0.04)] hover:bg-[#eff4ff] transition">

<div>

<div className="w-12 h-12 rounded-xl bg-[#ffdad6] flex items-center justify-center mb-6 group-hover:scale-110 transition">

<span className="material-symbols-outlined text-[#ba1a1a] text-2xl">
admin_panel_settings
</span>

</div>


<h3 className="text-xl font-bold mb-3">
Security & Access
</h3>


<p className="text-[#424754] text-sm mb-6">
Configure 2FA, IP whitelisting and encryption rules.
</p>

</div>


<button
onClick={()=>navigate("/global-admin/security")}
className="flex items-center gap-2 text-[#0058be] font-bold text-sm"
>

Review Security

<span className="material-symbols-outlined text-sm">
arrow_forward
</span>

</button>

</div>

</div>



{/* PRO TIP */}

<div className="grid lg:grid-cols-3 gap-8">

<div className="lg:col-span-2">

<div className="bg-gradient-to-br from-[#0058be] to-[#2170e4] rounded-2xl p-10 text-white relative overflow-hidden">

<span className="bg-white/20 px-3 py-1 rounded-full text-xs font-bold uppercase mb-4 inline-block">

Pro Tip

</span>


<h2 className="text-3xl font-bold mb-4">

Multi-Tenant Global Sync

</h2>


<p className="text-white/80 text-lg mb-8 max-w-xl">

Push branding and security updates to all school domains simultaneously.

</p>


<button className="bg-white text-[#0058be] px-6 py-3 rounded-lg font-bold">

Learn More

</button>

</div>

</div>



{/* system health */}

<div className="bg-[#e5eeff] rounded-2xl p-8">

<h3 className="text-xl font-bold mb-6">

System Health

</h3>


<div className="space-y-6 text-sm">

<div className="flex justify-between">

Core API

<span className="text-green-600 font-bold">
Operational
</span>

</div>


<div className="flex justify-between">

AI Cluster

<span className="text-green-600 font-bold">
Operational
</span>

</div>


<div className="flex justify-between">

Stripe Webhooks

<span className="text-green-600 font-bold">
Operational
</span>

</div>


<div className="pt-4 border-t text-xs text-gray-500">

Last Backup 14 mins ago

</div>

</div>

</div>

</div>



{/* activity */}

<section>

<div className="flex justify-between mb-6">

<div>

<h2 className="text-2xl font-bold">
Recent Configuration Changes
</h2>

<p className="text-gray-500">
Track administrative changes
</p>

</div>


<button className="text-[#0058be] font-bold">

View Audit Logs

</button>

</div>



<div className="bg-white rounded-2xl overflow-hidden shadow-sm">

<table className="w-full">

<thead className="bg-[#eff4ff] text-xs uppercase text-gray-500">

<tr>

<th className="px-6 py-4">
Admin
</th>

<th className="px-6 py-4">
Action
</th>

<th className="px-6 py-4">
Entity
</th>

<th className="px-6 py-4 text-right">
Time
</th>

</tr>

</thead>



<tbody className="text-sm">

<tr className="border-t">

<td className="px-6 py-4 font-semibold">
James Draven
</td>

<td>
Updated Stripe API key
</td>

<td>
Payment Gateway
</td>

<td className="text-right text-gray-400">
2h ago
</td>

</tr>



<tr className="border-t">

<td className="px-6 py-4 font-semibold">
Sarah Alon
</td>

<td>
IP Whitelisted
</td>

<td>
Security
</td>

<td className="text-right text-gray-400">
5h ago
</td>

</tr>



<tr className="border-t">

<td className="px-6 py-4 font-semibold">
Robert King
</td>

<td>
Modified AI prompt
</td>

<td>
Intelligence
</td>

<td className="text-right text-gray-400">
Yesterday
</td>

</tr>

</tbody>

</table>

</div>

</section>



</div>

</Layout>

)

}