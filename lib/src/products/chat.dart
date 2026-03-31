import '../http.dart';
import 'pos.dart' show ListResponse;

class Conversation {
  final String id, status, inboxId, contactId, createdAt, updatedAt;
  final String? assigneeId, subject;
  Conversation.fromJson(Map<String, dynamic> j)
      : id = j['id'], status = j['status'], inboxId = j['inbox_id'],
        contactId = j['contact_id'], createdAt = j['created_at'], updatedAt = j['updated_at'],
        assigneeId = j['assignee_id'], subject = j['subject'];
}

class ChatMessage {
  final String id, conversationId, content, type, authorType, createdAt;
  final String? authorId;
  ChatMessage.fromJson(Map<String, dynamic> j)
      : id = j['id'], conversationId = j['conversation_id'], content = j['content'],
        type = j['type'], authorType = j['author_type'], createdAt = j['created_at'],
        authorId = j['author_id'];
}

class Agent {
  final String id, name, email, role, createdAt, updatedAt;
  final bool isActive;
  Agent.fromJson(Map<String, dynamic> j)
      : id = j['id'], name = j['name'], email = j['email'], role = j['role'],
        createdAt = j['created_at'], updatedAt = j['updated_at'], isActive = j['is_active'];
}

class Contact {
  final String id, name, createdAt, updatedAt;
  final String? email, phone;
  Contact.fromJson(Map<String, dynamic> j)
      : id = j['id'], name = j['name'], createdAt = j['created_at'], updatedAt = j['updated_at'],
        email = j['email'], phone = j['phone'];
}

class Inbox {
  final String id, name, channelType, createdAt;
  final bool isEnabled;
  Inbox.fromJson(Map<String, dynamic> j)
      : id = j['id'], name = j['name'], channelType = j['channel_type'],
        createdAt = j['created_at'], isEnabled = j['is_enabled'];
}

class ChatClient {
  final XebokiHttpClient _http;
  final void Function(RateLimitInfo) _onRateLimit;
  ChatClient(this._http, this._onRateLimit);

  Future<ListResponse<Conversation>> listConversations({
    String? status, String? inboxId, String? assigneeId, int? limit,
  }) async {
    final (data, rl) = await _http.request('GET', '/v1/chat/conversations',
        query: {'status': status, 'inbox_id': inboxId, 'assignee_id': assigneeId, 'limit': limit?.toString()},
        fromJson: (j) => ListResponse<Conversation>(
          data: (j['data'] as List).map((e) => Conversation.fromJson(e)).toList(),
          total: j['total'], limit: j['limit'], offset: j['offset'],
        ));
    _onRateLimit(rl);
    return data;
  }

  Future<Conversation> createConversation(Map<String, dynamic> params) async {
    final (data, rl) = await _http.request('POST', '/v1/chat/conversations',
        body: params, fromJson: (j) => Conversation.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<Conversation> getConversation(String id) async {
    final (data, rl) = await _http.request('GET', '/v1/chat/conversations/$id',
        fromJson: (j) => Conversation.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<Conversation> updateConversation(String id, Map<String, dynamic> params) async {
    final (data, rl) = await _http.request('PATCH', '/v1/chat/conversations/$id',
        body: params, fromJson: (j) => Conversation.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<ListResponse<ChatMessage>> listMessages(String conversationId, {int? limit}) async {
    final (data, rl) = await _http.request('GET', '/v1/chat/conversations/$conversationId/messages',
        query: {'limit': limit?.toString()},
        fromJson: (j) => ListResponse<ChatMessage>(
          data: (j['data'] as List).map((e) => ChatMessage.fromJson(e)).toList(),
          total: j['total'], limit: j['limit'], offset: j['offset'],
        ));
    _onRateLimit(rl);
    return data;
  }

  Future<ChatMessage> sendMessage(String conversationId, Map<String, dynamic> params) async {
    final (data, rl) = await _http.request('POST', '/v1/chat/conversations/$conversationId/messages',
        body: params, fromJson: (j) => ChatMessage.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<ListResponse<Agent>> listAgents({int? limit}) async {
    final (data, rl) = await _http.request('GET', '/v1/chat/agents',
        query: {'limit': limit?.toString()},
        fromJson: (j) => ListResponse<Agent>(
          data: (j['data'] as List).map((e) => Agent.fromJson(e)).toList(),
          total: j['total'], limit: j['limit'], offset: j['offset'],
        ));
    _onRateLimit(rl);
    return data;
  }

  Future<Agent> createAgent(Map<String, dynamic> params) async {
    final (data, rl) = await _http.request('POST', '/v1/chat/agents',
        body: params, fromJson: (j) => Agent.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<ListResponse<Contact>> listContacts({String? search, int? limit}) async {
    final (data, rl) = await _http.request('GET', '/v1/chat/contacts',
        query: {'search': search, 'limit': limit?.toString()},
        fromJson: (j) => ListResponse<Contact>(
          data: (j['data'] as List).map((e) => Contact.fromJson(e)).toList(),
          total: j['total'], limit: j['limit'], offset: j['offset'],
        ));
    _onRateLimit(rl);
    return data;
  }

  Future<Contact> createContact(Map<String, dynamic> params) async {
    final (data, rl) = await _http.request('POST', '/v1/chat/contacts',
        body: params, fromJson: (j) => Contact.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<Contact> getContact(String id) async {
    final (data, rl) = await _http.request('GET', '/v1/chat/contacts/$id',
        fromJson: (j) => Contact.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<ListResponse<Inbox>> listInboxes() async {
    final (data, rl) = await _http.request('GET', '/v1/chat/inboxes',
        fromJson: (j) => ListResponse<Inbox>(
          data: (j['data'] as List).map((e) => Inbox.fromJson(e)).toList(),
          total: j['total'], limit: j['limit'], offset: j['offset'],
        ));
    _onRateLimit(rl);
    return data;
  }
}
