import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Importante para la navegación

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Historial de mensajes
  final List<Map<String, dynamic>> _messages = [
    {
      'text': "¡Hola! Soy ZampBot 🤖, tu asistente virtual con sabor peruano. ¿En qué puedo ayudarte hoy?",
      'isUser': false,
    },
  ];

  bool _isTyping = false;

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add({'text': text, 'isUser': true});
      _isTyping = true; 
    });
    _scrollToBottom();

    // Simulación de delay de IA
    await Future.delayed(const Duration(milliseconds: 1500));

    String botResponse = _getAIResponse(text);

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({'text': botResponse, 'isUser': false});
      });
      _scrollToBottom();
    }
  }

  // --- LÓGICA DE RESPUESTAS (Mantenemos tu diseño de "cerebro") ---
  String _getAIResponse(String input) {
    String text = input.toLowerCase();

    if (text.contains('hola')) return "¡Hola! 👋 Qué gusto verte. ¿Te provoca algo rico hoy?";
    if (text.contains('menu') || text.contains('carta')) return "Nuestra carta tiene Hamburguesas Royal, Club Sándwich y Frappés. 🍔 Puedes ver todo en la sección 'Menú'.";
    if (text.contains('horario')) return "Atendemos de Martes a Domingo de 9:00 AM a 8:00 PM.";
    if (text.contains('ubicacion') || text.contains('donde')) return "Estamos en Av. Paseo la Breña 199, Huancayo. ¡Te esperamos!";
    if (text.contains('gracias')) return "¡De nada! Zampástico día para ti. 😉";

    return "Mmm, interesante... 🤔 Aún estoy aprendiendo, pero si buscas comida deliciosa en Huancayo, ¡Zampa es el lugar!";
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(), // CAMBIO: Usamos context.pop()
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.black,
              radius: 18,
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ZampBot", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                Text("En línea", style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ÁREA DE MENSAJES
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg['text'], msg['isUser']);
              },
            ),
          ),

          // INDICADOR DE CARGA
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 10),
              child: Row(
                children: [
                  Text("ZampBot está escribiendo...", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),

          // BARRA DE ENTRADA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "Escribe un mensaje...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.black,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _handleSubmitted(_textController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? Colors.black : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Text(text, style: TextStyle(color: isUser ? Colors.white : Colors.black87)),
      ),
    );
  }
}