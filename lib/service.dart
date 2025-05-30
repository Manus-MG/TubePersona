import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model.dart';
import 'env.dart';
import 'package:http/http.dart' as http;
// SERVICES
class TranscriptService {

  static final Map<String, String> _headers = {
    'Cookie': AppConstants.headers
  };

  static Future<TranscriptData> fetchTranscript(String videoId) async {
    try {
      debugPrint('Fetching transcript for videoId: $videoId');

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}?platform=youtube&video_id=$videoId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw ApiException(
          'Failed to fetch transcript',
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body);

      if (data['code'] != 100000 || data['data'] == null) {
        throw TranscriptException('No transcript data available', videoId: videoId);
      }

      final transcripts = data['data']['transcripts'];
      if (transcripts == null || transcripts['en_auto'] == null) {
        throw TranscriptException('No English transcript available', videoId: videoId);
      }

      final customTranscripts = transcripts['en_auto']['custom'] as List?;
      if (customTranscripts == null || customTranscripts.isEmpty) {
        throw TranscriptException('Empty transcript data', videoId: videoId);
      }

      // Process and format transcript
      final transcriptBuffer = StringBuffer();
      for (var transcript in customTranscripts) {
        final timestamp = transcript['start'] ?? '0:00';
        final text = transcript['text'] ?? '';
        if (text.trim().isNotEmpty) {
          transcriptBuffer.writeln('[$timestamp] $text');
        }
      }

      final transcriptContent = transcriptBuffer.toString();
      if (transcriptContent.isEmpty) {
        throw TranscriptException('No valid transcript content found', videoId: videoId);
      }

      return TranscriptData(
        videoId: videoId,
        title: data['data']['title'] ?? 'Unknown Video',
        content: transcriptContent,
        fetchedAt: DateTime.now(),
      );

    } on TranscriptException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw TranscriptException('Unexpected error: $e', videoId: videoId);
    }
  }

  static String extractVideoId(String url) {
    if (url.isEmpty || url.contains(' ')) return '';

    Uri uri;
    try {
      uri = Uri.parse(url);
    } catch (e) {
      return '';
    }

    if (!['https', 'http'].contains(uri.scheme)) {
      return '';
    }

    // Check for standard YouTube URLs (watch, live)
    if (['youtube.com', 'www.youtube.com', 'm.youtube.com'].contains(uri.host) &&
        uri.pathSegments.isNotEmpty) {
      // Watch URL (youtube.com/watch?v=ID)
      if ((uri.pathSegments.first == 'watch' || uri.pathSegments.first == 'live') &&
          uri.queryParameters.containsKey('v')) {
        final videoId = uri.queryParameters['v']!;
        return _isValidId(videoId) ? videoId : '';
      }

      // Live URL (youtube.com/live/ID)
      if (uri.pathSegments.first == 'live' && uri.pathSegments.length >= 2) {
        final videoId = uri.pathSegments[1];
        return _isValidId(videoId) ? videoId : '';
      }

      // Shorts URL (youtube.com/shorts/ID)
      if (uri.pathSegments.first == 'shorts' && uri.pathSegments.length >= 2) {
        final videoId = uri.pathSegments[1];
        return _isValidId(videoId) ? videoId : '';
      }

      // Embed URL (youtube.com/embed/ID)
      if (uri.pathSegments.first == 'embed' && uri.pathSegments.length >= 2) {
        final videoId = uri.pathSegments[1];
        return _isValidId(videoId) ? videoId : '';
      }
    }

    // Short URL (youtu.be/ID)
    if (uri.host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
      final videoId = uri.pathSegments.first;
      return _isValidId(videoId) ? videoId : '';
    }

    return '';
  }

  static bool _isValidId(String id) => RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(id);


  static Future<TranscriptResult> fetchMultipleTranscripts(List<String> urls) async {
    final List<TranscriptData> transcripts = [];
    final List<String> errors = [];

    for (int i = 0; i < urls.length; i++) {
      try {
        final videoId = extractVideoId(urls[i]);
        if (videoId.isEmpty) {
          errors.add('Invalid URL format: ${urls[i]}');
          continue;
        }

        final transcript = await fetchTranscript(videoId);
        transcripts.add(transcript);

      } catch (e) {
        errors.add('Video ${i + 1}: $e');
      }
    }

    return TranscriptResult(
      success: transcripts.isNotEmpty,
      error: errors.isNotEmpty ? errors.join('\n') : null,
      transcripts: transcripts,
    );
  }
}

class SharedPreferencesService {
  static const String _transcriptKey = 'youtube_transcripts_v2';
  static const String _transcriptMetaKey = 'transcript_metadata';

  static Future<void> saveTranscripts(List<TranscriptData> transcripts) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save transcript data
      final transcriptJson = transcripts.map((t) => t.toJson()).toList();
      await prefs.setString(_transcriptKey, jsonEncode(transcriptJson));

      // Save metadata
      final metadata = {
        'count': transcripts.length,
        'lastUpdated': DateTime.now().toIso8601String(),
        'totalLength': transcripts.fold<int>(0, (sum, t) => sum + t.content.length),
      };
      await prefs.setString(_transcriptMetaKey, jsonEncode(metadata));

      debugPrint('Saved ${transcripts.length} transcripts to SharedPreferences');
    } catch (e) {
      throw Exception('Failed to save transcripts: $e');
    }
  }

  static Future<List<TranscriptData>> getTranscripts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transcriptString = prefs.getString(_transcriptKey);

      if (transcriptString == null || transcriptString.isEmpty) {
        return [];
      }

      final List<dynamic> transcriptJson = jsonDecode(transcriptString);
      return transcriptJson.map((json) => TranscriptData.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading transcripts: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getTranscriptMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metaString = prefs.getString(_transcriptMetaKey);

      if (metaString == null) return null;

      return jsonDecode(metaString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error loading transcript metadata: $e');
      return null;
    }
  }

  static Future<void> clearTranscripts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_transcriptKey);
    await prefs.remove(_transcriptMetaKey);
  }

  static Future<String> getFormattedTranscriptsForAI() async {
    final transcripts = await getTranscripts();
    if (transcripts.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('=== YOUTUBE VIDEO TRANSCRIPTS FOR PERSONA ANALYSIS ===\n');

    for (int i = 0; i < transcripts.length; i++) {
      final transcript = transcripts[i];
      buffer.writeln('--- Video ${i + 1}: ${transcript.title} ---');
      buffer.writeln('Video ID: ${transcript.videoId}');
      buffer.writeln('Fetched: ${transcript.fetchedAt.toString()}');
      buffer.writeln('Content:');

      // Limit content length to prevent API limits
      String content = transcript.content;
      if (content.length > AppConstants.maxTranscriptLength ~/ transcripts.length) {
        content = content.substring(0, AppConstants.maxTranscriptLength ~/ transcripts.length) + '...[truncated]';
      }

      buffer.writeln(content);
      buffer.writeln('\n${'=' * 50}\n');
    }

    return buffer.toString();
  }
}

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  final String _apiKey;

  GeminiService({required String apiKey}) : _apiKey = apiKey;

  Future<String> generateResponse({
    required String systemPrompt,
    required String userMessage,
    required List<ChatMessage> chatHistory,
  }) async {
    try {
      // Replace transcript placeholder with actual data
      String finalSystemPrompt = systemPrompt;
      if (systemPrompt.contains(AppConstants.transcriptPlaceholder)) {
        final transcriptData = await SharedPreferencesService.getFormattedTranscriptsForAI();
        finalSystemPrompt = systemPrompt.replaceAll(AppConstants.transcriptPlaceholder, transcriptData);
      }

      // Build conversation context
      final conversationBuffer = StringBuffer();
      conversationBuffer.writeln(finalSystemPrompt);
      conversationBuffer.writeln('\n=== CONVERSATION HISTORY ===');

      // Add recent chat history
      final recentHistory = chatHistory.reversed.take(AppConstants.maxChatHistory).toList().reversed;
      for (var message in recentHistory) {
        conversationBuffer.writeln('${message.isUser ? 'Human' : 'Assistant'}: ${message.content}');
      }

      conversationBuffer.writeln('\n=== CURRENT MESSAGE ===');
      conversationBuffer.writeln('Human: $userMessage');
      conversationBuffer.writeln('\nAssistant:');

      final requestBody = {
        "contents": [
          {
            "parts": [
              {
                "text": conversationBuffer.toString()
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.9,
          "topK": 1,
          "topP": 1,
          "maxOutputTokens": 2048,
        }
      };

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw ApiException(
          'Failed to generate response',
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body);

      if (data['candidates'] == null || data['candidates'].isEmpty) {
        throw ApiException('No response generated from AI');
      }

      final content = data['candidates'][0]['content']['parts'][0]['text'];
      return content?.toString() ?? 'Sorry, I could not generate a response.';

    } catch (e) {
      debugPrint('Error generating AI response: $e');
      throw ApiException('Failed to generate response: $e');
    }
  }
}


// EXCEPTIONS
class TranscriptException implements Exception {
  final String message;
  final String? videoId;

  TranscriptException(this.message, {this.videoId});

  @override
  String toString() => 'TranscriptException: $message${videoId != null ? ' (Video ID: $videoId)' : ''}';
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
