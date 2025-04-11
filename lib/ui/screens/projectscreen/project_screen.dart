import 'package:chinese_english_term_corrector/generated/l10n/app_localizations.dart';
import 'package:chinese_english_term_corrector/models/document.dart';
import 'package:chinese_english_term_corrector/models/project.dart';
import 'package:chinese_english_term_corrector/repositories/document_repository.dart';
import 'package:chinese_english_term_corrector/repositories/project_repository.dart';
import 'package:chinese_english_term_corrector/repositories/term_repository.dart';
import 'package:chinese_english_term_corrector/repositories/subscription_repository.dart';
import 'package:chinese_english_term_corrector/ui/screens/document_processing_screen.dart';
import 'package:chinese_english_term_corrector/ui/screens/subscription_screen.dart';
import 'package:chinese_english_term_corrector/utils/ass_parser.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

import 'document_list_item.dart';
import 'term_management_for_project.dart';
import 'report_screen_for_project.dart';
import 'subtitle_pair.dart';

class ProjectScreen extends StatefulWidget {
  final Project project;

  const ProjectScreen({Key? key, required this.project}) : super(key: key);

  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Mevcut projeyi TermRepository'ye tanıt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print(
          'DEBUG: initState - TermRepository.setCurrentProject çağrılıyor - projectId: ${widget.project.id}');
      final termRepo = Provider.of<TermRepository>(context, listen: false);
      termRepo.setCurrentProject(widget.project);

      // Proje ID'si ve terim listesini kontrol etmek için
      print(
          'DEBUG: initState sonrası - Terim listesi: ${termRepo.terms.map((t) => '${t.id}: ${t.chineseTerm}').join(', ')}');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.projectName}: ${widget.project.name}'),
        actions: [
          PopupMenuButton<String>(
            tooltip: l10n.addDocument,
            onSelected: (value) {
              if (value == 'add_files') {
                _addDocument();
              } else if (value == 'add_folder') {
                _addDocumentsFromFolder();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'add_files',
                child: Row(
                  children: [
                    const Icon(Icons.upload_file, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.addDocument),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'add_folder',
                child: Row(
                  children: [
                    const Icon(Icons.folder_open, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.addFromFolder),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.add_circle_outline),
          ),
          // Subscription status button
          Consumer<SubscriptionRepository>(
            builder: (context, subscriptionRepo, child) {
              final remainingUploads =
                  subscriptionRepo.subscription.remainingUploads;
              //final maxUploads = subscriptionRepo.subscription.remainingUploads;

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.receipt_long),
                    tooltip: l10n.subscriptionTitle,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SubscriptionScreen(),
                        ),
                      );
                    },
                  ),
                  if (remainingUploads == 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: const Text(
                          '!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.description), text: l10n.document),
            Tab(
                icon: const Icon(Icons.library_books),
                text: l10n.termManagement),
            Tab(icon: const Icon(Icons.assessment), text: l10n.reports),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDocumentsTab(),
          _buildTermsTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  // Belgeler sekmesi
  Widget _buildDocumentsTab() {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<ProjectRepository>(
      builder: (context, projectRepo, child) {
        final project = projectRepo.currentProject;

        if (project == null) {
          return Center(child: Text(l10n.projectNotFound));
        }

        if (project.documents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noDocumentsInProject,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _addDocument,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addDocument),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildProjectInfo(project),
            const Divider(),
            Expanded(
              child: ListView.separated(
                itemCount: project.documents.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final document = project.documents[index];
                  return DocumentListItem(
                    document: document,
                    onTap: () => _openDocument(document),
                    onDelete: () => _deleteDocument(document.id),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Terimler sekmesi
  Widget _buildTermsTab() {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<ProjectRepository>(
      builder: (context, projectRepo, child) {
        final project = projectRepo.currentProject;

        if (project == null) {
          return Center(child: Text(l10n.projectNotFound));
        }

        // Terimler yönetimi sayfasını burada çağır
        return TermManagementForProject(project: project);
      },
    );
  }

  // Raporlar sekmesi
  Widget _buildReportsTab() {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<ProjectRepository>(
      builder: (context, projectRepo, child) {
        final project = projectRepo.currentProject;

        if (project == null) {
          return Center(child: Text(l10n.projectNotFound));
        }

        if (project.documents.isEmpty) {
          return Center(
            child: Text(l10n.addDocumentsForReports),
          );
        }

        // Raporlar sayfasını burada çağır
        return ReportScreenForProject(project: project);
      },
    );
  }

  Widget _buildProjectInfo(Project project) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (project.description != null && project.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                project.description!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                l10n.document,
                '${project.documents.length}',
                Icons.description,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                l10n.correction,
                '${project.corrections.length}',
                Icons.auto_fix_high,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                l10n.lastUpdate,
                _formatDate(project.updatedAt),
                Icons.update,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addDocument() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // Abonelik durumunu kontrol et
      final subscriptionRepo =
          Provider.of<SubscriptionRepository>(context, listen: false);

      if (!subscriptionRepo.subscription.hasRemainingUploads) {
        // Yükleme hakkı kalmadıysa abonelik ekranına yönlendir
        _showSubscriptionDialog();
        return;
      }

      final chineseResult = await FilePicker.platform.pickFiles(
        dialogTitle: l10n.selectChineseSourceDocument,
        type: FileType.custom,
        allowedExtensions: ['txt', 'ass'],
      );

      if (chineseResult != null) {
        final englishResult = await FilePicker.platform.pickFiles(
          dialogTitle: l10n.selectEnglishTranslationDocument,
          type: FileType.custom,
          allowedExtensions: ['txt', 'ass'],
        );

        if (englishResult != null) {
          final chineseFile = File(chineseResult.files.single.path!);
          final englishFile = File(englishResult.files.single.path!);

          // Belge adını al
          final chineseFileName = chineseResult.files.single.name;
          final englishFileName = englishResult.files.single.name;

          // Belgenin içeriğini oku
          List<String> chineseLines = [];
          List<String> englishLines = [];

          if (chineseFile.path.toLowerCase().endsWith('.ass')) {
            final chineseContent = await chineseFile.readAsString();
            final chineseEvents = parseAssContent(chineseContent);
            chineseLines = chineseEvents.map((event) => event.text).toList();
          } else {
            chineseLines = await chineseFile.readAsLines();
          }

          if (englishFile.path.toLowerCase().endsWith('.ass')) {
            final englishContent = await englishFile.readAsString();
            final englishEvents = parseAssContent(englishContent);
            englishLines = englishEvents.map((event) => event.text).toList();
          } else {
            englishLines = await englishFile.readAsLines();
          }

          // Ensure both files have the same number of lines
          final minLines = chineseLines.length < englishLines.length
              ? chineseLines.length
              : englishLines.length;

          final documentLines = List.generate(minLines, (index) {
            return DocumentLine(
              lineNumber: index + 1,
              chineseText: chineseLines[index],
              englishText: englishLines[index],
            );
          });

          final document = Document(
            name: chineseFileName,
            lines: documentLines,
            chineseFilePath: chineseFile.path,
            englishFilePath: englishFile.path,
            chineseFileName: chineseFileName,
            englishFileName: englishFileName,
          );

          final projectRepo = Provider.of<ProjectRepository>(
            context,
            listen: false,
          );

          await projectRepo.addDocument(document);

          // Abonelik hakkını kullan
          await subscriptionRepo.useUpload();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.documentAddedSuccessfully),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorWithMessage(e.toString())),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _addDocumentsFromFolder() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // Abonelik durumunu kontrol et
      final subscriptionRepo =
          Provider.of<SubscriptionRepository>(context, listen: false);

      if (!subscriptionRepo.subscription.hasRemainingUploads) {
        // Yükleme hakkı kalmadıysa abonelik ekranına yönlendir
        _showSubscriptionDialog();
        return;
      }

      // Klasör seçme
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: l10n.selectSubtitleFolder,
      );

      if (result != null) {
        // Klasör yolu
        final folderPath = result;
        final directory = Directory(folderPath);

        // Klasördeki tüm dosyaları listele
        final files = directory.listSync().whereType<File>().toList();

        // Sadece .ass veya .txt uzantılı dosyaları filtrele
        final subtitleFiles = files.where((file) {
          final path = file.path.toLowerCase();
          return path.endsWith('.ass') || path.endsWith('.txt');
        }).toList();

        // Eşleştirme için geri kalanları işle
        final pairs = _matchSubtitleFiles(subtitleFiles);

        // Abonelik limiti nedeniyle yüklenebilecek dosya sayısını kontrol et
        final remainingUploads = subscriptionRepo.subscription.remainingUploads;
        final pairsToUpload = pairs.length > remainingUploads
            ? pairs.sublist(0, remainingUploads)
            : pairs;

        if (pairs.length > remainingUploads) {
          // Kullanıcıyı bilgilendir
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.subtitleUploadsRemaining(
                  remainingUploads, remainingUploads)),
              duration: const Duration(seconds: 5),
            ),
          );
        }

        int addedCount = 0;
        int errorCount = 0;

        // Her bir eşleşme için belge oluştur ve projeye ekle
        for (var pair in pairsToUpload) {
          try {
            final document = await _createDocumentFromFiles(
                pair.chineseFile, pair.englishFile);

            final projectRepo = Provider.of<ProjectRepository>(
              context,
              listen: false,
            );

            await projectRepo.addDocument(document);
            addedCount++;

            // Abonelik hakkını kullan
            await subscriptionRepo.useUpload();
          } catch (e) {
            errorCount++;
            print('Dosya eklenirken hata: ${pair.chineseFile.path} - $e');
          }
        }

        // Sonuçları göster
        if (addedCount > 0 || errorCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${l10n.filesAdded(addedCount)}${errorCount > 0 ? ', ${l10n.errorsOccurred(errorCount)}' : ''}'),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.noMatchingSubtitlePairs),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWithMessage(e.toString()))),
      );
    }
  }

  // Abonelik diyaloğunu göster
  void _showSubscriptionDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.subtitleUploadRights),
        content: Text(l10n.noUploadsRemaining),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            },
            child: Text(l10n.packages),
          ),
        ],
      ),
    );
  }

  // Altyazı dosyalarını eşleştir
  List<SubtitlePair> _matchSubtitleFiles(List<File> files) {
    // Çince ve İngilizce dosya eşleştirmelerini saklamak için liste
    final pairs = <SubtitlePair>[];

    // Aynı formatta ama sonu farklı olan dosyaları bulmak için map
    final fileMap = <String, Map<String, File>>{};

    for (var file in files) {
      final fileName = file.path.split('/').last;

      // Dosya adından dil belirteçlerini çıkar (ch/eng)
      String baseName;
      String lang;

      // "ch.ass" veya "eng.ass" gibi sonuçlara bakarak dili belirle
      if (fileName.contains('ch.ass') || fileName.contains('ch.txt')) {
        lang = 'ch';
        baseName = fileName.replaceAll('ch.ass', '').replaceAll('ch.txt', '');
      } else if (fileName.contains('eng.ass') || fileName.contains('eng.txt')) {
        lang = 'eng';
        baseName = fileName.replaceAll('eng.ass', '').replaceAll('eng.txt', '');
      } else if (fileName.contains('_ch.')) {
        lang = 'ch';
        final parts = fileName.split('_ch.');
        baseName = parts[0];
      } else if (fileName.contains('_eng.')) {
        lang = 'eng';
        final parts = fileName.split('_eng.');
        baseName = parts[0];
      } else {
        // Dil belirteci bulunamadı, atla
        continue;
      }

      // Bu temel ada sahip bir map yoksa oluştur
      if (!fileMap.containsKey(baseName)) {
        fileMap[baseName] = {};
      }

      // Dile göre dosyayı map'e ekle
      fileMap[baseName]![lang] = file;
    }

    // Her bir temel ad için Çince ve İngilizce dosyaları kontrol et
    for (var entry in fileMap.entries) {
      final langMap = entry.value;

      // Hem Çince hem de İngilizce dosya varsa bir çift oluştur
      if (langMap.containsKey('ch') && langMap.containsKey('eng')) {
        pairs.add(SubtitlePair(
          chineseFile: langMap['ch']!,
          englishFile: langMap['eng']!,
        ));
      }
    }

    return pairs;
  }

  // Dosyalardan belge oluştur
  Future<Document> _createDocumentFromFiles(
      File chineseFile, File englishFile) async {
    // Dosya adını al
    final chineseFileName = chineseFile.path.split('/').last;
    final englishFileName = englishFile.path.split('/').last;

    // Belgenin içeriğini oku
    List<String> chineseLines = [];
    List<String> englishLines = [];

    if (chineseFile.path.toLowerCase().endsWith('.ass')) {
      final chineseContent = await chineseFile.readAsString();
      final chineseEvents = parseAssContent(chineseContent);
      chineseLines = chineseEvents.map((event) => event.text).toList();
    } else {
      chineseLines = await chineseFile.readAsLines();
    }

    if (englishFile.path.toLowerCase().endsWith('.ass')) {
      final englishContent = await englishFile.readAsString();
      final englishEvents = parseAssContent(englishContent);
      englishLines = englishEvents.map((event) => event.text).toList();
    } else {
      englishLines = await englishFile.readAsLines();
    }

    // Ensure both files have the same number of lines
    final minLines = chineseLines.length < englishLines.length
        ? chineseLines.length
        : englishLines.length;

    final documentLines = List.generate(minLines, (index) {
      return DocumentLine(
        lineNumber: index + 1,
        chineseText: chineseLines[index],
        englishText: englishLines[index],
      );
    });

    final document = Document(
      name: chineseFileName,
      lines: documentLines,
      chineseFilePath: chineseFile.path,
      englishFilePath: englishFile.path,
      chineseFileName: chineseFileName,
      englishFileName: englishFileName,
    );

    return document;
  }

  void _openDocument(Document document) {
    // Belgeyi yükleme ve işleme için DocumentRepository'ye aktar
    //final documentRepo = DocumentRepository();

    // Static belge bilgisini ayarla (DocumentRepository üzerinden erişilebilir)
    DocumentRepository.setLoadedDocument(document);

    // Belge işleme ekranına git
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DocumentProcessingScreen(),
      ),
    );
  }

  Future<void> _deleteDocument(String documentId) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteDocument),
        content: Text(l10n.deleteDocumentConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final projectRepo = Provider.of<ProjectRepository>(
        context,
        listen: false,
      );
      await projectRepo.removeDocument(documentId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.documentDeleted)),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
