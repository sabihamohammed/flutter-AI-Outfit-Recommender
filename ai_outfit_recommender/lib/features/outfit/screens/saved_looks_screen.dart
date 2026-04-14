import 'package:flutter/material.dart';
import '../services/saved_outfits_service.dart';
import '../models/outfit_model.dart';

class SavedLooksScreen extends StatefulWidget {
  const SavedLooksScreen({super.key});

  @override
  State<SavedLooksScreen> createState() => _SavedLooksScreenState();
}

class _SavedLooksScreenState extends State<SavedLooksScreen> {
  void _removeSavedLook(int index) async {
    await SavedOutfitsService.deleteOutfitAt(index);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved look deleted'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<OutfitModel> savedLooks = SavedOutfitsService.savedOutfits;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7FB),
        elevation: 0,
        title: const Text(
          "Saved Looks",
          style: TextStyle(color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: savedLooks.isEmpty
          ? const Center(
              child: Text(
                "No saved looks yet 💔",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: savedLooks.length,
              itemBuilder: (context, index) {
                final outfit = savedLooks[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF8F4FF), Color(0xFFFDEBFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (outfit.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          child: Image.network(
                            outfit.imageUrl,
                            height: 240,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Image.network(
                              "https://picsum.photos/seed/fashion/600/400",
                              height: 240,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    outfit.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _removeSavedLook(index),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.deepPurple,
                                  ),
                                  tooltip: 'Delete saved look',
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Outfit: ${outfit.outfit}",
                              style: const TextStyle(height: 1.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Colors: ${outfit.colors}",
                              style: const TextStyle(height: 1.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Tip: ${outfit.tip}",
                              style: const TextStyle(height: 1.5),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Chip(label: Text(outfit.weather)),
                                Chip(label: Text(outfit.occasion)),
                                Chip(label: Text(outfit.gender)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
