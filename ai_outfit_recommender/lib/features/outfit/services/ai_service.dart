import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_keys.dart';

class AIService {
  static final List<String> vibes = [
    "minimal chic",
    "modern streetwear",
    "elegant polished",
    "casual luxe",
    "bold trendy",
    "clean classy",
  ];

  static Future<Map<String, dynamic>> getOutfit({
    required String weather,
    required String occasion,
    required String gender,
  }) async {
    final randomVibe = vibes[Random().nextInt(vibes.length)];

    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${ApiKeys.openAIKey}",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "temperature": 1.1,
        "messages": [
          {
            "role": "system",
            "content":
                "You are a professional fashion stylist. Return only valid JSON with no markdown, no backticks, and no extra explanation.",
          },
          {
            "role": "user",
            "content":
                """
Generate 2 different outfit suggestions for:
Weather: $weather
Occasion: $occasion
Gender: $gender
Style vibe: $randomVibe

Rules:
- Outfit 1 and Outfit 2 must be clearly different.
- The clothing must match the selected gender.
- The clothing must match the weather and occasion.


Return ONLY this JSON format:
{
  "outfit1": {
    "title": "short stylish title",
    "outfit": "1-2 sentence outfit description",
    "colors": "comma separated colors",
    "tips": "1 short styling tip",

  },
  "outfit2": {
    "title": "short stylish title",
    "outfit": "1-2 sentence outfit description",
    "colors": "comma separated colors",
    "tips": "1 short styling tip",
    
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
      throw Exception("Failed to get outfit suggestions");
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

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${ApiKeys.openAIKey}",
      },
      body: jsonEncode({
        "model": "dall-e-2",
        "prompt":
            "full body $gender fashion model, wearing: $prompt, showing complete outfit from head to shoes, white studio background, professional fashion photography, entire body visible including feet",
        "n": 1,
        "size": "512x512",
      }),
    );

    print("IMAGE STATUS: ${response.statusCode}");
    print("IMAGE BODY: ${response.body}");

    final data = jsonDecode(response.body);
    return data["data"][0]["url"];
  }
}
