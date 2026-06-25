import Layout from "../../components/erp/global/Layout";
import { useNavigate } from "react-router-dom";
import {useState} from "react";
export default function AddDomain(){

const navigate = useNavigate();
const [verified,setVerified] = useState(false);
const [checking,setChecking] = useState(false);

const handleVerify = ()=>{

setChecking(true);

setTimeout(()=>{

setChecking(false);
setVerified(true);

},1500);

};

return(

<Layout>

<div className="space-y-10">

{/* heading */}

<div>

<div className="flex items-center gap-2 text-sm text-gray-500 mb-2">

<span>Infrastructure</span>

<span className="material-symbols-outlined text-[14px]">
chevron_right
</span>

<span className="text-[#0058be] font-semibold">
Custom Domains
</span>

</div>


<h1 className="text-3xl font-extrabold">
Connect your institution
</h1>


<p className="text-gray-500 mt-2 max-w-2xl">

Configure white-labeled domains for your multi-tenant ERP instance.

</p>

</div>



<div className="grid grid-cols-12 gap-6">

{/* LEFT */}

<div className="col-span-12 lg:col-span-7 space-y-6">


{/* domain config */}

<div className="bg-white rounded-xl p-8 shadow-sm">

<div className="flex justify-between mb-8">

<div>

<h3 className="font-bold text-lg">
Domain Configuration
</h3>

<p className="text-sm text-gray-500">
Assign domain to school
</p>

</div>


<span
className={`
px-3 py-1
text-[11px]
font-semibold
rounded-full
tracking-wide
flex items-center gap-1
${verified
? "bg-green-100 text-green-700"
: "bg-amber-100 text-amber-700"}
`}
>

<span className="material-symbols-outlined text-[14px]">
{verified ? "check_circle" : "schedule"}
</span>

{verified ? "Verified" : "Pending Verification"}

</span>

</div>



{/* select school */}

<div>

<label className="text-xs font-bold text-gray-500 uppercase block mb-2">

Select School

</label>

<select className="w-full bg-[#eff4ff] px-4 py-3 rounded-md outline-none">

<option>St. Andrews International</option>
<option>Greenwood Institute</option>

</select>

</div>



{/* domain */}

<div>

<label className="text-xs font-bold text-gray-500 uppercase block mb-2">

Domain Name

</label>


<div className="flex">

<input
placeholder="portal.standrews"
className="flex-1 bg-[#eff4ff] px-4 py-3 rounded-l-md outline-none"
/>


<div className="bg-[#dce9ff] px-4 flex items-center rounded-r-md text-sm text-gray-600">

.scholarflow.pro

</div>

</div>


<p className="text-xs text-gray-500 mt-2 flex gap-1">

<span className="material-symbols-outlined text-[14px]">
info
</span>

Creates subdomain

</p>

</div>



{/* preview */}

<div className="border-t pt-6 space-y-4">

<div className="flex items-center justify-between">

{/* preview url */}

<div>

<p className="text-xs text-gray-500">
Preview URL
</p>

<p className="text-sm font-mono font-semibold text-[#0058be]">
https://portal.standrews.scholarflow.pro
</p>

</div>


{/* verify button */}

<button
onClick={handleVerify}
disabled={checking}
className={`
min-w-[140px]
px-6 py-3
rounded-md
font-semibold
text-sm
transition
shadow-sm
flex items-center justify-center
${checking
? "bg-[#dce9ff] text-[#0058be] cursor-not-allowed"
: "bg-gradient-to-r from-[#0058be] to-[#2170e4] text-white hover:opacity-90"
}
`}
>

{checking ? "Verifying..." : "Verify"}

</button>

</div>

</div>

</div>



{/* DNS */}

<div className="bg-white rounded-xl p-8 shadow-sm">

<div className="flex justify-between mb-6">

<h3 className="font-bold">
DNS Records
</h3>


<button className="text-[#0058be] text-xs font-semibold">

Copy All Records

</button>

</div>



<div className="space-y-4">

{/* A */}

<div className="p-4 bg-[#eff4ff] rounded-lg flex justify-between items-center">

<div className="flex gap-8">

<div>

<p className="text-[10px] font-bold text-gray-400 uppercase">
Type
</p>

<p className="font-mono text-sm font-bold">
A
</p>

</div>


<div>

<p className="text-[10px] font-bold text-gray-400 uppercase">
Name
</p>

<p className="font-mono text-sm">
@
</p>

</div>


<div>

<p className="text-[10px] font-bold text-gray-400 uppercase">
Value
</p>

<p className="font-mono text-sm">
76.76.21.21
</p>

</div>

</div>


<span className="material-symbols-outlined text-gray-300">
content_copy
</span>

</div>



{/* cname */}

<div className="p-4 bg-[#eff4ff] rounded-lg flex justify-between items-center">

<div className="flex gap-8">

<div>

<p className="text-[10px] font-bold text-gray-400 uppercase">
Type
</p>

<p className="font-mono text-sm font-bold">
CNAME
</p>

</div>


<div>

<p className="text-[10px] font-bold text-gray-400 uppercase">
Name
</p>

<p className="font-mono text-sm">
www
</p>

</div>


<div>

<p className="text-[10px] font-bold text-gray-400 uppercase">
Value
</p>

<p className="font-mono text-sm">
cname.yourerp.com
</p>

</div>

</div>


<span className="material-symbols-outlined text-gray-300">
content_copy
</span>

</div>


</div>

</div>


{/* buttons */}

<div className="flex justify-between pt-6">

<button
onClick={()=>navigate("/global-admin/domains")}
className="text-[#0058be] font-semibold flex items-center gap-2"
>

<span className="material-symbols-outlined">
arrow_back
</span>

Back

</button>


<button
onClick={()=>navigate("/global-admin/subscriptions")}
className="primary-gradient text-white px-8 py-3 rounded-md font-semibold shadow hover:opacity-90 transition"
>

Continue Setup

</button>

</div>


</div>



{/* RIGHT */}

<div className="col-span-12 lg:col-span-5 space-y-6">


{/* SSL */}

<div className="bg-gradient-to-br from-[#0b1c30] to-[#213145] p-8 rounded-xl text-white relative overflow-hidden">

<h3 className="text-lg font-bold mb-2">
Automated SSL
</h3>


<p className="text-sm text-gray-300 mb-6">

Every domain automatically receives SSL certificate.

</p>


<div className="text-xs text-gray-400">

+1.2k institutions secured

</div>

</div>



{/* steps */}

<div className="bg-[#eff4ff] p-8 rounded-xl">

<h3 className="text-xs font-bold uppercase mb-6">
Setup Instructions
</h3>



<div className="space-y-6 text-sm text-gray-600">

<div className="flex gap-3">

<div className="w-6 h-6 rounded-full bg-white flex items-center justify-center text-xs font-bold text-[#0058be]">

1

</div>

Log in to domain registrar

</div>



<div className="flex gap-3">

<div className="w-6 h-6 rounded-full bg-white flex items-center justify-center text-xs font-bold text-[#0058be]">

2

</div>

Add DNS records

</div>



<div className="flex gap-3">

<div className="w-6 h-6 rounded-full bg-white flex items-center justify-center text-xs font-bold text-[#0058be]">

3

</div>

Verify domain

</div>

</div>

</div>



</div>


</div>

</div>

</Layout>

)

}