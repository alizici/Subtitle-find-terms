// lib/ui/screens/document_processing_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../repositories/document_repository.dart';
import '../../repositories/term_repository.dart';
import '../../services/term_matcher.dart';
import '../../services/correction_service.dart';
import '../../models/correction.dart';
import '../widgets/document_preview.dart';

class DocumentProcessingScreen extends StatefulWidget {
  const DocumentProcessingScreen({Key? key}) : super(key: key);

  @override
  _DocumentProcessingScreenState createState() =>
      _DocumentProcessingScreenState();
}

class _DocumentProcessingScreenState extends State<DocumentProcessingScreen> {
  final DocumentRepository _documentRepo = DocumentRepository();
  List<Correction> _corrections = [];
  bool _isProcessing = false;
  bool _showSideBySide =
      false; // false olarak değiştirildi (dikey görünüm varsayılan)
  bool _showVerticalPanel =
      true; // true olarak değiştirildi (dikey panel varsayılan)
  double _panelSize = 300.0; // Panel boyutu için varsayılan değer
  double _minPanelSize = 150.0; // Minimum panel boyutu
  double _maxPanelSize = 600.0; // Maksimum panel boyutu

  // Düzeltmeler listesi için kaydırma kontrolcüsü ekleyelim
  final ScrollController _correctionsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Ekran açıldığında panel boyutunu ayarla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showVerticalPanel) {
        setState(() {
          _panelSize = MediaQuery.of(context).size.width * 0.35;
        });
      }
    });
  }

  @override
  void dispose() {
    // Widget yok edildiğinde controller'ı temizleyelim
    _correctionsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Corrections listesini her build işleminde repository'den al
    _corrections = _documentRepo.corrections;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Belge İşleme'),
        actions: [
          // Dikey/Yatay panel değiştirme butonu
          IconButton(
            icon: Icon(
                _showVerticalPanel ? Icons.view_sidebar : Icons.view_agenda),
            tooltip: _showVerticalPanel
                ? 'Yatay Panel Görünümü'
                : 'Dikey Panel Görünümü',
            onPressed: () {
              setState(() {
                _showVerticalPanel = !_showVerticalPanel;
                // Dikey panele geçerken boyutu sıfırla
                if (_showVerticalPanel) {
                  _panelSize = MediaQuery.of(context).size.width * 0.35;
                } else {
                  _panelSize = 300.0;
                }
              });
            },
          ),
          IconButton(
            icon: Icon(_showSideBySide ? Icons.view_agenda : Icons.view_column),
            tooltip: 'Görünümü Değiştir',
            onPressed: () {
              setState(() {
                _showSideBySide = !_showSideBySide;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_open),
            tooltip: 'Belge Aç',
            onPressed: _loadDocument,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Belgeyi Kaydet',
            onPressed:
                _documentRepo.currentDocument != null ? _saveDocument : null,
          ),
        ],
      ),
      body: _showVerticalPanel
          ? _buildHorizontalSplitView() // Dikey panel görünümü (yatay bölünmüş)
          : _buildVerticalSplitView(), // Yatay panel görünümü (dikey bölünmüş)
      floatingActionButton: _documentRepo.currentDocument != null
          ? FloatingActionButton(
              onPressed: _processDocument,
              child: const Icon(Icons.auto_fix_high),
            )
          : null,
    );
  }

  // Dikey bölünmüş görünüm (panel altta)
  Widget _buildVerticalSplitView() {
    return Column(
      children: [
        Expanded(
          child: _documentRepo.currentDocument == null
              ? const Center(child: Text('Lütfen bir belge yükleyin'))
              : _buildDocumentPreview(),
        ),
        GestureDetector(
          onVerticalDragUpdate: (details) {
            setState(() {
              _panelSize = (_panelSize - details.delta.dy)
                  .clamp(_minPanelSize, _maxPanelSize);
            });
          },
          child: Container(
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: _panelSize,
          child: _buildCorrectionPanel(),
        ),
      ],
    );
  }

  // Yatay bölünmüş görünüm (panel sağda)
  Widget _buildHorizontalSplitView() {
    final screenWidth = MediaQuery.of(context).size.width;
    // Dikey mod için uygun panel genişliği
    final defaultPanelWidth = screenWidth * 0.4;

    // Paneli ilk gösterimde uygun bir genişlikte başlat
    if (_panelSize > screenWidth * 0.6) {
      _panelSize = defaultPanelWidth;
    }

    return Row(
      children: [
        Expanded(
          child: _documentRepo.currentDocument == null
              ? const Center(child: Text('Lütfen bir belge yükleyin'))
              : _buildDocumentPreview(),
        ),
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              // Panel genişliği sınırlarını ekran boyutuna göre ayarla
              final minWidth = screenWidth * 0.25; // min %25
              final maxWidth = screenWidth * 0.6; // max %60

              _panelSize =
                  (_panelSize - details.delta.dx).clamp(minWidth, maxWidth);
            });
          },
          child: Container(
            width: 16,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Center(
              child: Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        Container(
          width: _panelSize,
          constraints: BoxConstraints(
            minWidth: screenWidth * 0.25,
            maxWidth: screenWidth * 0.6,
          ),
          child: _buildCorrectionPanel(isVertical: true),
        ),
      ],
    );
  }

  Widget _buildDocumentPreview() {
    if (_documentRepo.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_documentRepo.error != null) {
      return Center(
        child: Text(
          'Hata: ${_documentRepo.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return DocumentPreview(
      document: _documentRepo.currentDocument!,
      corrections: _corrections,
      showSideBySide: _showSideBySide,
      onLineSelected: (lineNumber) {
        _processLine(lineNumber);
      },
    );
  }

  Widget _buildCorrectionPanel({bool isVertical = false}) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: isVertical
                ? const Offset(-2, 0) // Yatay görünümde soldan gölge
                : const Offset(0, -2), // Dikey görünümde yukarıdan gölge
          ),
        ],
        borderRadius: isVertical
            ? const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              )
            : const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Panel başlığı - Esnek tasarım
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık ve bilgi
              Row(
                children: [
                  const Icon(Icons.auto_fix_high, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Düzeltmeler (${_corrections.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Panel boyutunu sıfırlama butonu
                  IconButton(
                    icon: const Icon(Icons.aspect_ratio, size: 20),
                    tooltip: 'Panel Boyutunu Sıfırla',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        if (isVertical) {
                          _panelSize = MediaQuery.of(context).size.width * 0.4;
                        } else {
                          _panelSize = 300.0;
                        }
                      });
                    },
                  ),
                ],
              ),
              // Butonları ayrı bir satıra taşı
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: isVertical
                      ? MainAxisAlignment.spaceEvenly
                      : MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _corrections.isNotEmpty
                          ? () => _applyAllCorrections()
                          : null,
                      icon: const Icon(Icons.done_all, size: 16),
                      label: Text(
                        isVertical ? 'Uygula' : 'Tümünü Uygula',
                        style: const TextStyle(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _corrections.isNotEmpty
                          ? () => _clearCorrections()
                          : null,
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: Text(
                        isVertical ? 'Temizle' : 'Temizle',
                        style: const TextStyle(fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_corrections.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                    'Toplam',
                    _corrections.length.toString(),
                    Icons.format_list_numbered,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Uygulandı',
                    _corrections.where((c) => c.isApplied).length.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Bekliyor',
                    _corrections.where((c) => !c.isApplied).length.toString(),
                    Icons.pending,
                    Colors.orange,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: _isProcessing
                ? const Center(child: CircularProgressIndicator())
                : _corrections.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.text_snippet,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Henüz düzeltme önerisi yok',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Düzeltme önerilerini görmek için sağ alt köşedeki düğmeye tıklayın',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          // Satır filtreleme arayüzü
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.filter_list,
                                    size: 18, color: Colors.blue.shade700),
                                const SizedBox(width: 6),
                                Text(
                                  'Satıra göre filtrele:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: Colors.blue.shade300),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        hint: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Text('Tüm satırlar'),
                                        ),
                                        isExpanded: true,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        value: null,
                                        // Düzeltmelerin bulunduğu satırlar
                                        items: _getUniqueLineNumbers()
                                            .map((lineNum) {
                                          return DropdownMenuItem<int>(
                                            value: lineNum,
                                            child: Text('Satır $lineNum'),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          // Satıra göre filtre uygula
                                          if (value != null) {
                                            _showOnlyLineCorrections(value);
                                          } else {
                                            _clearLineFilter();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Filtrelenmiş düzeltmeler listesi
                          Expanded(
                            child: _buildCorrectionsList(),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadDocument() async {
    try {
      final chineseResult = await FilePicker.platform.pickFiles(
        dialogTitle: 'Çince Kaynak Belgeyi Seçin',
        type: FileType.custom,
        allowedExtensions: ['txt', 'ass'],
      );

      if (chineseResult != null) {
        final englishResult = await FilePicker.platform.pickFiles(
          dialogTitle: 'İngilizce Çeviri Belgesini Seçin',
          type: FileType.custom,
          allowedExtensions: ['txt', 'ass'],
        );

        if (englishResult != null) {
          final chineseFile = File(chineseResult.files.single.path!);
          final englishFile = File(englishResult.files.single.path!);

          await _documentRepo.loadDocument(chineseFile, englishFile);
          setState(() {
            _corrections = [];
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  Future<void> _saveDocument() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Kaydetmek İçin Klasör Seçin',
      );

      if (result != null) {
        await _documentRepo.saveDocument(result);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Belge başarıyla kaydedildi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  Future<void> _processDocument() async {
    if (_documentRepo.currentDocument == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final termRepository =
          Provider.of<TermRepository>(context, listen: false);

      // Terim veritabanını kontrol et
      if (termRepository.terms.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terim veritabanı boş. Lütfen önce terim ekleyin.'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      final termMatcher = Provider.of<TermMatcher>(context, listen: false);
      final correctionService = CorrectionService(termMatcher);

      // İşlem başlangıcında kullanıcıya bilgi ver
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belge işleniyor, lütfen bekleyin...')),
      );

      final newCorrections = correctionService.generateCorrections(
        _documentRepo.currentDocument!,
      );

      // Düzeltmeleri satır numarasına göre sırala
      newCorrections.sort((a, b) => a.lineNumber.compareTo(b.lineNumber));

      // Bulunan tüm düzeltmeleri doğrudan repository'ye ekleyelim
      _documentRepo.clearCorrections(); // Önce mevcut düzeltmeleri temizle
      for (var correction in newCorrections) {
        _documentRepo.addCorrection(correction);
      }

      setState(() {
        // Artık corrections listesini doğrudan repository'den alacağız
        _isProcessing = false;
      });

      // Sonuçla ilgili kullanıcıya detaylı geri bildirim
      if (newCorrections.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Hiçbir düzeltme önerisi bulunamadı. Tüm terimler doğru kullanılmış veya eşleşen terim yok.'),
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newCorrections.length} düzeltme önerisi bulundu.'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Belge işleme hatası: $e');
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text('Belge işlenirken hata oluştu: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  void _processLine(int lineNumber) {
    if (_documentRepo.currentDocument == null) return;

    final termMatcher = Provider.of<TermMatcher>(context, listen: false);
    final correctionService = CorrectionService(termMatcher);

    final lineCorrections = correctionService.generateCorrectionsForLine(
      _documentRepo.currentDocument!,
      lineNumber,
    );

    // Düzeltmeleri satır numarasına göre sırala (aynı satır içindeki terimler için)
    lineCorrections.sort((a, b) => a.chineseTerm.compareTo(b.chineseTerm));

    // Mevcut satır düzeltmelerini repository'den kaldır ve yenileri ekle
    _documentRepo.clearLineCorrections(lineNumber);
    for (var correction in lineCorrections) {
      _documentRepo.addCorrection(correction);
    }

    // Düzeltme panelini bu satıra otomatik olarak filtrele
    _showOnlyLineCorrections(lineNumber);

    // Ekranı güncelle (artık _corrections repository'den gelecek)
    setState(() {});
  }

  // Düzenlenen düzeltmeyi uygulamak için metot
  void _applyEditedCorrection(
      String correctionId, String newIncorrectTerm, String newCorrectTerm) {
    print("Düzenlenmiş düzeltme uygulanıyor: $correctionId");
    print("Yeni metin: $newIncorrectTerm");

    // Uygulamadan önce kullanıcının girdiği metni kontrol et
    if (newIncorrectTerm.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Düzeltme metni boş olamaz!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Önce düzeltmeyi bul ve detayları kontrol et
      final correctionIndex = _documentRepo.corrections.indexWhere(
        (c) => c.id == correctionId,
      );

      if (correctionIndex != -1) {
        final correction = _documentRepo.corrections[correctionIndex];
        print(
            "Düzeltiliyor: Satır ${correction.lineNumber}, ID: ${correction.id}");
        print("Orijinal metin: ${_getLineText(correction.lineNumber)}");
      }

      // Düzenlenen düzeltmeyi repository üzerinden uygula
      _documentRepo.applyCustomCorrection(
          correctionId, newIncorrectTerm, newCorrectTerm);

      // Değişikliklerden sonra state'i güncelleme
      setState(() {
        _isProcessing = false;
        // Yeni değişiklikleri göstermek için corrections listesini repository'den tekrar al
        _corrections = List.from(_documentRepo.corrections);
        // Filtreyi temizleyerek tüm düzeltmeleri göster
        _clearLineFilter();
      });

      // Değişikliklerin GUI'ye yansıması için ek güvence
      Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {});
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Düzeltme başarıyla uygulandı'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Düzeltme uygulanırken hata: $e");
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Düzeltme uygulanırken hata oluştu: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _applyAllCorrections() {
    if (_corrections.isEmpty || _corrections.every((c) => c.isApplied)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uygulanacak düzeltme bulunamadı'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print("Tüm düzeltmeler uygulanıyor...");

    setState(() {
      _isProcessing = true;
    });

    // Tüm düzeltmeleri tek seferde uygulamak yerine her birini kendi içinde yeni metotla uygula
    final pendingCorrections = _corrections.where((c) => !c.isApplied).toList();

    for (var correction in pendingCorrections) {
      // Her bir düzeltme için mevcut satır metnini al
      final currentText =
          correction.editedIncorrectTerm ?? _getLineText(correction.lineNumber);

      // Düzeltme nesnesinde editedIncorrectTerm değerini ayarla
      correction.editedIncorrectTerm = currentText;

      // Custom metot ile düzeltmeleri uygula
      _documentRepo.applyCustomCorrection(correction.id, currentText, "");
    }

    setState(() {
      _isProcessing = false;
      // Correction listesini repository'den yeniden al
      _corrections = List.from(_documentRepo.corrections);
    });

    // Değişikliklerin GUI'ye yansıması için ek güvence
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {});
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(
      content: Text('Tüm düzeltmeler uygulandı'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
    ));
  }

  void _clearCorrections() {
    _documentRepo.clearCorrections();
    setState(() {});
  }

  // Satır numaralarını benzersiz olarak alma
  List<int> _getUniqueLineNumbers() {
    final lines = _corrections
        .where((c) => !c.isApplied)
        .map((c) => c.lineNumber)
        .toSet()
        .toList();

    lines.sort(); // Küçükten büyüğe sıralama
    return lines;
  }

  // Filtrelenmiş satır numarası
  int? _filteredLineNumber;

  // Sadece belirli bir satırın düzeltmelerini göster
  void _showOnlyLineCorrections(int lineNumber) {
    setState(() {
      _filteredLineNumber = lineNumber;

      // Kaydırma pozisyonunu sıfırla, böylece filtrelenmiş liste en baştan görüntülenir
      if (_correctionsScrollController.hasClients) {
        _correctionsScrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Satır filtresini temizle
  void _clearLineFilter() {
    setState(() {
      _filteredLineNumber = null;
    });
  }

  // Filtrelenmiş düzeltmeleri al
  List<Correction> _getFilteredCorrections() {
    // Önce uygulanmamış düzeltmeleri filtrele
    final pendingCorrections = _corrections.where((c) => !c.isApplied).toList();

    // Satır numarasına göre sırala
    pendingCorrections.sort((a, b) => a.lineNumber.compareTo(b.lineNumber));

    // Eğer satır filtresi varsa, sadece o satırın düzeltmelerini göster
    if (_filteredLineNumber != null) {
      return pendingCorrections
          .where((c) => c.lineNumber == _filteredLineNumber)
          .toList();
    }

    // Filtre yoksa tüm uygulanmamış düzeltmeleri satır sırasına göre göster
    return pendingCorrections;
  }

  // Satır metnini almak için yardımcı fonksiyon
  String _getLineText(int lineNumber) {
    if (_documentRepo.currentDocument == null) {
      print(
          "Uyarı: Belge yüklenmemiş, $lineNumber numaralı satır metni alınamıyor");
      return "";
    }

    final lineIndex = _documentRepo.currentDocument!.lines.indexWhere(
      (line) => line.lineNumber == lineNumber,
    );

    if (lineIndex != -1) {
      final text = _documentRepo.currentDocument!.lines[lineIndex].englishText;
      print("Satır $lineNumber metni: $text");
      return text;
    } else {
      print("Uyarı: Satır $lineNumber belgede bulunamadı");
      for (var line in _documentRepo.currentDocument!.lines) {
        print("Mevcut satır: ${line.lineNumber}");
      }
      return "";
    }
  }

  // Filtrelenmiş düzeltmeleri görüntüleyen liste builder
  Widget _buildCorrectionsList() {
    return ListView.builder(
      controller: _correctionsScrollController,
      // Sadece uygulanmamış ve filtrelenmiş düzeltmeleri göster
      itemCount: _getFilteredCorrections().length,
      itemBuilder: (context, index) {
        // Uygulanmamış düzeltmeleri filtrele ve listele
        final filteredCorrections = _getFilteredCorrections();
        final correction = filteredCorrections[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.orange.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Satır numarası ve terim bilgisi
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${correction.lineNumber}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Satır ${correction.lineNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.done, color: Colors.green),
                      onPressed: () {
                        // Önce düzeltmenin mevcut metnini alalım
                        final currentText = correction.editedIncorrectTerm ??
                            _getLineText(correction.lineNumber);

                        // Düzeltme nesnesinde editedIncorrectTerm değerini ayarla
                        correction.editedIncorrectTerm = currentText;

                        // Özelleştirilmiş düzeltme metodunu kullan
                        _applyEditedCorrection(correction.id, currentText, "");
                      },
                      tooltip: 'Düzeltmeyi Uygula',
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      iconSize: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Çince terim
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.translate, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          correction.chineseTerm,
                          style: TextStyle(
                            fontFamily: 'NotoSansSC',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Hatalı İngilizce Terim - Düzenlenebilir
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit, size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          'Satırın Mevcut Metni:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Düzeltilmiş metni buraya yazın',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Düzenlenebilir TextField - Satır Metni
                    TextFormField(
                      initialValue: _getLineText(correction.lineNumber),
                      decoration: InputDecoration(
                        fillColor: Colors.blue.shade50,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue.shade200),
                        ),
                        hintText: "Düzeltilmiş metni buraya yazın",
                        helperText:
                            "Satır ${correction.lineNumber} için düzeltme",
                      ),
                      key: ValueKey(
                          "edit_${correction.id}_${correction.lineNumber}"), // Anahtar ekleyerek widget'in doğru yenilenmesini sağlıyoruz
                      minLines: 2,
                      maxLines: 5,
                      onChanged: (value) {
                        // Düzenlenen metni geçici bir değişkende tutuyoruz
                        print(
                            "Satır ${correction.lineNumber} metni değiştirildi: $value");
                        correction.editedIncorrectTerm = value;
                      },
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Orijinal Terimler - Sadece Referans İçin
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terim Veritabanı Referansı:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Veritabanında Aranan Terim: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                                TextSpan(
                                  text: correction.incorrectEnglishTerm,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Önerilen Terim: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                TextSpan(
                                  text: correction.correctEnglishTerm,
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 4),
                          Text(
                            'Uyarı: Veriler arasında uyumsuzluk olabilir. Terim veritabanındaki bilgiler satırın mevcut içeriğiyle uyuşmayabilir! Kendi düzeltmenizi yapabilirsiniz.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Düzenleme Uygulama Butonu
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Düzenleme yapıldıktan sonra uygulanacak işlem
                        final newText = correction.editedIncorrectTerm ??
                            _getLineText(correction.lineNumber);

                        // Debug için print ekleyelim
                        print(
                            "Kaydet butonuna basıldı. editedIncorrectTerm: ${correction.editedIncorrectTerm}");
                        print("Uygulanacak newText: $newText");

                        // Düzeltme nesnesinde editedIncorrectTerm değerini ayarla
                        correction.editedIncorrectTerm = newText;

                        // Sadece newText kullanarak düzeltme yapılacak
                        _applyEditedCorrection(correction.id, newText,
                            ""); // doğru terime artık ihtiyaç yok
                      },
                      icon: const Icon(Icons.done_all, size: 16),
                      label: const Text(
                        'Değişiklikleri Kaydet',
                        style: TextStyle(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
