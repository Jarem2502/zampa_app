import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  List<Map<String, dynamic>> comments = [
    {
      'name': 'VAL',
      'image': 'assets/val_profile.png', 
      'rating': 5, 
      'comment': '“El café es riquísimo y las hamburguesas están bien contundentes.”',
      'date': 'Hace 2 días',
      'isLocal': true, 
    },
    {
      'name': 'JAREM',
      'image': 'assets/jarem_profile.png', 
      'rating': 4,
      'comment': '“Muy buena experiencia, precios justos y buena calidad.”',
      'date': 'Hace 1 semana',
      'isLocal': true,
    },
  ];

  double get averageRating {
    if (comments.isEmpty) return 0.0;
    double sum = 0;
    for (var c in comments) sum += c['rating'];
    return sum / comments.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(), // CAMBIO: GoRouter
        ),
        title: const Text("Reseñas", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(averageRating.toStringAsFixed(1), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Row(
                      children: List.generate(5, (i) => Icon(i < averageRating.round() ? Icons.star : Icons.star_border, color: Colors.amber, size: 20)),
                    ),
                    Text("${comments.length} comentarios", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _showAddReviewSheet,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Calificar"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                )
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: comments.length,
              itemBuilder: (context, index) => _buildCommentCard(comments.reversed.toList()[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: data['isLocal'] ? AssetImage(data['image']) : null,
                child: data['isLocal'] ? null : const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(data['date'], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
              Text("⭐ ${data['rating']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
            ],
          ),
          const SizedBox(height: 12),
          Text(data['comment'], style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  void _showAddReviewSheet() {
    int selectedStars = 5;
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 24, left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Tu opinión cuenta", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => IconButton(
                  icon: Icon(i < selectedStars ? Icons.star : Icons.star_border, color: Colors.amber, size: 30),
                  onPressed: () => setModalState(() => selectedStars = i + 1),
                )),
              ),
              TextField(
                controller: textController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: "Escribe algo...", filled: true),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      comments.add({
                        'name': 'Usuario', 'image': '', 'rating': selectedStars,
                        'comment': textController.text, 'date': 'Reciente', 'isLocal': false
                      });
                    });
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: const Text("Publicar"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}