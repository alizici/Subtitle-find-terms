// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '中英术语校正器';

  @override
  String get projectsScreenTitle => '项目';

  @override
  String get newProject => '新项目';

  @override
  String get deleteProject => '删除项目';

  @override
  String get editProject => '编辑项目';

  @override
  String get projectName => '项目名称';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get deleteConfirmation => '您确定要删除此项目吗？此操作无法撤消。';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get saveDialogTitle => '保存';

  @override
  String get categoryPerson => '人物';

  @override
  String get categoryPlace => '地点';

  @override
  String get categoryOrganization => '组织';

  @override
  String get categoryTechnical => '技术';

  @override
  String get categoryOther => '其他';

  @override
  String get categoryGeneral => '一般';

  @override
  String get defaultTermsFileName => '术语.json';

  @override
  String get defaultReportFileName => '术语报告.html';

  @override
  String get errorFileLoad => '加载文件时出错';

  @override
  String get errorFileSave => '保存文件时出错';

  @override
  String get errorTermImport => '导入术语时出错';

  @override
  String get errorTermExport => '导出术语时出错';

  @override
  String get successTermImport => '术语成功导入';

  @override
  String get successTermExport => '术语成功导出';

  @override
  String get successFileLoad => '文件加载成功';

  @override
  String get successFileSave => '文件保存成功';

  @override
  String get successCorrectionsApplied => '成功应用更正';

  @override
  String invalidTimeFormat(String timestamp) {
    return '时间格式无效: $timestamp';
  }

  @override
  String invalidSecondsFormat(String timestamp) {
    return '秒/厘秒格式无效: $timestamp';
  }

  @override
  String timestampParsingError(String timestamp, String error) {
    return '时间戳解析错误: \'$timestamp\' - $error';
  }

  @override
  String warningDialogueMissingFields(String line) {
    return '警告: 对话行中的字段不足: $line';
  }

  @override
  String dialogueParsingError(String line, String format, String error) {
    return '无法解析对话行: \'$line\'\n格式: $format\n错误: $error';
  }

  @override
  String get editButton => '编辑';

  @override
  String get deleteButton => '删除';

  @override
  String get sourceText => '源文本';

  @override
  String get englishTranslation => '英文翻译';

  @override
  String get corrected => '已修正';

  @override
  String get applyButton => '应用';

  @override
  String get appliedStatus => '已应用';

  @override
  String get linePrefix => '行';

  @override
  String get incorrectLabel => '错误:';

  @override
  String get correctLabel => '正确:';

  @override
  String get termManagement => '术语管理';

  @override
  String get import => '导入';

  @override
  String get export => '导出';

  @override
  String get searchTerm => '搜索术语';

  @override
  String get filterCategory => '过滤类别';

  @override
  String get all => '全部';

  @override
  String get personName => '人名';

  @override
  String get placeName => '地名';

  @override
  String get organization => '组织';

  @override
  String get technicalTerm => '技术术语';

  @override
  String get general => '通用';

  @override
  String get other => '其他';

  @override
  String get noTermsFound => '未找到术语';

  @override
  String get editTerm => '编辑术语';

  @override
  String get addNewTerm => '添加新术语';

  @override
  String get chineseTerm => '中文术语';

  @override
  String get enterChineseTerm => '请输入中文术语';

  @override
  String get englishTerm => '英文术语';

  @override
  String get enterEnglishTerm => '请输入英文术语';

  @override
  String get category => '类别';

  @override
  String get notes => '笔记';

  @override
  String get add => '添加';

  @override
  String get update => '更新';

  @override
  String get deleteTerm => '删除术语';

  @override
  String get confirmDelete => '您确定要删除此术语吗？';

  @override
  String get delete => '删除';

  @override
  String get importSuccess => '项目导入成功';

  @override
  String error(String error) {
    return '错误: $error';
  }

  @override
  String errorWithMessage(String message) {
    return '错误：$message';
  }

  @override
  String get importResult => '导入结果';

  @override
  String get ok => '确定';

  @override
  String get exportTerms => '导出术语';

  @override
  String get exportSuccess => '项目导出成功';

  @override
  String get reports => '报告';

  @override
  String get exportReport => '导出报告';

  @override
  String get pleaseUploadDocument => '请上传文档';

  @override
  String get summary => '摘要';

  @override
  String get totalLines => '总行数';

  @override
  String get correctedLines => '已更正行数';

  @override
  String get totalCorrections => '总更正数';

  @override
  String get appliedCorrections => '已应用更正';

  @override
  String get consistencyScore => '一致性评分';

  @override
  String get excellentConsistency => '优秀的一致性';

  @override
  String get goodConsistency => '良好的一致性';

  @override
  String get mediumConsistency => '中等一致性';

  @override
  String get lowConsistency => '低一致性';

  @override
  String get veryLowConsistency => '非常低的一致性';

  @override
  String get mostFrequentlyMistranslatedTerms => '最常被错误翻译的术语';

  @override
  String get noMistranslatedTermsFound => '未找到错误翻译的术语';

  @override
  String timesOccurred(int count) {
    return '$count 次';
  }

  @override
  String get correctionDetails => '更正详情';

  @override
  String totalCorrections2(int count) {
    return '总计: $count 项更正';
  }

  @override
  String get noCorrectionSuggestions => '暂无更正建议';

  @override
  String line(int number) {
    return '行: $number';
  }

  @override
  String get saveReport => '保存报告';

  @override
  String get consistencyReportFileName => '术语一致性报告.html';

  @override
  String get reportSavedSuccessfully => '报告已成功保存';

  @override
  String get importProjectTooltip => '导入项目';

  @override
  String get noProjectsMessage => '您尚未创建任何项目';

  @override
  String totalProjects(int count) {
    return '共 $count 个项目';
  }

  @override
  String get descriptionOptional => '描述（可选）';

  @override
  String get descriptionHint => '例如：5季武侠系列字幕术语的标准化';

  @override
  String get projectNameHint => '例如：武侠系列术语翻译';

  @override
  String get projectDeleted => '项目已删除';

  @override
  String get exportProjectDialogTitle => '导出项目';

  @override
  String projectDetails(int docCount, String updateDate) {
    return '文档：$docCount | 最后更新：$updateDate';
  }

  @override
  String get exportAction => '导出';

  @override
  String get deleteAction => '删除';

  @override
  String get documentProcessing => '文档处理';

  @override
  String get documentProcessingTitle => '文档处理';

  @override
  String get horizontalPanelTooltip => '水平面板视图';

  @override
  String get verticalPanelTooltip => '垂直面板视图';

  @override
  String get changeViewTooltip => '更改视图';

  @override
  String get openDocumentTooltip => '打开文档';

  @override
  String get saveDocumentTooltip => '保存文档';

  @override
  String get resetPanelSizeTooltip => '重置面板大小';

  @override
  String correctionsCount(int count) {
    return '校正 ($count)';
  }

  @override
  String get applyAllCorrections => '应用所有';

  @override
  String get applyCorrections => '应用';

  @override
  String get clearCorrections => '清除';

  @override
  String get total => '总计';

  @override
  String get applied => '已应用';

  @override
  String get pending => '待处理';

  @override
  String get noCorrectionsYet => '暂无校正建议';

  @override
  String get clickButtonForCorrections => '点击右下角按钮查看校正建议';

  @override
  String get filterByLine => '按行筛选：';

  @override
  String get allLines => '所有行';

  @override
  String lineNumber(Object number) {
    return '行 $number';
  }

  @override
  String get applyCorrection => '应用校正';

  @override
  String get currentLineText => '当前行文本：';

  @override
  String get enterCorrectedText => '在此输入校正文本';

  @override
  String correctionForLine(int number) {
    return '行 $number 的校正';
  }

  @override
  String get termDatabaseReference => '术语数据库参考：';

  @override
  String get termSearchedInDatabase => '在数据库中搜索的术语： ';

  @override
  String get suggestedTerm => '建议术语： ';

  @override
  String get dataDiscrepancyWarning => '警告：您可以进行自己的校正。';

  @override
  String get saveChanges => '保存更改';

  @override
  String get selectChineseSourceDocument => '选择中文源文档';

  @override
  String get selectEnglishTranslationDocument => '选择英文翻译文档';

  @override
  String get selectFolderToSave => '选择保存文件夹';

  @override
  String get documentSavedSuccessfully => '文档保存成功';

  @override
  String get emptyTermDatabase => '术语数据库为空。请先添加术语。';

  @override
  String get processingDocument => '正在处理文档';

  @override
  String get noCorrectionsFound => '未找到校正建议。所有术语使用正确或没有匹配的术语。';

  @override
  String correctionsFound(int count) {
    return '找到 $count 个校正建议。';
  }

  @override
  String errorProcessingDocument(String error) {
    return '处理文档时出错：$error';
  }

  @override
  String get correctionTextEmpty => '校正文本不能为空！';

  @override
  String get correctionAppliedSuccessfully => '校正应用成功';

  @override
  String errorApplyingCorrection(String error) {
    return '应用校正时出错：$error';
  }

  @override
  String get noCorrectionsToApply => '没有可应用的校正';

  @override
  String get allCorrectionsApplied => '所有校正已应用';

  @override
  String get projectTerms => '项目术语';

  @override
  String get newTerm => '新术语';

  @override
  String get noTermsInProject => '此项目中还没有术语';

  @override
  String get addTerm => '添加术语';

  @override
  String get optionalNotes => '备注（可选）';

  @override
  String get termsRequired => '中文和英文术语是必填的';

  @override
  String get termAdded => '术语已添加';

  @override
  String get termUpdated => '术语已更新';

  @override
  String get deleteTermConfirmation => '您确定要删除此术语吗？';

  @override
  String get termDeleted => '术语已删除';

  @override
  String get addDocument => '添加文档';

  @override
  String get addFromFolder => '从文件夹添加';

  @override
  String get projectNotFound => '找不到项目';

  @override
  String get noDocumentsInProject => '此项目中还没有文档';

  @override
  String get lastUpdate => '最后更新';

  @override
  String get addDocumentsForReports => '请先添加文档才能生成报告';

  @override
  String get documentAddedSuccessfully => '文档添加成功';

  @override
  String get selectSubtitleFolder => '选择包含字幕文件的文件夹';

  @override
  String filesAdded(int count) {
    return '已添加$count对文件';
  }

  @override
  String errorsOccurred(int count) {
    return '发生了$count个错误';
  }

  @override
  String get noMatchingSubtitlePairs => '找不到匹配的字幕对';

  @override
  String get deleteDocumentConfirmation => '您确定要从项目中删除此文档吗？';

  @override
  String get documentDeleted => '文档已删除';

  @override
  String get deleteDocument => '删除文档';

  @override
  String documentLineInfo(int lineCount, String correctionInfo) {
    return '行数: $lineCount | $correctionInfo';
  }

  @override
  String documentCorrectionInfo(int count) {
    return '$count 行有校正';
  }

  @override
  String documentDateInfo(String importDate, String processedInfo) {
    return '添加时间: $importDate $processedInfo';
  }

  @override
  String documentLastProcessedInfo(String date) {
    return '| 最后处理: $date';
  }

  @override
  String get consistencyReportTitle => '术语一致性报告';

  @override
  String get document => '文档';

  @override
  String get creationDate => '创建日期';

  @override
  String get totalLinesReport => '总行数';

  @override
  String get correctedLinesReport => '已更正行数';

  @override
  String get totalCorrectionsReport => '总更正数';

  @override
  String get appliedCorrectionsReport => '已应用更正数';

  @override
  String get termLabel => '术语';

  @override
  String get frequencyLabel => '频率';

  @override
  String get statusLabel => '状态';

  @override
  String get pendingStatus => '待处理';

  @override
  String get incorrectEnglishTerm => '错误英文术语';

  @override
  String get correctEnglishTerm => '正确英文术语';

  @override
  String get lineNumber1 => '行号';

  @override
  String get includingDuplicates => '包括重复项';

  @override
  String get uniqueCorrections => '唯一校正';

  @override
  String get lineNotFound => '未找到行';

  @override
  String get processingLine => '正在处理行';

  @override
  String get termMatchesFound => '找到术语匹配';

  @override
  String get warning => '警告';

  @override
  String get mismatchedLineNumbers => '行号不匹配';

  @override
  String get correcting => '正在修正';

  @override
  String get correction => '校正';

  @override
  String get shouldBe => '应该是';

  @override
  String get incorrectTermNotFound => '未找到不正确的术语';

  @override
  String get inLine => '在行';

  @override
  String get correctionsApplied => '应用了校正';

  @override
  String get correct => '正确';

  @override
  String get subscriptionTitle => '我的订阅';

  @override
  String subtitleUploadsRemaining(int remaining, int max) {
    return '剩余上传次数: $remaining / $max';
  }

  @override
  String get subtitleUploadRights => '字幕上传权限';

  @override
  String get noUploadsRemaining => '您没有剩余的字幕上传次数。请续订您的订阅以上传更多字幕。';

  @override
  String get packages => '套餐';

  @override
  String get basicPackage => '基础套餐';

  @override
  String get premiumPackage => '高级套餐';

  @override
  String get proPackage => '专业套餐';

  @override
  String subtitleUploads(int count) {
    return '$count次字幕上传权限';
  }

  @override
  String get purchase => '购买';

  @override
  String get recommended => '推荐';

  @override
  String get paymentSuccessful => '支付成功';

  @override
  String purchasedUploads(int count) {
    return '您已购买$count次字幕上传权限。';
  }

  @override
  String get documentFilesNotFound => '找不到文档文件';
}
