import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/auth_controller.dart';
import '../widget/auth_text_field.dart';

/// Booktopia Kullanıcı Kayıt Ekranı.
/// Ad soyad, e-posta ve şifre doğrulaması ile yeni hesap oluşturur.
class RegisterView extends StatefulWidget {
  const RegisterView({super.key, this.authController});

  final AuthController? authController;

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final AuthController _authController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _authController = widget.authController ?? AuthController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    if (widget.authController == null) {
      _authController.dispose();
    }
    super.dispose();
  }

  Future<void> _handleRegister() async {
    _authController.clearError();
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şifreler birbiriyle eşleşmiyor.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await _authController.signUp(
      email: _emailController.text,
      password: _passwordController.text,
      fullName: _nameController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Hesabınız başarıyla oluşturuldu! E-postanızı kontrol edin veya giriş yapın.',
          ),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 4),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.deepForest),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: ListenableBuilder(
              listenable: _authController,
              builder: (context, _) {
                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 24),
                      if (_authController.errorMessage != null) ...[
                        _buildErrorBanner(context, _authController.errorMessage!),
                        const SizedBox(height: 16),
                      ],
                      _buildFormFields(),
                      const SizedBox(height: 24),
                      _buildSubmitButton(context),
                      const SizedBox(height: 20),
                      _buildLoginPrompt(context),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yeni Hesap Oluştur',
          style: textTheme.headlineMedium?.copyWith(
            color: AppColors.deepForest,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Kişisel kitaplığınızı ve okuma yolculuğunuzu başlatın.',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        AuthTextField(
          controller: _nameController,
          labelText: 'Ad Soyad',
          hintText: 'Elif Yılmaz',
          prefixIcon: Icons.person_outline,
          textInputAction: TextInputAction.next,
          enabled: !_authController.isLoading,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Lütfen adınızı ve soyadınızı girin.';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        AuthTextField(
          controller: _emailController,
          labelText: 'E-posta Adresi',
          hintText: 'ornek@kitap.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !_authController.isLoading,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Lütfen e-posta adresinizi girin.';
            }
            if (!AuthController.isValidEmail(value)) {
              return 'Geçerli bir e-posta adresi yazın.';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        AuthTextField(
          controller: _passwordController,
          labelText: 'Şifre',
          hintText: 'En az 6 karakter',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          enabled: !_authController.isLoading,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20,
              color: AppColors.sage,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen bir şifre belirleyin.';
            }
            if (!AuthController.isValidPassword(value)) {
              return 'Şifreniz en az 6 karakter olmalıdır.';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        AuthTextField(
          controller: _confirmPasswordController,
          labelText: 'Şifre Tekrar',
          hintText: 'Şifrenizi tekrar girin',
          prefixIcon: Icons.lock_reset_outlined,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          enabled: !_authController.isLoading,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 20,
              color: AppColors.sage,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen şifrenizi tekrar girin.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final isLoading = _authController.isLoading;

    return ElevatedButton(
      onPressed: isLoading ? null : _handleRegister,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.deepForest,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              'Hesap Oluştur',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Zaten hesabınız var mı?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text(
            'Giriş Yapın',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.burgundy,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 20, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          GestureDetector(
            onTap: _authController.clearError,
            child: const Icon(Icons.close, size: 16, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
