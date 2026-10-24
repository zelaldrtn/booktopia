import 'package:flutter_test/flutter_test.dart';
import 'package:booktopia/features/authentication/controller/auth_controller.dart';
import 'package:booktopia/features/authentication/models/user_profile.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('fromJson and toJson should correctly serialize/deserialize', () {
      final json = {
        'id': 'test-uuid-1234',
        'username': 'okur_elif',
        'display_name': 'Elif Yılmaz',
        'avatar_url': 'https://example.com/avatar.jpg',
        'daily_goal_minutes': 30,
        'language': 'tr',
        'theme_mode': 'dark',
        'created_at': '2026-10-24T20:00:00.000Z',
        'updated_at': '2026-10-24T21:00:00.000Z',
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.id, 'test-uuid-1234');
      expect(profile.username, 'okur_elif');
      expect(profile.displayName, 'Elif Yılmaz');
      expect(profile.dailyGoalMinutes, 30);
      expect(profile.language, 'tr');
      expect(profile.themeMode, 'dark');

      final serialized = profile.toJson();
      expect(serialized['id'], 'test-uuid-1234');
      expect(serialized['username'], 'okur_elif');
      expect(serialized['daily_goal_minutes'], 30);
    });

    test('copyWith should update specified fields only', () {
      const profile = UserProfile(
        id: 'test-uuid',
        displayName: 'Eski Ad',
        dailyGoalMinutes: 20,
      );

      final updated = profile.copyWith(
        displayName: 'Yeni Ad',
        dailyGoalMinutes: 45,
      );

      expect(updated.id, 'test-uuid');
      expect(updated.displayName, 'Yeni Ad');
      expect(updated.dailyGoalMinutes, 45);
      expect(profile.displayName, 'Eski Ad');
    });
  });

  group('AuthController Validation Tests', () {
    test('isValidEmail should validate email formats correctly', () {
      expect(AuthController.isValidEmail('test@example.com'), isTrue);
      expect(AuthController.isValidEmail('user.name@domain.co'), isTrue);
      expect(AuthController.isValidEmail('invalid-email'), isFalse);
      expect(AuthController.isValidEmail('test@'), isFalse);
      expect(AuthController.isValidEmail(''), isFalse);
    });

    test('isValidPassword should require at least 6 characters', () {
      expect(AuthController.isValidPassword('123456'), isTrue);
      expect(AuthController.isValidPassword('securePassword1!'), isTrue);
      expect(AuthController.isValidPassword('12345'), isFalse);
      expect(AuthController.isValidPassword(''), isFalse);
    });

    test('signUp validation should set appropriate error messages when inputs invalid', () async {
      final controller = AuthController();

      final result1 = await controller.signUp(
        email: 'test@example.com',
        password: 'password123',
        fullName: '',
      );
      expect(result1, isFalse);
      expect(controller.errorMessage, 'Lütfen adınızı ve soyadınızı girin.');

      final result2 = await controller.signUp(
        email: 'invalid-email',
        password: 'password123',
        fullName: 'Ahmet Yılmaz',
      );
      expect(result2, isFalse);
      expect(controller.errorMessage, 'Lütfen geçerli bir e-posta adresi girin.');

      final result3 = await controller.signUp(
        email: 'test@example.com',
        password: '123',
        fullName: 'Ahmet Yılmaz',
      );
      expect(result3, isFalse);
      expect(controller.errorMessage, 'Şifreniz en az 6 karakter olmalıdır.');
    });

    test('signIn validation should require valid email and non-empty password', () async {
      final controller = AuthController();

      final result1 = await controller.signIn(
        email: 'invalid-email',
        password: 'password',
      );
      expect(result1, isFalse);
      expect(controller.errorMessage, 'Lütfen geçerli bir e-posta adresi girin.');

      final result2 = await controller.signIn(
        email: 'test@example.com',
        password: '',
      );
      expect(result2, isFalse);
      expect(controller.errorMessage, 'Lütfen şifrenizi girin.');
    });
  });
}
