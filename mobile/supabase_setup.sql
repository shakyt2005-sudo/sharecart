-- ShareCart Database Schema for Supabase

-- ============================================
-- 1. CREATE TABLES
-- ============================================

-- Vendors Table
CREATE TABLE IF NOT EXISTS vendors (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  shop_name TEXT NOT NULL,
  type TEXT NOT NULL,
  phone TEXT NOT NULL UNIQUE,
  location TEXT DEFAULT 'Chennai',
  rating DECIMAL(2,1) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
  is_verified BOOLEAN DEFAULT false,
  total_sales INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Items Table
CREATE TABLE IF NOT EXISTS items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  product_name TEXT NOT NULL,
  quantity TEXT NOT NULL,
  expiry_date TIMESTAMP WITH TIME ZONE NOT NULL,
  vendor_id UUID REFERENCES vendors(id) ON DELETE CASCADE,
  category TEXT,
  status TEXT DEFAULT 'available' CHECK (status IN ('available', 'reserved', 'sold')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 2. CREATE INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX IF NOT EXISTS idx_items_vendor_id ON items(vendor_id);
CREATE INDEX IF NOT EXISTS idx_items_expiry_date ON items(expiry_date);
CREATE INDEX IF NOT EXISTS idx_items_status ON items(status);
CREATE INDEX IF NOT EXISTS idx_items_category ON items(category);
CREATE INDEX IF NOT EXISTS idx_vendors_total_sales ON vendors(total_sales DESC);
CREATE INDEX IF NOT EXISTS idx_vendors_location ON vendors(location);

-- ============================================
-- 3. ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================

ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE items ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 4. CREATE RLS POLICIES
-- ============================================

-- Public read access for vendors
DROP POLICY IF EXISTS "Allow public read access on vendors" ON vendors;
CREATE POLICY "Allow public read access on vendors"
  ON vendors FOR SELECT
  USING (true);

-- Public read access for items
DROP POLICY IF EXISTS "Allow public read access on items" ON items;
CREATE POLICY "Allow public read access on items"
  ON items FOR SELECT
  USING (true);

-- Allow anyone to insert vendors (for registration)
DROP POLICY IF EXISTS "Allow insert for all users on vendors" ON vendors;
CREATE POLICY "Allow insert for all users on vendors"
  ON vendors FOR INSERT
  WITH CHECK (true);

-- Allow anyone to insert items
DROP POLICY IF EXISTS "Allow insert for all users on items" ON items;
CREATE POLICY "Allow insert for all users on items"
  ON items FOR INSERT
  WITH CHECK (true);

-- Allow vendors to update their own data
DROP POLICY IF EXISTS "Allow vendors to update own data" ON vendors;
CREATE POLICY "Allow vendors to update own data"
  ON vendors FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- Allow vendors to update their own items
DROP POLICY IF EXISTS "Allow vendors to update own items" ON items;
CREATE POLICY "Allow vendors to update own items"
  ON items FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- ============================================
-- 5. CREATE FUNCTIONS
-- ============================================

-- Function to increment vendor sales
CREATE OR REPLACE FUNCTION increment_sales(vendor_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE vendors
  SET total_sales = total_sales + 1,
      updated_at = NOW()
  WHERE id = vendor_id;
END;
$$ LANGUAGE plpgsql;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 6. CREATE TRIGGERS
-- ============================================

-- Trigger for vendors table
DROP TRIGGER IF EXISTS update_vendors_updated_at ON vendors;
CREATE TRIGGER update_vendors_updated_at
  BEFORE UPDATE ON vendors
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger for items table
DROP TRIGGER IF EXISTS update_items_updated_at ON items;
CREATE TRIGGER update_items_updated_at
  BEFORE UPDATE ON items
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 7. INSERT SAMPLE DATA (Optional - for testing)
-- ============================================

-- Sample Vendors
INSERT INTO vendors (shop_name, type, phone, location, rating, is_verified, total_sales)
VALUES
  ('Fresh Farms', 'Farm', '9876543210', 'T. Nagar, Chennai', 4.8, true, 120),
  ('City Bakery', 'Bakery', '9876543211', 'Anna Nagar, Chennai', 4.5, true, 85),
  ('Daily Dairy', 'Dairy', '9876543212', 'Adyar, Chennai', 4.2, false, 45),
  ('Metro Mart', 'Grocery', '9876543213', 'Velachery, Chennai', 4.6, true, 95)
ON CONFLICT (phone) DO NOTHING;

-- Sample Items (using vendor IDs from above)
INSERT INTO items (product_name, quantity, expiry_date, vendor_id, category, status)
SELECT 
  'Organic Carrots',
  '10 kg',
  NOW() + INTERVAL '2 days',
  v.id,
  'Vegetables',
  'available'
FROM vendors v WHERE v.phone = '9876543210'
UNION ALL
SELECT 
  'Whole Wheat Bread',
  '20 Loaves',
  NOW() + INTERVAL '1 day',
  v.id,
  'Bakery',
  'available'
FROM vendors v WHERE v.phone = '9876543211'
UNION ALL
SELECT 
  'Full Cream Milk',
  '50 Liters',
  NOW() + INTERVAL '12 hours',
  v.id,
  'Dairy',
  'available'
FROM vendors v WHERE v.phone = '9876543212'
UNION ALL
SELECT 
  'Canned Beans',
  '50 Cans',
  NOW() + INTERVAL '30 days',
  v.id,
  'Packaged',
  'available'
FROM vendors v WHERE v.phone = '9876543213';

-- ============================================
-- 8. VERIFICATION QUERIES
-- ============================================

-- Check tables created
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- Check sample data
-- SELECT * FROM vendors;
-- SELECT * FROM items;

-- Check best sellers
-- SELECT * FROM vendors WHERE total_sales > 50 ORDER BY total_sales DESC;
