import { Bell } from "lucide-react";

export default function SchoolHeader({ title }) {

return (

<header className="fixed top-0 right-0 w-[calc(100%-16rem)] z-40 bg-white/80 backdrop-blur-xl flex justify-between items-center px-8 h-20">

<div className="flex items-center gap-4">

<button className="hover:bg-slate-100 rounded-full p-2">

<span className="material-symbols-outlined text-blue-700">

menu

</span>

</button>

<h1 className="font-headline font-semibold text-lg text-blue-700">

{title}

</h1>

</div>


<div className="flex items-center gap-6">

{/* search */}

<div className="relative hidden lg:block">

<span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-outline text-sm">

search

</span>

<input
placeholder="Search records..."
className="pl-10 pr-4 py-2 bg-surface-container-low border-none rounded-md text-sm focus:ring-2 focus:ring-primary w-64"
/>

</div>


{/* notification icon instead of button */}

<button className="p-2 rounded-full hover:bg-surface-container-high">

<Bell size={20} />

</button>


{/* profile */}

<div className="w-10 h-10 rounded-full overflow-hidden border-2 border-surface-container-high">

<img
src="https://lh3.googleusercontent.com/aida-public/AB6AXuCr-h68ZGUP34FUflv2mFF-gNJjT5N_6ytDAglZduyU7THcHTXquHtKCzW8pah1ZVvvgH2DwFQmNae7GnJLai44EeHTkxyJ7zBwpwQDu-gvnmEk4ZR9VvIQ42BaYW5Iv2e6IOltaThdGqNRbF3cqmGeYfEhWJShw9MZsTyFHM6ygEEHITElBL26bGg34Jsu79sL7xFoRsP1OthWVTv3qIia-yBCPlh5GqFFycTauUCcNk7mlY9MFiACpCeL5aUtTEaP1cd3-aT6LQ"
/>

</div>

</div>

</header>

);

}