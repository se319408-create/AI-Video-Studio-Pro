import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

class FFmpegService {
  static Future<void> resizeVideo({required String inputPath, required String outputPath, int? height}) async {
    final scale = height == null ? 'scale=iw:ih' : 'scale=-2:$height';
    await _execute(['-y', '-i', inputPath, '-vf', scale, '-c:v', 'libx264', '-crf', '23', '-c:a', 'aac', outputPath]);
  }

  static Future<void> convertAudio({required String inputPath, required String outputPath, required String format}) async {
    final args = <String>['-y', '-i', inputPath, '-vn'];
    if (format == 'mp3') args.addAll(['-c:a', 'libmp3lame', '-q:a', '2']);
    if (format == 'm4a') args.addAll(['-c:a', 'aac', '-b:a', '192k']);
    if (format == 'wav') args.addAll(['-c:a', 'pcm_s16le']);
    args.add(outputPath);
    await _execute(args);
  }

  static Future<void> exportVideo({required String inputPath, required String outputPath, required bool saver}) async {
    final args = <String>['-y', '-i', inputPath, '-c:v', saver ? 'libx265' : 'libx264'];
    args.addAll(saver
        ? ['-crf', '28', '-preset', 'fast', '-c:a', 'aac', '-b:a', '64k']
        : ['-crf', '23', '-preset', 'medium', '-c:a', 'aac', '-b:a', '128k']);
    args.add(outputPath);
    await _execute(args);
  }

  static Future<void> _execute(List<String> arguments) async {
    final session = await FFmpegKit.executeWithArguments(arguments);
    final returnCode = await session.getReturnCode();
    if (!ReturnCode.isSuccess(returnCode)) {
      final details = await session.getFailStackTrace();
      throw Exception(details ?? 'FFmpeg exited with code ${returnCode?.getValue() ?? 'unknown'}');
    }
  }
}