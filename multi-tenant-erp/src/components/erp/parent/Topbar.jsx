import { useNavigate } from "react-router-dom";

export default function Topbar(){

  const navigate = useNavigate();

  return (

    <div className="h-16 bg-white border-b flex items-center justify-between px-6">

      <h2 className="font-bold text-lg text-slate-700">
        Parent Portal
      </h2>

      <div className="flex items-center gap-3">

        <button
          onClick={()=>navigate("/parent/notifications")}
          className="px-3 py-2 rounded-lg hover:bg-slate-100"
        >
          🔔
        </button>

        <button
          onClick={()=>navigate("/parent/settings")}
          className="px-3 py-2 rounded-lg hover:bg-slate-100"
        >
          ⚙️
        </button>

      </div>

    </div>

  );

}