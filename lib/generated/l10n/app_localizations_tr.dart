// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Çince-İngilizce Terim Düzeltici';

  @override
  String get projectsScreenTitle => 'Projeler';

  @override
  String get newProject => 'Yeni Proje';

  @override
  String get deleteProject => 'Projeyi Sil';

  @override
  String get editProject => 'Projeyi Düzenle';

  @override
  String get projectName => 'Proje Adı';

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'İptal';

  @override
  String get deleteConfirmation => 'Bu projeyi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get saveDialogTitle => 'Kaydet';

  @override
  String get categoryPerson => 'Kişi';

  @override
  String get categoryPlace => 'Yer';

  @override
  String get categoryOrganization => 'Organizasyon';

  @override
  String get categoryTechnical => 'Teknik';

  @override
  String get categoryOther => 'Diğer';

  @override
  String get categoryGeneral => 'Genel';

  @override
  String get defaultTermsFileName => 'terimler.json';

  @override
  String get defaultReportFileName => 'terim_raporu.html';

  @override
  String get errorFileLoad => 'Dosya yüklenirken bir hata oluştu';

  @override
  String get errorFileSave => 'Dosya kaydedilirken bir hata oluştu';

  @override
  String get errorTermImport => 'Terimler içe aktarılırken bir hata oluştu';

  @override
  String get errorTermExport => 'Terimler dışa aktarılırken bir hata oluştu';

  @override
  String get successTermImport => 'Terimler başarıyla içe aktarıldı';

  @override
  String get successTermExport => 'Terimler başarıyla dışa aktarıldı';

  @override
  String get successFileLoad => 'Dosya başarıyla yüklendi';

  @override
  String get successFileSave => 'Dosya başarıyla kaydedildi';

  @override
  String get successCorrectionsApplied => 'Düzeltmeler başarıyla uygulandı';

  @override
  String invalidTimeFormat(String timestamp) {
    return 'Geçersiz zaman formatı: $timestamp';
  }

  @override
  String invalidSecondsFormat(String timestamp) {
    return 'Geçersiz saniye/salise formatı: $timestamp';
  }

  @override
  String timestampParsingError(String timestamp, String error) {
    return 'Zaman damgası ayrıştırma hatası: \'$timestamp\' - $error';
  }

  @override
  String warningDialogueMissingFields(String line) {
    return 'Uyarı: Dialogue satırında yeterli alan bulunamadı: $line';
  }

  @override
  String dialogueParsingError(String line, String format, String error) {
    return 'Dialogue satırı ayrıştırılamadı: \'$line\'\nFormat: $format\nHata: $error';
  }

  @override
  String get editButton => 'Düzenle';

  @override
  String get deleteButton => 'Sil';

  @override
  String get sourceText => 'Kaynak Metin';

  @override
  String get englishTranslation => 'İngilizce Çeviri';

  @override
  String get corrected => 'Düzeltildi';

  @override
  String get applyButton => 'Uygula';

  @override
  String get appliedStatus => 'Uygulandı';

  @override
  String get linePrefix => 'Satır';

  @override
  String get incorrectLabel => 'Hatalı:';

  @override
  String get correctLabel => 'Doğru:';

  @override
  String get termManagement => 'Terim Yönetimi';

  @override
  String get import => 'İçe Aktar';

  @override
  String get export => 'Dışa Aktar';

  @override
  String get searchTerm => 'Terim Ara';

  @override
  String get filterCategory => 'Kategori Filtrele';

  @override
  String get all => 'Tümü';

  @override
  String get personName => 'Kişi İsmi';

  @override
  String get placeName => 'Yer İsmi';

  @override
  String get organization => 'Organizasyon';

  @override
  String get technicalTerm => 'Teknik Terim';

  @override
  String get general => 'Genel';

  @override
  String get other => 'Diğer';

  @override
  String get noTermsFound => 'Hiçbir terim bulunamadı';

  @override
  String get editTerm => 'Terimi Düzenle';

  @override
  String get addNewTerm => 'Yeni Terim Ekle';

  @override
  String get chineseTerm => 'Çince Terim';

  @override
  String get enterChineseTerm => 'Lütfen Çince terimi girin';

  @override
  String get englishTerm => 'İngilizce Terim';

  @override
  String get enterEnglishTerm => 'Lütfen İngilizce terimi girin';

  @override
  String get category => 'Kategori';

  @override
  String get notes => 'Notlar';

  @override
  String get add => 'Ekle';

  @override
  String get update => 'Güncelle';

  @override
  String get deleteTerm => 'Terimi Sil';

  @override
  String get confirmDelete => 'Bu terimi silmek istediğinizden emin misiniz?';

  @override
  String get delete => 'Sil';

  @override
  String get importSuccess => 'Proje başarıyla içe aktarıldı';

  @override
  String error(String error) {
    return 'Hata: $error';
  }

  @override
  String errorWithMessage(String message) {
    return 'Hata: $message';
  }

  @override
  String get importResult => 'İçe Aktarma Sonucu';

  @override
  String get ok => 'Tamam';

  @override
  String get exportTerms => 'Terimleri Dışa Aktar';

  @override
  String get exportSuccess => 'Proje başarıyla dışa aktarıldı';

  @override
  String get reports => 'Raporlar';

  @override
  String get exportReport => 'Rapor Dışa Aktar';

  @override
  String get pleaseUploadDocument => 'Lütfen bir belge yükleyin';

  @override
  String get summary => 'Özet';

  @override
  String get totalLines => 'Toplam Satır';

  @override
  String get correctedLines => 'Düzeltilen Satır';

  @override
  String get totalCorrections => 'Toplam Düzeltme';

  @override
  String get appliedCorrections => 'Uygulanan Düzeltme';

  @override
  String get consistencyScore => 'Tutarlılık Puanı';

  @override
  String get excellentConsistency => 'Mükemmel tutarlılık';

  @override
  String get goodConsistency => 'İyi tutarlılık';

  @override
  String get mediumConsistency => 'Orta tutarlılık';

  @override
  String get lowConsistency => 'Düşük tutarlılık';

  @override
  String get veryLowConsistency => 'Çok düşük tutarlılık';

  @override
  String get mostFrequentlyMistranslatedTerms => 'En Sık Yanlış Çevrilen Terimler';

  @override
  String get noMistranslatedTermsFound => 'Yanlış çevrilen terim bulunamadı';

  @override
  String timesOccurred(int count) {
    return '$count kez';
  }

  @override
  String get correctionDetails => 'Düzeltme Detayları';

  @override
  String totalCorrections2(int count) {
    return 'Toplam: $count düzeltme';
  }

  @override
  String get noCorrectionSuggestions => 'Henüz düzeltme önerisi yok';

  @override
  String line(int number) {
    return 'Satır: $number';
  }

  @override
  String get saveReport => 'Raporu Kaydet';

  @override
  String get consistencyReportFileName => 'terim_tutarlilik_raporu.html';

  @override
  String get reportSavedSuccessfully => 'Rapor başarıyla kaydedildi';

  @override
  String get importProjectTooltip => 'Projeyi İçe Aktar';

  @override
  String get noProjectsMessage => 'Henüz bir proje oluşturmadınız';

  @override
  String totalProjects(int count) {
    return 'Toplam $count proje';
  }

  @override
  String get descriptionOptional => 'Açıklama (İsteğe Bağlı)';

  @override
  String get descriptionHint => 'Örn: 5 sezonluk Wuxia serisi altyazı termlerinin standardizasyonu';

  @override
  String get projectNameHint => 'Örn: Wuxia Serisi Terim Çevirisi';

  @override
  String get projectDeleted => 'Proje silindi';

  @override
  String get exportProjectDialogTitle => 'Projeyi Dışa Aktar';

  @override
  String projectDetails(int docCount, String updateDate) {
    return 'Belgeler: $docCount | Son güncelleme: $updateDate';
  }

  @override
  String get exportAction => 'Dışa Aktar';

  @override
  String get deleteAction => 'Sil';

  @override
  String get documentProcessing => 'Belge İşleme';

  @override
  String get documentProcessingTitle => 'Belge İşleme';

  @override
  String get horizontalPanelTooltip => 'Yatay Panel Görünümü';

  @override
  String get verticalPanelTooltip => 'Dikey Panel Görünümü';

  @override
  String get changeViewTooltip => 'Görünümü Değiştir';

  @override
  String get openDocumentTooltip => 'Belge Aç';

  @override
  String get saveDocumentTooltip => 'Belgeyi Kaydet';

  @override
  String get resetPanelSizeTooltip => 'Panel Boyutunu Sıfırla';

  @override
  String correctionsCount(int count) {
    return 'Düzeltmeler ($count)';
  }

  @override
  String get applyAllCorrections => 'Tümünü Uygula';

  @override
  String get applyCorrections => 'Uygula';

  @override
  String get clearCorrections => 'Temizle';

  @override
  String get total => 'Toplam';

  @override
  String get applied => 'Uygulandı';

  @override
  String get pending => 'Bekliyor';

  @override
  String get noCorrectionsYet => 'Henüz düzeltme önerisi yok';

  @override
  String get clickButtonForCorrections => 'Düzeltme önerilerini görmek için sağ alt köşedeki düğmeye tıklayın';

  @override
  String get filterByLine => 'Satıra göre filtrele:';

  @override
  String get allLines => 'Tüm satırlar';

  @override
  String lineNumber(Object number) {
    return 'Satır $number';
  }

  @override
  String get applyCorrection => 'Düzeltmeyi Uygula';

  @override
  String get currentLineText => 'Satırın Mevcut Metni:';

  @override
  String get enterCorrectedText => 'Düzeltilmiş metni buraya yazın';

  @override
  String correctionForLine(int number) {
    return 'Satır $number için düzeltme';
  }

  @override
  String get termDatabaseReference => 'Terim Veritabanı Referansı:';

  @override
  String get termSearchedInDatabase => 'Veritabanında Aranan Terim: ';

  @override
  String get suggestedTerm => 'Önerilen Terim: ';

  @override
  String get dataDiscrepancyWarning => 'Uyarı: Kendi düzeltmenizi yapabilirsiniz.';

  @override
  String get saveChanges => 'Değişiklikleri Kaydet';

  @override
  String get selectChineseSourceDocument => 'Çince Kaynak Belgeyi Seçin';

  @override
  String get selectEnglishTranslationDocument => 'İngilizce Çeviri Belgesini Seçin';

  @override
  String get selectFolderToSave => 'Kaydetmek İçin Klasör Seçin';

  @override
  String get documentSavedSuccessfully => 'Belge başarıyla kaydedildi';

  @override
  String get emptyTermDatabase => 'Terim veritabanı boş. Lütfen önce terim ekleyin.';

  @override
  String get processingDocument => 'Belge işleniyor';

  @override
  String get noCorrectionsFound => 'Hiçbir düzeltme önerisi bulunamadı. Tüm terimler doğru kullanılmış veya eşleşen terim yok.';

  @override
  String correctionsFound(int count) {
    return '$count düzeltme önerisi bulundu.';
  }

  @override
  String errorProcessingDocument(String error) {
    return 'Belge işlenirken hata oluştu: $error';
  }

  @override
  String get correctionTextEmpty => 'Düzeltme metni boş olamaz!';

  @override
  String get correctionAppliedSuccessfully => 'Düzeltme başarıyla uygulandı';

  @override
  String errorApplyingCorrection(String error) {
    return 'Düzeltme uygulanırken hata oluştu: $error';
  }

  @override
  String get noCorrectionsToApply => 'Uygulanacak düzeltme bulunamadı';

  @override
  String get allCorrectionsApplied => 'Tüm düzeltmeler uygulandı';

  @override
  String get projectTerms => 'Proje Terimleri';

  @override
  String get newTerm => 'Yeni Terim';

  @override
  String get noTermsInProject => 'Bu projede henüz terim yok';

  @override
  String get addTerm => 'Terim Ekle';

  @override
  String get optionalNotes => 'Notlar (İsteğe Bağlı)';

  @override
  String get termsRequired => 'Çince ve İngilizce terimler gereklidir';

  @override
  String get termAdded => 'Terim eklendi';

  @override
  String get termUpdated => 'Terim güncellendi';

  @override
  String get deleteTermConfirmation => 'Bu terimi silmek istediğinizden emin misiniz?';

  @override
  String get termDeleted => 'Terim silindi';

  @override
  String get addDocument => 'Belge Ekle';

  @override
  String get addFromFolder => 'Klasörden Ekle';

  @override
  String get projectNotFound => 'Proje bulunamadı';

  @override
  String get noDocumentsInProject => 'Bu projede henüz belge yok';

  @override
  String get lastUpdate => 'Son Güncelleme';

  @override
  String get addDocumentsForReports => 'Raporlar oluşturmak için önce belgeler eklemelisiniz';

  @override
  String get documentAddedSuccessfully => 'Belge başarıyla eklendi';

  @override
  String get selectSubtitleFolder => 'Altyazı Dosyalarını İçeren Klasörü Seçin';

  @override
  String filesAdded(int count) {
    return '$count dosya çifti eklendi';
  }

  @override
  String errorsOccurred(int count) {
    return '$count hata oluştu';
  }

  @override
  String get noMatchingSubtitlePairs => 'Eşleşen altyazı çifti bulunamadı';

  @override
  String get deleteDocumentConfirmation => 'Bu belgeyi projeden silmek istediğinizden emin misiniz?';

  @override
  String get documentDeleted => 'Belge silindi';

  @override
  String get deleteDocument => 'Belgeyi Sil';

  @override
  String documentLineInfo(int lineCount, String correctionInfo) {
    return 'Satır sayısı: $lineCount | $correctionInfo';
  }

  @override
  String documentCorrectionInfo(int count) {
    return '$count satırda düzeltme';
  }

  @override
  String documentDateInfo(String importDate, String processedInfo) {
    return 'Eklenme: $importDate $processedInfo';
  }

  @override
  String documentLastProcessedInfo(String date) {
    return '| Son işlem: $date';
  }

  @override
  String get consistencyReportTitle => 'Terim Tutarlılık Raporu';

  @override
  String get document => 'Belge';

  @override
  String get creationDate => 'Oluşturulma Tarihi';

  @override
  String get totalLinesReport => 'Toplam satır sayısı';

  @override
  String get correctedLinesReport => 'Düzeltilen satır sayısı';

  @override
  String get totalCorrectionsReport => 'Toplam düzeltme sayısı';

  @override
  String get appliedCorrectionsReport => 'Uygulanan düzeltme sayısı';

  @override
  String get termLabel => 'Terim';

  @override
  String get frequencyLabel => 'Sıklık';

  @override
  String get statusLabel => 'Durum';

  @override
  String get pendingStatus => 'Beklemede';

  @override
  String get incorrectEnglishTerm => 'Yanlış İngilizce Terim';

  @override
  String get correctEnglishTerm => 'Doğru İngilizce Terim';

  @override
  String get lineNumber1 => 'Satır No';

  @override
  String get includingDuplicates => 'tekrarlar dahil';

  @override
  String get uniqueCorrections => 'Benzersiz düzeltmeler';

  @override
  String get lineNotFound => 'Satır bulunamadı';

  @override
  String get processingLine => 'Satır işleniyor';

  @override
  String get termMatchesFound => 'terim eşleşmesi bulundu';

  @override
  String get warning => 'UYARI';

  @override
  String get mismatchedLineNumbers => 'Eşleşmeyen satır numaraları';

  @override
  String get correcting => 'Düzeltiliyor';

  @override
  String get correction => 'Düzeltme';

  @override
  String get shouldBe => 'olması gereken';

  @override
  String get incorrectTermNotFound => 'Hatalı terim bulunamadı';

  @override
  String get inLine => 'satırında';

  @override
  String get correctionsApplied => 'düzeltme uygulandı';

  @override
  String get correct => 'doğru';

  @override
  String get subscriptionTitle => 'Aboneliğim';

  @override
  String subtitleUploadsRemaining(int remaining, int max) {
    return 'Kalan yüklemeler: $remaining / $max';
  }

  @override
  String get subtitleUploadRights => 'Altyazı Yükleme Hakları';

  @override
  String get noUploadsRemaining => 'Hiç altyazı yükleme hakkınız kalmadı. Daha fazla altyazı yüklemek için aboneliğinizi yenileyin.';

  @override
  String get packages => 'Paketler';

  @override
  String get basicPackage => 'Temel Paket';

  @override
  String get premiumPackage => 'Premium Paket';

  @override
  String get proPackage => 'Pro Paket';

  @override
  String subtitleUploads(int count) {
    return '$count altyazı yükleme hakkı';
  }

  @override
  String get purchase => 'Satın Al';

  @override
  String get recommended => 'Önerilen';

  @override
  String get paymentSuccessful => 'Ödeme Başarılı';

  @override
  String purchasedUploads(int count) {
    return '$count altyazı yükleme hakkı satın aldınız.';
  }
}
