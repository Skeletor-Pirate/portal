import Sidebar from "./Sidebar";
import Header from "./Header";

export default function Layout({ children }) {

return (

<div className="bg-[#f8f9ff] text-[#0b1c30] min-h-screen">

<Sidebar/>

<div className="ml-64">

<Header/>

<div className="p-8 max-w-7xl mx-auto space-y-8">

{children}

</div>

</div>

</div>

)

}