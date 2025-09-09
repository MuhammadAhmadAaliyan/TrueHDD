import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'services/truehdd_service.dart';
import 'package:path/path.dart' as p;

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
  String _selectedFileName = "";
  bool strict = false;
  bool _inAnalysisSummary = false;
  double progress = 0.0;

  final List<String> _logs = [];
  final List<String> logFormats = ["Plain", "JSON"];
  final List<String> logLevels = [
    "Off",
    "Info",
    "Debug",
    "Warn",
    "Error",
    "Trace",
  ];
  final List<String> _analysisSummary = [];

  // Helper to append logs safely
  void _appendLog(String line) {
    setState(() {
      // Handle summary section
      if (_inAnalysisSummary) {
        if (line.startsWith("Process exited with code")) {
          _logs.add(line); // exit code -> log only
        } else if (line.trim().isNotEmpty) {
          _analysisSummary.add(line);
        }
      } else if (line.contains("Analysis Summary")) {
        // Switch to summary mode
        _inAnalysisSummary = true;
        _analysisSummary.clear(); // remove "Processing..."
      } else {
        // Normal log
        _logs.add(line);

        // Progress update driven by log count
        // Each new log moves bar forward until process exit
        if (progress < 0.95) {
          progress += 0.02; // smooth increment
          if (progress > 0.95) progress = 0.95; // keep room for final 100%
        }
      }

      // Ensure 100% on exit
      if (line.startsWith("Process exited with code")) {
        progress = 1.0;
      }
    });

    // Auto-scroll logs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logVerticalController.hasClients) {
        _logVerticalController.jumpTo(
          _logVerticalController.position.maxScrollExtent,
        );
      }
    });
  }

  Future<void> _runInfo() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      _showAlert("Missing Input", "Please select an Input file");
      return;
    }

    setState(() {
      _logs.clear();
      _analysisSummary
        ..clear()
        ..add("Processing...");
      _inAnalysisSummary = false;
      progress = 0.0;
    });

    // Build options only if not default
    final options = <String>[];
    if (logLevel.toLowerCase() != "info") {
      options.addAll(["--loglevel", logLevel.toLowerCase()]);
    }
    if (logFormat.toLowerCase() != "plain") {
      options.addAll(["--log-format", logFormat.toLowerCase()]);
    }
    if (strict) {
      options.add("--strict");
    }

    final stream = await TrueHddService.runInfo(
      inputPath: input,
      options: options,
    );

    stream.listen((line) {
      _appendLog(line);
    });
  }

  Future<void> _runDecode() async {
    final input = _inputController.text.trim();
    String output = _outputController.text.trim();

    if (input.isEmpty) {
      _showAlert("Missing Input", "Please select an Input file.");
      return;
    }

    if (output.isEmpty) {
      _showAlert("Missing Output", "Please select folder for Output.");
      return;
    }

    setState(() {
      _logs.clear();
      _analysisSummary.clear();
      _inAnalysisSummary = false;
      progress = 0.0;
    });

    final options = <String>[];
    final outputPath = p.join(output, _selectedFileName);
    if (logLevel.toLowerCase() != "info") {
      options.addAll(["--loglevel", logLevel.toLowerCase()]);
    }
    if (logFormat.toLowerCase() != "plain") {
      options.addAll(["--log-format", logFormat.toLowerCase()]);
    }
    if (strict) {
      options.add("--strict");
    }

    // Always add output path for decode
    options.addAll(["--output-path", outputPath]);

    final stream = await TrueHddService.runDecode(
      inputPath: input,
      options: options,
    );

    stream.listen((line) {
      _appendLog(line);
    });
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickInputFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['thd', 'mlp'],
    );

    if (result != null && result.files.single.path != null) {
      String fullPath = result.files.single.path!;
      String fileName = p.basename(fullPath);
      setState(() {
        _inputController.text = fullPath;
        _selectedFileName = fileName;
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
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.inputLogAndDropDownBgColor(brightness),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  return TextField(
                    readOnly: true,
                    controller: controller,
                    style: TextStyle(
                      color: AppTheme.textColor(brightness),
                      fontFamily: "Inter",
                    ),
                    decoration: InputDecoration(
                      hintText: label,
                      hintStyle: TextStyle(
                        color: AppTheme.hintColor(brightness),
                        fontFamily: "Inter",
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      suffixIcon: value.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              color: AppTheme.hintColor(brightness),
                              splashColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onPressed: () => controller.clear(),
                            )
                          : null,
                    ),
                  );
                },
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
                gradient: AppTheme.buttonGradient(brightness),
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
            activeTrackColor: AppTheme.switchTrackColor(brightness),
            inactiveTrackColor: AppTheme.inputLogAndDropDownBgColor(brightness),
            activeThumbColor: AppTheme.switchThumbColor(brightness),
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

          // Progress Bar
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  // Background (unfilled area)
                  Container(
                    height: 20,
                    color: AppTheme.inputLogAndDropDownBgColor(brightness),
                  ),

                  // Filled Area (depends on theme)
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value, // progress value (0.0 → 1.0)
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: brightness == Brightness.light
                            ? const Color(0xFF9929EA) // Solid for light mode
                            : null,
                        gradient: brightness == Brightness.dark
                            ? const LinearGradient(
                                colors: [Color(0xFF9929EA), Color(0xFFE754FF)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Percentage Text
          Text(
            "${(value * 100).toStringAsFixed(0)}%",
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
          // Cancel Button (Gradient Background)
          SizedBox(
            height: 40,
            child: ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ).copyWith(
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                  ),
              onPressed: () {
                // Cancel logic
              },
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AppTheme.cancelButtonGradient(brightness),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          // Info Button (Gradient Border only)
          // Info Button (Gradient Border ONLY)
          SizedBox(
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.infoButtonBorderGradient(brightness),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(2), // Border thickness
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.menuBarAndMainAreaColor(
                    brightness,
                  ), // match bg so only border shows
                  borderRadius: BorderRadius.circular(10),
                ),
                child: OutlinedButton(
                  style:
                      OutlinedButton.styleFrom(
                        side: BorderSide.none, // Remove default border
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ).copyWith(
                        overlayColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                  onPressed: () {
                    _runInfo();
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
            ),
          ),

          const SizedBox(width: 30),

          // Decode Button (Gradient Background)
          SizedBox(
            height: 40,
            child: ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ).copyWith(
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                  ),
              onPressed: () {
                _runDecode();
              },
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AppTheme.buttonGradient(brightness),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text(
                    "Decode",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
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
                              logFormat = val!;
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
                                    controller: _analysisVerticalController,
                                    thumbVisibility: true,
                                    //trackVisibility: true,
                                    notificationPredicate: (notif) =>
                                        notif.metrics.axis == Axis.vertical,
                                    child: Scrollbar(
                                      controller: _analysisHorizontalController,
                                      thumbVisibility: true,
                                      //trackVisibility: true,
                                      notificationPredicate: (notif) =>
                                          notif.metrics.axis == Axis.horizontal,
                                      child: SingleChildScrollView(
                                        controller: _analysisVerticalController,
                                        scrollDirection: Axis.vertical,
                                        child: SingleChildScrollView(
                                          controller: _analysisHorizontalController,
                                          scrollDirection: Axis.horizontal,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right:
                                                  12, // space for vertical scrollbar
                                              bottom:
                                                  12, // space for horizontal scrollbar
                                            ),
                                            child: SelectableText(
                                              _analysisSummary.join("\n"),
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
                                    controller: _logVerticalController,
                                    thumbVisibility: true,
                                    //trackVisibility: true,
                                    notificationPredicate: (notif) =>
                                        notif.metrics.axis == Axis.vertical,
                                    child: Scrollbar(
                                      controller: _logHorizontalController,
                                      thumbVisibility: true,
                                      //trackVisibility: true,
                                      notificationPredicate: (notif) =>
                                          notif.metrics.axis == Axis.horizontal,
                                      child: SingleChildScrollView(
                                        controller: _logVerticalController,
                                        scrollDirection: Axis.vertical,
                                        child: SingleChildScrollView(
                                          controller: _logHorizontalController,
                                          scrollDirection: Axis.horizontal,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 12,
                                              bottom: 12,
                                            ),
                                            child: SelectableText(
                                              _logs.join("\n"),
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
