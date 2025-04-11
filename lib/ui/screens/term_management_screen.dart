// lib/ui/screens/term_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../models/term_pair.dart';
import '../../repositories/term_repository.dart';
import '../widgets/term_list_item.dart';
import 'package:chinese_english_term_corrector/generated/l10n/app_localizations.dart';

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
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.termManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: localizations.import,
            onPressed: _importTerms,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: localizations.export,
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
                    decoration: InputDecoration(
                      labelText: localizations.searchTerm,
                      prefixIcon: const Icon(Icons.search),
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
                  hint: Text(localizations.filterCategory),
                  value: _filterCategory,
                  onChanged: (TermCategory? value) {
                    setState(() {
                      _filterCategory = value;
                    });
                  },
                  items: [
                    DropdownMenuItem<TermCategory?>(
                      value: null,
                      child: Text(localizations.all),
                    ),
                    ...TermCategory.values.map((category) {
                      return DropdownMenuItem<TermCategory?>(
                        value: category,
                        child: Text(_getCategoryName(category, localizations)),
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
                      localizations.errorWithMessage(termRepo.error ?? ''),
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
                  return Center(child: Text(localizations.noTermsFound));
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

  String _getCategoryName(
      TermCategory category, AppLocalizations localizations) {
    switch (category) {
      case TermCategory.person:
        return localizations.personName;
      case TermCategory.place:
        return localizations.placeName;
      case TermCategory.organization:
        return localizations.organization;
      case TermCategory.technical:
        return localizations.technicalTerm;
      case TermCategory.general:
        return localizations.general;
      case TermCategory.other:
        return localizations.other;
    }
  }

  void _showTermDialog(BuildContext context, [TermPair? term]) {
    final localizations = AppLocalizations.of(context)!;
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
        title:
            Text(isEditing ? localizations.editTerm : localizations.addNewTerm),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _chineseTermController,
                  decoration: InputDecoration(
                    labelText: localizations.chineseTerm,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.enterChineseTerm;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _englishTermController,
                  decoration: InputDecoration(
                    labelText: localizations.englishTerm,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.enterEnglishTerm;
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<TermCategory>(
                  value: _selectedCategory,
                  decoration:
                      InputDecoration(labelText: localizations.category),
                  items: TermCategory.values.map((category) {
                    return DropdownMenuItem<TermCategory>(
                      value: category,
                      child: Text(_getCategoryName(category, localizations)),
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
                  decoration: InputDecoration(labelText: localizations.notes),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.cancel),
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
            child: Text(isEditing ? localizations.update : localizations.add),
          ),
        ],
      ),
    );
  }

  void _deleteTerm(BuildContext context, String termId) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteTerm),
        content: Text(localizations.deleteTermConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.cancel),
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
            child: Text(localizations.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _importTerms() async {
    final localizations = AppLocalizations.of(context)!;

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
            SnackBar(content: Text(localizations.importSuccess)),
          );
        }
      }
    } catch (e) {
      _showErrorDialog('${localizations.error}: $e');
    }
  }

  // Sonuç mesajını dialog olarak göster
  void _showResultDialog(String message) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.importResult),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.ok),
          ),
        ],
      ),
    );
  }

  // Hata mesajını dialog olarak göster
  void _showErrorDialog(String message) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.error as String),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _exportTerms() async {
    final localizations = AppLocalizations.of(context)!;

    try {
      final termRepo = Provider.of<TermRepository>(context, listen: false);
      final jsonContent = await termRepo.exportTerms();

      final result = await FilePicker.platform.saveFile(
        dialogTitle: localizations.exportTerms,
        fileName: localizations.defaultTermsFileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(jsonContent);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.exportSuccess)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.errorWithMessage(e.toString()))),
      );
    }
  }
}
