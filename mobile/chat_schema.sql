-- ============================================
-- SHARECART CHAT SYSTEM - COMPLETE SETUP
-- ============================================
-- Copy and run this ENTIRE script in Supabase SQL Editor
-- This will set up everything needed for chat to work

-- ============================================
-- STEP 1: DROP EXISTING TABLES (CLEAN START)
-- ============================================

DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS conversations CASCADE;
DROP FUNCTION IF EXISTS update_last_message() CASCADE;
DROP FUNCTION IF EXISTS update_conversations_updated_at() CASCADE;

-- ============================================
-- STEP 2: CREATE CONVERSATIONS TABLE
-- ============================================

CREATE TABLE conversations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  buyer_id UUID REFERENCES vendors(id) ON DELETE CASCADE NOT NULL,
  seller_id UUID REFERENCES vendors(id) ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES items(id) ON DELETE CASCADE NOT NULL,
  product_name TEXT NOT NULL,
  last_message TEXT,
  last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(buyer_id, seller_id, product_id)
);

-- ============================================
-- STEP 3: CREATE MESSAGES TABLE
-- ============================================

CREATE TABLE messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE NOT NULL,
  sender_id UUID REFERENCES vendors(id) ON DELETE CASCADE NOT NULL,
  receiver_id UUID REFERENCES vendors(id) ON DELETE CASCADE NOT NULL,
  message_text TEXT NOT NULL,
  message_type TEXT DEFAULT 'text',
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- STEP 4: CREATE INDEXES
-- ============================================

CREATE INDEX idx_conversations_buyer ON conversations(buyer_id);
CREATE INDEX idx_conversations_seller ON conversations(seller_id);
CREATE INDEX idx_conversations_product ON conversations(product_id);
CREATE INDEX idx_conversations_last_message_at ON conversations(last_message_at DESC);
CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_created_at ON messages(created_at ASC);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_receiver ON messages(receiver_id);

-- ============================================
-- STEP 5: ENABLE RLS
-- ============================================

ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- ============================================
-- STEP 6: CREATE PERMISSIVE POLICIES (WORKING)
-- ============================================

-- Conversations - Allow all operations for now
CREATE POLICY "allow_all_conversations_select" ON conversations FOR SELECT USING (true);
CREATE POLICY "allow_all_conversations_insert" ON conversations FOR INSERT WITH CHECK (true);
CREATE POLICY "allow_all_conversations_update" ON conversations FOR UPDATE USING (true);

-- Messages - Allow all operations for now
CREATE POLICY "allow_all_messages_select" ON messages FOR SELECT USING (true);
CREATE POLICY "allow_all_messages_insert" ON messages FOR INSERT WITH CHECK (true);
CREATE POLICY "allow_all_messages_update" ON messages FOR UPDATE USING (true);

-- ============================================
-- STEP 7: AUTO-UPDATE LAST MESSAGE TRIGGER
-- ============================================

CREATE OR REPLACE FUNCTION update_last_message()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE conversations
  SET
    last_message = NEW.message_text,
    last_message_at = NOW(),
    updated_at = NOW()
  WHERE id = NEW.conversation_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_new_message
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION update_last_message();

-- ============================================
-- STEP 8: VERIFICATION
-- ============================================

-- Check tables exist
SELECT 'Tables created successfully' as status,
  (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'conversations') as conversations_table,
  (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'messages') as messages_table;

-- Check indexes
SELECT 'Indexes created: ' || COUNT(*)::text as status
FROM pg_indexes 
WHERE tablename IN ('conversations', 'messages');

-- Success message
SELECT '✅ CHAT SYSTEM READY!' as status;
