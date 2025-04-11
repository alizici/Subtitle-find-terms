import 'package:chinese_english_term_corrector/generated/l10n/app_localizations.dart';
import 'package:chinese_english_term_corrector/models/project.dart';
import 'package:chinese_english_term_corrector/models/term_pair.dart';
import 'package:chinese_english_term_corrector/repositories/term_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

// Proje için Terim Yönetimi Widget'ı
class TermManagementForProject extends StatelessWidget {
  final Project project;

  const TermManagementForProject({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Her buildda TermRepository'nin mevcut projeyi görüntülediğinden emin ol
    final termRepo = Provider.of<TermRepository>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;
    print('DEBUG: TermManagementForProject build - projectId: ${project.id}');

    // Eğer şu anki proje TermRepository'deki set edilmiş projeden farklıysa, güncelle
    // Bu, başka projeden gelip geri döndüğümüzde veya TermRepository reset edildiğinde önemli
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print(
          'DEBUG: TermManagementForProject - mevcut projeyi kontrol ediyor - projectId: ${project.id}');
      termRepo.setCurrentProject(project);
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.projectTerms,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // TXT formatından terim içe aktarma işlemi
                      _importTermsFromTxt(context);
                    },
                    icon: const Icon(Icons.file_upload, size: 16),
                    label: Text(localizations.import),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Yeni terim ekleme
                      _showAddTermDialog(context);
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(localizations.newTerm),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: Consumer<TermRepository>(
            builder: (context, termRepo, child) {
              if (termRepo.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (termRepo.terms.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.noTermsInProject,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAddTermDialog(context),
                        icon: const Icon(Icons.add),
                        label: Text(localizations.addTerm),
                      ),
                    ],
                  ),
                );
              }

              return _buildTermList(context, termRepo);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTermList(BuildContext context, TermRepository termRepo) {
    final localizations = AppLocalizations.of(context)!;
    return ListView.builder(
      itemCount: termRepo.terms.length,
      itemBuilder: (context, index) {
        final term = termRepo.terms[index];
        return ListTile(
          title: Text('${term.chineseTerm} - ${term.englishTerm}'),
          subtitle: Text(_getCategoryName(context, term.category)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: localizations.editButton,
                onPressed: () {
                  // Terim düzenleme
                  _showEditTermDialog(context, term);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: localizations.deleteButton,
                onPressed: () {
                  // Terim silme - hem ID hem de Çince terimi geçiyoruz
                  _confirmDeleteTerm(context, term.id, term.chineseTerm);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddTermDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // Yerel state değişkenleri
    String chineseTerm = '';
    String englishTerm = '';
    TermCategory selectedCategory = TermCategory.general;
    String? notes;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(localizations.addNewTerm),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: localizations.chineseTerm,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        chineseTerm = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: localizations.englishTerm,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        englishTerm = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TermCategory>(
                      decoration: InputDecoration(
                        labelText: localizations.category,
                        border: const OutlineInputBorder(),
                      ),
                      value: selectedCategory,
                      items: TermCategory.values
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child:
                                    Text(_getCategoryName(context, category)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: localizations.optionalNotes,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        notes = value.isEmpty ? null : value;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(localizations.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (chineseTerm.isNotEmpty && englishTerm.isNotEmpty) {
                      final termRepo = Provider.of<TermRepository>(
                        context,
                        listen: false,
                      );

                      // Aktif projeyi kontrol et
                      termRepo.setCurrentProject(project);

                      // Yeni terim ekle
                      final newTerm = TermPair(
                        chineseTerm: chineseTerm,
                        englishTerm: englishTerm,
                        category: selectedCategory,
                        notes: notes,
                      );

                      termRepo.addTerm(newTerm);
                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(localizations.termAdded)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations.termsRequired),
                        ),
                      );
                    }
                  },
                  child: Text(localizations.add),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditTermDialog(BuildContext context, TermPair term) {
    final localizations = AppLocalizations.of(context)!;
    // Yerel state değişkenleri
    String chineseTerm = term.chineseTerm;
    String englishTerm = term.englishTerm;
    TermCategory selectedCategory = term.category;
    String? notes = term.notes;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(localizations.editTerm),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: localizations.chineseTerm,
                        border: const OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: chineseTerm),
                      onChanged: (value) {
                        chineseTerm = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: localizations.englishTerm,
                        border: const OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: englishTerm),
                      onChanged: (value) {
                        englishTerm = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TermCategory>(
                      decoration: InputDecoration(
                        labelText: localizations.category,
                        border: const OutlineInputBorder(),
                      ),
                      value: selectedCategory,
                      items: TermCategory.values
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child:
                                    Text(_getCategoryName(context, category)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: localizations.optionalNotes,
                        border: const OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: notes ?? ''),
                      maxLines: 3,
                      onChanged: (value) {
                        notes = value.isEmpty ? null : value;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(localizations.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (chineseTerm.isNotEmpty && englishTerm.isNotEmpty) {
                      final termRepo = Provider.of<TermRepository>(
                        context,
                        listen: false,
                      );

                      // Aktif projeyi kontrol et
                      termRepo.setCurrentProject(project);

                      // Mevcut terimi güncelle
                      final updatedTerm = TermPair(
                        id: term.id,
                        chineseTerm: chineseTerm,
                        englishTerm: englishTerm,
                        category: selectedCategory,
                        notes: notes,
                      );

                      termRepo.updateTerm(updatedTerm);
                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(localizations.termUpdated)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations.termsRequired),
                        ),
                      );
                    }
                  },
                  child: Text(localizations.update),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteTerm(
      BuildContext context, String termId, String chineseTerm) {
    final localizations = AppLocalizations.of(context)!;
    // Silmeden önce terim listesini yazdır
    final termRepo = Provider.of<TermRepository>(context, listen: false);
    print(
        'DEBUG: Silmeden önce terim listesi: ${termRepo.terms.map((t) => '${t.id}: ${t.chineseTerm}').join(', ')}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteTerm),
        content:
            Text('${localizations.deleteTermConfirmation}\n\n$chineseTerm'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              print(
                  'DEBUG: Silme işlemi başlatılıyor - termId: $termId, chineseTerm: $chineseTerm');

              // Silme işlemi - index ile silme yöntemini kullanacağız
              final index = termRepo.terms
                  .indexWhere((t) => t.chineseTerm == chineseTerm);
              if (index != -1) {
                print('DEBUG: Silme için terim bulundu, index: $index');
                termRepo.deleteTermByIndex(index);
              } else {
                print(
                    'ERROR: Silinecek terim bulunamadı - chineseTerm: $chineseTerm');
              }

              Navigator.of(context).pop();

              // Silme sonrası terim listesini yazdır
              print(
                  'DEBUG: Silme sonrası terim listesi: ${termRepo.terms.map((t) => '${t.id}: ${t.chineseTerm}').join(', ')}');

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(localizations.termDeleted)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(localizations.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _importTermsFromTxt(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    try {
      // Dosya seçme
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();

        // TermRepository üzerinden içe aktarma
        final termRepo = Provider.of<TermRepository>(context, listen: false);

        // Aktif projeyi kontrol et
        termRepo.setCurrentProject(project);

        // Terimleri içe aktar
        await termRepo.importTermsFromTxt(content);

        // Sonucu göster
        final importResult = termRepo.importResult;
        if (importResult != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(importResult)),
          );
          termRepo.clearImportResult();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.error(e.toString())),
        ),
      );
    }
  }

  String _getCategoryName(BuildContext context, TermCategory category) {
    final localizations = AppLocalizations.of(context)!;
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
}
