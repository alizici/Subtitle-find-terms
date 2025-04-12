import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('tr'),
    Locale('en'),
    Locale('zh')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Chinese-English Term Corrector'**
  String get appTitle;

  /// Title for the projects screen
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projectsScreenTitle;

  /// New project button and dialog title
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get newProject;

  /// Delete project dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Project'**
  String get deleteProject;

  /// Edit project button text
  ///
  /// In en, this message translates to:
  /// **'Edit Project'**
  String get editProject;

  /// Project name field label
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get projectName;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this project? This action cannot be undone.'**
  String get deleteConfirmation;

  /// Yes button text
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No button text
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Save dialog title
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveDialogTitle;

  /// Category name for persons
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get categoryPerson;

  /// Category name for places
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get categoryPlace;

  /// Category name for organizations
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get categoryOrganization;

  /// Category name for technical terms
  ///
  /// In en, this message translates to:
  /// **'Technical'**
  String get categoryTechnical;

  /// Category name for other terms
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// Category name for general terms
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get categoryGeneral;

  /// Default terms file name
  ///
  /// In en, this message translates to:
  /// **'terms.json'**
  String get defaultTermsFileName;

  /// Default report file name
  ///
  /// In en, this message translates to:
  /// **'term_report.html'**
  String get defaultReportFileName;

  /// Error message for file loading
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading the file'**
  String get errorFileLoad;

  /// Error message for file saving
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving the file'**
  String get errorFileSave;

  /// Error message for term importing
  ///
  /// In en, this message translates to:
  /// **'An error occurred while importing terms'**
  String get errorTermImport;

  /// Error message for term exporting
  ///
  /// In en, this message translates to:
  /// **'An error occurred while exporting terms'**
  String get errorTermExport;

  /// Success message for term importing
  ///
  /// In en, this message translates to:
  /// **'Terms successfully imported'**
  String get successTermImport;

  /// Success message for term exporting
  ///
  /// In en, this message translates to:
  /// **'Terms successfully exported'**
  String get successTermExport;

  /// Success message for file loading
  ///
  /// In en, this message translates to:
  /// **'File successfully loaded'**
  String get successFileLoad;

  /// Success message for file saving
  ///
  /// In en, this message translates to:
  /// **'File successfully saved'**
  String get successFileSave;

  /// Success message for applying corrections
  ///
  /// In en, this message translates to:
  /// **'Corrections successfully applied'**
  String get successCorrectionsApplied;

  /// Error message for invalid time format
  ///
  /// In en, this message translates to:
  /// **'Invalid time format: {timestamp}'**
  String invalidTimeFormat(String timestamp);

  /// Error message for invalid seconds format
  ///
  /// In en, this message translates to:
  /// **'Invalid seconds/centiseconds format: {timestamp}'**
  String invalidSecondsFormat(String timestamp);

  /// Error message for timestamp parsing error
  ///
  /// In en, this message translates to:
  /// **'Timestamp parsing error: \'{timestamp}\' - {error}'**
  String timestampParsingError(String timestamp, String error);

  /// Warning message for dialogue line with missing fields
  ///
  /// In en, this message translates to:
  /// **'Warning: Not enough fields in Dialogue line: {line}'**
  String warningDialogueMissingFields(String line);

  /// Error message for dialogue parsing error
  ///
  /// In en, this message translates to:
  /// **'Could not parse Dialogue line: \'{line}\'\nFormat: {format}\nError: {error}'**
  String dialogueParsingError(String line, String format, String error);

  /// Edit button tooltip text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// Delete button tooltip text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// Title for the source text column
  ///
  /// In en, this message translates to:
  /// **'Source Text'**
  String get sourceText;

  /// Title for the English translation column
  ///
  /// In en, this message translates to:
  /// **'English Translation'**
  String get englishTranslation;

  /// Label for corrected text
  ///
  /// In en, this message translates to:
  /// **'Corrected'**
  String get corrected;

  /// Apply button text for correction items
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyButton;

  /// Status text when a correction has been applied
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get appliedStatus;

  /// Prefix for line number display
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get linePrefix;

  /// Label for incorrect translation
  ///
  /// In en, this message translates to:
  /// **'Incorrect:'**
  String get incorrectLabel;

  /// Label for correct translation
  ///
  /// In en, this message translates to:
  /// **'Correct:'**
  String get correctLabel;

  /// Navigation label for term management screen
  ///
  /// In en, this message translates to:
  /// **'Term Management'**
  String get termManagement;

  /// Import button text
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// Export button tooltip text
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// Search field label
  ///
  /// In en, this message translates to:
  /// **'Search Term'**
  String get searchTerm;

  /// Category filter dropdown label
  ///
  /// In en, this message translates to:
  /// **'Filter Category'**
  String get filterCategory;

  /// All categories option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Category: Person Name
  ///
  /// In en, this message translates to:
  /// **'Person Name'**
  String get personName;

  /// Category: Place Name
  ///
  /// In en, this message translates to:
  /// **'Place Name'**
  String get placeName;

  /// Category: Organization
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organization;

  /// Category: Technical Term
  ///
  /// In en, this message translates to:
  /// **'Technical Term'**
  String get technicalTerm;

  /// Category: General
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// Category: Other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Message when no terms match the filters
  ///
  /// In en, this message translates to:
  /// **'No terms found'**
  String get noTermsFound;

  /// Dialog title for editing term
  ///
  /// In en, this message translates to:
  /// **'Edit Term'**
  String get editTerm;

  /// Dialog title for adding new term
  ///
  /// In en, this message translates to:
  /// **'Add New Term'**
  String get addNewTerm;

  /// Chinese term input label
  ///
  /// In en, this message translates to:
  /// **'Chinese Term'**
  String get chineseTerm;

  /// Validation message for Chinese term
  ///
  /// In en, this message translates to:
  /// **'Please enter Chinese term'**
  String get enterChineseTerm;

  /// English term input label
  ///
  /// In en, this message translates to:
  /// **'English Term'**
  String get englishTerm;

  /// Validation message for English term
  ///
  /// In en, this message translates to:
  /// **'Please enter English term'**
  String get enterEnglishTerm;

  /// Category dropdown label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Notes field label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Update button text
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Dialog title for deleting term
  ///
  /// In en, this message translates to:
  /// **'Delete Term'**
  String get deleteTerm;

  /// Confirmation message for term deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this term?'**
  String get confirmDelete;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Message shown after successful project import
  ///
  /// In en, this message translates to:
  /// **'Project imported successfully'**
  String get importSuccess;

  /// Error message template
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(String error);

  /// Error message with details
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// Import result dialog title
  ///
  /// In en, this message translates to:
  /// **'Import Result'**
  String get importResult;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Export dialog title
  ///
  /// In en, this message translates to:
  /// **'Export Terms'**
  String get exportTerms;

  /// Message shown after successful project export
  ///
  /// In en, this message translates to:
  /// **'Project exported successfully'**
  String get exportSuccess;

  /// Navigation label for reports screen
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// Export report button tooltip text
  ///
  /// In en, this message translates to:
  /// **'Export Report'**
  String get exportReport;

  /// Message shown when no document is loaded
  ///
  /// In en, this message translates to:
  /// **'Please upload a document'**
  String get pleaseUploadDocument;

  /// Title for the summary section
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// Label for total lines count
  ///
  /// In en, this message translates to:
  /// **'Total Lines'**
  String get totalLines;

  /// Label for corrected lines count
  ///
  /// In en, this message translates to:
  /// **'Corrected Lines'**
  String get correctedLines;

  /// Label for total corrections count
  ///
  /// In en, this message translates to:
  /// **'Total Corrections'**
  String get totalCorrections;

  /// Label for applied corrections count
  ///
  /// In en, this message translates to:
  /// **'Applied Corrections'**
  String get appliedCorrections;

  /// Title for the consistency score section
  ///
  /// In en, this message translates to:
  /// **'Consistency Score'**
  String get consistencyScore;

  /// Text for excellent consistency score
  ///
  /// In en, this message translates to:
  /// **'Excellent consistency'**
  String get excellentConsistency;

  /// Text for good consistency score
  ///
  /// In en, this message translates to:
  /// **'Good consistency'**
  String get goodConsistency;

  /// Text for medium consistency score
  ///
  /// In en, this message translates to:
  /// **'Medium consistency'**
  String get mediumConsistency;

  /// Text for low consistency score
  ///
  /// In en, this message translates to:
  /// **'Low consistency'**
  String get lowConsistency;

  /// Text for very low consistency score
  ///
  /// In en, this message translates to:
  /// **'Very low consistency'**
  String get veryLowConsistency;

  /// Title for the mistranslated terms section
  ///
  /// In en, this message translates to:
  /// **'Most Frequently Mistranslated Terms'**
  String get mostFrequentlyMistranslatedTerms;

  /// Message shown when no mistranslated terms are found
  ///
  /// In en, this message translates to:
  /// **'No mistranslated terms found'**
  String get noMistranslatedTermsFound;

  /// Number of times a term was mistranslated
  ///
  /// In en, this message translates to:
  /// **'{count} times'**
  String timesOccurred(int count);

  /// Title for the correction details section
  ///
  /// In en, this message translates to:
  /// **'Correction Details'**
  String get correctionDetails;

  /// Total number of corrections
  ///
  /// In en, this message translates to:
  /// **'Total: {count} corrections'**
  String totalCorrections2(int count);

  /// Message shown when no correction suggestions are available
  ///
  /// In en, this message translates to:
  /// **'No correction suggestions yet'**
  String get noCorrectionSuggestions;

  /// Line number
  ///
  /// In en, this message translates to:
  /// **'Line: {number}'**
  String line(int number);

  /// Save report dialog title
  ///
  /// In en, this message translates to:
  /// **'Save Report'**
  String get saveReport;

  /// Default filename for the consistency report
  ///
  /// In en, this message translates to:
  /// **'term_consistency_report.html'**
  String get consistencyReportFileName;

  /// Message shown when report is saved successfully
  ///
  /// In en, this message translates to:
  /// **'Report saved successfully'**
  String get reportSavedSuccessfully;

  /// Tooltip for import project button
  ///
  /// In en, this message translates to:
  /// **'Import Project'**
  String get importProjectTooltip;

  /// Message shown when user has no projects
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created any projects yet'**
  String get noProjectsMessage;

  /// Total number of projects
  ///
  /// In en, this message translates to:
  /// **'Total {count} projects'**
  String totalProjects(int count);

  /// Optional description field label
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// Example hint for project description field
  ///
  /// In en, this message translates to:
  /// **'E.g.: Standardization of subtitle terms for 5-season Wuxia series'**
  String get descriptionHint;

  /// Example hint for project name field
  ///
  /// In en, this message translates to:
  /// **'E.g.: Wuxia Series Term Translation'**
  String get projectNameHint;

  /// Message shown after project is deleted
  ///
  /// In en, this message translates to:
  /// **'Project deleted'**
  String get projectDeleted;

  /// Title for export project dialog
  ///
  /// In en, this message translates to:
  /// **'Export Project'**
  String get exportProjectDialogTitle;

  /// Project details showing document count and last update date
  ///
  /// In en, this message translates to:
  /// **'Documents: {docCount} | Last update: {updateDate}'**
  String projectDetails(int docCount, String updateDate);

  /// Export action label in popup menu
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportAction;

  /// Delete action label in popup menu
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// Navigation label for document processing screen
  ///
  /// In en, this message translates to:
  /// **'Document Processing'**
  String get documentProcessing;

  /// Title for document processing screen
  ///
  /// In en, this message translates to:
  /// **'Document Processing'**
  String get documentProcessingTitle;

  /// Tooltip for horizontal panel view
  ///
  /// In en, this message translates to:
  /// **'Horizontal Panel View'**
  String get horizontalPanelTooltip;

  /// Tooltip for vertical panel view
  ///
  /// In en, this message translates to:
  /// **'Vertical Panel View'**
  String get verticalPanelTooltip;

  /// Tooltip for changing document view mode
  ///
  /// In en, this message translates to:
  /// **'Change View'**
  String get changeViewTooltip;

  /// Tooltip for open document button
  ///
  /// In en, this message translates to:
  /// **'Open Document'**
  String get openDocumentTooltip;

  /// Tooltip for save document button
  ///
  /// In en, this message translates to:
  /// **'Save Document'**
  String get saveDocumentTooltip;

  /// Tooltip for resetting panel size
  ///
  /// In en, this message translates to:
  /// **'Reset Panel Size'**
  String get resetPanelSizeTooltip;

  /// Title showing number of corrections
  ///
  /// In en, this message translates to:
  /// **'Corrections ({count})'**
  String correctionsCount(int count);

  /// Button to apply all corrections at once
  ///
  /// In en, this message translates to:
  /// **'Apply All'**
  String get applyAllCorrections;

  /// Button to apply corrections (short version)
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyCorrections;

  /// Button to clear all corrections
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearCorrections;

  /// Label for total corrections count
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Label for applied corrections count
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get applied;

  /// Label for pending corrections count
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Message shown when there are no corrections
  ///
  /// In en, this message translates to:
  /// **'No correction suggestions yet'**
  String get noCorrectionsYet;

  /// Instruction for generating corrections
  ///
  /// In en, this message translates to:
  /// **'Click the button in the bottom right corner to see correction suggestions'**
  String get clickButtonForCorrections;

  /// Label for line filter dropdown
  ///
  /// In en, this message translates to:
  /// **'Filter by line:'**
  String get filterByLine;

  /// Option for showing all lines in filter
  ///
  /// In en, this message translates to:
  /// **'All lines'**
  String get allLines;

  /// Label for line number
  ///
  /// In en, this message translates to:
  /// **'Line {number}'**
  String lineNumber(Object number);

  /// Tooltip for applying single correction
  ///
  /// In en, this message translates to:
  /// **'Apply Correction'**
  String get applyCorrection;

  /// Label for current line text field
  ///
  /// In en, this message translates to:
  /// **'Current Line Text:'**
  String get currentLineText;

  /// Hint for entering corrected text
  ///
  /// In en, this message translates to:
  /// **'Enter corrected text here'**
  String get enterCorrectedText;

  /// Helper text for correction field
  ///
  /// In en, this message translates to:
  /// **'Correction for line {number}'**
  String correctionForLine(int number);

  /// Title for term database reference section
  ///
  /// In en, this message translates to:
  /// **'Term Database Reference:'**
  String get termDatabaseReference;

  /// Label for term searched in database
  ///
  /// In en, this message translates to:
  /// **'Term Searched in Database: '**
  String get termSearchedInDatabase;

  /// Label for suggested term
  ///
  /// In en, this message translates to:
  /// **'Suggested Term: '**
  String get suggestedTerm;

  /// Warning about potential discrepancies in data
  ///
  /// In en, this message translates to:
  /// **'Warning: You can make your own correction.'**
  String get dataDiscrepancyWarning;

  /// Button to save changes
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Dialog title for selecting Chinese source document
  ///
  /// In en, this message translates to:
  /// **'Select Chinese Source Document'**
  String get selectChineseSourceDocument;

  /// Dialog title for selecting English translation document
  ///
  /// In en, this message translates to:
  /// **'Select English Translation Document'**
  String get selectEnglishTranslationDocument;

  /// Dialog title for selecting folder to save document
  ///
  /// In en, this message translates to:
  /// **'Select Folder to Save'**
  String get selectFolderToSave;

  /// Message shown when document is saved successfully
  ///
  /// In en, this message translates to:
  /// **'Document saved successfully'**
  String get documentSavedSuccessfully;

  /// Warning when term database is empty
  ///
  /// In en, this message translates to:
  /// **'Term database is empty. Please add terms first.'**
  String get emptyTermDatabase;

  /// Message when processing document
  ///
  /// In en, this message translates to:
  /// **'Processing document'**
  String get processingDocument;

  /// Message when no corrections are found
  ///
  /// In en, this message translates to:
  /// **'No correction suggestions found. All terms are used correctly or there are no matching terms.'**
  String get noCorrectionsFound;

  /// Message showing number of corrections found
  ///
  /// In en, this message translates to:
  /// **'{count} correction suggestions found.'**
  String correctionsFound(int count);

  /// Error message while processing document
  ///
  /// In en, this message translates to:
  /// **'Error processing document: {error}'**
  String errorProcessingDocument(String error);

  /// Error when correction text is empty
  ///
  /// In en, this message translates to:
  /// **'Correction text cannot be empty!'**
  String get correctionTextEmpty;

  /// Message when correction is applied successfully
  ///
  /// In en, this message translates to:
  /// **'Correction applied successfully'**
  String get correctionAppliedSuccessfully;

  /// Error message when applying correction
  ///
  /// In en, this message translates to:
  /// **'Error applying correction: {error}'**
  String errorApplyingCorrection(String error);

  /// Message when there are no corrections to apply
  ///
  /// In en, this message translates to:
  /// **'No corrections to apply'**
  String get noCorrectionsToApply;

  /// Message when all corrections are applied
  ///
  /// In en, this message translates to:
  /// **'All corrections applied'**
  String get allCorrectionsApplied;

  /// Project terms title
  ///
  /// In en, this message translates to:
  /// **'Project Terms'**
  String get projectTerms;

  /// New term button text
  ///
  /// In en, this message translates to:
  /// **'New Term'**
  String get newTerm;

  /// Text shown when project has no terms
  ///
  /// In en, this message translates to:
  /// **'No terms in this project yet'**
  String get noTermsInProject;

  /// Add term button text
  ///
  /// In en, this message translates to:
  /// **'Add Term'**
  String get addTerm;

  /// Optional notes input label
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get optionalNotes;

  /// Error message for required fields
  ///
  /// In en, this message translates to:
  /// **'Chinese and English terms are required'**
  String get termsRequired;

  /// Success message after adding term
  ///
  /// In en, this message translates to:
  /// **'Term added'**
  String get termAdded;

  /// Success message after updating term
  ///
  /// In en, this message translates to:
  /// **'Term updated'**
  String get termUpdated;

  /// Confirmation message for term deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this term?'**
  String get deleteTermConfirmation;

  /// Success message after deleting term
  ///
  /// In en, this message translates to:
  /// **'Term deleted'**
  String get termDeleted;

  /// Text for add document button
  ///
  /// In en, this message translates to:
  /// **'Add Document'**
  String get addDocument;

  /// Text for add from folder option
  ///
  /// In en, this message translates to:
  /// **'Add from Folder'**
  String get addFromFolder;

  /// Message shown when project is not found
  ///
  /// In en, this message translates to:
  /// **'Project not found'**
  String get projectNotFound;

  /// Message shown when there are no documents in project
  ///
  /// In en, this message translates to:
  /// **'No documents in this project yet'**
  String get noDocumentsInProject;

  /// Label for last update date
  ///
  /// In en, this message translates to:
  /// **'Last Update'**
  String get lastUpdate;

  /// Message shown when no documents to generate reports
  ///
  /// In en, this message translates to:
  /// **'Add documents first to generate reports'**
  String get addDocumentsForReports;

  /// Message shown when document is added
  ///
  /// In en, this message translates to:
  /// **'Document added successfully'**
  String get documentAddedSuccessfully;

  /// Dialog title for selecting subtitle folder
  ///
  /// In en, this message translates to:
  /// **'Select Folder Containing Subtitle Files'**
  String get selectSubtitleFolder;

  /// Message showing number of files added
  ///
  /// In en, this message translates to:
  /// **'{count} file pairs added'**
  String filesAdded(int count);

  /// Message showing number of errors
  ///
  /// In en, this message translates to:
  /// **'{count} errors occurred'**
  String errorsOccurred(int count);

  /// Message when no matching subtitle pairs are found
  ///
  /// In en, this message translates to:
  /// **'No matching subtitle pairs found'**
  String get noMatchingSubtitlePairs;

  /// Confirmation message for document deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this document from the project?'**
  String get deleteDocumentConfirmation;

  /// Message shown after document is deleted
  ///
  /// In en, this message translates to:
  /// **'Document deleted'**
  String get documentDeleted;

  /// Title for document deletion dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Document'**
  String get deleteDocument;

  /// Document line information with correction status
  ///
  /// In en, this message translates to:
  /// **'Lines: {lineCount} | {correctionInfo}'**
  String documentLineInfo(int lineCount, String correctionInfo);

  /// Information about corrections in document lines
  ///
  /// In en, this message translates to:
  /// **'Corrections in {count} lines'**
  String documentCorrectionInfo(int count);

  /// Document date information
  ///
  /// In en, this message translates to:
  /// **'Added: {importDate} {processedInfo}'**
  String documentDateInfo(String importDate, String processedInfo);

  /// Last processed date information
  ///
  /// In en, this message translates to:
  /// **'| Last processed: {date}'**
  String documentLastProcessedInfo(String date);

  /// Title for the term consistency report
  ///
  /// In en, this message translates to:
  /// **'Term Consistency Report'**
  String get consistencyReportTitle;

  /// Label for document name
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// Label for creation date
  ///
  /// In en, this message translates to:
  /// **'Creation Date'**
  String get creationDate;

  /// Label for total lines in report
  ///
  /// In en, this message translates to:
  /// **'Total number of lines'**
  String get totalLinesReport;

  /// Label for corrected lines in report
  ///
  /// In en, this message translates to:
  /// **'Number of corrected lines'**
  String get correctedLinesReport;

  /// Label for total corrections in report
  ///
  /// In en, this message translates to:
  /// **'Total number of corrections'**
  String get totalCorrectionsReport;

  /// Label for applied corrections in report
  ///
  /// In en, this message translates to:
  /// **'Number of applied corrections'**
  String get appliedCorrectionsReport;

  /// Label for term column in table
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get termLabel;

  /// Label for frequency column in table
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequencyLabel;

  /// Label for status column in table
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// Status text when a correction is pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingStatus;

  /// Label for incorrect English term
  ///
  /// In en, this message translates to:
  /// **'Incorrect English Term'**
  String get incorrectEnglishTerm;

  /// Label for correct English term
  ///
  /// In en, this message translates to:
  /// **'Correct English Term'**
  String get correctEnglishTerm;

  /// No description provided for @lineNumber1.
  ///
  /// In en, this message translates to:
  /// **'Line Number'**
  String get lineNumber1;

  /// Text for including duplicates in counts
  ///
  /// In en, this message translates to:
  /// **'including duplicates'**
  String get includingDuplicates;

  /// Label for unique corrections count
  ///
  /// In en, this message translates to:
  /// **'Unique corrections'**
  String get uniqueCorrections;

  /// Error message when line not found
  ///
  /// In en, this message translates to:
  /// **'Line not found'**
  String get lineNotFound;

  /// Message when processing a line
  ///
  /// In en, this message translates to:
  /// **'Processing line'**
  String get processingLine;

  /// Message for number of term matches found
  ///
  /// In en, this message translates to:
  /// **'term matches found'**
  String get termMatchesFound;

  /// Warning label
  ///
  /// In en, this message translates to:
  /// **'WARNING'**
  String get warning;

  /// Warning about mismatched line numbers
  ///
  /// In en, this message translates to:
  /// **'Mismatched line numbers'**
  String get mismatchedLineNumbers;

  /// Message about correcting an issue
  ///
  /// In en, this message translates to:
  /// **'Correcting'**
  String get correcting;

  /// Label for a correction item
  ///
  /// In en, this message translates to:
  /// **'Correction'**
  String get correction;

  /// Text indicating what something should be
  ///
  /// In en, this message translates to:
  /// **'should be'**
  String get shouldBe;

  /// Warning when incorrect term not found in text
  ///
  /// In en, this message translates to:
  /// **'Incorrect term not found'**
  String get incorrectTermNotFound;

  /// Preposition for specifying in which line
  ///
  /// In en, this message translates to:
  /// **'in line'**
  String get inLine;

  /// Message for number of corrections applied
  ///
  /// In en, this message translates to:
  /// **'corrections applied'**
  String get correctionsApplied;

  /// Label for correct items count
  ///
  /// In en, this message translates to:
  /// **'correct'**
  String get correct;

  /// Title of subscription screen
  ///
  /// In en, this message translates to:
  /// **'My Subscription'**
  String get subscriptionTitle;

  /// Shows remaining subtitle upload credits
  ///
  /// In en, this message translates to:
  /// **'Remaining uploads: {remaining} / {max}'**
  String subtitleUploadsRemaining(int remaining, int max);

  /// Header for the remaining upload rights section
  ///
  /// In en, this message translates to:
  /// **'Subtitle Upload Rights'**
  String get subtitleUploadRights;

  /// Message shown when user has no uploads remaining
  ///
  /// In en, this message translates to:
  /// **'You have no subtitle uploads remaining. Renew your subscription to upload more subtitles.'**
  String get noUploadsRemaining;

  /// Header for subscription packages section
  ///
  /// In en, this message translates to:
  /// **'Packages'**
  String get packages;

  /// Name of the basic subscription package
  ///
  /// In en, this message translates to:
  /// **'Basic Package'**
  String get basicPackage;

  /// Name of the premium subscription package
  ///
  /// In en, this message translates to:
  /// **'Premium Package'**
  String get premiumPackage;

  /// Name of the pro subscription package
  ///
  /// In en, this message translates to:
  /// **'Pro Package'**
  String get proPackage;

  /// Number of subtitle upload rights in a package
  ///
  /// In en, this message translates to:
  /// **'{count} subtitle upload rights'**
  String subtitleUploads(int count);

  /// Purchase button text
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// Label for recommended package
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// Title for successful payment dialog
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get paymentSuccessful;

  /// Message showing number of purchased uploads
  ///
  /// In en, this message translates to:
  /// **'You have purchased {count} subtitle upload rights.'**
  String purchasedUploads(int count);

  /// Error message when document files cannot be found
  ///
  /// In en, this message translates to:
  /// **'Document files not found'**
  String get documentFilesNotFound;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'tr': return AppLocalizationsTr();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
