import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../widgets/scale_on_tap.dart';

class KrishiChatPage extends StatefulWidget {
  final Map<String, dynamic>? scanContext;
  final String? initialQuery;

  const KrishiChatPage({
    super.key,
    this.scanContext,
    this.initialQuery,
  });

  @override
  State<KrishiChatPage> createState() => _KrishiChatPageState();
}

class _KrishiChatPageState extends State<KrishiChatPage> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isHindi = false;

  @override
  void initState() {
    super.initState();
    // Default welcome message in bilingual context
    _messages.add({
      "sender": "ai",
      "text": "Namaste! I am Krishi AI, your crop assistant. How can I help protect your fields today?\n\nनमस्ते! मैं कृषि एआई हूँ। आज मैं आपकी फसल की सुरक्षा में कैसे मदद कर सकता हूँ?"
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Determine language from application locale
      final currentLocale = Localizations.localeOf(context).languageCode;
      setState(() {
        _isHindi = currentLocale == 'hi';
      });

      if (widget.initialQuery != null) {
        _handleSendMessage(widget.initialQuery!);
      } else if (widget.scanContext != null) {
        // Automatically request advice for active scan
        final crop = widget.scanContext!["crop_type"] ?? "maize";
        final pred = widget.scanContext!["prediction"] ?? "Fall Armyworm suspected";
        final conf = ((widget.scanContext!["confidence"] ?? 0.0) * 100).toStringAsFixed(0);
        
        final initialPrompt = _isHindi 
            ? "कृपया मेरी पत्ती के स्कैन का परिणाम समझाएं: फसल - ${crop == 'maize' ? 'मक्का' : crop}, परिणाम - $pred, विश्वास स्तर - $conf%"
            : "Please explain my leaf scan result: Crop - $crop, Result - $pred, Confidence - $conf%";
        
        _handleSendMessage(initialPrompt, autoInjectScanContext: true);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Pre-baked bilingual local answers to bypass Gemini and save requests
  Map<String, String> get _preBakedAnswersEn => {
    "what is fall armyworm": "Fall Armyworm (Spodoptera frugiperda) is an insect pest that primarily damages maize crops. The larvae feed aggressively on leaf whorls and ears, causing significant grain yield loss if left unmanaged.",
    "treatment advice": "Organic treatments include:\n1. Handpick and destroy visible caterpillars and egg masses.\n2. Mix 5ml neem oil extract per liter of water with soft soap and spray into leaf whorls at twilight.\n3. Release Trichogramma parasitic wasps to destroy pest eggs naturally.",
    "prevention tips": "Preventive farming practices:\n1. Push-Pull Method: Plant greenleaf desmodium (moth repellent) inside rows and napier grass (moth attractant) around borders.\n2. Rotate maize with non-host legume crops.\n3. Clear weeds consistently to remove shelter.",
    "symptoms": "Typical damage symptoms include:\n1. 'Window-pane' papery holes in young leaves.\n2. Large ragged feeding holes in older leaves.\n3. Fine sawdust-like brown fecal dust (frass) accumulated inside leaf whorls.",
  };

  Map<String, String> get _preBakedAnswersHi => {
    "what is fall armyworm": "फॉल आर्मीवॉर्म (स्पोडोप्टेरा फ्रूगीपर्दा) एक विनाशकारी कीट है जो मुख्य रूप से मक्के को नुकसान पहुंचाता है। इसके लार्वा पत्तियों और बालियों को बहुत तेजी से खाकर फसल को भारी नुकसान पहुंचाते हैं।",
    "treatment advice": "सुरक्षित जैविक उपचार विधि:\n1. पत्तों से अंडों और सुंडियों (लार्वा) को हाथों से बीनकर नष्ट करें।\n2. प्रति लीटर पानी में 5 मिली नीम का तेल मिलाकर शाम के समय मक्के की गोब (पोंगो) में छिड़काव करें।\n3. अंडों को जैविक रूप से नष्ट करने के लिए ट्राइकोग्रामा कार्ड का उपयोग करें।",
    "prevention tips": "बचाव के कृषि उपाय:\n1. 'पुश-पुल' तकनीक: फसल के बीच डेस्मोडियम (कीट विकर्षक) और चारों ओर नेपियर घास (कीट आकर्षक) लगाएं।\n2. फसल चक्र अपनाएं और मक्के के बाद दलहन (दालें) उगाएं।\n3. खेत को पूरी तरह खरपतवार मुक्त और साफ रखें।",
    "symptoms": "नुकसान के मुख्य लक्षण:\n1. पत्तों पर छोटे जालीदार पारदर्शी छेद (खिड़की जैसी आकृति) होना।\n2. पत्तियों पर बड़े-बड़े फटे हुए छेद दिखना।\n3. मक्के के गोब के अंदर लकड़ी के बुरादे जैसा भूरा कचरा/मल दिखना।",
  };

  String? _checkPreBaked(String query) {
    final norm = query.toLowerCase().trim().replaceAll("?", "").replaceAll(".", "").replaceAll(",", "");
    
    // Check English variations
    if (norm.contains("what is fall") || norm.contains("what is faw") || norm.contains("armyworm क्या है") || norm.contains("सैनिक कीट क्या है")) {
      return _isHindi ? _preBakedAnswersHi["what is fall armyworm"] : _preBakedAnswersEn["what is fall armyworm"];
    }
    if (norm.contains("treatment") || norm.contains("उपचार") || norm.contains("इलाज") || norm.contains("control")) {
      return _isHindi ? _preBakedAnswersHi["treatment advice"] : _preBakedAnswersEn["treatment advice"];
    }
    if (norm.contains("prevent") || norm.contains("बचाव") || norm.contains("रोकथाम")) {
      return _isHindi ? _preBakedAnswersHi["prevention tips"] : _preBakedAnswersEn["prevention tips"];
    }
    if (norm.contains("symptom") || norm.contains("लक्षण") || norm.contains("पहचान")) {
      return _isHindi ? _preBakedAnswersHi["symptoms"] : _preBakedAnswersEn["symptoms"];
    }
    if (norm.contains("explain scan") || norm.contains("explain my scan") || norm.contains("स्कैन") || norm.contains("scan result")) {
      if (widget.scanContext != null) {
        final pred = widget.scanContext!["prediction"] ?? "damaged";
        final isHealthy = pred.toLowerCase().contains("healthy") || pred.toLowerCase().contains("normal");
        if (isHealthy) {
          return _isHindi
              ? "साप्ताहिक जांच के आधार पर आपकी पत्ती स्वस्थ है और किसी फॉल आर्मीवॉर्म (FAW) संक्रमण का संकेत नहीं है। नियमित निगरानी जारी रखें।"
              : "Based on the leaf scan analysis, the crop leaf is healthy. No signs of Fall Armyworm damage were detected. Continue regular crop inspections.";
        } else {
          return _isHindi
              ? "निदान विश्लेषण के अनुसार, पत्ती पर फॉल आर्मीवॉर्म (सैनिक कीट) के नुकसान के लक्षण पाए गए हैं। संक्रमण को रोकने के लिए तुरंत नीम के तेल आधारित जैविक उपचार लागू करें।"
              : "Based on the leaf scan analysis, Fall Armyworm (FAW) damage has been detected on the crop leaf. It is highly recommended to apply safe organic control measures immediately to prevent further infestation.";
        }
      } else {
        return _isHindi
            ? "कृपया कोई स्कैन परिणाम प्रदान करें ताकि मैं उसका विश्लेषण कर सकूं।"
            : "Please scan a leaf first or provide scan context so I can explain the diagnostic results.";
      }
    }
    
    return null;
  }

  Future<void> _handleSendMessage(String text, {bool autoInjectScanContext = false}) async {
    if (text.trim().isEmpty) return;

    // Add user message to state
    setState(() {
      _messages.add({"sender": "user", "text": text});
      _isTyping = true;
    });
    _scrollToBottom();
    _textController.clear();

    // Check Pre-baked local cache to save token request costs
    final localAnswer = _checkPreBaked(text);
    if (localAnswer != null) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add({"sender": "ai", "text": localAnswer});
      });
      _scrollToBottom();
      return;
    }

    // Call production backend
    try {
      final String baseUrl = AppConfig.getBaseUrl();
      final uri = Uri.parse('$baseUrl${AppConfig.chatEndpoint}');

      // Limit memory transmission to last 5 messages (minimizes context size)
      final historyList = _messages
          .skip(_messages.length > 6 ? _messages.length - 6 : 0)
          .take(_messages.length - 1 > 0 ? _messages.length - 1 : 0)
          .toList();

      final body = {
        "message": text,
        "language": _isHindi ? "hi" : "en",
        "scan_context": (autoInjectScanContext || widget.scanContext != null) ? widget.scanContext : null,
        "chat_history": historyList,
      };

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "X-API-Key": AppConfig.apiKey,
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reply = data["reply"] ?? "Unable to connect to assistant. / सहायक से संपर्क करने में असमर्थ।";
        setState(() {
          _isTyping = false;
          _messages.add({"sender": "ai", "text": reply});
        });
      } else if (response.statusCode == 429) {
        setState(() {
          _isTyping = false;
          _messages.add({
            "sender": "ai",
            "text": _isHindi 
                ? "कृषि एआई अभी व्यस्त है। कृपया थोड़ी देर बाद पुनः प्रयास करें।"
                : "Krishi FAW AI is currently busy. Please try again later."
          });
        });
      } else {
        setState(() {
          _isTyping = false;
          _messages.add({
            "sender": "ai",
            "text": _isHindi
                ? "कृषि एआई अस्थायी रूप से अनुपलब्ध है। कृपया कुछ क्षणों में पुनः प्रयास करें।"
                : "Krishi FAW AI is temporarily unavailable. Please try again in a few moments."
          });
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add({
          "sender": "ai",
          "text": _isHindi
              ? "कनेक्शन एरर। कृपया अपना इंटरनेट जांचें और पुनः प्रयास करें।"
              : "Connection error. Please check your internet connection and try again."
        });
      });
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
    return PopScope(
      canPop: true,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "Krishi FAW AI Assistant",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF1B4332),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isHindi ? Icons.translate : Icons.language, color: Colors.white),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isHindi = !_isHindi;
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 1. Diagnostic scan indicator card (if scanContext active)
          if (widget.scanContext != null)
            _buildActiveScanCard(),

          // 2. Chat message history list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // 3. Interactive suggestion chips (bypasses Gemini for repeat FAQ costs)
          _buildSuggestionChips(),

          // 4. Text Input Field panel
          _buildInputPanel(),
        ],
      ),
    ),
  );
}

  Widget _buildActiveScanCard() {
    final crop = widget.scanContext!["crop_type"] ?? "maize";
    final pred = widget.scanContext!["prediction"] ?? "Fall Armyworm suspected";
    final conf = ((widget.scanContext!["confidence"] ?? 0.0) * 100).toStringAsFixed(0);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics_outlined, color: Color(0xFF2E7D32), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isHindi ? "सक्रिय पत्ता निदान स्कैन" : "Active Diagnosis Scan Context",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
                Text(
                  _isHindi 
                      ? "मक्का: $pred ($conf% विश्वास)"
                      : "${crop.toUpperCase()}: $pred ($conf% Confidence)",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> msg) {
    final isAi = msg["sender"] == "ai";
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isAi ? Colors.white : const Color(0xFF1B4332),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isAi ? const Radius.circular(0) : const Radius.circular(20),
            bottomRight: isAi ? const Radius.circular(20) : const Radius.circular(0),
          ),
          border: isAi ? Border.all(color: const Color(0xFFE2E8F0), width: 1.2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Text(
          msg["text"] ?? "",
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            color: isAi ? const Color(0xFF1E293B) : Colors.white,
            height: 1.45,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade800),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _isHindi ? "कृषि एआई सोच रहा है..." : "Krishi FAW AI is thinking...",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChips() {
    final suggestions = <String>[];
    if (widget.scanContext != null) {
      suggestions.add(_isHindi ? "स्कैन का विवरण" : "Explain scan");
    }
    if (_isHindi) {
      suggestions.addAll(["सैनिक कीट क्या है?", "इलाज सलाह", "बचाव उपाय", "लक्षण"]);
    } else {
      suggestions.addAll(["What is Fall Armyworm?", "Treatment advice", "Prevention tips", "Symptoms"]);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        physics: const BouncingScrollPhysics(),
        itemCount: suggestions.length,
        itemBuilder: (context, idx) {
          final query = suggestions[idx];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ScaleOnTap(
              onTap: () {
                HapticFeedback.lightImpact();
                _handleSendMessage(query);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                ),
                alignment: Alignment.center,
                child: Text(
                  query,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D6A4F),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1.2)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: TextField(
                  controller: _textController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: _isHindi ? "कीट या उपचार के बारे में पूछें..." : "Ask anything about crops or pests...",
                    hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      _handleSendMessage(val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            ScaleOnTap(
              onTap: () {
                if (_textController.text.trim().isNotEmpty) {
                  _handleSendMessage(_textController.text);
                }
              },
              child: Container(
                height: 48,
                width: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF1B4332),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
