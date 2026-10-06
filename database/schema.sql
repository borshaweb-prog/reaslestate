PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS admins (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  display_name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'admin' CHECK(role IN ('admin','editor')),
  is_active INTEGER NOT NULL DEFAULT 1 CHECK(is_active IN (0,1)),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS site_settings (
  id INTEGER PRIMARY KEY CHECK(id=1),
  name TEXT NOT NULL DEFAULT 'Borsha Home',
  short_name TEXT NOT NULL DEFAULT 'BORSHA',
  tagline TEXT NOT NULL DEFAULT 'Property, with signal.',
  description TEXT NOT NULL DEFAULT 'A premium property discovery platform for considered buyers and renters.',
  currency TEXT NOT NULL DEFAULT 'BDT',
  default_city TEXT NOT NULL DEFAULT 'Dhaka',
  owner_whatsapp TEXT NOT NULL DEFAULT '',
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS social_links (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  platform TEXT NOT NULL UNIQUE CHECK(platform IN('facebook','instagram','youtube','linkedin')),
  url TEXT NOT NULL DEFAULT '',
  is_enabled INTEGER NOT NULL DEFAULT 1 CHECK(is_enabled IN(0,1)),
  sort_order INTEGER NOT NULL DEFAULT 0,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS agents (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  role TEXT NOT NULL,
  territory TEXT NOT NULL DEFAULT '',
  listings INTEGER NOT NULL DEFAULT 0 CHECK(listings>=0),
  phone TEXT NOT NULL DEFAULT '',
  whatsapp TEXT NOT NULL DEFAULT '',
  messenger TEXT NOT NULL DEFAULT '',
  avatar TEXT NOT NULL DEFAULT '',
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS properties (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  city TEXT NOT NULL,
  area TEXT NOT NULL,
  status TEXT NOT NULL CHECK(status IN('For Sale','For Rent','Sold','Rented')),
  type TEXT NOT NULL,
  price REAL NOT NULL DEFAULT 0 CHECK(price>=0),
  price_label TEXT NOT NULL DEFAULT '',
  beds INTEGER NOT NULL DEFAULT 0 CHECK(beds>=0),
  baths INTEGER NOT NULL DEFAULT 0 CHECK(baths>=0),
  size_sqft INTEGER NOT NULL DEFAULT 0 CHECK(size_sqft>=0),
  signal REAL NOT NULL DEFAULT 0 CHECK(signal BETWEEN 0 AND 100),
  featured INTEGER NOT NULL DEFAULT 0 CHECK(featured IN(0,1)),
  agent_id TEXT,
  cover TEXT NOT NULL DEFAULT '',
  gallery_json TEXT NOT NULL DEFAULT '[]',
  description TEXT NOT NULL DEFAULT '',
  amenities_json TEXT NOT NULL DEFAULT '[]',
  scores_json TEXT NOT NULL DEFAULT '{"location":0,"layout":0,"light":0,"resilience":0}',
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(agent_id) REFERENCES agents(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS bookings (
  id TEXT PRIMARY KEY,
  property_id TEXT NOT NULL,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT NOT NULL DEFAULT '',
  home_address TEXT NOT NULL,
  preferred_date TEXT NOT NULL,
  guests INTEGER NOT NULL DEFAULT 1 CHECK(guests>0),
  note TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'new' CHECK(status IN('new','contacted','confirmed','cancelled','completed')),
  whatsapp_sent INTEGER NOT NULL DEFAULT 0 CHECK(whatsapp_sent IN(0,1)),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(property_id) REFERENCES properties(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS reviews (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  role TEXT NOT NULL,
  rating INTEGER NOT NULL DEFAULT 5 CHECK(rating BETWEEN 1 AND 5),
  review_text TEXT NOT NULL,
  is_published INTEGER NOT NULL DEFAULT 1 CHECK(is_published IN(0,1)),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  admin_id TEXT,
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  details_json TEXT NOT NULL DEFAULT '{}',
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(admin_id) REFERENCES admins(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_properties_city ON properties(city);
CREATE INDEX IF NOT EXISTS idx_properties_status ON properties(status);
CREATE INDEX IF NOT EXISTS idx_properties_featured ON properties(featured);
CREATE INDEX IF NOT EXISTS idx_properties_agent ON properties(agent_id);
CREATE INDEX IF NOT EXISTS idx_bookings_property ON bookings(property_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_created ON bookings(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reviews_published ON reviews(is_published,sort_order);
CREATE INDEX IF NOT EXISTS idx_audit_entity ON audit_logs(entity_type,entity_id);

INSERT OR IGNORE INTO site_settings(id,name,short_name,tagline,description,currency,default_city,owner_whatsapp)
VALUES(1,'Borsha Home','BORSHA','Property, with signal.','A premium property discovery platform for considered buyers and renters.','BDT','Dhaka','');

INSERT OR IGNORE INTO social_links(platform,url,sort_order) VALUES
('facebook','https://facebook.com',1),('instagram','https://instagram.com',2),
('youtube','https://youtube.com',3),('linkedin','https://linkedin.com',4);

INSERT OR IGNORE INTO agents(id,name,role,territory,listings,phone,whatsapp,messenger,avatar) VALUES
('AG-01','Arif Rahman','Senior Property Advisor','Gulshan · Banani',14,'+880 1711 000001','8801711000001','','https://i.pravatar.cc/160?img=12'),
('AG-02','Nadia Karim','Residential Consultant','Dhanmondi · Uttara',11,'+880 1711 000002','8801711000002','','https://i.pravatar.cc/160?img=47'),
('AG-03','Tanvir Hasan','Chattogram Lead','Khulshi · Panchlaish',9,'+880 1711 000003','8801711000003','','https://i.pravatar.cc/160?img=33');

INSERT OR IGNORE INTO properties
(id,title,slug,city,area,status,type,price,price_label,beds,baths,size_sqft,signal,featured,agent_id,cover,gallery_json,description,amenities_json,scores_json)
VALUES
('BG-1001','Green Residence','green-residence','Dhaka','Gulshan 2','For Sale','Apartment',28500000,'৳2.85 Cr',4,4,2480,96.2,1,'AG-01','https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?auto=format&fit=crop&w=1600&q=88','["https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?auto=format&fit=crop&w=1600&q=88","https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?auto=format&fit=crop&w=1200&q=88"]','A quiet, light-filled residence designed around generous proportions, privacy and everyday city access.','["Reserved Parking","Generator","24/7 Security","Residents Gym","High-speed Lift","Backup Water"]','{"location":98,"layout":94,"light":96,"resilience":95}'),
('BG-1002','Lakeview 07','lakeview-07','Dhaka','Dhanmondi','For Rent','Apartment',95000,'৳95k / mo',3,3,1780,92.4,1,'AG-02','https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?auto=format&fit=crop&w=1600&q=88','["https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?auto=format&fit=crop&w=1600&q=88","https://images.unsplash.com/photo-1600607688969-a5bfcd646154?auto=format&fit=crop&w=1200&q=88"]','Calm interiors, generous windows and a short walk to everyday essentials.','["Lake View","Parking","Security","Lift","Generator"]','{"location":94,"layout":91,"light":95,"resilience":89}'),
('BG-1003','Bayline House','bayline-house','Chattogram','Khulshi','For Sale','House',17200000,'৳1.72 Cr',3,3,2120,94.8,1,'AG-03','https://images.unsplash.com/photo-1600585154526-990dced4db0d?auto=format&fit=crop&w=1600&q=88','["https://images.unsplash.com/photo-1600585154526-990dced4db0d?auto=format&fit=crop&w=1600&q=88"]','A private family home with open-air living and a coastal-city rhythm.','["Private Garden","Parking","Rooftop","Security"]','{"location":93,"layout":96,"light":92,"resilience":94}'),
('BG-1004','Gulshan Atelier','gulshan-atelier','Dhaka','Gulshan 1','For Sale','Penthouse',39500000,'৳3.95 Cr',4,4,3050,91.7,0,'AG-01','https://images.unsplash.com/photo-1600607688969-a5bfcd646154?auto=format&fit=crop&w=1600&q=88','["https://images.unsplash.com/photo-1600607688969-a5bfcd646154?auto=format&fit=crop&w=1600&q=88"]','A refined penthouse for buyers who value privacy and proportion.','["Private Terrace","Concierge","Parking","Gym"]','{"location":96,"layout":90,"light":91,"resilience":90}'),
('BG-1005','Crescent Court','crescent-court','Chattogram','Panchlaish','For Rent','Apartment',68000,'৳68k / mo',3,2,1520,89.9,0,'AG-03','https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?auto=format&fit=crop&w=1600&q=88','["https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?auto=format&fit=crop&w=1600&q=88"]','A bright apartment with a strong value-to-space ratio.','["Lift","Parking","Generator","Security"]','{"location":88,"layout":92,"light":90,"resilience":89}'),
('BG-1006','Banani Courtyard','banani-courtyard','Dhaka','Banani','For Rent','Duplex',120000,'৳120k / mo',4,4,2700,95.1,1,'AG-02','https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?auto=format&fit=crop&w=1600&q=88','["https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?auto=format&fit=crop&w=1600&q=88"]','A duplex with indoor-outdoor character and a rare private courtyard.','["Private Courtyard","Parking","Security","Lift"]','{"location":95,"layout":94,"light":96,"resilience":94}'),
('BH-1007','Meghna Residence','meghna-residence','Dhaka','Baridhara','For Sale','Apartment',31800000,'৳3.18 Cr',4,4,2660,97.1,1,'AG-02','https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?auto=format&fit=crop&w=1600&q=88','["https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?auto=format&fit=crop&w=1600&q=88"]','A composed Baridhara residence with deep daylight, generous rooms and quiet streets.','["Reserved Parking","Residents Lounge","Security","Generator","High-speed Lift"]','{"location":98,"layout":96,"light":97,"resilience":96}'),
('BH-1008','Palm Court','palm-court','Dhaka','Uttara','For Sale','Duplex',19800000,'৳1.98 Cr',4,3,2310,93.8,1,'AG-01','https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?auto=format&fit=crop&w=1600&q=88','["https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?auto=format&fit=crop&w=1600&q=88"]','A warm duplex shaped for family life, with a private terrace and generous circulation.','["Private Terrace","Parking","Security","Lift","Backup Water"]','{"location":91,"layout":95,"light":94,"resilience":93}'),
('BH-1009','Riverstone 12','riverstone-12','Dhaka','Mohakhali','For Rent','Apartment',110000,'৳110k / mo',3,3,1860,90.6,0,'AG-02','https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1600&q=88','["https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1600&q=88"]','A polished city apartment with strong daylight and efficient everyday living.','["Parking","Gym","Security","Generator"]','{"location":90,"layout":91,"light":92,"resilience":89}'),
('BH-1010','Palm Bay Villa','palm-bay-villa','Chattogram','Nasirabad','For Sale','Villa',26400000,'৳2.64 Cr',5,4,3420,95.6,1,'AG-03','https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1600&q=88','["https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1600&q=88"]','A private villa with layered outdoor spaces, natural light and room to grow.','["Private Garden","Carport","Rooftop","Security","Generator"]','{"location":94,"layout":97,"light":95,"resilience":96}'),
('BH-1011','Studio No. 8','studio-no-8','Dhaka','Tejgaon','For Rent','Studio',52000,'৳52k / mo',1,1,780,88.9,0,'AG-01','https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?auto=format&fit=crop&w=1600&q=88','["https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?auto=format&fit=crop&w=1600&q=88"]','A compact, design-led studio for professionals who want central access without excess.','["Furnished","Security","Lift","Generator"]','{"location":93,"layout":86,"light":90,"resilience":87}'),
('BH-1012','Lakeside Verve','lakeside-verve','Dhaka','Gulshan 2','For Sale','Penthouse',46500000,'৳4.65 Cr',4,5,3680,98.0,1,'AG-02','https://images.unsplash.com/photo-1600607688969-a5bfcd646154?auto=format&fit=crop&w=1600&q=88','["https://images.unsplash.com/photo-1600607688969-a5bfcd646154?auto=format&fit=crop&w=1600&q=88"]','A top-floor residence with expansive glazing, private outdoor space and exceptional city access.','["Private Terrace","Concierge","Parking","Residents Gym","Security"]','{"location":99,"layout":97,"light":98,"resilience":97}');

INSERT OR IGNORE INTO reviews(id,name,role,rating,review_text,is_published,sort_order) VALUES
('RV-01','Nafis Ahmed','Verified Buyer · Dhaka',5,'The Signal view made comparing homes dramatically easier. I stopped guessing and started deciding.',1,1),
('RV-02','Samira Chowdhury','Verified Renter · Dhanmondi',5,'Beautiful listings, useful details and zero marketplace noise. Exactly how property discovery should feel.',1,2),
('RV-03','Raihan Kabir','Verified Buyer · Gulshan',5,'The property context is what sold me. The score explains the recommendation instead of just shouting a price.',1,3),
('RV-04','Maliha Rahman','Verified Buyer · Banani',5,'From shortlist to viewing, Borsha Home feels considered at every step.',1,4),
('RV-05','Tahmid Hasan','Verified Renter · Chattogram',5,'Finally a property site that feels like a premium product rather than a classifieds page.',1,5),
('RV-06','Farhan Islam','Verified Buyer · Khulshi',5,'Fast, clean and genuinely useful. The Signal layer is the feature I kept coming back to.',1,6),
('RV-07','Ishrat Jahan','Verified Buyer · Dhaka',5,'The photography and decision layer work together beautifully. I found my shortlist in minutes.',1,7),
('RV-08','Adnan Hossain','Verified Renter · Dhanmondi',5,'Clear pricing, strong property context and a much calmer browsing experience.',1,8);

COMMIT;