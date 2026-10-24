import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/book.dart';

/// Kitap ekleme ve düzenleme formu modal diyaloğu.
class AddEditBookDialog extends StatefulWidget {
  const AddEditBookDialog({
    super.key,
    this.book,
    required this.onSave,
  });

  final Book? book;
  final Future<bool> Function({
    required String title,
    required String author,
    required int totalPages,
    required int currentPage,
    required String status,
    String? category,
    String? coverUrl,
    String? notes,
    double? rating,
  }) onSave;

  @override
  State<AddEditBookDialog> createState() => _AddEditBookDialogState();
}

class _AddEditBookDialogState extends State<AddEditBookDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _totalPagesController;
  late final TextEditingController _currentPageController;
  late final TextEditingController _categoryController;
  late final TextEditingController _coverUrlController;
  late final TextEditingController _notesController;

  late String _status;
  double _rating = 0;
  bool _isLoading = false;

  bool get isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleController = TextEditingController(text: b?.title ?? '');
    _authorController = TextEditingController(text: b?.author ?? '');
    _totalPagesController =
        TextEditingController(text: b != null ? b.totalPages.toString() : '');
    _currentPageController =
        TextEditingController(text: b != null ? b.currentPage.toString() : '0');
    _categoryController = TextEditingController(text: b?.category ?? '');
    _coverUrlController = TextEditingController(text: b?.coverUrl ?? '');
    _notesController = TextEditingController(text: b?.notes ?? '');
    _status = b?.status ?? 'reading';
    _rating = b?.rating ?? 0.0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _totalPagesController.dispose();
    _currentPageController.dispose();
    _categoryController.dispose();
    _coverUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final totalPages = int.tryParse(_totalPagesController.text) ?? 0;
    final currentPage = int.tryParse(_currentPageController.text) ?? 0;

    if (currentPage > totalPages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mevcut sayfa toplam sayfa sayısından büyük olamaz.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await widget.onSave(
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      totalPages: totalPages,
      currentPage: currentPage,
      status: _status,
      category: _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim(),
      coverUrl: _coverUrlController.text.trim().isEmpty
          ? null
          : _coverUrlController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      rating: _rating > 0 ? _rating : null,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: AppColors.cream,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Kitabı Düzenle' : 'Yeni Kitap Ekle',
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.deepForest,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.sandBeige),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _titleController,
                    label: 'Kitap Adı *',
                    hint: 'Örn: Bilinmeyen Bir Kadının Mektubu',
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Kitap adı zorunludur' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _authorController,
                    label: 'Yazar *',
                    hint: 'Örn: Stefan Zweig',
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Yazar adı zorunludur' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _totalPagesController,
                          label: 'Toplam Sayfa *',
                          hint: 'Örn: 80',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Zorunlu';
                            final n = int.tryParse(v);
                            if (n == null || n <= 0) return 'Geçersiz';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _currentPageController,
                          label: 'Mevcut Sayfa',
                          hint: 'Örn: 48',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStatusDropdown(),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _categoryController,
                    label: 'Tür / Kategori',
                    hint: 'Örn: Dünya Klasikleri, Distopya',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _coverUrlController,
                    label: 'Kapak Görseli URL (İsteğe bağlı)',
                    hint: 'https://...',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _notesController,
                    label: 'Kişisel Notlar',
                    hint: 'Kitapla ilgili düşünceleriniz...',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepForest,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEditing ? 'Değişiklikleri Kaydet' : 'Kitaplığıma Ekle',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.deepForest,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted.withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.creamHighest),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.sandBeige.withValues(alpha: 0.7),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.deepForest, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Okuma Durumu',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.deepForest,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.sandBeige.withValues(alpha: 0.7),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _status,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.deepForest),
              items: const [
                DropdownMenuItem(
                  value: 'reading',
                  child: Text('Şu An Okuyorum (Okunuyor)'),
                ),
                DropdownMenuItem(
                  value: 'to_read',
                  child: Text('Okunacak (Listemde)'),
                ),
                DropdownMenuItem(
                  value: 'completed',
                  child: Text('Okundu (Tamamlandı)'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _status = val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
