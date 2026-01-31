import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class ChatService {
  final _supabase = Supabase.instance.client;

  /// Get existing conversation or create new one
  Future<Conversation?> getOrCreateConversation({
    required String buyerId,
    required String sellerId,
    required String productId,
    required String productName,
  }) async {
    try {
      print('Looking for conversation: buyer=$buyerId, seller=$sellerId, product=$productId');
      
      // Try to find existing conversation (check both directions)
      final existing = await _supabase
          .from('conversations')
          .select('*, buyers:buyer_id(*), sellers:seller_id(*)')
          .eq('buyer_id', buyerId)
          .eq('seller_id', sellerId)
          .eq('product_id', productId)
          .maybeSingle();

      if (existing != null) {
        print('Found existing conversation: ${existing['id']}');
        return Conversation.fromSupabase(existing);
      }

      // Also check reversed (in case roles were swapped)
      final reversed = await _supabase
          .from('conversations')
          .select('*, buyers:buyer_id(*), sellers:seller_id(*)')
          .eq('buyer_id', sellerId)
          .eq('seller_id', buyerId)
          .eq('product_id', productId)
          .maybeSingle();

      if (reversed != null) {
        print('Found reversed conversation: ${reversed['id']}');
        return Conversation.fromSupabase(reversed);
      }

      print('No existing conversation found, creating new one');
      
      // Create new conversation
      final response = await _supabase
          .from('conversations')
          .insert({
            'buyer_id': buyerId,
            'seller_id': sellerId,
            'product_id': productId,
            'product_name': productName,
          })
          .select('*, buyers:buyer_id(*), sellers:seller_id(*)')
          .single();

      print('Created new conversation: ${response['id']}');
      return Conversation.fromSupabase(response);
    } catch (e, stackTrace) {
      print('Error getting/creating conversation: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Send a message and update conversation
  Future<bool> sendMessage(ChatMessage message) async {
    try {
      print('Sending message: ${message.messageText}');
      print('Conversation ID: ${message.conversationId}');
      print('Sender ID: ${message.senderId}');
      print('Receiver ID: ${message.receiverId}');
      
      // Insert message
      final insertedMessage = await _supabase
          .from('messages')
          .insert(message.toJson())
          .select()
          .single();
      
      print('Message inserted successfully: ${insertedMessage['id']}');

      // Update conversation last_message
      await _supabase
          .from('conversations')
          .update({
            'last_message': message.messageText,
            'last_message_at': DateTime.now().toIso8601String(),
          })
          .eq('id', message.conversationId);

      print('Conversation updated successfully');
      return true;
    } catch (e, stackTrace) {
      print('Error sending message: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Fetch all conversations for a user
  Future<List<Conversation>> fetchConversations(String userId) async {
    try {
      final response = await _supabase
          .from('conversations')
          .select('*, buyers:buyer_id(*), sellers:seller_id(*)')
          .or('buyer_id.eq.$userId,seller_id.eq.$userId')
          .order('last_message_at', ascending: false);

      return (response as List)
          .map((c) => Conversation.fromSupabase(c))
          .toList();
    } catch (e) {
      print('Error fetching conversations: $e');
      return [];
    }
  }

  /// Fetch all messages in a conversation
  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((m) => ChatMessage.fromSupabase(m))
          .toList();
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .eq('receiver_id', userId)
          .eq('is_read', false);
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  /// Get unread message count for a conversation
  Future<int> getUnreadCount(String conversationId, String userId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select('id')
          .eq('conversation_id', conversationId)
          .eq('receiver_id', userId)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
}
