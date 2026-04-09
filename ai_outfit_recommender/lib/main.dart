import 'package:flutter/material.dart';
import 'features/outfit/screens/outfit_screen.dart';
import 'features/outfit/services/saved_outfits_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Load saved outfits before app starts
  await SavedOutfitsService.loadOutfits();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: OutfitScreen());
  }
}
