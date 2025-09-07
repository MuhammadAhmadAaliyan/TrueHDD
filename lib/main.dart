import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

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

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final ScrollController _analysisVerticalController = ScrollController();
  final ScrollController _analysisHorizontalController = ScrollController();
  final ScrollController _logVerticalController = ScrollController();
  final ScrollController _logHorizontalController = ScrollController();

  // Dropdown + Switch state
  String logFormat = "Plain";
  String logLevel = "Info";
  bool strict = false;
  double progress = 0.4; // 40% example

  final List<String> logFormats = ["Plain", "JSON"];
  final List<String> logLevels = [
    "Off",
    "Info",
    "Debug",
    "Warn",
    "Error",
    "Trace",
  ];

  Future<void> _pickInputFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['thd', 'mlp'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _inputController.text = result.files.single.path!;
      });
    }
  }

  Future<void> _pickOutputFolder() async {
    String? result = await FilePicker.platform.getDirectoryPath();

    if (result != null) {
      setState(() {
        _outputController.text = result;
      });
    }
  }

  Widget _buildPathRow({
    required String label,
    required TextEditingController controller,
    required VoidCallback onBrowse,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.inputLogAndDropDownBgColor(
                  Theme.of(context).brightness,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: controller,
                readOnly: true,
                style: TextStyle(
                  color: AppTheme.textColor(Theme.of(context).brightness),
                  fontFamily: "Inter",
                ),
                decoration: InputDecoration(
                  hintText: label,
                  hintStyle: TextStyle(
                    color: AppTheme.hintColor(Theme.of(context).brightness),
                    fontFamily: "Inter",
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onBrowse,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF9929EA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.folder_open,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textColor(brightness),
              fontSize: 14,
              fontFamily: "Inter",
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: AppTheme.inputLogAndDropDownBgColor(brightness),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: value,
              underline: const SizedBox(),
              dropdownColor: AppTheme.menuBarAndMainAreaColor(brightness),
              borderRadius: BorderRadius.circular(15),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              style: TextStyle(
                color: AppTheme.textColor(brightness),
                fontSize: 14,
                fontFamily: "Inter",
              ),
              items: items
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: "Inter",
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: brightness == Brightness.dark
                ? Color(0xFFc17cf2)
                : Color(0xFF9929EA),
            inactiveTrackColor: AppTheme.inputLogAndDropDownBgColor(brightness),
            activeThumbColor: brightness == Brightness.dark
                ? Color(0xFF3c0960)
                : Color(0xFFFFFFFF),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow({required String label, required double value}) {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: "Inter",
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: LinearProgressIndicator(
                value: value, // 0.0 → 1.0
                minHeight: 20,
                backgroundColor: AppTheme.inputLogAndDropDownBgColor(
                  brightness,
                ),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF9929EA),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "${(value * 100).toStringAsFixed(0)}%", // percentage text
            style: const TextStyle(
              fontSize: 14,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonRow() {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          // Cancel Button (on left)
          SizedBox(
            height: 40, // fixed height
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2727),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onPressed: () {
                // Cancel logic
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const Spacer(), // pushes Info + Decode to the right
          // Info Button (outlined)
          SizedBox(
            height: 40,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF9929EA), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onPressed: () {
                // Info logic
              },
              child: Text(
                "Info",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor(brightness),
                ),
              ),
            ),
          ),

          const SizedBox(width: 30), // space between Info and Decode
          // Decode Button
          SizedBox(
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9929EA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onPressed: () {
                // Decode logic
              },
              child: const Text(
                "Decode",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // dispose text controllers
    _inputController.dispose();
    _outputController.dispose();

    // dispose analysis controllers
    _analysisVerticalController.dispose();
    _analysisHorizontalController.dispose();

    // dispose log controllers
    _logVerticalController.dispose();
    _logHorizontalController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Menu bar
          Container(
            height: 28,
            color: AppTheme.menuBarAndMainAreaColor(brightness),
            child: Row(
              children: [
                PopupMenuButton<String>(
                  tooltip: "",
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  offset: const Offset(0, 28),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: AppTheme.textColor(brightness),
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "Help",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textColor(brightness),
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
                PopupMenuButton<String>(
                  tooltip: "",
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  offset: const Offset(0, 28),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.palette_outlined,
                          color: AppTheme.textColor(brightness),
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "Appearance",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textColor(brightness),
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

          // App Title with Image
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "assests/images/App Logo.jpg",
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "TrueHDD",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.bold,
                    color: AppTheme.tickAndTitleColor(brightness),
                  ),
                ),
              ],
            ),
          ),
          //Main Area
          const SizedBox(height: 6),

          Expanded(
            child: Row(
              children: [
                // Left panel (flex 1)
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.menuBarAndMainAreaColor(brightness),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPathRow(
                          label: "Select input file(.thd/.mlp/etc)",
                          controller: _inputController,
                          onBrowse: _pickInputFile,
                        ),
                        const SizedBox(height: 20),
                        _buildPathRow(
                          label: "Select output folder(for Decode)",
                          controller: _outputController,
                          onBrowse: _pickOutputFolder,
                        ),
                        const SizedBox(height: 50),
                        _buildDropdownRow(
                          label: "Log Format:",
                          value: logFormat,
                          items: logFormats,
                          onChanged: (val) {
                            setState(() {
                              logLevel = val!;
                            });
                          },
                        ),
                        const SizedBox(height: 35),
                        _buildDropdownRow(
                          label: "Log Level:",
                          value: logLevel,
                          items: logLevels,
                          onChanged: (val) {
                            setState(() {
                              logLevel = val!;
                            });
                          },
                        ),
                        const SizedBox(height: 35),
                        _buildSwitchRow(
                          label: "Strict:",
                          value: strict,
                          onChanged: (val) {
                            setState(() {
                              strict = val;
                            });
                          },
                        ),
                        const SizedBox(height: 45),
                        _buildProgressRow(label: "Progress:", value: progress),
                        const SizedBox(height: 30),
                        Expanded(child: Container()),
                        _buildButtonRow(),
                      ],
                    ),
                  ),
                ),

                // Right panel (flex 1)
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.menuBarAndMainAreaColor(brightness),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top container: Analysis Summary
                        Expanded(
                          flex: 1, // shorter height
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.inputLogAndDropDownBgColor(
                                brightness,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Title
                                Center(
                                  child: Text(
                                    "Analysis Summary:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: "Inter",
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textColor(brightness),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Scrollable content
                                Expanded(
                                  child: Scrollbar(
                                    controller: _analysisHorizontalController,
                                    thumbVisibility: true,
                                    trackVisibility: true,
                                    notificationPredicate: (notif) =>
                                        notif.metrics.axis == Axis.horizontal,
                                    child: Scrollbar(
                                      controller: _analysisVerticalController,
                                      thumbVisibility: true,
                                      trackVisibility: true,
                                      notificationPredicate: (notif) =>
                                          notif.metrics.axis == Axis.vertical,
                                      child: SingleChildScrollView(
                                        controller:
                                            _analysisHorizontalController,
                                        scrollDirection: Axis.horizontal,
                                        child: SingleChildScrollView(
                                          controller:
                                              _analysisVerticalController,
                                          scrollDirection: Axis.vertical,
                                          child: SelectableText(
                                            """Some very long text here ...""",
                                            style: TextStyle(
                                              fontFamily: "FiraCode",
                                              color:
                                                  AppTheme.logAndAnalysisAreaTextColor(
                                                    brightness,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Bottom container: Output Log
                        Expanded(
                          flex: 2, // taller height
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.inputLogAndDropDownBgColor(
                                brightness,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Title
                                Center(
                                  child: Text(
                                    "Output Log:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: "Inter",
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textColor(brightness),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Scrollable content
                                Expanded(
                                  child: Scrollbar(
                                    controller: _logHorizontalController,
                                    thumbVisibility: true,
                                    trackVisibility: true,
                                    notificationPredicate: (notif) =>
                                        notif.metrics.axis == Axis.horizontal,
                                    child: Scrollbar(
                                      controller: _logVerticalController,
                                      thumbVisibility: true,
                                      trackVisibility: true,
                                      notificationPredicate: (notif) =>
                                          notif.metrics.axis == Axis.vertical,
                                      child: SingleChildScrollView(
                                        controller: _logHorizontalController,
                                        scrollDirection: Axis.horizontal,
                                        child: SingleChildScrollView(
                                          controller: _logVerticalController,
                                          scrollDirection: Axis.vertical,
                                          child: SelectableText(
                                            """Log line 1: starting decode...
Log line 2: processing input file...
Log line 3: warning: header mismatch
Log line 4: decode finished successfully ✅""",
                                            style: TextStyle(
                                              fontFamily: "FiraCode",
                                              color:
                                                  AppTheme.logAndAnalysisAreaTextColor(
                                                    brightness,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
    return PopupMenuItem<String>(
      value: mode == ThemeMode.system
          ? "systemDefault"
          : mode == ThemeMode.light
          ? "light"
          : "dark",
      child: Row(
        children: [
          if (currentMode == mode)
            Icon(
              Icons.check,
              size: 18,
              color: AppTheme.tickAndTitleColor(Theme.of(context).brightness),
            )
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: AppTheme.textColor(Theme.of(context).brightness),
              fontFamily: "Inter",
            ),
          ),
        ],
      ),
    );
  }
}
