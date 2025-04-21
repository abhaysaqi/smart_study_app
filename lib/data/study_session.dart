import 'dart:convert';
import 'package:uuid/uuid.dart';

/// Enum representing the type of study session
enum SessionType {
  questionSolver,
  writingAssistant,
  quiz,
  codeHelper,
  summary
}

/// Model class for representing a study session
class StudySession {
  final String id;
  final SessionType type;
  final String title;
  final String content;
  final String? response;
  final DateTime createdAt;
  final bool isFavorite;

  StudySession({
    String? id,
    required this.type,
    required this.title,
    required this.content,
    this.response,
    DateTime? createdAt,
    this.isFavorite = false,
  })
      : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Convert to a Map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'title': title,
      'content': content,
      'response': response,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isFavorite': isFavorite,
    };
  }

  /// Create a StudySession from a Map (JSON deserialization)
  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'],
      type: SessionType.values[map['type']],
      title: map['title'],
      content: map['content'],
      response: map['response'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  /// Create a copy of this StudySession with modified fields
  StudySession copyWith({
    String? id,
    SessionType? type,
    String? title,
    String? content,
    String? response,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return StudySession(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      response: response ?? this.response,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // String representation for debugging
  @override
  String toString() {
    return 'StudySession{id: $id, type: $type, title: $title, createdAt: $createdAt}';
  }
}

/// Helper class for managing study sessions with shared_preferences
class StudySessionManager {
  static const String _storageKey = 'study_sessions';

  /// Save a list of study sessions to storage
  static Future<bool> saveSessions(List<StudySession> sessions) async {
    try {
      final List<Map<String, dynamic>> sessionMaps = 
          sessions.map((session) => session.toMap()).toList();
      // In an actual implementation, this would use shared_preferences
      // For now, we're just returning true
      return true;
    } catch (e) {
      print('Error saving sessions: $e');
      return false;
    }
  }

  /// Load study sessions from storage
  static Future<List<StudySession>> loadSessions() async {
    try {
      // In an actual implementation, this would use shared_preferences
      // For simplicity, we're returning an empty list
      return [];
    } catch (e) {
      print('Error loading sessions: $e');
      return [];
    }
  }

  /// Add a session to storage
  static Future<bool> addSession(StudySession session) async {
    try {
      final List<StudySession> existingSessions = await loadSessions();
      existingSessions.add(session);
      return await saveSessions(existingSessions);
    } catch (e) {
      print('Error adding session: $e');
      return false;
    }
  }

  /// Delete a session from storage
  static Future<bool> deleteSession(String sessionId) async {
    try {
      final List<StudySession> existingSessions = await loadSessions();
      existingSessions.removeWhere((session) => session.id == sessionId);
      return await saveSessions(existingSessions);
    } catch (e) {
      print('Error deleting session: $e');
      return false;
    }
  }

  /// Get a session by ID
  static Future<StudySession?> getSessionById(String sessionId) async {
    try {
      final List<StudySession> existingSessions = await loadSessions();
      return existingSessions.firstWhere(
        (session) => session.id == sessionId,
        orElse: () => throw Exception('Session not found'),
      );
    } catch (e) {
      print('Error getting session: $e');
      return null;
    }
  }

  /// Toggle the favorite status of a session
  static Future<bool> toggleFavorite(String sessionId) async {
    try {
      final List<StudySession> existingSessions = await loadSessions();
      final int index = existingSessions.indexWhere(
        (session) => session.id == sessionId,
      );
      
      if (index >= 0) {
        final session = existingSessions[index];
        existingSessions[index] = session.copyWith(
          isFavorite: !session.isFavorite,
        );
        return await saveSessions(existingSessions);
      }
      return false;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }
}