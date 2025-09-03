import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';

class TrueHddService {
  /// Runs `truehdd.exe --help` and returns a stream of log lines.
  static Future<Stream<String>> runHelp() async {
    final process = await Process.start(
      "truehdd.exe",
      ["--help"],
      workingDirectory: Directory.current.path,
    );

    // Merge stdout and stderr into one stream of lines
    final outputStream = StreamGroup.merge([
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter()),
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .map((line) => "ERROR: $line"),
    ]);

    // Append exit code when process completes
    return outputStream.transform(
      StreamTransformer.fromHandlers(
        handleDone: (sink) async {
          final exitCode = await process.exitCode;
          sink.add("Process exited with code $exitCode");
          sink.close();
        },
      ),
    );
  }
}
