import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_keys.dart';

class AIService {
  static final List<String> vibes = [
    "minimal chic",
    "modern polished",
    "clean classy",
    "elegant smart casual",
    "structured refined",
    "soft power dressing",
  ];

  static final List<String> officePalettes = [
    "navy, white, beige",
    "charcoal, light blue, black",
    "olive, cream, brown",
    "taupe, white, camel",
    "black, grey, burgundy",
    "dusty blue, ivory, tan",
  ];

  static final List<String> casualPalettes = [
    "white, denim blue, beige",
    "black, grey, white",
    "olive, black, cream",
    "brown, ivory, blue",
    "pink, white, light denim",
    "green, beige, tan",
  ];

  static String getRandomPalette(String occasion) {
    final random = Random();
    if (occasion.toLowerCase() == "office") {
      return officePalettes[random.nextInt(officePalettes.length)];
    }
    return casualPalettes[random.nextInt(casualPalettes.length)];
  }

  static Future<Map<String, dynamic>> getOutfit({
    required String weather,
    required String occasion,
    required String gender,
  }) async {
    final random = Random();
    final randomVibe = vibes[random.nextInt(vibes.length)];
    final palette1 = getRandomPalette(occasion);
    String palette2 = getRandomPalette(occasion);

    while (palette2 == palette1) {
      palette2 = getRandomPalette(occasion);
    }

    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final isOffice = occasion.toLowerCase() == "office";

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${ApiKeys.openAIKey}",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "temperature": 1.0,
        "messages": [
          {
            "role": "system",
            "content":
                "You are a professional fashion stylist. Return only valid JSON. No markdown. No backticks. No explanation.",
          },
          {
            "role": "user",
            "content":
                """
Generate exactly 2 different outfit suggestions.

Context:
Weather: $weather
Occasion: $occasion
Gender: $gender
Style vibe: $randomVibe

Important rules:
- Outfit 1 and Outfit 2 must look clearly different.
- Use different clothing combinations.
- Use different color palettes for each outfit.
- Do not repeat the same main colors in both outfits.
- Keep descriptions short, stylish, and realistic.
- Match the selected gender.
- Match the selected weather.
- Match the selected occasion.

${isOffice ? """
For OFFICE occasion:
- Prioritize polished, structured, work-appropriate outfits.
- Avoid partywear, athleisure, hoodies, ripped jeans, flashy club looks, crop tops, bodycon party dresses, gym wear, and overly casual streetwear.
- Prefer items like blazers, trousers, smart blouses, button-down shirts, midi dresses, loafers, heels, ankle boots, structured skirts, knit tops, chinos, polished layers.
- office_fit must be one of:
  "startup casual", "business casual", "formal office"
- office_score must be between 7 and 10.
""" : """
For non-office occasions:
- Keep the outfit aligned with the selected occasion naturally.
- office_fit can be "not applicable"
- office_score can be between 1 and 10 based on office suitability.
"""}

Color palette rules:
- Outfit 1 palette: $palette1
- Outfit 2 palette: $palette2

Return ONLY this JSON:
{
  "outfit1": {
    "title": "short stylish title",
    "outfit": "1-2 sentence outfit description",
    "colors": "comma separated colors",
    "palette": "$palette1",
    "tips": "1 short styling tip",
    "office_score": 8,
    "office_fit": "business casual",
    "image_prompt": "full outfit visual prompt for image generation"
  },
  "outfit2": {
    "title": "short stylish title",
    "outfit": "1-2 sentence outfit description",
    "colors": "comma separated colors",
    "palette": "$palette2",
    "tips": "1 short styling tip",
    "office_score": 7,
    "office_fit": "startup casual",
    "image_prompt": "full outfit visual prompt for image generation"
  }
}
""",
          },
        ],
      }),
    );

    print("Chat API response:");
    print(response.body);

    if (response.statusCode != 200) {
      throw Exception("Failed to get outfit suggestions: ${response.body}");
    }

    final data = jsonDecode(response.body);
    String content = data["choices"][0]["message"]["content"];

    content = content.replaceAll("```json", "").replaceAll("```", "").trim();

    return jsonDecode(content) as Map<String, dynamic>;
  }

  static String cleanPrompt(String prompt) {
    return prompt
        .replaceAll('"', '')
        .replaceAll('\n', ' ')
        .replaceAll(':', '')
        .replaceAll(';', '')
        .trim();
  }

  static Future<String> generateOutfitImage(
    String prompt,
    String gender,
    String occasion,
  ) async {
    final url = Uri.parse("https://api.openai.com/v1/images/generations");

    final officeStyleNote = occasion.toLowerCase() == "office"
        ? "professional officewear, polished, modest, structured, business casual or formal office look, not casual streetwear"
        : "occasion appropriate styling";

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${ApiKeys.openAIKey}",
      },
      body: jsonEncode({
        "model": "dall-e-2",
        "prompt":
            "full body $gender fashion model wearing $prompt, $officeStyleNote, complete outfit from head to shoes, clean studio background, professional fashion photography, entire body visible including footwear",
        "n": 1,
        "size": "512x512",
      }),
    );

    print("IMAGE STATUS: ${response.statusCode}");
    print("IMAGE BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to generate image: ${response.body}");
    }

    final data = jsonDecode(response.body);
    return data["data"][0]["url"];
  }

  static Future<String> generateComboImage(
    String prompt,
    String gender,
    String occasion,
    String weather,
  ) async {
    final url = Uri.parse("https://api.openai.com/v1/images/generations");

    final occasionStyle = occasion.toLowerCase() == "office"
        ? "professional officewear, polished, modest, structured, business casual or formal office look"
        : "occasion-appropriate styling";

    final effectivePrompt = prompt.trim().isNotEmpty
        ? "fashion image showing the exact colors in $prompt as a side-by-side palette and a $gender model wearing the combo in $weather weather for $occasion. Show the selected color palette clearly with swatches or color blocks alongside the outfit. $occasionStyle, clean studio background, modern fashion photography"
        : "fashion image showing a $gender model wearing a stylish outfit for $occasionStyle in $weather weather, with color swatches and moodboard elements, clean studio background, modern fashion photography";

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${ApiKeys.openAIKey}",
      },
      body: jsonEncode({
        "model": "dall-e-2",
        "prompt": effectivePrompt,
        "n": 1,
        "size": "512x512",
      }),
    );

    print("IMAGE STATUS: ${response.statusCode}");
    print("IMAGE BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to generate image: ${response.body}");
    }

    final data = jsonDecode(response.body);
    return data["data"][0]["url"];
  }

  static Future<Map<String, dynamic>> getColorComboSuggestions({
    required List<String> colors,
    required String weather,
    required String occasion,
    required String gender,
  }) async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${ApiKeys.openAIKey}",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "temperature": 0.9,
        "messages": [
          {
            "role": "system",
            "content":
                "You are a professional fashion stylist. Return only valid JSON. No markdown. No backticks. No explanation.",
          },
          {
            "role": "user",
            "content":
                """
The user already owns these color families:
${colors.join(", ")}

Context:
Weather: $weather
Occasion: $occasion
Gender: $gender

Task:
Suggest exactly 3 stylish color combinations using only or mostly these colors.
Keep them realistic, wearable, and suitable for the selected context.
Each combo must include an image_prompt that asks for the exact listed colors to be shown on a model wearing the combo and preferably also as swatches or a side-by-side palette.

Return ONLY this JSON:
{
  "combos": [
    {
      "title": "short combo name",
      "colors": "comma separated colors",
      "why_it_works": "1 short explanation",
      "style_tip": "1 short styling tip",
      "image_prompt": "detailed prompt describing exact colors for a model wearing the combo, with palette swatches or side-by-side colors"
    },
    {
      "title": "short combo name",
      "colors": "comma separated colors",
      "why_it_works": "1 short explanation",
      "style_tip": "1 short styling tip",
      "image_prompt": "detailed prompt describing exact colors for a model wearing the combo, with palette swatches or side-by-side colors"
    },
    {
      "title": "short combo name",
      "colors": "comma separated colors",
      "why_it_works": "1 short explanation",
      "style_tip": "1 short styling tip",
      "image_prompt": "detailed prompt describing exact colors for a model wearing the combo, with palette swatches or side-by-side colors"
    }
  ]
}
""",
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to get color combo suggestions: ${response.body}",
      );
    }

    final data = jsonDecode(response.body);
    String content = data["choices"][0]["message"]["content"];
    content = content.replaceAll("```json", "").replaceAll("```", "").trim();

    return jsonDecode(content) as Map<String, dynamic>;
  }
}
