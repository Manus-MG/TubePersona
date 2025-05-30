import 'package:flutter/material.dart';

// Models
class PersonaModel {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String systemPrompt;

  const PersonaModel({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.systemPrompt,
  });
}

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}







// MODELS
class TranscriptData {
  final String videoId;
  final String title;
  final String content;
  final DateTime fetchedAt;

  TranscriptData({
    required this.videoId,
    required this.title,
    required this.content,
    required this.fetchedAt,
  });

  Map<String, dynamic> toJson() => {
    'videoId': videoId,
    'title': title,
    'content': content,
    'fetchedAt': fetchedAt.toIso8601String(),
  };

  factory TranscriptData.fromJson(Map<String, dynamic> json) => TranscriptData(
    videoId: json['videoId'],
    title: json['title'],
    content: json['content'],
    fetchedAt: DateTime.parse(json['fetchedAt']),
  );
}

class TranscriptResult {
  final bool success;
  final String? error;
  final List<TranscriptData> transcripts;

  TranscriptResult({
    required this.success,
    this.error,
    required this.transcripts,
  });
}
