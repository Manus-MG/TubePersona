import 'package:flutter/material.dart';
import 'package:persona/constants.dart';
import 'package:persona/widgets.dart';
import 'model.dart';
import 'service.dart';
import 'env.dart';


// PERSONA DATA
class PersonaData {
  static const String hiteshSystemPrompt = """
You are an AI Persona of Hitesh Choudhary. You have to answer every question as if you are Hitesh Choudhary and sound natural with a human tone. Use the below examples to understand how Hitesh talks and his background.

Background:
Hitesh Choudhary is a popular Indian YouTuber, educator, and software developer who teaches programming and web development. He is known for his "Chai aur Code" series and speaks in a mix of Hindi and English. He is very passionate about teaching and helping students learn to code.

Speaking Style Analysis:
- Uses "जी हाँ", "अच्छा", "ठीक है", "ओके" frequently
- Signature phrase "चाय और कोड" (Chai aur Code)
- Mixes Hindi and English naturally (Hinglish)
- Very encouraging and supportive teaching tone
- Uses "आप सभी का स्वागत है" for greetings
- Often says "बहुत ही मजा आ रहा है", "थैंक यू सो मच"
- Explains technical concepts in Hindi/Hinglish
- Patient, step-by-step teaching approach
- Uses "बेटा" affectionately for students

Real Conversation Examples:
${Constants.hiteshConversationExamples}

Instructions:
- Study the conversation patterns above carefully
- Mimic Hitesh's exact speaking style, tone, and phrase usage
- Maintain his encouraging, teacher-like personality
- Use the same Hindi-English mix and expressions
- Always respond as if you are Hitesh himself
- Reply always in English language
""";

  static const String piyushSystemPrompt = """
You are an AI Persona of Piyush Garg. You have to answer every question as if you are Piyush Garg and sound natural with a human tone. Use the below examples to understand how Piyush talks and his background.

Background:
Piyush Garg is a popular tech YouTuber and educator from India who creates content about web development, programming, and technology. He is known for his practical approach to teaching and his energetic personality.

Speaking Style Analysis:
- Very energetic and enthusiastic personality
- Uses "गाइस" (guys) very frequently
- Signature phrases "ओके सो", "बहुत बढ़िया", "लेट मी नो"
- More English-heavy than Hitesh but still uses Hindi
- Direct and to-the-point communication style
- Uses "मेरे को" instead of "मुझे"
- Interactive with audience - "थैंक यू सो मच"
- Often repeats "हेलो हेलो हेलो"
- Uses "आर वी लाइव" when starting streams

Real Conversation Examples:
${Constants.piyushConversationExamples}

Instructions:
- Study the conversation patterns above carefully
- Mimic Piyush's exact speaking style, energy, and expressions
- Maintain his energetic, direct personality
- Use the same Hindi-English mix and signature phrases
- Always respond as if you are Piyush himself
- Reply always in English language
""";

  static String buildCustomYouTuberPrompt() {
    return """
You are an AI assistant that mimics the exact speaking style, personality, and teaching approach of the YouTuber(s) from the provided video transcripts below.

CRITICAL INSTRUCTIONS:
1. Study the conversation patterns, phrases, and speaking style from the transcripts
2. Mimic the exact tone, energy, expressions, and mannerisms used in the videos
3. Maintain the same teaching approach and personality traits
4. Use similar technical explanations, examples, and analogies
5. Keep the same level of enthusiasm, energy, and engagement
6. Copy the exact way they address their audience
7. Use the same catchphrases, signature expressions, and speech patterns
8. Always respond as if you are the YouTuber from these videos
9. Reply in English language but maintain their natural speaking style
10. Be helpful, educational, and engaging just like they are in their videos

YOUTUBE VIDEO TRANSCRIPTS FOR PERSONA ANALYSIS:
${AppConstants.transcriptPlaceholder}

Remember: Your responses should sound exactly like the YouTuber(s) from the transcripts above. Study their personality, teaching style, and unique expressions carefully.
""";
  }

  static final List<PersonaModel> personas = [
    PersonaModel(
      name: 'Hitesh Persona',
      description: 'Chai aur Code - Learn with Hitesh\'s teaching style',
      icon: Icons.code,
      color: Colors.blue,
      systemPrompt: hiteshSystemPrompt,
    ),
    PersonaModel(
      name: 'Piyush Persona',
      description: 'Energetic tech content and programming insights',
      icon: Icons.computer,
      color: Colors.green,
      systemPrompt: piyushSystemPrompt,
    ),
    PersonaModel(
      name: 'Custom YouTuber Persona',
      description: 'Create persona from your favorite YouTube videos',
      icon: Icons.play_circle_filled,
      color: Colors.purple,
      systemPrompt: buildCustomYouTuberPrompt(),
    ),
  ];
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _onPersonaTap(BuildContext context, PersonaModel persona) {
    if (persona.name == 'Custom YouTuber Persona') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const YouTubeTranscriptScreen(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(persona: persona),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Persona Hub',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Your AI Mentor',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chat with AI personas that mimic your favorite tech YouTubers',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: PersonaData.personas.length,
                itemBuilder: (context, index) {
                  final persona = PersonaData.personas[index];
                  return PersonaCard(
                    persona: persona,
                    onTap: () => _onPersonaTap(context, persona),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Powered by Google Gemini AI',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final PersonaModel persona;

  const ChatScreen({super.key, required this.persona});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late final GeminiService _geminiService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService(apiKey: AppConstants.geminiApiKey);
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    String welcomeMessage;
    switch (widget.persona.name) {
      case 'Hitesh Persona':
        welcomeMessage = "हां जी स्वागत है आप सभी का! मैं हूं Hitesh और आज हम करेंगे चाय और कोड! बताइए क्या सीखना है आज?";
        break;
      case 'Piyush Persona':
        welcomeMessage = "हेलो हेलो हेलो! ओके सो गाइस, आई एम Piyush और आज हम लर्न करेंगे कुछ नया। लेट मी नो व्हाट यू वांट टू लर्न!";
        break;
      case 'Custom YouTuber Persona':
        welcomeMessage = "Hello! I'm your custom AI persona based on the YouTube videos you selected. I'll respond in the style and personality of those creators. What would you like to learn or discuss today?";
        break;
      default:
        welcomeMessage = "Hello! I'm your AI assistant ready to help you with programming and tech questions. What would you like to learn today?";
    }

    setState(() {
      _messages.add(ChatMessage(
        content: welcomeMessage,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(
        content: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await _geminiService.generateResponse(
        systemPrompt: widget.persona.systemPrompt,
        userMessage: userMessage,
        chatHistory: _messages,
      );

      setState(() {
        _messages.add(ChatMessage(
          content: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          content: "I apologize, but I encountered an error while processing your request. Please try again or check your internet connection.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(widget.persona.icon, color: widget.persona.color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.persona.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: widget.persona.color.withOpacity(0.1),
        actions: [
          if (widget.persona.name == 'Custom YouTuber Persona')
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showTranscriptInfo(),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return const ChatLoadingIndicator();
                }
                
                final message = _messages[index];
                return ChatBubble(
                  message: message,
                  personaColor: widget.persona.color,
                );
              },
            ),
          ),
          ChatInputField(
            controller: _messageController,
            onSend: _sendMessage,
            isLoading: _isLoading,
            personaColor: widget.persona.color,
          ),
        ],
      ),
    );
  }

  void _showTranscriptInfo() async {
    final metadata = await SharedPreferencesService.getTranscriptMetadata();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transcript Information'),
        content: metadata != null 
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Videos: ${metadata['count']}'),
                Text('Last Updated: ${DateTime.parse(metadata['lastUpdated']).toString().split('.')[0]}'),
                Text('Total Characters: ${metadata['totalLength']}'),
              ],
            )
          : const Text('No transcript data found'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class YouTubeTranscriptScreen extends StatefulWidget {
  const YouTubeTranscriptScreen({super.key});

  @override
  State<YouTubeTranscriptScreen> createState() => _YouTubeTranscriptScreenState();
}

class _YouTubeTranscriptScreenState extends State<YouTubeTranscriptScreen> {
  final List<TextEditingController> _urlControllers = [TextEditingController()];
  final ScrollController _scrollController = ScrollController();
  TranscriptStatus _status = TranscriptStatus.initial;
  String _statusMessage = '';
  List<TranscriptData> _existingTranscripts = [];

  @override
  void initState() {
    super.initState();
    _loadExistingTranscripts();
  }

  Future<void> _loadExistingTranscripts() async {
    final transcripts = await SharedPreferencesService.getTranscripts();
    final metadata = await SharedPreferencesService.getTranscriptMetadata();
    
    setState(() {
      _existingTranscripts = transcripts;
      if (transcripts.isNotEmpty) {
        _statusMessage = 'Found ${transcripts.length} existing transcripts';
        _status = TranscriptStatus.success;
      }
    });
  }

  void _addUrlField() {
    setState(() {
      _urlControllers.add(TextEditingController());
    });
    _scrollToBottom();
  }

  void _removeUrlField(int index) {
    if (_urlControllers.length > 1) {
      setState(() {
        _urlControllers[index].dispose();
        _urlControllers.removeAt(index);
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _fetchTranscripts() async {
    final validUrls = _urlControllers
        .map((controller) => controller.text.trim())
        .where((url) => url.isNotEmpty)
        .toList();

    if (validUrls.isEmpty) {
      _showSnackBar('Please enter at least one YouTube URL', Colors.orange);
      return;
    }

    setState(() {
      _status = TranscriptStatus.loading;
      _statusMessage = 'Fetching transcripts...';
    });

    try {
      final result = await TranscriptService.fetchMultipleTranscripts(validUrls);
      
      if (result.success) {
        await SharedPreferencesService.saveTranscripts(result.transcripts);
        
        setState(() {
          _existingTranscripts = result.transcripts;
          _status = TranscriptStatus.success;
          _statusMessage = 'Successfully fetched ${result.transcripts.length} transcripts';
        });
        
        _showSnackBar('Transcripts saved successfully!', Colors.green);
        
        if (result.error != null) {
          _showErrorDialog('Partial Success', result.error!);
        }
        
        // Auto-navigate to chat after successful fetch
        _navigateToChat();
        
      } else {
        setState(() {
          _status = TranscriptStatus.error;
          _statusMessage = 'Failed to fetch any transcripts';
        });
        
        _showErrorDialog('Fetch Failed', result.error ?? 'Unknown error occurred');
      }
      
    } catch (e) {
      setState(() {
        _status = TranscriptStatus.error;
        _statusMessage = 'Error: $e';
      });
      
      _showSnackBar('Failed to fetch transcripts', Colors.red);
    }
  }

  void _navigateToChat() {
    final customPersona = PersonaModel(
      name: 'Custom YouTuber Persona',
      description: 'Based on ${_existingTranscripts.length} YouTube videos',
      icon: Icons.play_circle_filled,
      color: Colors.purple,
      systemPrompt: PersonaData.buildCustomYouTuberPrompt(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(persona: customPersona),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearTranscripts() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Transcripts'),
        content: const Text('Are you sure you want to clear all saved transcripts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SharedPreferencesService.clearTranscripts();
      setState(() {
        _existingTranscripts = [];
        _status = TranscriptStatus.initial;
        _statusMessage = 'Transcripts cleared';
      });
      _showSnackBar('Transcripts cleared successfully!', Colors.orange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Transcript Fetcher'),
        backgroundColor: Colors.purple.withOpacity(0.1),
        actions: [
          if (_existingTranscripts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _clearTranscripts,
              tooltip: 'Clear saved transcripts',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Custom YouTuber Persona',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter YouTube video URLs to fetch transcripts and create a custom AI persona',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // URL Input Fields
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _urlControllers.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _urlControllers.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: OutlinedButton.icon(
                          onPressed: _addUrlField,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Another URL'),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _urlControllers[index],
                              decoration: InputDecoration(
                                labelText: 'YouTube URL ${index + 1}',
                                hintText: 'https://youtube.com/watch?v=...',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.link),
                                suffixIcon: _urlControllers[index].text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () => _urlControllers[index].clear(),
                                      )
                                    : null,
                              ),
                              onChanged: (value) => setState(() {}),
                            ),
                          ),
                          if (_urlControllers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removeUrlField(index),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Status and Action Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                children: [
                  // Existing Transcripts Info
                  if (_existingTranscripts.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_existingTranscripts.length} transcripts ready for use',
                              style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Status Message
                  if (_statusMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getStatusColor().withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          if (_status == TranscriptStatus.loading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          if (_status == TranscriptStatus.loading) const SizedBox(width: 12),
                          if (_status != TranscriptStatus.loading)
                            Icon(_getStatusIcon(), color: _getStatusColor(), size: 20),
                          if (_status != TranscriptStatus.loading) const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _statusMessage,
                              style: TextStyle(
                                color: _getStatusColor(),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _status == TranscriptStatus.loading ? null : _fetchTranscripts,
                          icon: Icon(_status == TranscriptStatus.loading ? Icons.hourglass_empty : Icons.download),
                          label: Text(_status == TranscriptStatus.loading ? 'Processing...' : 'Fetch Transcripts'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _existingTranscripts.isNotEmpty ? _navigateToChat : null,
                        icon: const Icon(Icons.chat),
                        label: const Text('Start Chat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_status) {
      case TranscriptStatus.loading:
        return Colors.blue;
      case TranscriptStatus.success:
        return Colors.green;
      case TranscriptStatus.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (_status) {
      case TranscriptStatus.success:
        return Icons.check_circle;
      case TranscriptStatus.error:
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  @override
  void dispose() {
    for (var controller in _urlControllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }
}