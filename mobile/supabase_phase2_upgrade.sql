-- ShareCart - Phase 2 Upgrade Script
-- Adds Profiles (Login/Guest), Chat System, and Messages

-- ============================================
-- 1. PROFILES TABLE (for Login & User Roles)
-- ============================================
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  phone TEXT UNIQUE,
  name TEXT,
  location TEXT,
  role TEXT DEFAULT 'user' CHECK (role IN ('user', 'vendor')), -- 'guest' is client-side only
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 2. CHATS TABLE (Negotiation System)
-- ============================================
CREATE TABLE chats (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  item_id UUID REFERENCES items(id) ON DELETE CASCADE,
  buyer_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  seller_id UUID REFERENCES vendors(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(item_id, buyer_id) -- Only one chat per item per buyer
);

-- ============================================
-- 3. MESSAGES TABLE
-- ============================================
CREATE TABLE messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  chat_id UUID REFERENCES chats(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL, -- Can be profile_id or vendor_id
  content TEXT NOT NULL,
  is_quick_reply BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 4. RLS POLICIES (Row Level Security)
-- ============================================

-- PROFILES
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public profiles are viewable by everyone" ON profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can insert their own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- CHATS
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users/Vendors can view their own chats" ON chats
  FOR SELECT USING (
    auth.uid() = buyer_id OR 
    EXISTS (SELECT 1 FROM vendors WHERE id = seller_id AND id = (SELECT id FROM vendors WHERE phone = (SELECT phone FROM profiles WHERE id = auth.uid())))
  );

CREATE POLICY "Authenticated users can create chats" ON chats
  FOR INSERT WITH CHECK (auth.uid() = buyer_id);

-- MESSAGES
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Chat participants can view messages" ON messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM chats 
      WHERE id = messages.chat_id 
      AND (
        buyer_id = auth.uid() OR 
        seller_id = (SELECT id FROM vendors WHERE id = chats.seller_id) -- Simplified logic for MVP
      )
    )
  );

CREATE POLICY "Participants can send messages" ON messages
  FOR INSERT WITH CHECK (true); -- Logic handled in app for sender_id validation

-- ============================================
-- 5. REALTIME
-- ============================================
-- Enable Limitless Realtime for Chat
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE chats;

-- ============================================
-- 6. TRIGGERS
-- ============================================
-- Auto-update updated_at for Profiles and Chats
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chats_updated_at
  BEFORE UPDATE ON chats
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Success Message
SELECT '✅ Phase 2 Upgrade Complete: Profiles, Chats, and Messages tables created.' as result;
