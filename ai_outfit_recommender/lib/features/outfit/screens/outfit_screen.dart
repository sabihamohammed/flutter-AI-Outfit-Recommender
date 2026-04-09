import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../widgets/selection_button.dart';
import '../models/outfit_model.dart';
import '../services/saved_outfits_service.dart';
import 'saved_looks_screen.dart';

class OutfitScreen extends StatefulWidget {
  const OutfitScreen({super.key});

  @override
  State<OutfitScreen> createState() => _OutfitScreenState();
}

class _OutfitScreenState extends State<OutfitScreen> {
  String selectedWeather = "";
  String selectedOccasion = "";
  String selectedGender = "";
  bool isReloadingOutfit1 = false;
  bool isReloadingOutfit2 = false;

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

    setState(() {
      isLoading = true;
    });

    try {
      final data = await AIService.getOutfit(
        weather: selectedWeather,
        occasion: selectedOccasion,
        gender: selectedGender,
      );

      final results = await Future.wait([
        AIService.generateOutfitImage(
          data["outfit1"]["image_prompt"],
          selectedGender,
          selectedOccasion,
        ),
        AIService.generateOutfitImage(
          data["outfit2"]["image_prompt"],
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
      setState(() {
        outfitData = null;
        image1 = "";
        image2 = "";
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to generate outfit: $e')));
    }
  }

  Future<void> regenerateSingleOutfit(String outfitKey) async {
    if (selectedWeather.isEmpty ||
        selectedOccasion.isEmpty ||
        selectedGender.isEmpty ||
        outfitData == null) {
      return;
    }

    setState(() {
      if (outfitKey == "outfit1") {
        isReloadingOutfit1 = true;
      } else {
        isReloadingOutfit2 = true;
      }
    });

    try {
      final newData = await AIService.getOutfit(
        weather: selectedWeather,
        occasion: selectedOccasion,
        gender: selectedGender,
      );

      final Map<String, dynamic> newOutfit = newData[outfitKey];

      final String newImage = await AIService.generateOutfitImage(
        newOutfit["image_prompt"],
        selectedGender,
        selectedOccasion,
      );

      setState(() {
        outfitData![outfitKey] = newOutfit;

        if (outfitKey == "outfit1") {
          image1 = newImage;
          isReloadingOutfit1 = false;
        } else {
          image2 = newImage;
          isReloadingOutfit2 = false;
        }
      });
    } catch (e) {
      setState(() {
        if (outfitKey == "outfit1") {
          isReloadingOutfit1 = false;
        } else {
          isReloadingOutfit2 = false;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to reload $outfitKey: $e")),
      );
    }
  }

  Future<void> saveLook({
    required String title,
    required String outfit,
    required String colors,
    required String tip,
    required String imageUrl,
  }) async {
    final savedOutfit = OutfitModel(
      title: title,
      outfit: outfit,
      colors: colors,
      tip: tip,
      imageUrl: imageUrl,
      weather: selectedWeather,
      occasion: selectedOccasion,
      gender: selectedGender,
    );

    await SavedOutfitsService.saveOutfit(savedOutfit);

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title saved successfully'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget buildOutfitCard(
    String title,
    String imageUrl,
    Map<String, dynamic> outfit,
    String outfitKey,
    bool isReloading,
  ) {
    final String outfitTitle = outfit["title"] ?? "";
    final String outfitDescription = outfit["outfit"] ?? "";
    final String colors = outfit["colors"] ?? "";
    final String tip = outfit["tips"] ?? "";
    final String officeFit = outfit["office_fit"] ?? "";
    final String palette = outfit["palette"] ?? "";
    final int officeScore = outfit["office_score"] ?? 0;

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
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      backgroundColor: Colors.black,
                      insetPadding: EdgeInsets.zero,
                      child: InteractiveViewer(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Image.network(
                            "https://picsum.photos/seed/fashion/600/400",
                            fit: BoxFit.contain,
                          ),
                        ),
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
                  outfitTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Outfit: $outfitDescription",
                  style: const TextStyle(height: 1.5),
                ),
                const SizedBox(height: 8),
                Text("Colors: $colors", style: const TextStyle(height: 1.5)),
                const SizedBox(height: 8),
                Text("Palette: $palette", style: const TextStyle(height: 1.5)),
                const SizedBox(height: 8),
                Text("Tip: $tip", style: const TextStyle(height: 1.5)),

                if (selectedOccasion == "Office") ...[
                  const SizedBox(height: 8),
                  Text("Office Fit: $officeFit"),
                  const SizedBox(height: 8),
                  Text("Office Score: $officeScore/10"),
                ],

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          saveLook(
                            title: outfitTitle.isNotEmpty ? outfitTitle : title,
                            outfit: outfitDescription,
                            colors: colors,
                            tip: tip,
                            imageUrl: imageUrl,
                          );
                        },
                        icon: const Icon(Icons.favorite_border),
                        label: const Text("Save Look"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: isReloading
                          ? null
                          : () => regenerateSingleOutfit(outfitKey),
                      child: isReloading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Try Another 🔄"),
                    ),
                  ],
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
    final int savedCount = SavedOutfitsService.savedOutfits.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7FB),
        elevation: 0,
        title: const Text(
          "AI Outfit Recommender",
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedLooksScreen(),
                ),
              ).then((_) {
                setState(() {});
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "Saved: $savedCount",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
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
                SelectionButton(
                  label: "Sunny ☀️",
                  isSelected: selectedWeather == "Sunny",
                  onTap: () => setState(() => selectedWeather = "Sunny"),
                ),
                SelectionButton(
                  label: "Rainy 🌧️",
                  isSelected: selectedWeather == "Rainy",
                  onTap: () => setState(() => selectedWeather = "Rainy"),
                ),
                SelectionButton(
                  label: "Cold ❄️",
                  isSelected: selectedWeather == "Cold",
                  onTap: () => setState(() => selectedWeather = "Cold"),
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
                SelectionButton(
                  label: "Party 🎉",
                  isSelected: selectedOccasion == "Party",
                  onTap: () => setState(() => selectedOccasion = "Party"),
                ),
                SelectionButton(
                  label: "Office 💼",
                  isSelected: selectedOccasion == "Office",
                  onTap: () => setState(() => selectedOccasion = "Office"),
                ),
                SelectionButton(
                  label: "Gym 🏋️",
                  isSelected: selectedOccasion == "Gym",
                  onTap: () => setState(() => selectedOccasion = "Gym"),
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
                SelectionButton(
                  label: "Female 👗",
                  isSelected: selectedGender == "Female",
                  onTap: () => setState(() => selectedGender = "Female"),
                ),
                SelectionButton(
                  label: "Male 👔",
                  isSelected: selectedGender == "Male",
                  onTap: () => setState(() => selectedGender = "Male"),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed:
                    (selectedWeather.isEmpty ||
                        selectedOccasion.isEmpty ||
                        selectedGender.isEmpty)
                    ? null
                    : generateOutfit,
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
                      "outfit1",
                      isReloadingOutfit1,
                    ),
                    buildOutfitCard(
                      "Outfit 2 🔥",
                      image2,
                      outfitData!["outfit2"],
                      "outfit2",
                      isReloadingOutfit2,
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
