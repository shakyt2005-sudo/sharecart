-- ==============================================================================
-- 🚀 SHARECART MASTER SETUP SCRIPT
-- RUN THIS SCRIPT ONCE TO SETUP THE ENTIRE DATABASE FROM SCRATCH
-- ==============================================================================

-- 1. CLEANUP (Removes old tables if they exist - BE CAREFUL on Production!)
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS chats CASCADE;
DROP TABLE IF EXISTS items CASCADE;
DROP TABLE IF EXISTS vendors CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- 2. CREATE TABLES

-- PROFILES (Users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT,
  phone TEXT UNIQUE,
  location TEXT,
  role TEXT DEFAULT 'user', -- 'user' or 'vendor'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- VENDORS (Shops)
CREATE TABLE vendors (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  shop_name TEXT NOT NULL,
  type TEXT NOT NULL, -- 'Grocery', 'Bakery', etc.
  phone TEXT UNIQUE NOT NULL, -- Used for login/identification
  location TEXT DEFAULT 'Chennai',
  rating DECIMAL(2,1) DEFAULT 0.0,
  is_verified BOOLEAN DEFAULT false,
  total_sales INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ITEMS (Products)
CREATE TABLE items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  product_name TEXT NOT NULL,
  quantity TEXT NOT NULL,
  expiry_date TIMESTAMP WITH TIME ZONE NOT NULL,
  vendor_id UUID REFERENCES vendors(id) ON DELETE CASCADE,
  category TEXT, -- 'Vegetables', 'Bakery', 'Dairy', etc.
  status TEXT DEFAULT 'available',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- CHATS (Negotiations)
CREATE TABLE chats (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  item_id UUID REFERENCES items(id) ON DELETE CASCADE,
  buyer_id UUID REFERENCES profiles(id) ON DELETE CASCADE, -- User Profile
  seller_id UUID REFERENCES vendors(id) ON DELETE CASCADE, -- Vendor
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- MESSAGES (Chat History)
CREATE TABLE messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  chat_id UUID REFERENCES chats(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL, -- Generic ID (could be profile or vendor)
  content TEXT NOT NULL,
  is_quick_reply BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- TRANSACTIONS (New Requirement)
CREATE TABLE transactions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  buyer_id UUID REFERENCES profiles(id),
  vendor_id UUID REFERENCES vendors(id),
  item_id UUID REFERENCES items(id),
  amount DECIMAL(10,2) NOT NULL,
  status TEXT DEFAULT 'completed', -- pending, completed, failed
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. ENABLE SECURITY (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE items ENABLE ROW LEVEL SECURITY;
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- 4. CREATE POLICIES (Simplified for Development)

-- PUBLIC READ ACCESS (Guest Mode Support)
CREATE POLICY "Public Read Vendors" ON vendors FOR SELECT USING (true);
CREATE POLICY "Public Read Items" ON items FOR SELECT USING (true);

-- AUTHENTICATED ACCESS
CREATE POLICY "Auth Read Profiles" ON profiles FOR SELECT USING (true);
CREATE POLICY "Auth Update Own Profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- CHAT / TRANSACTION ACCESS
CREATE POLICY "Chat Access" ON chats FOR SELECT USING (
    auth.uid() = buyer_id OR 
    EXISTS (SELECT 1 FROM vendors WHERE id = seller_id) -- Simplified
);

-- 5. SEED (SAMPLE) DATA

-- Insert Sample Vendors
INSERT INTO vendors (shop_name, type, phone, location, rating, is_verified, total_sales) VALUES
('Fresh Farms', 'Farm', '9876543210', 'T. Nagar, Chennai', 4.8, true, 120),
('City Bakery', 'Bakery', '9876543211', 'Anna Nagar, Chennai', 4.5, true, 85),
('Daily Dairy', 'Dairy', '9876543212', 'Adyar, Chennai', 4.2, false, 45),
('Metro Mart', 'Grocery', '9876543213', 'Velachery, Chennai', 4.6, true, 95);

-- Insert Sample Items
-- Note: We use subqueries to get vendor IDs dynamically
INSERT INTO items (product_name, quantity, expiry_date, category, vendor_id) 
SELECT 'Organic Carrots', '10 kg', NOW() + INTERVAL '2 days', 'Vegetables', id FROM vendors WHERE shop_name = 'Fresh Farms';

INSERT INTO items (product_name, quantity, expiry_date, category, vendor_id) 
SELECT 'Fresh Tomatoes', '15 kg', NOW() + INTERVAL '3 days', 'Vegetables', id FROM vendors WHERE shop_name = 'Fresh Farms';

INSERT INTO items (product_name, quantity, expiry_date, category, vendor_id) 
SELECT 'Sourdough Bread', '12 loaves', NOW() + INTERVAL '1 day', 'Bakery', id FROM vendors WHERE shop_name = 'City Bakery';

INSERT INTO items (product_name, quantity, expiry_date, category, vendor_id) 
SELECT 'Chocolate Cake', '5 pieces', NOW() + INTERVAL '12 hours', 'Bakery', id FROM vendors WHERE shop_name = 'City Bakery';

INSERT INTO items (product_name, quantity, expiry_date, category, vendor_id) 
SELECT 'Full Cream Milk', '20 liters', NOW() + INTERVAL '2 days', 'Dairy', id FROM vendors WHERE shop_name = 'Daily Dairy';

-- 6. FINAL SUCCESS MESSAGE
SELECT '✅ ShareCart Database Setup Complete! Tables created and sample data loaded.' as status;
