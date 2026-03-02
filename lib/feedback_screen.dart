import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';
import '../providers/auth_provider.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  bool _isLoading = true;
  List<ReviewModel> _reviews = [];
  final ReviewService _reviewService = ReviewService();

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    final fetchedReviews = await _reviewService.getReviews();
    if (mounted) {
      setState(() {
        _reviews = fetchedReviews;
        _isLoading = false;
      });
    }
  }

  double get averageRating {
    if (_reviews.isEmpty) return 0.0;
    double sum = 0;
    for (var r in _reviews) {
      sum += r.rating;
    }
    return sum / _reviews.length;
  }

  void _showAddReviewModal() {
    final isAuth = context.read<AuthProvider>().isAuthenticated;
    if (!isAuth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes iniciar sesión para comentar")),
      );
      return;
    }

    int selectedStars = 5;
    final textController = TextEditingController();
    bool isSending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "¿Qué te pareció Zampa?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // Estrellitas interactivas
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => IconButton(
                      icon: Icon(
                        i < selectedStars ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 40,
                      ),
                      onPressed: () =>
                          setModalState(() => selectedStars = i + 1),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Caja de texto general
                TextField(
                  controller: textController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        "Cuéntanos tu experiencia con nuestro local, la comida o el delivery...",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Botón de enviar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isSending
                        ? null
                        : () async {
                            if (textController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Por favor escribe un comentario",
                                  ),
                                ),
                              );
                              return;
                            }

                            setModalState(() => isSending = true);

                            // 🔥 Enviamos solo las estrellas y el texto
                            bool success = await _reviewService.sendReview(
                              rating: selectedStars,
                              comment: textController.text.trim(),
                            );

                            if (success && context.mounted) {
                              context.pop();
                              _loadReviews();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("¡Gracias por tu opinión!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              setModalState(() => isSending = false);
                              if (context.mounted)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Error al enviar reseña"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isSending
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Publicar Reseña",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
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
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Comunidad Zampa",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < averageRating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Basado en ${_reviews.length} reseñas",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _showAddReviewModal,
                        icon: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Opinar",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF81C784),
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _reviews.isEmpty
                      ? const Center(
                          child: Text(
                            "Sé el primero en dejar una reseña.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final review = _reviews[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.grey[200],
                                        backgroundImage:
                                            review.userAvatar != null
                                            ? NetworkImage(review.userAvatar!)
                                            : null,
                                        child: review.userAvatar == null
                                            ? Text(
                                                review.userName[0]
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              review.userName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              review.date,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: List.generate(
                                          5,
                                          (i) => Icon(
                                            i < review.rating
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    review.comment,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
