import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Nuestra Esencia",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Hero( 
                    tag: 'logo',
                    child: Image.asset('assets/zampalogo.png', height: 100, errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.restaurant, size: 80, color: Colors.green);
                    }),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "PASIÓN PERUANA POR EL SABOR",
                    style: TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 3, 
                      color: Colors.grey
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildSectionCard(
              title: "Nuestra Historia",
              icon: Icons.history_edu,
              color: Colors.green,
              content: 
                "\"Zampa\" nació del sueño de sus fundadores de crear un espacio donde la buena comida se combine con momentos felices.\n\n"
                "El nombre surge de una expresión popular que evoca comer rápido, con ganas y sin vueltas. Representa esa conexión entre la comida rápida y la pasión peruana por el sabor.",
            ),

            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  _buildMissionItem(
                    "Misión", 
                    "Brindar experiencias culinarias de alta calidad a través de una propuesta innovadora y accesible.", 
                    Icons.flag, 
                    Colors.orange
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  _buildMissionItem(
                    "Visión", 
                    "Ser referentes en el sector gastronómico de Huancayo, destacando por nuestra excelencia.", 
                    Icons.visibility, 
                    Colors.blue
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  "Valores Z.A.M.P.A.",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildValueTile("Z", "Servicio de Calidad", "Experiencia eficiente y amable.", Colors.black),
            _buildValueTile("A", "Alta Calidad", "Ingredientes frescos y seleccionados.", Colors.green[700]!),
            _buildValueTile("M", "Motivación", "Cultura de crecimiento personal.", Colors.orange[700]!),
            _buildValueTile("P", "Perseverancia", "Enfocados en superar obstáculos.", Colors.red[700]!),
            _buildValueTile("A", "Aprendizaje", "Innovación y mejora continua.", Colors.blue[700]!),

            const SizedBox(height: 40),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C), 
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    "ENCUÉNTRANOS",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 20),
                  _buildContactRow(Icons.location_on, "Av. Paseo la Breña 199, Huancayo", Colors.greenAccent),
                  const SizedBox(height: 16),
                  _buildContactRow(Icons.access_time, "Mar - Dom: 09:00 AM - 08:00 PM\n(Lunes Cerrado)", Colors.orangeAccent),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIcon(Icons.facebook),
                      const SizedBox(width: 20),
                      _buildSocialIcon(Icons.camera_alt), 
                      const SizedBox(width: 20),
                      _buildSocialIcon(Icons.music_note), 
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            Text("v1.0.0", style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Color color, required String content}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: color, width: 6)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(content, style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildMissionItem(String title, String content, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(content, style: const TextStyle(color: Colors.black54, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueTile(String letter, String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Text(letter, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, height: 1.4))),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.black87, size: 24),
    );
  }
}