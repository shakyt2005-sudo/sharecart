import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final _chatService = ChatService();

  List<Conversation> _conversations = [];
  List<ChatMessage> _currentMessages = [];
  Conversation? _currentConversation;
  bool _isLoading = false;
  String? _error;

  List<Conversation> get conversations => _conversations;
  List<ChatMessage> get currentMessages => _currentMessages;
  Conversation? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all conversations for a user
  Future<void> loadConversations(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _chatService.fetchConversations(userId);
    } catch (e) {
      _error = 'Failed to load conversations';
      print('Error loading conversations: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Open or create a conversation
  Future<Conversation?> openConversation({
    required String buyerId,
    required String sellerId,
    required String productId,
    required String productName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentConversation = await _chatService.getOrCreateConversation(
        buyerId: buyerId,
        sellerId: sellerId,
        productId: productId,
        productName: productName,
      );

      if (_currentConversation != null) {
        await loadMessages(_currentConversation!.id);
      }
    } catch (e) {
      _error = 'Failed to open conversation';
      print('Error opening conversation: $e');
    }

    _isLoading = false;
    notifyListeners();
    return _currentConversation;
  }

  /// Load messages for a conversation
  Future<void> loadMessages(String conversationId) async {
    try {
      _currentMessages = await _chatService.fetchMessages(conversationId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load messages';
      print('Error loading messages: $e');
    }
  }

  /// Send a message
  Future<bool> sendMessage({
    required String messageText,
    required String senderId,
    required String receiverId,
  }) async {
    if (_currentConversation == null) {
      _error = 'No active conversation';
      print('ERROR: No active conversation when trying to send message');
      return false;
    }

    try {
      print('ChatProvider: Sending message...');
      print('Current conversation ID: ${_currentConversation!.id}');
      
      final message = ChatMessage(
        id: '',
        conversationId: _currentConversation!.id,
        senderId: senderId,
        receiverId: receiverId,
        messageText: messageText,
        messageType: 'text',
        isRead: false,
        createdAt: DateTime.now(),
      );

      final success = await _chatService.sendMessage(message);
      
      if (success) {
        print('ChatProvider: Message sent successfully, reloading messages...');
        // Reload messages to get the new one with proper ID
        await loadMessages(_currentConversation!.id);
        return true;
      } else {
        print('ChatProvider: ChatService returned false');
      }
      
      return false;
    } catch (e, stackTrace) {
      _error = 'Failed to send message';
      print('ChatProvider Error sending message: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Mark messages as read
  Future<void> markAsRead(String conversationId, String userId) async {
    try {
      await _chatService.markMessagesAsRead(conversationId, userId);
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  /// Clear current conversation
  void clearCurrentConversation() {
    _currentConversation = null;
    _currentMessages = [];
    notifyListeners();
  }

  /// Refresh conversations (for pull-to-refresh)
  Future<void> refreshConversations(String userId) async {
    await loadConversations(userId);
  }
}
