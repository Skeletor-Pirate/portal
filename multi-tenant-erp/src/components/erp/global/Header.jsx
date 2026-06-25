import { useNavigate } from "react-router-dom";
export default function Header(){
    const navigate = useNavigate();

return(

<header className="flex justify-between items-center h-16 px-8 bg-white/80 backdrop-blur-md shadow-[0_12px_32px_rgba(11,28,48,0.06)] sticky top-0">

<div className="flex items-center gap-4">

<div className="p-2 rounded-full hover:bg-gray-100">

<span className="material-symbols-outlined text-blue-600">
search
</span>

</div>

<h1 className="text-xl font-semibold">
Global Overview
</h1>

</div>


<div className="flex items-center gap-6">

<button
onClick={()=>navigate("/global-admin/notifications")}
className="p-2 rounded-full hover:bg-[#eff4ff]"
>

<span className="material-symbols-outlined text-[#0058be]">
notifications
</span>

</button>


<div className="w-10 h-10 rounded-full bg-[#e8eefc] flex items-center justify-center">

<span className="material-symbols-outlined text-[#2563eb]">
person
</span>

</div>

</div>

</header>

)

}