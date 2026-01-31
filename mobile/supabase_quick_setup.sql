-- ShareCart - Quick Setup Script
-- Run this in Supabase SQL Editor to create tables and add sample data

-- ============================================
-- 1. DROP EXISTING TABLES (if any)
-- ============================================
DROP TABLE IF EXISTS items CASCADE;
DROP TABLE IF EXISTS vendors CASCADE;
DROP FUNCTION IF EXISTS increment_sales CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column CASCADE;

-- ============================================
-- 2. CREATE TABLES
-- ============================================

CREATE TABLE vendors (
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

CREATE TABLE items (
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
-- 3. CREATE INDEXES
-- ============================================

CREATE INDEX idx_items_vendor_id ON items(vendor_id);
CREATE INDEX idx_items_expiry_date ON items(expiry_date);
CREATE INDEX idx_items_status ON items(status);
CREATE INDEX idx_items_category ON items(category);
CREATE INDEX idx_vendors_total_sales ON vendors(total_sales DESC);

-- ============================================
-- 4. ENABLE RLS
-- ============================================

ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE items ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 5. CREATE RLS POLICIES
-- ============================================

CREATE POLICY "Allow public read on vendors"
  ON vendors FOR SELECT
  USING (true);

CREATE POLICY "Allow public read on items"
  ON items FOR SELECT
  USING (true);

CREATE POLICY "Allow insert on vendors"
  ON vendors FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow insert on items"
  ON items FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow update on vendors"
  ON vendors FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow update on items"
  ON items FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- ============================================
-- 6. CREATE FUNCTIONS
-- ============================================

CREATE OR REPLACE FUNCTION increment_sales(vendor_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE vendors
  SET total_sales = total_sales + 1,
      updated_at = NOW()
  WHERE id = vendor_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 7. CREATE TRIGGERS
-- ============================================

CREATE TRIGGER update_vendors_updated_at
  BEFORE UPDATE ON vendors
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_items_updated_at
  BEFORE UPDATE ON items
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 8. INSERT SAMPLE DATA
-- ============================================

-- Insert Vendors
INSERT INTO vendors (shop_name, type, phone, location, rating, is_verified, total_sales)
VALUES
  ('Fresh Farms', 'Farm', '9876543210', 'T. Nagar, Chennai', 4.8, true, 120),
  ('City Bakery', 'Bakery', '9876543211', 'Anna Nagar, Chennai', 4.5, true, 85),
  ('Daily Dairy', 'Dairy', '9876543212', 'Adyar, Chennai', 4.2, false, 45),
  ('Metro Mart', 'Grocery', '9876543213', 'Velachery, Chennai', 4.6, true, 95),
  ('Green Valley', 'Farm', '9876543214', 'Mylapore, Chennai', 4.7, true, 65);

-- Insert Items (using vendor phone to find IDs)
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
  'Fresh Tomatoes',
  '15 kg',
  NOW() + INTERVAL '3 days',
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
  'Chocolate Donuts',
  '30 pieces',
  NOW() + INTERVAL '12 hours',
  v.id,
  'Bakery',
  'available'
FROM vendors v WHERE v.phone = '9876543211'

UNION ALL

SELECT 
  'Full Cream Milk',
  '50 Liters',
  NOW() + INTERVAL '8 hours',
  v.id,
  'Dairy',
  'available'
FROM vendors v WHERE v.phone = '9876543212'

UNION ALL

SELECT 
  'Fresh Cheese',
  '5 kg',
  NOW() + INTERVAL '5 days',
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
FROM vendors v WHERE v.phone = '9876543213'

UNION ALL

SELECT 
  'Fresh Spinach',
  '8 kg',
  NOW() + INTERVAL '1 day',
  v.id,
  'Vegetables',
  'available'
FROM vendors v WHERE v.phone = '9876543214';

-- ============================================
-- 9. VERIFY DATA
-- ============================================

-- Check vendors
SELECT 'Vendors Created:' as info, COUNT(*) as count FROM vendors;

-- Check items
SELECT 'Items Created:' as info, COUNT(*) as count FROM items;

-- Check best sellers
SELECT 'Best Sellers:' as info, shop_name, total_sales 
FROM vendors 
WHERE total_sales > 50 
ORDER BY total_sales DESC;

-- Success message
SELECT '✅ Database setup complete! You now have:' as message
UNION ALL
SELECT '   - 5 vendors with ratings and sales'
UNION ALL
SELECT '   - 8 surplus items across categories'
UNION ALL
SELECT '   - All tables, indexes, and policies configured'
UNION ALL
SELECT '   - Ready to use with Flutter app!';
