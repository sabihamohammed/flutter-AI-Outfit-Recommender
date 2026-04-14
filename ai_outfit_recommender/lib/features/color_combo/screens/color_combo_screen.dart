import 'package:flutter/material.dart';
import '../../outfit/models/outfit_model.dart';
import '../../outfit/services/ai_service.dart';
import '../../outfit/services/saved_outfits_service.dart';
import '../../outfit/widgets/selection_button.dart';

class ColorComboScreen extends StatefulWidget {
  const ColorComboScreen({super.key});

  @override
  State<ColorComboScreen> createState() => _ColorComboScreenState();
}

class _ColorComboScreenState extends State<ColorComboScreen> {
  bool isLoading = false;
  Map<String, dynamic>? comboData;
  List<String> comboImages = [];
  List<bool> comboSaved = [];

  final Map<String, List<Color>> colorPalettes = {
    "Black": [Colors.black, Colors.grey.shade900, Colors.grey.shade800],
    "White": [Colors.white, Colors.grey.shade100, Colors.grey.shade200],
    "Blue": [Colors.blue.shade200, Colors.blue, Colors.blue.shade900],
    "Navy": [
      const Color(0xFF1A237E),
      const Color(0xFF283593),
      const Color(0xFF3949AB),
    ],
    "Grey": [Colors.grey.shade300, Colors.grey.shade500, Colors.grey.shade800],
    "Beige": [
      const Color(0xFFF5F5DC),
      const Color(0xFFE8DCC4),
      const Color(0xFFD2B48C),
    ],
    "Brown": [
      const Color(0xFFA1887F),
      const Color(0xFF8D6E63),
      const Color(0xFF5D4037),
    ],
    "Olive": [
      const Color(0xFFB5C99A),
      const Color(0xFF6B8E23),
      const Color(0xFF556B2F),
    ],
    "Pink": [Colors.pink.shade100, Colors.pink.shade300, Colors.pink.shade600],
    "Red": [Colors.red.shade200, Colors.red, Colors.red.shade900],
    "Green": [Colors.green.shade200, Colors.green, Colors.green.shade900],
    "Yellow": [Colors.yellow.shade200, Colors.amber, Colors.orange.shade700],
  };

  final List<String> selectedColors = [];

  String selectedWeather = "";
  String selectedOccasion = "";
  String selectedGender = "";

  void toggleColor(String color) {
    setState(() {
      if (selectedColors.contains(color)) {
        selectedColors.remove(color);
      } else {
        selectedColors.add(color);
      }
    });
  }

  Future<void> getColorSuggestions() async {
    if (selectedColors.isEmpty ||
        selectedWeather.isEmpty ||
        selectedOccasion.isEmpty ||
        selectedGender.isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
      comboData = null;
      comboImages = [];
    });

    try {
      final data = await AIService.getColorComboSuggestions(
        colors: selectedColors,
        weather: selectedWeather,
        occasion: selectedOccasion,
        gender: selectedGender,
      );

      final combos = data["combos"] as List;

      final images = await Future.wait(
        combos.map((combo) {
          return AIService.generateComboImage(
            combo["image_prompt"] ?? "",
            selectedGender,
            selectedOccasion,
            selectedWeather,
          );
        }),
      );

      setState(() {
        comboData = data;
        comboImages = images;
        comboSaved = List<bool>.generate(combos.length, (index) {
          final combo = combos[index] as Map<String, dynamic>;
          final savedOutfit = OutfitModel(
            title: combo["title"] ?? "Color Combo",
            outfit:
                combo["why_it_works"] ??
                combo["style_tip"] ??
                "Stylish color combo",
            colors: combo["colors"] ?? selectedColors.join(", "),
            tip: combo["style_tip"] ?? "Use these colors for your look.",
            imageUrl: images[index],
            weather: selectedWeather,
            occasion: selectedOccasion,
            gender: selectedGender,
          );
          return SavedOutfitsService.containsOutfit(savedOutfit);
        });
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to get suggestions: $e")));
    }
  }

  Widget buildColorCircle(String colorName, List<Color> shades) {
    final bool isSelected = selectedColors.contains(colorName);

    return GestureDetector(
      onTap: () => toggleColor(colorName),
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.transparent,
            width: 1.25,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: CircleAvatar(
          radius: 14,
          backgroundColor: shades[1],
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 12)
              : null,
        ),
      ),
    );
  }

  Future<void> _saveComboLook(
    int index,
    Map<String, dynamic> combo,
    String imageUrl,
  ) async {
    final title = combo["title"] ?? "Color Combo";
    final outfit =
        combo["why_it_works"] ?? combo["style_tip"] ?? "Stylish color combo";
    final colors = combo["colors"] ?? selectedColors.join(", ");
    final tip = combo["style_tip"] ?? "Use these colors for your look.";

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

    final bool saved = await SavedOutfitsService.saveOutfit(savedOutfit);

    setState(() {
      comboSaved[index] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved ? 'Combo saved to Saved Looks' : 'This combo is already saved',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget buildComboCard(
    Map<String, dynamic> combo,
    String imageUrl,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFFF8F4FF), Color(0xFFFDEBFF)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              child: Image.network(
                imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 220,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.image_not_supported)),
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
                    Expanded(
                      child: Text(
                        combo["title"] ?? "",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    Tooltip(
                      message: comboSaved.length > index && comboSaved[index]
                          ? 'Saved'
                          : 'Save look',
                      child: IconButton(
                        onPressed:
                            comboSaved.length > index && comboSaved[index]
                            ? null
                            : () => _saveComboLook(index, combo, imageUrl),
                        icon: Icon(
                          comboSaved.length > index && comboSaved[index]
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: comboSaved.length > index && comboSaved[index]
                              ? Colors.redAccent
                              : Colors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Colors: ${combo["colors"] ?? ""}",
                  style: const TextStyle(height: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  "Why it works: ${combo["why_it_works"] ?? ""}",
                  style: const TextStyle(height: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tip: ${combo["style_tip"] ?? ""}",
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
    final combos = comboData?["combos"] as List? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7FB),
        elevation: 0,
        title: const Text(
          "Color Combo Guide 🎨",
          style: TextStyle(color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pick the colors you already have",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),

            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: colorPalettes.entries.map((entry) {
                return buildColorCircle(entry.key, entry.value);
              }).toList(),
            ),

            const SizedBox(height: 18),

            if (selectedColors.isNotEmpty)
              Text(
                "Selected Colors: ${selectedColors.join(", ")}",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.deepPurple,
                ),
              ),

            const SizedBox(height: 24),

            const Text(
              "Select Weather",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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

            const SizedBox(height: 20),

            const Text(
              "Select Occasion",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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

            const SizedBox(height: 20),

            const Text(
              "Select Gender",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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

            const SizedBox(height: 28),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.pinkAccent],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed:
                    selectedColors.isEmpty ||
                        selectedWeather.isEmpty ||
                        selectedOccasion.isEmpty ||
                        selectedGender.isEmpty ||
                        isLoading
                    ? null
                    : getColorSuggestions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Get Color Suggestions ✨",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            if (combos.isNotEmpty)
              ...List.generate(combos.length, (index) {
                final combo = combos[index] as Map<String, dynamic>;
                final imageUrl = comboImages.length > index
                    ? comboImages[index]
                    : "";
                return buildComboCard(combo, imageUrl, index);
              }),
          ],
        ),
      ),
    );
  }
}
