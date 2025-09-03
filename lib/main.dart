import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme_manager.dart';
import 'app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeManager = ThemeManager();
  await themeManager.loadTheme();

  runApp(
    ChangeNotifierProvider(create: (_) => themeManager, child: const MyApp()),
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
    final titleColor = brightness == Brightness.light ? const Color(0xFF9929EA): Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        Icon(
                          Icons.help_outline,
                          color: AppTheme.menuTextColor(brightness),
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "Help",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w500,
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
                        Icon(
                          Icons.palette_outlined,
                          color: AppTheme.menuTextColor(brightness),
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "Appearance",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w500,
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
                      _buildThemeOption(
                        "System Default",
                        ThemeMode.system,
                        currentMode,
                        context,
                      ),
                      _buildThemeOption(
                        "Light",
                        ThemeMode.light,
                        currentMode,
                        context,
                      ),
                      _buildThemeOption(
                        "Dark",
                        ThemeMode.dark,
                        currentMode,
                        context,
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          //App Title with Image
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "assests/images/App Logo.jpg",
                    width: 45,
                    height: 45,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "TrueHDD",
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.bold,
                    color: titleColor
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildThemeOption(
    String text,
    ThemeMode mode,
    ThemeMode currentMode,
    BuildContext context,
  ) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final checkColor = isLight ? const Color(0xFF9929EA) : Colors.white;

    return PopupMenuItem<String>(
      value: mode == ThemeMode.system
          ? "systemDefault"
          : mode == ThemeMode.light
          ? "light"
          : "dark",
      child: Row(
        children: [
          if (currentMode == mode)
            Icon(Icons.check, size: 18, color: checkColor)
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: AppTheme.menuTextColor(Theme.of(context).brightness),
              fontFamily: "Inter",
            ),
          ),
        ],
      ),
    );
  }
}
