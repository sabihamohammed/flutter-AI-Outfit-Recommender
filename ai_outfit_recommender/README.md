# 👗 AI Outfit Recommender (Flutter + OpenAI)

A modern Flutter mobile application that generates personalized outfit suggestions using AI based on user inputs like weather, occasion, and gender.

The app combines **LLM-powered recommendations** with **AI-generated outfit visuals**, delivering a smart and interactive fashion assistant experience.

---

## 🚀 Features

- 🎯 Personalized outfit recommendations using AI
- 🌦️ Context-aware suggestions (Weather + Occasion)
- 👤 Gender-based styling logic
- 🎨 Randomized style “vibes” for varied outputs
- 🖼️ AI-generated outfit images (full-body fashion visuals)
- 🔁 Dynamic results — different outfits every time
- 💅 Modern UI with gradients, animations, and cards
- ⚡ Fast API integration with real-time results

---

## 🧠 How It Works

1. User selects:
   - Weather (Sunny / Rainy / Cold)
   - Occasion (Party / Office / Gym)
   - Gender (Male / Female)

2. App sends request to OpenAI API:
   - Generates 2 unique outfit suggestions
   - Includes styling tips, colors, and image prompts

3. Image generation:
   - Uses prompt → converts into image URL
   - Displays full-body outfit visuals

4. UI renders:
   - Stylish cards with outfit + image + tips

---

## 🛠️ Tech Stack

### Frontend
- Flutter (Dart)
- Material UI
- Responsive layout & animations

### Backend / AI
- OpenAI API (`gpt-4o-mini`)
- Prompt engineering for structured JSON output

### Image Generation
- Pollinations AI (text → image)

### Networking
- `http` package for API calls

---


