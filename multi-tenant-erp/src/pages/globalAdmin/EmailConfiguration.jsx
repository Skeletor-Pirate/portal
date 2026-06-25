import Layout from "../../components/erp/global/Layout";
import { useNavigate } from "react-router-dom";

export default function EmailConfiguration(){

const navigate = useNavigate();

return(

<Layout>

<div className="min-h-screen bg-[#f8f9ff]">

<div className="max-w-6xl mx-auto px-8 py-10">

{/* header */}

<div className="flex items-start justify-between mb-10">

<div>

<h1 className="text-4xl font-extrabold text-[#0b1c30] leading-tight">
Email Configuration
</h1>

<p className="text-[#424754] mt-2 max-w-2xl">
Configure your institutional SMTP server to manage automated notifications, password resets, and official school communications.
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


<div className="grid lg:grid-cols-3 gap-8">

{/* form */}

<div className="lg:col-span-2 space-y-6">

<div className="bg-white p-8 rounded-lg shadow-sm border border-gray-100">

<h3 className="text-xl font-bold mb-6 flex items-center gap-2">

<span className="material-symbols-outlined text-[#0058be]">
mail
</span>

SMTP Server Settings

</h3>



<div className="grid md:grid-cols-2 gap-6">

{/* host */}

<div>

<label className="text-xs font-bold text-gray-500 uppercase">

SMTP Host

</label>

<input
defaultValue="smtp.postmarkapp.com"
className="w-full mt-2 px-4 py-3 rounded-md bg-[#eff4ff]"
/>

</div>



{/* port */}

<div>

<label className="text-xs font-bold text-gray-500 uppercase">

Port

</label>

<input
defaultValue="587"
className="w-full mt-2 px-4 py-3 rounded-md bg-[#eff4ff]"
/>

</div>



{/* email */}

<div>

<label className="text-xs font-bold text-gray-500 uppercase">

Sender Email

</label>

<input
defaultValue="notifications@scholarflow.pro"
className="w-full mt-2 px-4 py-3 rounded-md bg-[#eff4ff]"
/>

</div>



{/* name */}

<div>

<label className="text-xs font-bold text-gray-500 uppercase">

Sender Name

</label>

<input
defaultValue="ScholarFlow Pro Platform"
className="w-full mt-2 px-4 py-3 rounded-md bg-[#eff4ff]"
/>

</div>



{/* password */}

<div className="md:col-span-2">

<label className="text-xs font-bold text-gray-500 uppercase">

Password / API Key

</label>

<input
type="password"
defaultValue="••••••••••••••••"
className="w-full mt-2 px-4 py-3 rounded-md bg-[#eff4ff]"
/>

</div>

</div>

</div>



{/* buttons */}

<div className="flex justify-end gap-4">

<button className="px-6 py-3 text-[#0058be] font-bold hover:bg-[#eff4ff] rounded-md">

Send Test Email

</button>



<button
onClick={()=>navigate("/global-admin/settings")}
className="px-8 py-3 bg-gradient-to-br from-[#0058be] to-[#2170e4] text-white font-bold rounded-md shadow"
>

Save SMTP Settings

</button>

</div>

</div>



{/* right column */}

<div className="space-y-6">

{/* status */}

<div className="bg-white p-6 rounded-lg border">

<div className="flex justify-between mb-4">

<p className="text-xs font-bold text-gray-500 uppercase">
Status
</p>


<div className="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>

</div>



<div className="text-center py-4">

<div className="w-16 h-16 bg-green-50 rounded-full flex items-center justify-center mx-auto mb-4">

<span className="material-symbols-outlined text-green-600 text-3xl">
cloud_done
</span>

</div>


<h4 className="font-bold text-lg">

Email Service: Connected

</h4>


<p className="text-sm text-gray-500">
Last sync: 2 minutes ago
</p>

</div>


<p className="text-xs text-gray-500 italic mt-3">

Postmark infrastructure is responding normally with 14ms latency.

</p>

</div>



{/* insight */}

<div className="bg-[#eff4ff] p-6 rounded-lg border">

<h4 className="font-bold text-[#0058be] flex items-center gap-2 mb-3">

<span className="material-symbols-outlined text-sm">
lightbulb
</span>

Intelligent Insight

</h4>


<p className="text-sm text-[#0b1c30]">

Using <b>TLS on Port 587</b> is recommended for academic security compliance.

Ensure your firewall allows outbound traffic to the Postmark IP range.

</p>

</div>



{/* card */}

<div className="bg-gradient-to-br from-[#0058be] to-[#6b38d4] p-6 rounded-lg text-white">

<p className="text-xs uppercase opacity-80">
Security Protocol
</p>


<div className="flex justify-between items-end mt-4">

<p className="text-xl font-bold">
Enterprise Grade Encryption
</p>


<span className="material-symbols-outlined text-4xl opacity-60">
verified_user
</span>

</div>

</div>

</div>

</div>

</div>

</div>

</Layout>

);

}