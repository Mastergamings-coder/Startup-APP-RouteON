import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../theme/miffy_style.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  bool isInfoSearch = true; 
  bool isLoading = false;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'role': 'assistant',
      'type': 'text',
      'content': 'BUTUAN TRANSIT AI v1.0 ONLINE. INPUT DESTINATION FOR FARE AND ROUTE GUIDANCE.',
    }
  ];

  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    // PUT YOUR ACTUAL API KEY HERE
    const apiKey = 'AIzaSyAohP5CA18z5pLfnGsvdRHdJ06K0znnw3I'; 
    
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system('''
You are the Butuan City Transit Expert AI. 
Use this LTFRB fare logic: Minimum fare is ₱14.00 for the first 4km, plus ₱2.00 per succeeding kilometer. 
If the user asks for a route, provide the step-by-step jeepney/tricycle ride, estimated distance, and calculate the exact fare based on the ₱14 base rate.
Keep your answers brief, confident, and format them clearly.
'''),
    );
    _chat = _model.startChat();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'type': 'text',
        'content': isInfoSearch ? text : 'ROUTE TO ${text.toUpperCase()}',
      });
      isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final prompt = isInfoSearch 
          ? text 
          : "Calculate route and fare to $text. Reply in this strict format: \nPLAN: [Steps]\nDIST: [KM] \nTIME: [Mins] \nFARE: [₱ Amount]";
      
      final response = await _chat.sendMessage(Content.text(prompt));
      final responseText = response.text ?? "Error calculating route.";

      setState(() {
        if (isInfoSearch) {
          _messages.add({
            'role': 'assistant',
            'type': 'text',
            'content': responseText,
          });
        } else {
          _messages.add({
            'role': 'assistant',
            'type': 'guidance',
            'instructions': _extractData(responseText, 'PLAN:'),
            'distance': _extractData(responseText, 'DIST:').replaceAll('KM', '').trim(),
            'time': _extractData(responseText, 'TIME:').replaceAll('Mins', '').trim(),
            'fare': _extractData(responseText, 'FARE:'),
          });
        }
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'type': 'text',
          'content': 'SYSTEM ERROR: CONNECTION FAILED. $e',
        });
      });
    } finally {
      setState(() {
        isLoading = false;
      });
      _scrollToBottom();
    }
  }

  String _extractData(String source, String key) {
    try {
      final lines = source.split('\n');
      final line = lines.firstWhere((l) => l.startsWith(key), orElse: () => '$key Unknown');
      return line.replaceAll(key, '').trim();
    } catch (e) {
      return 'Unknown';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text('TRANSIT ASSISTANT', style: MiffyStyle.headerBlack.copyWith(color: Colors.white, fontSize: 20)),
                ],
              ),
              const SizedBox(height: 8),
              Text('4-STEP LOGIC ENGINE: INTENT > DIST > FARE > PLAN', style: MiffyStyle.overline.copyWith(color: Colors.white60)),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(child: _buildTab('INFO SEARCH', true)),
            Expanded(child: _buildTab('FARE CALC', false)),
          ],
        ),
        Container(height: 2, color: Colors.black),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(24),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isUser = msg['role'] == 'user';

              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(isUser ? 'PASSENGER' : 'SYSTEM', style: MiffyStyle.overline),
                    const SizedBox(height: 8),
                    msg['type'] == 'text' 
                        ? _buildTextBubble(msg['content'], isUser)
                        : _buildGuidanceCard(msg),
                  ],
                ),
              );
            },
          ),
        ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(color: Colors.black),
          ),
        Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black, width: 2)),
          ),
          padding: const EdgeInsets.all(24),
          child: isInfoSearch 
              ? Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(hintText: 'Ask about routes...'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 56,
                      width: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.zero,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        onPressed: _sendMessage,
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    TextField(
                      controller: _controller,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(hintText: 'Destination landmark...'),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: MiffyButton(text: 'CALCULATE JOURNEY', onPressed: _sendMessage),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildTab(String text, bool isTabInfoSearch) {
    final isActive = isInfoSearch == isTabInfoSearch;
    return GestureDetector(
      onTap: () => setState(() => isInfoSearch = isTabInfoSearch),
      child: Container(
        color: isActive ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        child: Text(
          text,
          style: MiffyStyle.overline.copyWith(
            color: isActive ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildTextBubble(String text, bool isUser) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUser ? Colors.black : Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: isUser ? [MiffyStyle.hardShadow] : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isUser ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildGuidanceCard(Map<String, dynamic> data) {
    return Container(
      decoration: MiffyStyle.cardDecoration,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.black,
            child: Row(
              children: [
                const Icon(Icons.directions_bus, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text('TRANSIT CALCULATION', style: MiffyStyle.overline.copyWith(color: Colors.white)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PLAN', style: MiffyStyle.overline.copyWith(color: Colors.black38)),
                const SizedBox(height: 4),
                Text(data['instructions'] ?? '', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border.symmetric(horizontal: BorderSide(color: Colors.black, width: 2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.black, width: 2))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DIST', style: MiffyStyle.overline),
                        Text('${data['distance']}KM', style: MiffyStyle.headerBlack.copyWith(fontSize: 24)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TIME', style: MiffyStyle.overline),
                        Text('${data['time']}MIN', style: MiffyStyle.headerBlack.copyWith(fontSize: 24)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CALCULATED BUTUAN FARE', style: MiffyStyle.overline.copyWith(color: Colors.white60)),
                Text(data['fare'] ?? '', style: MiffyStyle.headerBlack.copyWith(color: Colors.white, fontSize: 28, fontStyle: FontStyle.italic)),
              ],
            ),
          )
        ],
      ),
    );
  }
}