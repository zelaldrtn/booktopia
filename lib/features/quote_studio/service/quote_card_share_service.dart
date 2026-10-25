import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'quote_share_platform_stub.dart'
    if (dart.library.io) 'quote_share_platform_io.dart'
    if (dart.library.html) 'quote_share_platform_web.dart' as platform;

/// Quote Studio alıntı kartlarını görsel (PNG) olarak dışa aktarma,
/// sistem paylaşım menüsüne gönderme ve cihaza indirme servisi.
class QuoteCardShareService {
  QuoteCardShareService._();
  static final QuoteCardShareService instance = QuoteCardShareService._();

  /// Verilen GlobalKey'e bağlı RepaintBoundary'den yüksek çözünürlüklü PNG üretir.
  Future<Uint8List?> captureCardImage(
    GlobalKey boundaryKey, {
    double pixelRatio = 3.0,
  }) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('[QuoteCardShareService] RenderRepaintBoundary bulunamadı.');
        return null;
      }

      // 3.0 pixelRatio ile Instagram Story / WhatsApp için 1080px+ kristal netliğinde görsel
      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        debugPrint('[QuoteCardShareService] PNG ByteData dönüştürülemedi.');
        return null;
      }

      return byteData.buffer.asUint8List();
    } catch (e, stackTrace) {
      debugPrint('[QuoteCardShareService] captureCardImage error: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Görsel kartı platforma uygun biçimde paylaşır (Android Paylaşım Menüsü veya Web Share/İndirme).
  Future<bool> shareQuoteCard({
    required Uint8List pngBytes,
    required String fileName,
    required String caption,
  }) async {
    return platform.shareImageFile(
      pngBytes: pngBytes,
      fileName: fileName,
      caption: caption,
    );
  }

  /// Görsel kartı doğrudan cihaz hafızasına / İndirilenlere kaydeder.
  Future<bool> downloadQuoteCard({
    required Uint8List pngBytes,
    required String fileName,
  }) async {
    return platform.downloadImageFile(
      pngBytes: pngBytes,
      fileName: fileName,
    );
  }
}
