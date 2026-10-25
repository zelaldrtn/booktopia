import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:booktopia/features/authentication/models/user_profile.dart';
import 'package:booktopia/features/profile/controller/profile_controller.dart';

void main() {
  group('Profile Avatar and Controller Tests', () {
    test('UserProfile correctly preserves and updates avatarUrl', () {
      const profile = UserProfile(
        id: 'user-1',
        displayName: 'Ayşe Okur',
        avatarUrl: null,
      );

      expect(profile.avatarUrl, isNull);

      final withAvatar = profile.copyWith(
        avatarUrl: 'https://example.supabase.co/storage/v1/object/public/avatars/user-1/avatar.png',
      );

      expect(withAvatar.avatarUrl, equals('https://example.supabase.co/storage/v1/object/public/avatars/user-1/avatar.png'));
      expect(withAvatar.toJson()['avatar_url'], equals('https://example.supabase.co/storage/v1/object/public/avatars/user-1/avatar.png'));

      final removedAvatar = withAvatar.copyWith(clearAvatarUrl: true);
      expect(removedAvatar.avatarUrl, isNull);
    });

    test('ProfileController initializes with default states', () {
      final controller = ProfileController();

      expect(controller.profile, isNull);
      expect(controller.isUploadingAvatar, isFalse);
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
    });

    test('uploadProfilePhoto returns false and sets errorMessage when unauthenticated', () async {
      final controller = ProfileController();
      final result = await controller.uploadProfilePhoto(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileExtension: 'png',
      );

      expect(result, isFalse);
      expect(controller.isUploadingAvatar, isFalse);
      expect(controller.errorMessage, contains('oturum açık olmalıdır'));
    });

    test('removeProfilePhoto returns false and sets errorMessage when unauthenticated', () async {
      final controller = ProfileController();
      final result = await controller.removeProfilePhoto();

      expect(result, isFalse);
      expect(controller.isUploadingAvatar, isFalse);
      expect(controller.errorMessage, contains('oturum açık olmalıdır'));
    });
  });
}
