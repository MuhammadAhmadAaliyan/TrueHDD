import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';

class TrueHddService {
  /// Runs a `truehdd` command with given subcommand, options and input.
  static Future<Stream<String>> _runCommand(
    String subcommand, {
    required String inputPath,
    List<String>? options,
    bool forceProgress = false,
  }) async {
    // Build command arguments
    final args = <String>[subcommand];

    if (options != null && options.isNotEmpty) {
      args.addAll(options);
    }

    // For decode, always add --progress
    if (forceProgress) {
      if (!args.contains("--progress")) {
        args.add("--progress");
      }
    }

    args.add(inputPath);

    final process = await Process.start(
      "truehdd.exe",
      args,
      workingDirectory: Directory.current.path,
    );

    // Merge stdout and stderr into one stream of lines
    // Merge stdout and stderr into one stream of lines
    final stdoutStream = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    final stderrStream = process.stderr
        .transform(utf8.decoder)
        .expand((chunk) {
          // Split both on \n and \r so we capture progress updates
          return chunk.split(RegExp(r'[\r\n]+'));
        })
        .where((line) => line.trim().isNotEmpty);

    final outputStream = StreamGroup.merge([stdoutStream, stderrStream]);

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

  /// Runs `truehdd info [OPTIONS] <INPUT>`
  static Future<Stream<String>> runInfo({
    required String inputPath,
    List<String>? options,
  }) {
    return _runCommand("info", inputPath: inputPath, options: options);
  }

  /// Runs `truehdd decode [OPTIONS] <INPUT>` (always with --progress)
  static Future<Stream<String>> runDecode({
    required String inputPath,
    List<String>? options,
  }) {
    return _runCommand(
      "decode",
      inputPath: inputPath,
      options: options,
      forceProgress: true,
    );
  }
}
