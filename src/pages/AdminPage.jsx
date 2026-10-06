import React,{useMemo,useState}from"react";
import{BarChart3,Building2,Users,Settings,Plus,Trash2,Save,Eye,Star,Search,ClipboardList,MessageCircle,CalendarDays}from"lucide-react";
import SiteLayout from"../components/layout/SiteLayout";
import{properties as seedProperties}from"../data/properties";
import{agents as seedAgents}from"../data/agents";
import{siteConfig}from"../config/site";
import{useLocalStorage}from"../hooks/useLocalStorage";

const blank={id:"",title:"",slug:"",city:"Dhaka",area:"",status:"For Sale",type:"Apartment",price:0,priceLabel:"",beds:3,baths:2,size:1200,signal:80,featured:false,agent:"",cover:"",gallery:[],description:"",amenities:[],scores:{location:80,layout:80,light:80,resilience:80}};

export default function AdminPage(){
  const[data,setData]=useLocalStorage("borsha_properties_v1",seedProperties);
  const[people,setPeople]=useLocalStorage("borsha_agents_v1",seedAgents);
  const[settings,setSettings]=useLocalStorage("borsha_site_v1",siteConfig);
  const[bookings,setBookings]=useLocalStorage("borsha_bookings_v1",[]);
  const[tab,setTab]=useState("overview");
  const[editing,setEditing]=useState(null);
  const[search,setSearch]=useState("");
  const visible=useMemo(()=>data.filter(p=>[p.title,p.city,p.area,p.status].join(" ").toLowerCase().includes(search.toLowerCase())),[data,search]);

  const saveProperty=e=>{
    e.preventDefault();
    const p={...editing,price:Number(editing.price),signal:Number(editing.signal),beds:Number(editing.beds),baths:Number(editing.baths),size:Number(editing.size),amenities:Array.isArray(editing.amenities)?editing.amenities:editing.amenities.split(",").map(x=>x.trim()).filter(Boolean)};
    setData(x=>x.some(a=>a.id===p.id)?x.map(a=>a.id===p.id?p:a):[p,...x]);setEditing(null)
  };
  const remove=id=>{if(confirm("Delete this property?"))setData(x=>x.filter(p=>p.id!==id))};
  const removeBooking=id=>{if(confirm("Remove this booking from this browser?"))setBookings(x=>x.filter(b=>b.id!==id))};

  return <SiteLayout><main className="admin-page">
    <aside className="admin-sidebar">
      <div className="admin-title">CONTROL ROOM<small>Borsha CMS / local mode</small></div>
      {[["overview","Overview",BarChart3],["properties","Listings",Building2],["bookings","Bookings",ClipboardList],["agents","Agents",Users],["settings","Site settings",Settings]].map(([id,label,I])=><button className={tab===id?"active":""} onClick={()=>setTab(id)} key={id}><I size={17}/>{label}{id==="bookings"&&bookings.length>0?<b className="admin-badge">{bookings.length}</b>:null}</button>)}
      <a href="/" target="_blank"><Eye size={17}/>View website</a>
    </aside>

    <section className="admin-content">
      {tab==="overview"&&<>
        <div className="admin-head"><div><small>CONTROL ROOM</small><h1>Good decisions start <em>here.</em></h1></div><button className="btn btn-primary" onClick={()=>{setEditing({...blank,id:"BG-"+Date.now(),slug:"new-residence"});setTab("properties")}}><Plus size={16}/> New listing</button></div>
        <div className="stat-grid">
          <div><Building2/><b>{data.length}</b><span>Listings</span></div>
          <div><Star/><b>{data.filter(p=>p.featured).length}</b><span>Featured</span></div>
          <div><Users/><b>{people.length}</b><span>Agents</span></div>
          <div><ClipboardList/><b>{bookings.length}</b><span>Bookings</span></div>
        </div>
        <div className="admin-panel"><h2>Quick inventory</h2>{data.slice(0,6).map(p=><div className="admin-row" key={p.id}><img src={p.cover} alt=""/><div><b>{p.title}</b><small>{p.city} · {p.status}</small></div><strong>{p.signal}</strong><button onClick={()=>{setEditing({...p});setTab("properties")}}>Edit</button></div>)}</div>
      </>}

      {tab==="properties"&&<>
        <div className="admin-head"><div><small>INVENTORY</small><h1>Property <em>editor.</em></h1></div><button className="btn btn-primary" onClick={()=>setEditing({...blank,id:"BG-"+Date.now(),slug:"new-residence"})}><Plus size={16}/> Add property</button></div>
        <div className="admin-toolbar"><Search size={16}/><input value={search} onChange={e=>setSearch(e.target.value)} placeholder="Filter listings…"/></div>
        {editing?<form className="editor-form" onSubmit={saveProperty}><div className="editor-top"><h2>{editing.title||"New listing"}</h2><button type="button" onClick={()=>setEditing(null)}>Close</button></div><div className="form-grid">{["title","slug","city","area","status","type","priceLabel","agent","cover"].map(k=><label key={k}>{k}<input value={editing[k]??""} onChange={e=>setEditing({...editing,[k]:e.target.value})}/></label>)}{["price","beds","baths","size","signal"].map(k=><label key={k}>{k}<input type="number" value={editing[k]??0} onChange={e=>setEditing({...editing,[k]:e.target.value})}/></label>)}<label className="wide">Description<textarea value={editing.description} onChange={e=>setEditing({...editing,description:e.target.value})}/></label><label className="wide">Amenities <input value={Array.isArray(editing.amenities)?editing.amenities.join(", "):editing.amenities} onChange={e=>setEditing({...editing,amenities:e.target.value})}/></label><label className="check"><input type="checkbox" checked={!!editing.featured} onChange={e=>setEditing({...editing,featured:e.target.checked})}/> Featured listing</label></div><button className="btn btn-primary" type="submit"><Save size={16}/> Save listing</button></form>:<div className="admin-panel">{visible.map(p=><div className="admin-row" key={p.id}><img src={p.cover} alt=""/><div><b>{p.title}</b><small>{p.id} · {p.city} · {p.status}</small></div><strong>{p.priceLabel}</strong><button onClick={()=>setEditing({...p})}>Edit</button><button className="danger" onClick={()=>remove(p.id)}><Trash2 size={15}/></button></div>)}</div>}
      </>}

      {tab==="bookings"&&<BookingManager bookings={bookings} removeBooking={removeBooking}/>}

      {tab==="agents"&&<AgentEditor people={people} setPeople={setPeople}/>}

      {tab==="settings"&&<div className="settings-editor">
        <div className="admin-head"><div><small>BRAND SYSTEM</small><h1>Site <em>settings.</em></h1></div></div>
        <div className="editor-form">
          <label>Brand name<input value={settings.name} onChange={e=>setSettings({...settings,name:e.target.value})}/></label>
          <label>Tagline<input value={settings.tagline} onChange={e=>setSettings({...settings,tagline:e.target.value})}/></label>
          <label>Description<textarea value={settings.description} onChange={e=>setSettings({...settings,description:e.target.value})}/></label>
          <h3>Owner WhatsApp booking connection</h3>
          <p className="form-help">Enter the owner WhatsApp number with country code. Bangladesh example: 8801XXXXXXXXX. Property booking requests will be sent directly to this number.</p>
          <label>Owner WhatsApp number<input type="tel" placeholder="8801XXXXXXXXX" value={settings.ownerWhatsapp||""} onChange={e=>setSettings({...settings,ownerWhatsapp:e.target.value})}/></label>
          <h3>Social media links</h3>
          <p className="form-help">Add full profile URLs. These links are shown on the public footer.</p>
          <div className="form-grid">{["facebook","instagram","youtube","linkedin"].map(k=><label key={k}>{k}<input type="url" placeholder={"https://"+k+".com/..."} value={settings.socials?.[k]||""} onChange={e=>setSettings({...settings,socials:{...(settings.socials||{}),[k]:e.target.value}})}/></label>)}</div>
          <button className="btn btn-primary" onClick={()=>alert("Settings saved locally.")}><Save size={16}/> Save settings</button>
        </div>
      </div>}
    </section>
  </main></SiteLayout>
}

function BookingManager({bookings,removeBooking}){
  return <div>
    <div className="admin-head"><div><small>PROPERTY BOOKING COLLECTION</small><h1>Booking <em>requests.</em></h1></div></div>
    <div className="booking-admin-note"><MessageCircle size={17}/><div><b>Direct WhatsApp flow</b><span>Every new booking is saved locally and opens a pre-filled WhatsApp message to the owner.</span></div></div>
    {bookings.length===0?<div className="admin-panel empty-state"><ClipboardList size={28}/><h2>No booking requests yet.</h2><p>When a visitor books a property from this browser, the request will appear here.</p></div>:<div className="booking-list">{bookings.map(b=><article className="booking-admin-card" key={b.id}>
      <div className="booking-admin-card-head"><div><small>{b.id} · {new Date(b.createdAt).toLocaleString()}</small><h2>{b.property}</h2></div><button className="danger" onClick={()=>removeBooking(b.id)}><Trash2 size={15}/></button></div>
      <div className="booking-detail-grid"><span><b>Name</b>{b.name}</span><span><b>Phone</b>{b.phone}</span><span><b>Email</b>{b.email||"—"}</span><span><b>Preferred date</b>{b.preferredDate}</span><span><b>Guests</b>{b.guests}</span><span className="wide"><b>Home / current address</b>{b.homeAddress}</span><span className="wide"><b>Message</b>{b.note||"—"}</span></div>
    </article>)}</div>}
  </div>
}

function AgentEditor({people,setPeople}){
  const[edit,setEdit]=useState(null);
  const blankA={id:"AG-"+Date.now(),name:"",role:"Property Advisor",territory:"Dhaka",listings:0,phone:"",whatsapp:"",messenger:"",avatar:""};
  return <><div className="admin-head"><div><small>TEAM</small><h1>Agent <em>directory.</em></h1></div><button className="btn btn-primary" onClick={()=>setEdit({...blankA,id:"AG-"+Date.now()})}><Plus size={16}/> Add agent</button></div>
    {edit&&<form className="editor-form" onSubmit={e=>{e.preventDefault();setPeople(x=>x.some(a=>a.id===edit.id)?x.map(a=>a.id===edit.id?edit:a):[edit,...x]);setEdit(null)}}><div className="form-grid">{["name","role","territory","phone","whatsapp","messenger","avatar"].map(k=><label key={k}>{k}<input value={edit[k]} onChange={e=>setEdit({...edit,[k]:e.target.value})}/></label>)}</div><button className="btn btn-primary"><Save size={16}/> Save agent</button></form>}
    <div className="admin-panel">{people.map(a=><div className="admin-row" key={a.id}><img className="avatar" src={a.avatar} alt=""/><div><b>{a.name}</b><small>{a.role} · {a.territory}</small></div><strong>{a.listings}</strong><button onClick={()=>setEdit({...a})}>Edit</button></div>)}</div>
  </>
}