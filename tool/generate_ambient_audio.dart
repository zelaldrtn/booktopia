// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() async {
  final outputDir = Directory('assets/audio');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  const sampleRate = 22050; // 22.05 kHz stereo
  const durationSeconds = 8.0;
  final totalSamples = (sampleRate * durationSeconds).toInt();

  print('Generating ambient soundscapes ($totalSamples samples, stereo, $sampleRate Hz)...');

  // 1. Rain
  final rainBytes = generateRain(sampleRate, totalSamples);
  File('assets/audio/rain.wav').writeAsBytesSync(rainBytes);
  print('✓ Generated assets/audio/rain.wav (${rainBytes.length} bytes)');

  // 2. Fireplace
  final fireplaceBytes = generateFireplace(sampleRate, totalSamples);
  File('assets/audio/fireplace.wav').writeAsBytesSync(fireplaceBytes);
  print('✓ Generated assets/audio/fireplace.wav (${fireplaceBytes.length} bytes)');

  // 3. Library
  final libraryBytes = generateLibrary(sampleRate, totalSamples);
  File('assets/audio/library.wav').writeAsBytesSync(libraryBytes);
  print('✓ Generated assets/audio/library.wav (${libraryBytes.length} bytes)');

  // 4. Cafe
  final cafeBytes = generateCafe(sampleRate, totalSamples);
  File('assets/audio/cafe.wav').writeAsBytesSync(cafeBytes);
  print('✓ Generated assets/audio/cafe.wav (${cafeBytes.length} bytes)');

  print('All ambient sounds generated successfully!');
}

/// Applies a smooth circular loop crossfade so looping is seamless.
void applyLoopCrossfade(Float64List left, Float64List right, int sampleRate, double fadeSec) {
  final fadeSamples = (sampleRate * fadeSec).toInt().clamp(1, left.length ~/ 4);
  final total = left.length;

  for (int i = 0; i < fadeSamples; i++) {
    final t = i / fadeSamples;
    // Equal power crossfade
    final gainIn = sin(t * pi / 2);
    final gainOut = cos(t * pi / 2);

    final startIdx = i;
    final endIdx = total - fadeSamples + i;

    final blendedL = left[startIdx] * gainIn + left[endIdx] * gainOut;
    final blendedR = right[startIdx] * gainIn + right[endIdx] * gainOut;

    left[startIdx] = blendedL;
    right[startIdx] = blendedR;
    left[endIdx] = blendedL;
    right[endIdx] = blendedR;
  }
}

/// Creates a standard 16-bit PCM Stereo WAV file
Uint8List encodeWav(Float64List left, Float64List right, int sampleRate) {
  final numSamples = left.length;
  final numChannels = 2;
  final bytesPerSample = 2; // 16-bit
  final byteRate = sampleRate * numChannels * bytesPerSample;
  final blockAlign = numChannels * bytesPerSample;
  final dataSize = numSamples * blockAlign;
  final fileSize = 36 + dataSize;

  final buffer = ByteData(44 + dataSize);

  // RIFF Chunk Descriptor
  buffer.setUint8(0, 0x52); // 'R'
  buffer.setUint8(1, 0x49); // 'I'
  buffer.setUint8(2, 0x46); // 'F'
  buffer.setUint8(3, 0x46); // 'F'
  buffer.setUint32(4, fileSize, Endian.little);
  buffer.setUint8(8, 0x57);  // 'W'
  buffer.setUint8(9, 0x41);  // 'A'
  buffer.setUint8(10, 0x56); // 'V'
  buffer.setUint8(11, 0x45); // 'E'

  // "fmt " sub-chunk
  buffer.setUint8(12, 0x66); // 'f'
  buffer.setUint8(13, 0x6D); // 'm'
  buffer.setUint8(14, 0x74); // 't'
  buffer.setUint8(15, 0x20); // ' '
  buffer.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
  buffer.setUint16(20, 1, Endian.little);  // AudioFormat (1 = PCM)
  buffer.setUint16(22, numChannels, Endian.little);
  buffer.setUint32(24, sampleRate, Endian.little);
  buffer.setUint32(28, byteRate, Endian.little);
  buffer.setUint16(32, blockAlign, Endian.little);
  buffer.setUint16(34, 16, Endian.little); // BitsPerSample

  // "data" sub-chunk
  buffer.setUint8(36, 0x64); // 'd'
  buffer.setUint8(37, 0x61); // 'a'
  buffer.setUint8(38, 0x74); // 't'
  buffer.setUint8(39, 0x61); // 'a'
  buffer.setUint32(40, dataSize, Endian.little);

  // Write samples
  int offset = 44;
  for (int i = 0; i < numSamples; i++) {
    final sL = (left[i].clamp(-1.0, 1.0) * 32767).toInt();
    final sR = (right[i].clamp(-1.0, 1.0) * 32767).toInt();
    buffer.setInt16(offset, sL, Endian.little);
    buffer.setInt16(offset + 2, sR, Endian.little);
    offset += 4;
  }

  return buffer.buffer.asUint8List();
}

Uint8List generateRain(int sampleRate, int totalSamples) {
  final left = Float64List(totalSamples);
  final right = Float64List(totalSamples);
  final rand = Random(42);

  // Pink noise state
  double b0L = 0, b1L = 0, b2L = 0;
  double b0R = 0, b1R = 0, b2R = 0;
  // Low-pass filter state
  double lpfL = 0, lpfR = 0;

  for (int i = 0; i < totalSamples; i++) {
    final wL = rand.nextDouble() * 2 - 1;
    final wR = rand.nextDouble() * 2 - 1;

    // Pink noise
    b0L = 0.99765 * b0L + wL * 0.0990460;
    b1L = 0.96300 * b1L + wL * 0.2965164;
    b2L = 0.57000 * b2L + wL * 1.0526913;
    final pinkL = b0L + b1L + b2L + wL * 0.1848;

    b0R = 0.99765 * b0R + wR * 0.0990460;
    b1R = 0.96300 * b1R + wR * 0.2965164;
    b2R = 0.57000 * b2R + wR * 1.0526913;
    final pinkR = b0R + b1R + b2R + wR * 0.1848;

    // Gentle low-pass (smoothing)
    lpfL += 0.25 * (pinkL * 0.12 - lpfL);
    lpfR += 0.25 * (pinkR * 0.12 - lpfR);

    // Subtle atmospheric modulation
    final mod = 0.85 + 0.15 * sin(2 * pi * i / (sampleRate * 4.0));

    // Occasional raindrop droplet impulses
    double dropletL = 0, dropletR = 0;
    if (rand.nextDouble() < 0.003) {
      dropletL = (rand.nextDouble() * 2 - 1) * 0.35;
    }
    if (rand.nextDouble() < 0.003) {
      dropletR = (rand.nextDouble() * 2 - 1) * 0.35;
    }

    left[i] = (lpfL * mod + dropletL) * 0.6;
    right[i] = (lpfR * mod + dropletR) * 0.6;
  }

  applyLoopCrossfade(left, right, sampleRate, 0.8);
  return encodeWav(left, right, sampleRate);
}

Uint8List generateFireplace(int sampleRate, int totalSamples) {
  final left = Float64List(totalSamples);
  final right = Float64List(totalSamples);
  final rand = Random(123);

  // Brown noise for warm hearth air
  double brownL = 0, brownR = 0;

  for (int i = 0; i < totalSamples; i++) {
    final wL = rand.nextDouble() * 2 - 1;
    final wR = rand.nextDouble() * 2 - 1;

    brownL = (brownL + (0.04 * wL)) / 1.02;
    brownR = (brownR + (0.04 * wR)) / 1.02;

    left[i] = brownL * 0.35;
    right[i] = brownR * 0.35;
  }

  // Add random wood crackles
  final numCrackles = (totalSamples / sampleRate * 14).toInt();
  for (int c = 0; c < numCrackles; c++) {
    final start = rand.nextInt(totalSamples - 2000);
    final amp = 0.2 + rand.nextDouble() * 0.5;
    final pan = rand.nextDouble(); // 0: left, 1: right
    final len = 200 + rand.nextInt(600); // 10-30 ms

    for (int j = 0; j < len; j++) {
      final decay = exp(-j / 60.0);
      final osc = sin(2 * pi * j * (1200 + rand.nextDouble() * 2400) / sampleRate);
      final val = osc * decay * amp;
      final idx = start + j;
      if (idx < totalSamples) {
        left[idx] += val * (1.0 - pan);
        right[idx] += val * pan;
      }
    }
  }

  applyLoopCrossfade(left, right, sampleRate, 0.8);
  return encodeWav(left, right, sampleRate);
}

Uint8List generateLibrary(int sampleRate, int totalSamples) {
  final left = Float64List(totalSamples);
  final right = Float64List(totalSamples);
  final rand = Random(456);

  // Very soft room tone (steep low-pass filtered noise)
  double filterL = 0, filterR = 0;

  for (int i = 0; i < totalSamples; i++) {
    final wL = rand.nextDouble() * 2 - 1;
    final wR = rand.nextDouble() * 2 - 1;

    filterL += 0.05 * (wL * 0.2 - filterL);
    filterR += 0.05 * (wR * 0.2 - filterR);

    // Deep calm stillness
    left[i] = filterL * 0.3;
    right[i] = filterR * 0.3;
  }

  // Periodic soft page whispers
  const pageInterval = 4.0;
  final numPages = (totalSamples / (sampleRate * pageInterval)).toInt();
  for (int p = 0; p < numPages; p++) {
    final start = (p * pageInterval * sampleRate).toInt() + (rand.nextDouble() * sampleRate * 0.5).toInt();
    if (start + 6000 >= totalSamples) continue;

    for (int j = 0; j < 5000; j++) {
      final env = sin(j / 5000.0 * pi);
      final noise = (rand.nextDouble() * 2 - 1) * 0.08;
      final idx = start + j;
      if (idx < totalSamples) {
        left[idx] += noise * env * 0.4;
        right[idx] += noise * env * 0.6;
      }
    }
  }

  applyLoopCrossfade(left, right, sampleRate, 0.8);
  return encodeWav(left, right, sampleRate);
}

Uint8List generateCafe(int sampleRate, int totalSamples) {
  final left = Float64List(totalSamples);
  final right = Float64List(totalSamples);
  final rand = Random(789);

  // Warm muffled room ambience
  double lowL = 0, lowR = 0;
  double midL = 0, midR = 0;

  for (int i = 0; i < totalSamples; i++) {
    final wL = rand.nextDouble() * 2 - 1;
    final wR = rand.nextDouble() * 2 - 1;

    lowL += 0.08 * (wL * 0.25 - lowL);
    lowR += 0.08 * (wR * 0.25 - lowR);

    midL += 0.18 * (wL * 0.15 - midL);
    midR += 0.18 * (wR * 0.15 - midR);

    final breathe = 0.85 + 0.15 * sin(2 * pi * i / (sampleRate * 3.5));

    left[i] = (lowL * 0.6 + midL * 0.4) * breathe * 0.45;
    right[i] = (lowR * 0.6 + midR * 0.4) * breathe * 0.45;
  }

  // Subtle porcelain chime
  const clinkInterval = 3.5;
  final numClinks = (totalSamples / (sampleRate * clinkInterval)).toInt();
  for (int c = 0; c < numClinks; c++) {
    final start = (c * clinkInterval * sampleRate).toInt() + (rand.nextDouble() * sampleRate).toInt();
    if (start + 2000 >= totalSamples) continue;

    final freq = 2100.0 + rand.nextDouble() * 500.0;
    for (int j = 0; j < 1500; j++) {
      final decay = exp(-j / 180.0);
      final val = sin(2 * pi * j * freq / sampleRate) * decay * 0.07;
      final idx = start + j;
      if (idx < totalSamples) {
        left[idx] += val * 0.7;
        right[idx] += val * 0.3;
      }
    }
  }

  applyLoopCrossfade(left, right, sampleRate, 0.8);
  return encodeWav(left, right, sampleRate);
}
