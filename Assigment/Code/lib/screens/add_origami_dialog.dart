import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/origami_model.dart';
import '../providers/app_settings_provider.dart';
import '../providers/origami_provider.dart';

class AddOrigamiDialog extends StatefulWidget {
  const AddOrigamiDialog({Key? key}) : super(key: key);

  @override
  State<AddOrigamiDialog> createState() => _AddOrigamiDialogState();
}

class _AddOrigamiDialogState extends State<AddOrigamiDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Custom Origami');
  final _urlController = TextEditingController(
    text: 'https://raw.githubusercontent.com/nhatminh-k18hl/PRM393/main/Assigment/Data/Upload_data/folding_paper_3x3.zip',
  );
  final _paperSizeController = TextEditingController(text: '15x15 cm (Square Paper)');
  final _paperTypeController = TextEditingController(text: 'Standard Origami Sheet');
  final _toolsController = TextEditingController(text: 'None');

  String _selectedDifficulty = 'Beginner Origami';

  final List<String> _difficulties = [
    'Beginner Origami',
    'Intermediate Origami',
    'Advanced Origami',
    'Modular Origami',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _urlController.dispose();
    _paperSizeController.dispose();
    _paperTypeController.dispose();
    _toolsController.dispose();
    super.dispose();
  }

  void _submitForm(OrigamiProvider provider) {
    if (_formKey.currentState?.validate() ?? false) {
      final customId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
      final categoryText = _categoryController.text.trim();
      final categories = categoryText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (categories.isEmpty) {
        categories.add(_selectedDifficulty);
      }

      final newModel = OrigamiModel(
        id: customId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        difficulty: _selectedDifficulty,
        categories: categories,
        previewImg: 'folding_paper_3x3_thumb',
        downloadUrl: _urlController.text.trim(),
        materials: {
          'paper_size': _paperSizeController.text.trim(),
          'paper_type': _paperTypeController.text.trim(),
          'tools': _toolsController.text.trim().split(',').map((e) => e.trim()).toList(),
        },
      );

      provider.addCustomModel(newModel);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Custom origami method "${newModel.title}" added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final origamiProvider = Provider.of<OrigamiProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          width: 560,
          height: 320,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: settings.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: settings.primaryColor.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 16,
              )
            ],
          ),
          child: Column(
            children: [
              // Header bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: settings.primaryColor.withOpacity(0.15),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.add_circle_outline, color: settings.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Add New Origami Method',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: settings.textColor,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 18, color: settings.textColor.withOpacity(0.6)),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Form body
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _titleController,
                                style: TextStyle(fontSize: 12, color: settings.textColor),
                                decoration: _buildInputDecoration(settings, 'Method Title', Icons.title),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Enter title' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                value: _selectedDifficulty,
                                style: TextStyle(fontSize: 11, color: settings.textColor),
                                decoration: _buildInputDecoration(settings, 'Difficulty', Icons.star),
                                dropdownColor: settings.backgroundColor,
                                items: _difficulties.map((d) {
                                  return DropdownMenuItem(value: d, child: Text(d, style: TextStyle(fontSize: 11, color: settings.textColor)));
                                }).toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _selectedDifficulty = v);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _categoryController,
                                style: TextStyle(fontSize: 11, color: settings.textColor),
                                decoration: _buildInputDecoration(settings, 'Categories (comma separated)', Icons.label),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _paperSizeController,
                                style: TextStyle(fontSize: 11, color: settings.textColor),
                                decoration: _buildInputDecoration(settings, 'Paper Size', Icons.aspect_ratio),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 2,
                          style: TextStyle(fontSize: 11, color: settings.textColor),
                          decoration: _buildInputDecoration(settings, 'Method Description & Instructions', Icons.description),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Enter description' : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _urlController,
                          style: TextStyle(fontSize: 10, color: settings.textColor),
                          decoration: _buildInputDecoration(settings, 'Package Download URL (.zip)', Icons.link),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Enter package URL' : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer Action Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel', style: TextStyle(fontSize: 12, color: settings.textColor.withOpacity(0.6))),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Save Method', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: settings.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onPressed: () => _submitForm(origamiProvider),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(AppSettingsProvider settings, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 10, color: settings.textColor.withOpacity(0.6)),
      prefixIcon: Icon(icon, size: 14, color: settings.primaryColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      filled: true,
      fillColor: settings.textColor.withOpacity(0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: settings.textColor.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: settings.primaryColor),
      ),
    );
  }
}
