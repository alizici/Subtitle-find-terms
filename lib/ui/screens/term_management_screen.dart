// lib/ui/screens/term_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../models/term_pair.dart';
import '../../repositories/term_repository.dart';
import '../widgets/term_list_item.dart';

class TermManagementScreen extends StatefulWidget {
  const TermManagementScreen({Key? key}) : super(key: key);

  @override
  _TermManagementScreenState createState() => _TermManagementScreenState();
}

class _TermManagementScreenState extends State<TermManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _chineseTermController = TextEditingController();
  final _englishTermController = TextEditingController();
  TermCategory _selectedCategory = TermCategory.general;
  final _notesController = TextEditingController();

  String? _searchQuery;
  TermCategory? _filterCategory;

  @override
  void dispose() {
    _chineseTermController.dispose();
    _englishTermController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terim Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'İçe Aktar',
            onPressed: _importTerms,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Dışa Aktar',
            onPressed: _exportTerms,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Terim Ara',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.isEmpty ? null : value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<TermCategory?>(
                  hint: const Text('Kategori Filtrele'),
                  value: _filterCategory,
                  onChanged: (TermCategory? value) {
                    setState(() {
                      _filterCategory = value;
                    });
                  },
                  items: [
                    const DropdownMenuItem<TermCategory?>(
                      value: null,
                      child: Text('Tümü'),
                    ),
                    ...TermCategory.values.map((category) {
                      return DropdownMenuItem<TermCategory?>(
                        value: category,
                        child: Text(_getCategoryName(category)),
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TermRepository>(
              builder: (context, termRepo, child) {
                if (termRepo.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (termRepo.error != null) {
                  return Center(
                    child: Text(
                      'Hata: ${termRepo.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final filteredTerms = termRepo.terms.where((term) {
                  // Kategori filtresi
                  if (_filterCategory != null &&
                      term.category != _filterCategory) {
                    return false;
                  }

                  // Arama filtresi
                  if (_searchQuery != null && _searchQuery!.isNotEmpty) {
                    final query = _searchQuery!.toLowerCase();
                    return term.chineseTerm.toLowerCase().contains(query) ||
                        term.englishTerm.toLowerCase().contains(query);
                  }

                  return true;
                }).toList();

                if (filteredTerms.isEmpty) {
                  return const Center(child: Text('Hiçbir terim bulunamadı'));
                }

                return ListView.builder(
                  itemCount: filteredTerms.length,
                  itemBuilder: (context, index) {
                    final term = filteredTerms[index];
                    return TermListItem(
                      term: term,
                      onEdit: () => _showTermDialog(context, term),
                      onDelete: () => _deleteTerm(context, term.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTermDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getCategoryName(TermCategory category) {
    switch (category) {
      case TermCategory.person:
        return 'Kişi İsmi';
      case TermCategory.place:
        return 'Yer İsmi';
      case TermCategory.organization:
        return 'Organizasyon';
      case TermCategory.technical:
        return 'Teknik Terim';
      case TermCategory.general:
        return 'Genel';
      case TermCategory.other:
        return 'Diğer';
    }
  }

  void _showTermDialog(BuildContext context, [TermPair? term]) {
    final bool isEditing = term != null;

    if (isEditing) {
      _chineseTermController.text = term.chineseTerm;
      _englishTermController.text = term.englishTerm;
      _selectedCategory = term.category;
      _notesController.text = term.notes ?? '';
    } else {
      _chineseTermController.clear();
      _englishTermController.clear();
      _selectedCategory = TermCategory.general;
      _notesController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Terimi Düzenle' : 'Yeni Terim Ekle'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _chineseTermController,
                  decoration: const InputDecoration(
                    labelText: 'Çince Terim',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen Çince terimi girin';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _englishTermController,
                  decoration: const InputDecoration(
                    labelText: 'İngilizce Terim',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen İngilizce terimi girin';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<TermCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: TermCategory.values.map((category) {
                    return DropdownMenuItem<TermCategory>(
                      value: category,
                      child: Text(_getCategoryName(category)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Notlar'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final termRepo = Provider.of<TermRepository>(
                  context,
                  listen: false,
                );

                final newTerm = TermPair(
                  id: isEditing ? term.id : null,
                  chineseTerm: _chineseTermController.text,
                  englishTerm: _englishTermController.text,
                  category: _selectedCategory,
                  notes: _notesController.text.isNotEmpty
                      ? _notesController.text
                      : null,
                );

                if (isEditing) {
                  termRepo.updateTerm(newTerm);
                } else {
                  termRepo.addTerm(newTerm);
                }

                Navigator.of(context).pop();
              }
            },
            child: Text(isEditing ? 'Güncelle' : 'Ekle'),
          ),
        ],
      ),
    );
  }

  void _deleteTerm(BuildContext context, String termId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terimi Sil'),
        content: const Text(
          'Bu terimi silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final termRepo = Provider.of<TermRepository>(
                context,
                listen: false,
              );
              termRepo.deleteTerm(termId);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _importTerms() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'csv', 'txt'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final fileExtension =
            result.files.single.extension?.toLowerCase() ?? '';

        final termRepo = Provider.of<TermRepository>(context, listen: false);

        if (fileExtension == 'txt') {
          await termRepo.importTermsFromTxt(content);
        } else {
          await termRepo.importTerms(content);
        }

        // Import sonucunu göster
        if (termRepo.importResult != null) {
          _showResultDialog(termRepo.importResult!);
          // Dialog gösterildikten sonra importResult'ı temizle
          termRepo.clearImportResult();
        } else if (termRepo.error != null) {
          _showErrorDialog(termRepo.error!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Terimler başarıyla içe aktarıldı')),
          );
        }
      }
    } catch (e) {
      _showErrorDialog('Hata: $e');
    }
  }

  // Sonuç mesajını dialog olarak göster
  void _showResultDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İçe Aktarma Sonucu'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  // Hata mesajını dialog olarak göster
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportTerms() async {
    try {
      final termRepo = Provider.of<TermRepository>(context, listen: false);
      final jsonContent = await termRepo.exportTerms();

      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Terimleri Dışa Aktar',
        fileName: 'terms.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(jsonContent);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terimler başarıyla dışa aktarıldı')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }
}
