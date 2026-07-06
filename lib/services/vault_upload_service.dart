import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:shared_preferences/shared_preferences.dart';

class VaultImageRecord {
  const VaultImageRecord({
    required this.id,
    required this.fileName,
    required this.source,
    required this.createdAt,
    required this.mimeType,
    required this.encodedImage,
  });

  final String id;
  final String fileName;
  final String source;
  final DateTime createdAt;
  final String mimeType;
  final String encodedImage;

  Uint8List get bytes => base64Decode(encodedImage);

  Map<String, Object> toJson() {
    return <String, Object>{
      'id': id,
      'fileName': fileName,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
      'mimeType': mimeType,
      'encodedImage': encodedImage,
    };
  }

  static VaultImageRecord fromJson(Map<String, Object?> json) {
    return VaultImageRecord(
      id: json['id'] as String? ?? '',
      fileName: json['fileName'] as String? ?? 'Image upload',
      source: json['source'] as String? ?? 'Upload',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      mimeType: json['mimeType'] as String? ?? 'image/*',
      encodedImage: json['encodedImage'] as String? ?? '',
    );
  }
}

class VaultUploadService {
  const VaultUploadService();

  static const String _imagesKey = 'ciantis.vault.images';
  static const int _maxSavedImages = 12;
  static const int _maxStoredImageDimension = 540;

  Future<List<VaultImageRecord>> readImages() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_imagesKey);
    if (raw == null || raw.isEmpty) {
      return <VaultImageRecord>[];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return <VaultImageRecord>[];
    }

    return decoded
        .whereType<Map<String, Object?>>()
        .map(VaultImageRecord.fromJson)
        .where((record) => record.encodedImage.isNotEmpty)
        .toList(growable: false);
  }

  Future<VaultImageRecord> saveImage({
    required Uint8List bytes,
    required String fileName,
    required String source,
    String mimeType = 'image/*',
  }) async {
    final storageBytes = await _storageSafeImageBytes(bytes);
    final now = DateTime.now();
    final record = VaultImageRecord(
      id: 'vault-image-${now.microsecondsSinceEpoch}',
      fileName: fileName.isEmpty ? 'Image upload' : fileName,
      source: source,
      createdAt: now,
      mimeType: 'image/png',
      encodedImage: base64Encode(storageBytes),
    );

    final images = <VaultImageRecord>[
      record,
      ...await readImages(),
    ].take(_maxSavedImages).toList(growable: false);
    final preferences = await SharedPreferences.getInstance();
    final saved = await _tryWriteImages(preferences, images);
    if (!saved) {
      throw const VaultUploadException(
        'This image could not be saved. Try a smaller photo.',
      );
    }

    return record;
  }

  Future<bool> _tryWriteImages(
    SharedPreferences preferences,
    List<VaultImageRecord> images,
  ) async {
    var records = images;

    while (records.isNotEmpty) {
      try {
        final saved = await preferences.setString(
          _imagesKey,
          jsonEncode(records.map((image) => image.toJson()).toList()),
        );
        if (saved) {
          return true;
        }
      } catch (_) {
        // Browser storage may reject large image payloads. Drop older uploads
        // and retry so the new upload still has somewhere to land.
      }

      records = records.take(records.length - 1).toList(growable: false);
    }

    return false;
  }

  Future<Uint8List> _storageSafeImageBytes(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: _maxStoredImageDimension,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return bytes;
    }

    return byteData.buffer.asUint8List();
  }
}

class VaultUploadException implements Exception {
  const VaultUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}
