import 'dart:typed_data';

/// Platform-agnostik paylaşım ve dosya indirme stub arayüzü.
Future<bool> shareImageFile({
  required Uint8List pngBytes,
  required String fileName,
  required String caption,
}) {
  throw UnsupportedError('Platform paylaşımı desteklemiyor.');
}

Future<bool> downloadImageFile({
  required Uint8List pngBytes,
  required String fileName,
}) {
  throw UnsupportedError('Platform dosya indirmeyi desteklemiyor.');
}
