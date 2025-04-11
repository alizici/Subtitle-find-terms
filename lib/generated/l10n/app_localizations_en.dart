// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Chinese-English Term Corrector';

  @override
  String get projectsScreenTitle => 'Projects';

  @override
  String get newProject => 'New Project';

  @override
  String get deleteProject => 'Delete Project';

  @override
  String get editProject => 'Edit Project';

  @override
  String get projectName => 'Project Name';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteConfirmation => 'Are you sure you want to delete this project? This action cannot be undone.';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get saveDialogTitle => 'Save';

  @override
  String get categoryPerson => 'Person';

  @override
  String get categoryPlace => 'Place';

  @override
  String get categoryOrganization => 'Organization';

  @override
  String get categoryTechnical => 'Technical';

  @override
  String get categoryOther => 'Other';

  @override
  String get categoryGeneral => 'General';

  @override
  String get defaultTermsFileName => 'terms.json';

  @override
  String get defaultReportFileName => 'term_report.html';

  @override
  String get errorFileLoad => 'An error occurred while loading the file';

  @override
  String get errorFileSave => 'An error occurred while saving the file';

  @override
  String get errorTermImport => 'An error occurred while importing terms';

  @override
  String get errorTermExport => 'An error occurred while exporting terms';

  @override
  String get successTermImport => 'Terms successfully imported';

  @override
  String get successTermExport => 'Terms successfully exported';

  @override
  String get successFileLoad => 'File successfully loaded';

  @override
  String get successFileSave => 'File successfully saved';

  @override
  String get successCorrectionsApplied => 'Corrections successfully applied';

  @override
  String invalidTimeFormat(String timestamp) {
    return 'Invalid time format: $timestamp';
  }

  @override
  String invalidSecondsFormat(String timestamp) {
    return 'Invalid seconds/centiseconds format: $timestamp';
  }

  @override
  String timestampParsingError(String timestamp, String error) {
    return 'Timestamp parsing error: \'$timestamp\' - $error';
  }

  @override
  String warningDialogueMissingFields(String line) {
    return 'Warning: Not enough fields in Dialogue line: $line';
  }

  @override
  String dialogueParsingError(String line, String format, String error) {
    return 'Could not parse Dialogue line: \'$line\'\nFormat: $format\nError: $error';
  }

  @override
  String get editButton => 'Edit';

  @override
  String get deleteButton => 'Delete';

  @override
  String get sourceText => 'Source Text';

  @override
  String get englishTranslation => 'English Translation';

  @override
  String get corrected => 'Corrected';

  @override
  String get applyButton => 'Apply';

  @override
  String get appliedStatus => 'Applied';

  @override
  String get linePrefix => 'Line';

  @override
  String get incorrectLabel => 'Incorrect:';

  @override
  String get correctLabel => 'Correct:';

  @override
  String get termManagement => 'Term Management';

  @override
  String get import => 'Import';

  @override
  String get export => 'Export';

  @override
  String get searchTerm => 'Search Term';

  @override
  String get filterCategory => 'Filter Category';

  @override
  String get all => 'All';

  @override
  String get personName => 'Person Name';

  @override
  String get placeName => 'Place Name';

  @override
  String get organization => 'Organization';

  @override
  String get technicalTerm => 'Technical Term';

  @override
  String get general => 'General';

  @override
  String get other => 'Other';

  @override
  String get noTermsFound => 'No terms found';

  @override
  String get editTerm => 'Edit Term';

  @override
  String get addNewTerm => 'Add New Term';

  @override
  String get chineseTerm => 'Chinese Term';

  @override
  String get enterChineseTerm => 'Please enter Chinese term';

  @override
  String get englishTerm => 'English Term';

  @override
  String get enterEnglishTerm => 'Please enter English term';

  @override
  String get category => 'Category';

  @override
  String get notes => 'Notes';

  @override
  String get add => 'Add';

  @override
  String get update => 'Update';

  @override
  String get deleteTerm => 'Delete Term';

  @override
  String get confirmDelete => 'Are you sure you want to delete this term?';

  @override
  String get delete => 'Delete';

  @override
  String get importSuccess => 'Project imported successfully';

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get importResult => 'Import Result';

  @override
  String get ok => 'OK';

  @override
  String get exportTerms => 'Export Terms';

  @override
  String get exportSuccess => 'Project exported successfully';

  @override
  String get reports => 'Reports';

  @override
  String get exportReport => 'Export Report';

  @override
  String get pleaseUploadDocument => 'Please upload a document';

  @override
  String get summary => 'Summary';

  @override
  String get totalLines => 'Total Lines';

  @override
  String get correctedLines => 'Corrected Lines';

  @override
  String get totalCorrections => 'Total Corrections';

  @override
  String get appliedCorrections => 'Applied Corrections';

  @override
  String get consistencyScore => 'Consistency Score';

  @override
  String get excellentConsistency => 'Excellent consistency';

  @override
  String get goodConsistency => 'Good consistency';

  @override
  String get mediumConsistency => 'Medium consistency';

  @override
  String get lowConsistency => 'Low consistency';

  @override
  String get veryLowConsistency => 'Very low consistency';

  @override
  String get mostFrequentlyMistranslatedTerms => 'Most Frequently Mistranslated Terms';

  @override
  String get noMistranslatedTermsFound => 'No mistranslated terms found';

  @override
  String timesOccurred(int count) {
    return '$count times';
  }

  @override
  String get correctionDetails => 'Correction Details';

  @override
  String totalCorrections2(int count) {
    return 'Total: $count corrections';
  }

  @override
  String get noCorrectionSuggestions => 'No correction suggestions yet';

  @override
  String line(int number) {
    return 'Line: $number';
  }

  @override
  String get saveReport => 'Save Report';

  @override
  String get consistencyReportFileName => 'term_consistency_report.html';

  @override
  String get reportSavedSuccessfully => 'Report saved successfully';

  @override
  String get importProjectTooltip => 'Import Project';

  @override
  String get noProjectsMessage => 'You haven\'t created any projects yet';

  @override
  String totalProjects(int count) {
    return 'Total $count projects';
  }

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get descriptionHint => 'E.g.: Standardization of subtitle terms for 5-season Wuxia series';

  @override
  String get projectNameHint => 'E.g.: Wuxia Series Term Translation';

  @override
  String get projectDeleted => 'Project deleted';

  @override
  String get exportProjectDialogTitle => 'Export Project';

  @override
  String projectDetails(int docCount, String updateDate) {
    return 'Documents: $docCount | Last update: $updateDate';
  }

  @override
  String get exportAction => 'Export';

  @override
  String get deleteAction => 'Delete';

  @override
  String get documentProcessing => 'Document Processing';

  @override
  String get documentProcessingTitle => 'Document Processing';

  @override
  String get horizontalPanelTooltip => 'Horizontal Panel View';

  @override
  String get verticalPanelTooltip => 'Vertical Panel View';

  @override
  String get changeViewTooltip => 'Change View';

  @override
  String get openDocumentTooltip => 'Open Document';

  @override
  String get saveDocumentTooltip => 'Save Document';

  @override
  String get resetPanelSizeTooltip => 'Reset Panel Size';

  @override
  String correctionsCount(int count) {
    return 'Corrections ($count)';
  }

  @override
  String get applyAllCorrections => 'Apply All';

  @override
  String get applyCorrections => 'Apply';

  @override
  String get clearCorrections => 'Clear';

  @override
  String get total => 'Total';

  @override
  String get applied => 'Applied';

  @override
  String get pending => 'Pending';

  @override
  String get noCorrectionsYet => 'No correction suggestions yet';

  @override
  String get clickButtonForCorrections => 'Click the button in the bottom right corner to see correction suggestions';

  @override
  String get filterByLine => 'Filter by line:';

  @override
  String get allLines => 'All lines';

  @override
  String lineNumber(Object number) {
    return 'Line $number';
  }

  @override
  String get applyCorrection => 'Apply Correction';

  @override
  String get currentLineText => 'Current Line Text:';

  @override
  String get enterCorrectedText => 'Enter corrected text here';

  @override
  String correctionForLine(int number) {
    return 'Correction for line $number';
  }

  @override
  String get termDatabaseReference => 'Term Database Reference:';

  @override
  String get termSearchedInDatabase => 'Term Searched in Database: ';

  @override
  String get suggestedTerm => 'Suggested Term: ';

  @override
  String get dataDiscrepancyWarning => 'Warning: You can make your own correction.';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get selectChineseSourceDocument => 'Select Chinese Source Document';

  @override
  String get selectEnglishTranslationDocument => 'Select English Translation Document';

  @override
  String get selectFolderToSave => 'Select Folder to Save';

  @override
  String get documentSavedSuccessfully => 'Document saved successfully';

  @override
  String get emptyTermDatabase => 'Term database is empty. Please add terms first.';

  @override
  String get processingDocument => 'Processing document';

  @override
  String get noCorrectionsFound => 'No correction suggestions found. All terms are used correctly or there are no matching terms.';

  @override
  String correctionsFound(int count) {
    return '$count correction suggestions found.';
  }

  @override
  String errorProcessingDocument(String error) {
    return 'Error processing document: $error';
  }

  @override
  String get correctionTextEmpty => 'Correction text cannot be empty!';

  @override
  String get correctionAppliedSuccessfully => 'Correction applied successfully';

  @override
  String errorApplyingCorrection(String error) {
    return 'Error applying correction: $error';
  }

  @override
  String get noCorrectionsToApply => 'No corrections to apply';

  @override
  String get allCorrectionsApplied => 'All corrections applied';

  @override
  String get projectTerms => 'Project Terms';

  @override
  String get newTerm => 'New Term';

  @override
  String get noTermsInProject => 'No terms in this project yet';

  @override
  String get addTerm => 'Add Term';

  @override
  String get optionalNotes => 'Notes (Optional)';

  @override
  String get termsRequired => 'Chinese and English terms are required';

  @override
  String get termAdded => 'Term added';

  @override
  String get termUpdated => 'Term updated';

  @override
  String get deleteTermConfirmation => 'Are you sure you want to delete this term?';

  @override
  String get termDeleted => 'Term deleted';

  @override
  String get addDocument => 'Add Document';

  @override
  String get addFromFolder => 'Add from Folder';

  @override
  String get projectNotFound => 'Project not found';

  @override
  String get noDocumentsInProject => 'No documents in this project yet';

  @override
  String get lastUpdate => 'Last Update';

  @override
  String get addDocumentsForReports => 'Add documents first to generate reports';

  @override
  String get documentAddedSuccessfully => 'Document added successfully';

  @override
  String get selectSubtitleFolder => 'Select Folder Containing Subtitle Files';

  @override
  String filesAdded(int count) {
    return '$count file pairs added';
  }

  @override
  String errorsOccurred(int count) {
    return '$count errors occurred';
  }

  @override
  String get noMatchingSubtitlePairs => 'No matching subtitle pairs found';

  @override
  String get deleteDocumentConfirmation => 'Are you sure you want to delete this document from the project?';

  @override
  String get documentDeleted => 'Document deleted';

  @override
  String get deleteDocument => 'Delete Document';

  @override
  String documentLineInfo(int lineCount, String correctionInfo) {
    return 'Lines: $lineCount | $correctionInfo';
  }

  @override
  String documentCorrectionInfo(int count) {
    return 'Corrections in $count lines';
  }

  @override
  String documentDateInfo(String importDate, String processedInfo) {
    return 'Added: $importDate $processedInfo';
  }

  @override
  String documentLastProcessedInfo(String date) {
    return '| Last processed: $date';
  }

  @override
  String get consistencyReportTitle => 'Term Consistency Report';

  @override
  String get document => 'Document';

  @override
  String get creationDate => 'Creation Date';

  @override
  String get totalLinesReport => 'Total number of lines';

  @override
  String get correctedLinesReport => 'Number of corrected lines';

  @override
  String get totalCorrectionsReport => 'Total number of corrections';

  @override
  String get appliedCorrectionsReport => 'Number of applied corrections';

  @override
  String get termLabel => 'Term';

  @override
  String get frequencyLabel => 'Frequency';

  @override
  String get statusLabel => 'Status';

  @override
  String get pendingStatus => 'Pending';

  @override
  String get incorrectEnglishTerm => 'Incorrect English Term';

  @override
  String get correctEnglishTerm => 'Correct English Term';

  @override
  String get lineNumber1 => 'Line Number';

  @override
  String get includingDuplicates => 'including duplicates';

  @override
  String get uniqueCorrections => 'Unique corrections';

  @override
  String get lineNotFound => 'Line not found';

  @override
  String get processingLine => 'Processing line';

  @override
  String get termMatchesFound => 'term matches found';

  @override
  String get warning => 'WARNING';

  @override
  String get mismatchedLineNumbers => 'Mismatched line numbers';

  @override
  String get correcting => 'Correcting';

  @override
  String get correction => 'Correction';

  @override
  String get shouldBe => 'should be';

  @override
  String get incorrectTermNotFound => 'Incorrect term not found';

  @override
  String get inLine => 'in line';

  @override
  String get correctionsApplied => 'corrections applied';

  @override
  String get correct => 'correct';

  @override
  String get subscriptionTitle => 'My Subscription';

  @override
  String subtitleUploadsRemaining(int remaining, int max) {
    return 'Remaining uploads: $remaining / $max';
  }

  @override
  String get subtitleUploadRights => 'Subtitle Upload Rights';

  @override
  String get noUploadsRemaining => 'You have no subtitle uploads remaining. Renew your subscription to upload more subtitles.';

  @override
  String get packages => 'Packages';

  @override
  String get basicPackage => 'Basic Package';

  @override
  String get premiumPackage => 'Premium Package';

  @override
  String get proPackage => 'Pro Package';

  @override
  String subtitleUploads(int count) {
    return '$count subtitle upload rights';
  }

  @override
  String get purchase => 'Purchase';

  @override
  String get recommended => 'Recommended';

  @override
  String get paymentSuccessful => 'Payment Successful';

  @override
  String purchasedUploads(int count) {
    return 'You have purchased $count subtitle upload rights.';
  }
}
