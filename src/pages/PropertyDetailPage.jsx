import React,{useState}from"react";
import{Link,useParams}from"react-router-dom";
import{ArrowLeft,Check,CalendarDays,Mail,MapPin,MessageCircle,Phone,Send,Users}from"lucide-react";
import SiteLayout from"../components/layout/SiteLayout";
import SignalScore from"../components/property/SignalScore";
import{properties}from"../data/properties";
import{siteConfig}from"../config/site";
import{useLocalStorage}from"../hooks/useLocalStorage";

const blankBooking={name:"",phone:"",email:"",homeAddress:"",preferredDate:"",guests:"1",note:""};

function normalizeWhatsapp(value){
  let digits=String(value||"").replace(/\D/g,"");
  if(digits.startsWith("00"))digits=digits.slice(2);
  if(digits.length===11&&digits.startsWith("0"))digits="880"+digits.slice(1);
  return digits;
}

export default function PropertyDetailPage(){
  const{slug}=useParams();
  const[items]=useLocalStorage("borsha_properties_v1",properties);
  const[settings]=useLocalStorage("borsha_site_v1",siteConfig);
  const[bookings,setBookings]=useLocalStorage("borsha_bookings_v1",[]);
  const[booking,setBooking]=useState(blankBooking);
  const[bookingOpen,setBookingOpen]=useState(false);
  const[sent,setSent]=useState(false);
  const p=items.find(x=>x.slug===slug)||properties.find(x=>x.slug===slug);

  if(!p)return <SiteLayout><main className="info-page"><h1>Residence <em>not found.</em></h1><Link to="/properties" className="btn btn-primary">Back to properties</Link></main></SiteLayout>;

  const submitBooking=e=>{
    e.preventDefault();
    const owner=normalizeWhatsapp(settings.ownerWhatsapp);
    if(!owner){alert("Booking is ready, but the owner WhatsApp number has not been connected in the admin panel.");return}
    const record={...booking,id:"BK-"+Date.now(),propertyId:p.id,property:p.title,propertySlug:p.slug,createdAt:new Date().toISOString()};
    setBookings(x=>[record,...x]);
    const message=[
      "BORSHA HOME — PROPERTY BOOKING",
      "",
      "Property: "+p.title,
      "Property ID: "+p.id,
      "Status: "+p.status,
      "Price: "+p.priceLabel,
      "Location: "+p.area+", "+p.city,
      "",
      "Customer details",
      "Name: "+booking.name,
      "Phone: "+booking.phone,
      "Email: "+(booking.email||"Not provided"),
      "Home address: "+booking.homeAddress,
      "Preferred date: "+booking.preferredDate,
      "Guests/occupants: "+booking.guests,
      "Message: "+(booking.note||"No additional message"),
      "",
      "Sent from Borsha Home booking system."
    ].join("\n");
    window.open("https://wa.me/"+owner+"?text="+encodeURIComponent(message),"_blank","noopener,noreferrer");
    setBooking(blankBooking);
    setSent(true);
  };

  return <SiteLayout><main className="detail-page">
    <Link to="/properties" className="back-link"><ArrowLeft size={15}/> All properties</Link>
    <div className="detail-hero">
      <img src={p.cover} alt={p.title}/>
      <div>
        <small>{p.status} · {p.city} · {p.area}</small>
        <h1>{p.title}</h1>
        <p>{p.description}</p>
        <strong className="detail-price">{p.priceLabel}</strong>
        <SignalScore score={p.signal} details/>
        <div className="detail-stats"><span>{p.beds}<small>BEDS</small></span><span>{p.baths}<small>BATHS</small></span><span>{p.size.toLocaleString()}<small>SQ FT</small></span></div>
        <button className="btn btn-primary booking-trigger" type="button" onClick={()=>{setBookingOpen(true);setSent(false)}}><CalendarDays size={17}/> Book this property</button>
      </div>
    </div>

    {bookingOpen&&<section className="booking-panel" aria-label="Property booking form">
      <div className="booking-intro">
        <small>PRIVATE VIEWING / BOOKING</small>
        <h2>Reserve your <em>next step.</em></h2>
        <p>Fill in your details. After submission, the complete booking request will open directly in the owner's WhatsApp.</p>
        {sent&&<div className="booking-success"><MessageCircle size={16}/> Booking request prepared for WhatsApp.</div>}
      </div>
      <form className="booking-form" onSubmit={submitBooking}>
        <div className="booking-property-summary"><img src={p.cover} alt=""/><div><b>{p.title}</b><span>{p.area}, {p.city} · {p.priceLabel}</span></div></div>
        <div className="form-grid">
          <label>Full name<input required value={booking.name} onChange={e=>setBooking({...booking,name:e.target.value})} placeholder="Your full name"/></label>
          <label>Phone number<input required type="tel" value={booking.phone} onChange={e=>setBooking({...booking,phone:e.target.value})} placeholder="01XXXXXXXXX"/></label>
          <label>Email address<input type="email" value={booking.email} onChange={e=>setBooking({...booking,email:e.target.value})} placeholder="you@example.com"/></label>
          <label>Preferred date<input required type="date" value={booking.preferredDate} onChange={e=>setBooking({...booking,preferredDate:e.target.value})}/></label>
          <label>Guests / occupants<input required type="number" min="1" max="50" value={booking.guests} onChange={e=>setBooking({...booking,guests:e.target.value})}/></label>
          <label className="wide">Home / current address<textarea required value={booking.homeAddress} onChange={e=>setBooking({...booking,homeAddress:e.target.value})} placeholder="House, road, area, city"/></label>
          <label className="wide">Additional message<textarea value={booking.note} onChange={e=>setBooking({...booking,note:e.target.value})} placeholder="Viewing time, requirements or anything else…"/></label>
        </div>
        <div className="booking-actions"><button className="btn btn-primary" type="submit"><Send size={16}/> Continue to WhatsApp</button><button className="booking-cancel" type="button" onClick={()=>setBookingOpen(false)}>Cancel</button></div>
        <small className="booking-note"><Phone size={13}/> Your phone and address are included in the private WhatsApp booking message.</small>
      </form>
    </section>}

    <section className="detail-section"><div><small>WHY IT SCORES</small><h2>Signal, <em>explained.</em></h2></div><div className="score-list">{Object.entries(p.scores||{}).map(([k,v])=><div key={k}><span>{k}</span><b>{v}</b><i><em style={{width:v+"%"}}/></i></div>)}</div></section>
    <section className="detail-section"><div><small>AMENITIES</small><h2>Designed for <em>daily life.</em></h2></div><div className="amenities">{p.amenities.map(x=><span key={x}><Check size={14}/>{x}</span>)}</div></section>
  </main></SiteLayout>
}