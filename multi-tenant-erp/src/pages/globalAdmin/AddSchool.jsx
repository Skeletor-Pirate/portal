import Layout from "../../components/erp/global/Layout";
import { useNavigate } from "react-router-dom";
export default function AddSchool(){
const navigate = useNavigate();
return(

<Layout>

<main className="max-w-5xl mx-auto w-full">

{/* stepper */}

<div className="mb-12">

<div className="flex items-center justify-between relative">

<div className="absolute top-1/2 left-0 w-full h-[2px] bg-[#e5eeff] -translate-y-1/2"></div>



{/* step 1 */}

<div className="flex flex-col items-center gap-3">

<div className="w-10 h-10 rounded-full bg-blue-600 text-white flex items-center justify-center font-bold ring-8 ring-[#f8f9ff]">

1

</div>

<span className="text-xs font-semibold text-blue-600 uppercase tracking-wider">

Institution

</span>

</div>



{/* step 2 */}

<div className="flex flex-col items-center gap-3">

<div className="w-10 h-10 rounded-full bg-[#e5eeff] text-gray-500 flex items-center justify-center font-bold ring-8 ring-[#f8f9ff]">

2

</div>

<span className="text-xs text-gray-500 uppercase tracking-wider">

Identity

</span>

</div>



{/* step 3 */}

<div className="flex flex-col items-center gap-3">

<div className="w-10 h-10 rounded-full bg-[#e5eeff] text-gray-500 flex items-center justify-center font-bold ring-8 ring-[#f8f9ff]">

3

</div>

<span className="text-xs text-gray-500 uppercase tracking-wider">

Plan

</span>

</div>



{/* step 4 */}

<div className="flex flex-col items-center gap-3">

<div className="w-10 h-10 rounded-full bg-[#e5eeff] text-gray-500 flex items-center justify-center font-bold ring-8 ring-[#f8f9ff]">

4

</div>

<span className="text-xs text-gray-500 uppercase tracking-wider">

Admin

</span>

</div>

</div>

</div>



{/* layout */}

<div className="grid lg:grid-cols-12 gap-8">

{/* left form */}

<div className="lg:col-span-8 space-y-6">

<div className="bg-white rounded-xl p-8 shadow-sm">

<h2 className="text-2xl font-bold mb-2">

School Information

</h2>

<p className="text-gray-500 text-sm mb-8">

Provide the core identity details for your academic institution.

</p>



<div className="space-y-6">

{/* logo upload */}

<div className="flex items-center gap-6 p-6 bg-[#eff4ff] rounded-lg border-2 border-dashed border-gray-200">

<div className="w-20 h-20 rounded-xl bg-[#e5eeff] flex items-center justify-center text-blue-600">

<span className="material-symbols-outlined text-4xl">

add_a_photo

</span>

</div>



<div>

<h3 className="font-semibold">

Institution Logo

</h3>

<p className="text-xs text-gray-500 mb-3">

PNG, JPG or SVG. Max size 2MB.

</p>

<button className="text-sm font-semibold text-blue-600">

Upload brand asset

</button>

</div>

</div>



{/* grid inputs */}

<div className="grid md:grid-cols-2 gap-6">

<div>

<label className="text-sm font-semibold text-gray-500">

Official Name

</label>

<input
placeholder="St Peters Academy"
className="w-full mt-2 bg-[#eff4ff] rounded-md px-4 py-3 outline-none focus:ring-2 focus:ring-blue-200"
/>

</div>



<div>

<label className="text-sm font-semibold text-gray-500">

Institution Email

</label>

<input
placeholder="contact@school.edu"
className="w-full mt-2 bg-[#eff4ff] rounded-md px-4 py-3 outline-none focus:ring-2 focus:ring-blue-200"
/>

</div>



<div>

<label className="text-sm font-semibold text-gray-500">

Phone Number

</label>

<input
placeholder="+1 000 000 000"
className="w-full mt-2 bg-[#eff4ff] rounded-md px-4 py-3 outline-none focus:ring-2 focus:ring-blue-200"
/>

</div>



<div>

<label className="text-sm font-semibold text-gray-500">

Country

</label>

<select className="w-full mt-2 bg-[#eff4ff] rounded-md px-4 py-3 outline-none">

<option>United States</option>
<option>United Kingdom</option>
<option>Canada</option>

</select>

</div>

</div>



{/* address */}

<div>

<label className="text-sm font-semibold text-gray-500">

Physical Address

</label>

<textarea
rows="3"
placeholder="123 Education Street..."
className="w-full mt-2 bg-[#eff4ff] rounded-md px-4 py-3 outline-none"
/>

</div>



{/* language */}

<div className="grid md:grid-cols-2 gap-6">

<div>

<label className="text-sm font-semibold text-gray-500">

Preferred Language

</label>

<select className="w-full mt-2 bg-[#eff4ff] rounded-md px-4 py-3">

<option>English</option>
<option>Spanish</option>

</select>

</div>



<div>

<label className="text-sm font-semibold text-gray-500">

Timezone

</label>

<select className="w-full mt-2 bg-[#eff4ff] rounded-md px-4 py-3">

<option>GMT +5:30</option>
<option>GMT +0</option>

</select>

</div>

</div>

</div>

</div>



{/* bottom buttons */}

<div className="flex justify-between pt-4">

<button
onClick={()=>navigate("/global-admin/schools")}
className="px-6 py-3 text-[#0058be] font-bold hover:bg-[#e5eeff] rounded-md transition-colors"
>

Save as Draft

</button>



<button
onClick={()=>navigate("/global-admin/add-domain")}
className="px-10 py-3 bg-gradient-to-br from-[#0058be] to-[#2170e4] text-white font-bold rounded-md shadow-lg shadow-[#0058be]/20 flex items-center gap-2 group"
>

Continue to Domain Setup

<span className="material-symbols-outlined transition-transform group-hover:translate-x-1">

arrow_forward

</span>

</button>

</div>

</div>



{/* right side */}

<div className="lg:col-span-4 space-y-6">

{/* help card */}

<div className="bg-blue-600 text-white p-6 rounded-xl relative overflow-hidden">

<h3 className="font-bold text-lg mb-2">

Need Assistance?

</h3>

<p className="text-sm mb-4">

Our onboarding specialist can help setup your institution.

</p>



<button className="bg-white/20 px-4 py-2 rounded-full text-sm">

Chat with Support

</button>



<span className="material-symbols-outlined absolute -right-4 -bottom-4 text-8xl opacity-10">

school

</span>

</div>



{/* tip */}

<div className="bg-[#eff4ff] p-6 rounded-xl">

<h3 className="text-xs font-bold tracking-widest mb-4">

ONBOARDING TIP

</h3>



<div className="flex gap-4">

<div className="w-10 h-10 bg-orange-200 rounded-full flex items-center justify-center">

<span className="material-symbols-outlined">

lightbulb

</span>

</div>



<p className="text-sm">

Use generic admin email instead of personal email.

</p>

</div>

</div>



{/* image */}

<div className="rounded-xl overflow-hidden">

<img
src="https://lh3.googleusercontent.com/aida-public/AB6AXuC2tJT-YlniLwBYIk3Agrtu-ZZ09ini71CSCk_lL3NyPc_NKW9GvlNDArAefbfo2ZuJPx_bPgHfaRtcBUnowTvyD9Ea8yIofRI0k7P7SWe_vcEafC9crruXzeYpIlo-XuUxXSqKjt_70ylTPBskO8i_PMY6P3f3ocXlHGz9xAJuNwkzqRtdlXc9q3-Hlo6C0UXDqg4why6WQx1Kpf5N3VM0Tg8Xqkhg5LGj0P5F1biZ_zreKpN_GSoB946bGYNp5J4a1qWO6GXwDg"
className="w-full"
/>

</div>

</div>

</div>

</main>

</Layout>

)

}