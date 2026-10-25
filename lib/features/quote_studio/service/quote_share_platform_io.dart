// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Mobil / Masaüstü ortamında görseli geçici dosyaya kaydedip sistem paylaşım menüsünü açar.
Future<bool> shareImageFile({
  required Uint8List pngBytes,
  required String fileName,
  required String caption,
}) async {
  try {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(pngBytes, flush: true);

    final xFile = XFile(
      file.path,
      mimeType: 'image/png',
      name: fileName,
    );

    final result = await Share.shareXFiles(
      [xFile],
      text: caption,
      subject: 'Booktopia Alıntı Kartı',
    );

    // Paylaşım menüsü açıldığında veya işlem tamamlandığında başarılı sayılır
    return result.status == ShareResultStatus.success ||
        result.status == ShareResultStatus.dismissed;
  } catch (e) {
    debugPrint('[QuoteShareIO] shareImageFile error: $e');
    rethrow;
  }
}

/// Mobil ortamda görseli indirilenler veya geçici dizine kaydeder.
Future<bool> downloadImageFile({
  required Uint8List pngBytes,
  required String fileName,
}) async {
  try {
    Directory? targetDir;
    try {
      targetDir = await getDownloadsDirectory();
    } catch (_) {
      targetDir = null;
    }
    targetDir ??= await getApplicationDocumentsDirectory();

    final file = File('${targetDir.path}/$fileName');
    await file.writeAsBytes(pngBytes, flush: true);
    debugPrint('[QuoteShareIO] Dosya kaydedildi: ${file.path}');
    return true;
  } catch (e) {
    debugPrint('[QuoteShareIO] downloadImageFile error: $e');
    rethrow;
  }
}
