// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

/// Flutter Web ortamında görseli Web Share API veya tarayıcı indirme fallback'i ile paylaşır.
Future<bool> shareImageFile({
  required Uint8List pngBytes,
  required String fileName,
  required String caption,
}) async {
  try {
    final xFile = XFile.fromData(
      pngBytes,
      mimeType: 'image/png',
      name: fileName,
    );

    final result = await Share.shareXFiles(
      [xFile],
      text: caption,
      subject: 'Booktopia Alıntı Kartı',
    );

    if (result.status == ShareResultStatus.success ||
        result.status == ShareResultStatus.dismissed) {
      return true;
    }
  } catch (e) {
    debugPrint('[QuoteShareWeb] Web Share API kullanılamadı, indirme devreye giriyor: $e');
  }

  // Web Share API dosya paylaşımını desteklemeyen masaüstü tarayıcılarda doğrudan indir
  return downloadImageFile(pngBytes: pngBytes, fileName: fileName);
}

/// Web tarayıcısında PNG görselini anında kullanıcının İndirilenler klasörüne kaydeder.
Future<bool> downloadImageFile({
  required Uint8List pngBytes,
  required String fileName,
}) async {
  try {
    final blob = html.Blob([pngBytes], 'image/png');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);

    return true;
  } catch (e) {
    debugPrint('[QuoteShareWeb] downloadImageFile error: $e');
    rethrow;
  }
}
