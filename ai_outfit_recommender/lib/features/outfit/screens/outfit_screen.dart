import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class OutfitScreen extends StatefulWidget {
  const OutfitScreen({super.key});

  @override
  State<OutfitScreen> createState() => _OutfitScreenState();
}

class _OutfitScreenState extends State<OutfitScreen> {
  String selectedWeather = "";
  String selectedOccasion = "";
  String selectedGender = "";

  Map<String, dynamic>? outfitData;
  String image1 = "";
  String image2 = "";
  bool isLoading = false;

  Future<void> generateOutfit() async {
    if (selectedWeather.isEmpty ||
        selectedOccasion.isEmpty ||
        selectedGender.isEmpty) {
      return;
    }

    setState(() => isLoading = true);

    try {
      final data = await AIService.getOutfit(
        weather: selectedWeather,
        occasion: selectedOccasion,
        gender: selectedGender,
      );

      final results = await Future.wait([
        AIService.generateOutfitImage(
          data["outfit1"]["outfit"],
          selectedGender,
          selectedOccasion,
        ),
        AIService.generateOutfitImage(
          data["outfit2"]["outfit"],
          selectedGender,
          selectedOccasion,
        ),
      ]);

      setState(() {
        outfitData = data;
        image1 = results[0];
        image2 = results[1];
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        outfitData = null;
        image1 = "";
        image2 = "";
        isLoading = false;
      });
    }
  }

  Widget buildButton(String label, VoidCallback onTap, bool isSelected) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget buildOutfitCard(
    String title,
    String imageUrl,
    Map<String, dynamic> outfit,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: Colors.black,
                    insetPadding: EdgeInsets.zero,
                    child: InteractiveViewer(
                      child: Image.network(imageUrl, fit: BoxFit.contain),
                    ),
                  ),
                );
              },
              child: Image.network(
                imageUrl,
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 280,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (_, __, ___) => Image.network(
                  "https://picsum.photos/seed/fashion/600/400",
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.deepPurple),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  outfit["title"] ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Outfit: ${outfit["outfit"] ?? ""}",
                  style: const TextStyle(height: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  "Colors: ${outfit["colors"] ?? ""}",
                  style: const TextStyle(height: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tip: ${outfit["tips"] ?? ""}",
                  style: const TextStyle(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7FB),
        elevation: 0,
        title: const Text(
          "AI Outfit Recommender",
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Weather",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              children: [
                buildButton(
                  "Sunny ☀️",
                  () => setState(() => selectedWeather = "Sunny"),
                  selectedWeather == "Sunny",
                ),
                buildButton(
                  "Rainy 🌧️",
                  () => setState(() => selectedWeather = "Rainy"),
                  selectedWeather == "Rainy",
                ),
                buildButton(
                  "Cold ❄️",
                  () => setState(() => selectedWeather = "Cold"),
                  selectedWeather == "Cold",
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Select Occasion",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              children: [
                buildButton(
                  "Party 🎉",
                  () => setState(() => selectedOccasion = "Party"),
                  selectedOccasion == "Party",
                ),
                buildButton(
                  "Office 💼",
                  () => setState(() => selectedOccasion = "Office"),
                  selectedOccasion == "Office",
                ),
                buildButton(
                  "Gym 🏋️",
                  () => setState(() => selectedOccasion = "Gym"),
                  selectedOccasion == "Gym",
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Select Gender",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              children: [
                buildButton(
                  "Female 👗",
                  () => setState(() => selectedGender = "Female"),
                  selectedGender == "Female",
                ),
                buildButton(
                  "Male 👔",
                  () => setState(() => selectedGender = "Male"),
                  selectedGender == "Male",
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.pinkAccent],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: generateOutfit,
                child: const Text(
                  "Get Outfit ✨",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (outfitData != null)
              Expanded(
                child: ListView(
                  children: [
                    buildOutfitCard(
                      "Outfit 1 ✨",
                      image1,
                      outfitData!["outfit1"],
                    ),
                    buildOutfitCard(
                      "Outfit 2 🔥",
                      image2,
                      outfitData!["outfit2"],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
