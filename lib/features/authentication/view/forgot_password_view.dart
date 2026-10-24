import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/auth_controller.dart';
import '../widget/auth_text_field.dart';

/// Booktopia Şifremi Unuttum Ekranı.
/// Kullanıcının e-posta adresine güvenli şifre sıfırlama bağlantısı gönderir.
class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key, this.authController});

  final AuthController? authController;

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  late final AuthController _authController;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    _authController = widget.authController ?? AuthController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    if (widget.authController == null) {
      _authController.dispose();
    }
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    _authController.clearError();
    if (!_formKey.currentState!.validate()) return;

    final success = await _authController.resetPassword(
      email: _emailController.text,
    );

    if (success && mounted) {
      setState(() {
        _emailSent = true;
      });
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
                if (_emailSent) {
                  return _buildSuccessCard(context);
                }

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
                      AuthTextField(
                        controller: _emailController,
                        labelText: 'Kayıtlı E-posta Adresi',
                        hintText: 'ornek@kitap.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
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
                      const SizedBox(height: 24),
                      _buildSubmitButton(context),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Giriş Ekranına Dön',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.deepForest,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
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
          'Şifrenizi mi Unuttunuz?',
          style: textTheme.headlineMedium?.copyWith(
            color: AppColors.deepForest,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Hesabınıza ait e-posta adresini girin; size şifre sıfırlama bağlantısı gönderelim.',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final isLoading = _authController.isLoading;

    return ElevatedButton(
      onPressed: isLoading ? null : _handleResetPassword,
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
              'Sıfırlama Bağlantısı Gönder',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
    );
  }

  Widget _buildSuccessCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepForest.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.mark_email_read_outlined,
            size: 56,
            color: AppColors.success,
          ),
          const SizedBox(height: 16),
          Text(
            'Bağlantı Gönderildi',
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.deepForest,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_emailController.text} adresine şifre sıfırlama bağlantısı gönderildi. Lütfen gelen kutunuzu kontrol edin.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepForest,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Giriş Ekranına Dön'),
          ),
        ],
      ),
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
