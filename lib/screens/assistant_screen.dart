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
    // PUT YOUR BRAND NEW SECURE API KEY HERE
    const apiKey = 'PM the user'; 
    
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system('''
You are the Butuan City Transit Expert AI. 

FARE LOGIC (LTFRB & SP ORDINANCE NO. 6824-2023): 
1. PUJ / Multicab: ₱14.00 base fare.
2. Motorized Tricycle: ₱10.00 base fare.
* CRITICAL MULTI-LEG MATH: If a trip requires TWO vehicles (e.g., Tricycle from barangay + Multicab on highway), you MUST add both base fares for the TOTAL EXPENSE (₱10 + ₱14 = ₱24).

BUTUAN ROUTE MATRIX:
- J.C. Aquino Ave (Highway): Where Robinsons, SM, and Gaisano are. ONLY Multicabs (R1/R2) travel here.
- Route 1 (R1) / Route 2 (R2) Multicab: Use these for highway travel.
- Orange Tricycle: Maon, Obrero, City Hall, City Proper.
- Green Tricycle: Banza, Maug, Mahay.
- Yellow Tricycle: Villa Kananga, San Vicente.
- Red Tricycle: Holy Redeemer, Langihan.

MULTI-LEG ROUTING RULES:
If starting inside a barangay (like Maon) going to a highway mall (like Robinsons), DO NOT use one vehicle. You MUST recommend taking a Tricycle to the highway, then transferring to a Multicab.

STRICT FORMAT RULES:
1. NEVER output "N/A". Estimate distance geographically.
2. NEVER use markdown formatting like asterisks (**).
3. Distinguish the steps and vehicles clearly.
4. Reply EXACTLY in this format, with no extra text before or after:
PLAN: [Step 1: Vehicle and route. Step 2: Vehicle and route.]
BREAKDOWN: [Vehicle 1 (₱Fare)] + [Vehicle 2 (₱Fare)]
DIST: [Estimated Number] KM
TIME: [Estimated Number] MIN
EXPENSE: ₱[Calculated Total Amount]

EXAMPLE TRIP:
User: Maon to Robinsons
PLAN: Step 1: Take an Orange Tricycle from Maon to the highway. Step 2: Transfer to an R1 or R2 Multicab to Robinsons.
BREAKDOWN: Orange Tricycle (₱10) + Multicab (₱14)
DIST: 4 KM
TIME: 15 MIN
EXPENSE: ₱24
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
          : "Calculate route and fare to $text. Reply strictly using the requested format tags (PLAN:, BREAKDOWN:, DIST:, TIME:, EXPENSE:).";
      
      final response = await _chat.sendMessage(Content.text(prompt));
      final responseText = (response.text ?? "Error calculating route.")
          .replaceAll('**', '')
          .replaceAll('*', ''); 

      if (!mounted) return; 

      setState(() {
        isLoading = false;
      });

      if (isInfoSearch) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'type': 'text',
            'content': responseText,
          });
        });
        _scrollToBottom();
      } else {
        _showTransitChoiceDialog(responseText);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        _messages.add({
          'role': 'assistant',
          'type': 'text',
          'content': 'SYSTEM ERROR: CONNECTION FAILED. $e',
        });
      });
      _scrollToBottom();
    }
  }

  void _showTransitChoiceDialog(String aiResponseText) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Colors.black, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: Colors.black,
                  child: Text('⚠️ PROJECT SCOPE ADVISORY', style: MiffyStyle.overline.copyWith(color: Colors.white)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'VERIFIED TRANSIT ONLY',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                const Text(
                  'It is highly recommended to ride with verified PUJs and Tricycles using our calculated routes. Going to unverified terminals for private drop-offs falls outside the scope of our standard pricing matrix and involves unregulated bargaining.',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: MiffyButton(
                    text: 'USE VERIFIED ROUTE',
                    onPressed: () {
                      Navigator.pop(context); 
                      _addCalculatedRoute(aiResponseText);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: MiffyButton(
                    text: 'GO TO UNVERIFIED TERMINAL',
                    isOutline: true,
                    onPressed: () {
                      Navigator.pop(context); 
                      _addBargainRoute();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addCalculatedRoute(String responseText) {
    setState(() {
      _messages.add({
        'role': 'assistant',
        'type': 'text',
        'content': '✅ VERIFIED ROUTE ACCEPTED. Generating Ticket...',
      });
      _messages.add({
        'role': 'assistant',
        'type': 'guidance',
        'instructions': _extractData(responseText, 'PLAN:'),
        'breakdown': _extractData(responseText, 'BREAKDOWN:'), 
        'distance': _extractData(responseText, 'DIST:').replaceAll('KM', '').trim(),
        'time': _extractData(responseText, 'TIME:').replaceAll('MIN', '').trim(),
        'expense': _extractData(responseText, 'EXPENSE:'), 
      });
    });
    _scrollToBottom();
  }

  void _addBargainRoute() {
    setState(() {
      _messages.add({
        'role': 'assistant',
        'type': 'text',
        'content': '⚠️ UNVERIFIED TERMINAL SELECTED.\n\nPlease proceed to the nearest transport terminal. Private hire trips are unregulated by our system. \n\nPrepare to negotiate pricing directly with the driver based on distance and area restrictions.',
      });
    });
    _scrollToBottom();
  }

  String _extractData(String source, String key) {
    try {
      final lines = source.split('\n');
      final line = lines.firstWhere((l) => l.trim().startsWith(key), orElse: () => '$key Unknown');
      return line.replaceFirst(key, '').trim();
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
              Text('SP ORDINANCE 6824-2023 INJECTED', style: MiffyStyle.overline.copyWith(color: Colors.white60)),
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
          height: 1.5,
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
                const Icon(Icons.receipt_long, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text('TRANSIT ITINERARY', style: MiffyStyle.overline.copyWith(color: Colors.white)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RECOMMENDED ROUTE', style: MiffyStyle.overline.copyWith(color: Colors.black38)),
                const SizedBox(height: 6),
                Text(
                  data['instructions'] ?? '', 
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 16),
                Text('FARE BREAKDOWN', style: MiffyStyle.overline.copyWith(color: Colors.black38)),
                const SizedBox(height: 4),
                Text(
                  data['breakdown'] ?? '', 
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black87),
                ),
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
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.black, width: 2))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DISTANCE', style: MiffyStyle.overline),
                        const SizedBox(height: 4),
                        Text('${data['distance']} KM', style: MiffyStyle.headerBlack.copyWith(fontSize: 20)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EST. TIME', style: MiffyStyle.overline),
                        const SizedBox(height: 4),
                        Text('${data['time']} MIN', style: MiffyStyle.headerBlack.copyWith(fontSize: 20)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.black,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TOTAL EXPENSE', style: MiffyStyle.overline.copyWith(color: Colors.white70, letterSpacing: 2)),
                const SizedBox(height: 4),
                Text(
                  data['expense'] ?? '₱0.00', 
                  style: MiffyStyle.headerBlack.copyWith(color: Colors.white, fontSize: 32),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
