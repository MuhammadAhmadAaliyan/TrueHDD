import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme_manager.dart';
import 'app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeManager = ThemeManager();
  await themeManager.loadTheme();

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeManager,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return MaterialApp(
      title: "TrueHDD GUI",
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeManager.themeMode,
      home: const MyHomePage(title: "TrueHDD GUI"),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      body: Column(
        children: [
          //Menu bar
          Container(
            height: 28,
            color: AppTheme.menuBarColor(brightness),
            child: Row(
              children: [
                // Help Menu
                PopupMenuButton<String>(
                  tooltip: "",
                  offset: const Offset(0, 28),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.help_outline,
                            color: AppTheme.menuTextColor(brightness), size: 18),
                        const SizedBox(width: 5),
                        Text(
                          "Help",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.menuTextColor(brightness),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onSelected: (value) {},
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: "info", child: Text("Info")),
                    PopupMenuItem(value: "decode", child: Text("Decode")),
                    PopupMenuItem(value: "aboutApp", child: Text("About App")),
                  ],
                ),

                const SizedBox(width: 30),

                // Appearance Menu
                PopupMenuButton<String>(
                  tooltip: "",
                  offset: const Offset(0, 28),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.palette_outlined,
                            color: AppTheme.menuTextColor(brightness), size: 18),
                        const SizedBox(width: 5),
                        Text(
                          "Appearance",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.menuTextColor(brightness),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onSelected: (value) {
                    if (value == "systemDefault") {
                      themeManager.setTheme(ThemeMode.system);
                    } else if (value == "light") {
                      themeManager.setTheme(ThemeMode.light);
                    } else if (value == "dark") {
                      themeManager.setTheme(ThemeMode.dark);
                    }
                  },
                  itemBuilder: (context) {
                    final currentMode = themeManager.themeMode;
                    return [
                      _buildThemeOption("System Default", ThemeMode.system, currentMode),
                      _buildThemeOption("Light", ThemeMode.light, currentMode),
                      _buildThemeOption("Dark", ThemeMode.dark, currentMode),
                    ];
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildThemeOption(
      String text, ThemeMode mode, ThemeMode currentMode) {
    return PopupMenuItem(
      value: mode == ThemeMode.system
          ? "systemDefault"
          : mode == ThemeMode.light
              ? "light"
              : "dark",
      child: Row(
        children: [
          if (currentMode == mode)
            const Icon(Icons.check, size: 16)
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}