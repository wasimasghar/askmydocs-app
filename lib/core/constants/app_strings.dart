/// All user-facing text in one place (easy to localize later).
abstract final class AppStrings {
  static const String appName = 'AskMyDocs';
  static const String appTagline = 'Chat with your PDFs';

  // Navigation.
  static const String navChat = 'Chat';
  static const String navSettings = 'Settings';

  // Dashboard.
  static const String newChat = 'New chat';
  static const String emptyTitle = 'Ask anything about your docs';
  /// Generic starters that make sense for any kind of PDF.
  static const List<String> suggestedQuestions = [
    'Summarize this document in a few lines',
    'What are the main topics covered?',
    'What are the key takeaways?',
  ];
  static const String emptyMessage =
      'Upload PDFs in Settings, then ask questions in plain language. '
      'Every answer links back to the exact page it came from.';
  static const String inputHint = 'Ask a question about your documents…';
  static const String inputDisclaimer =
      'Answers are generated from your PDFs. Check the sources.';
  static const String send = 'Send';
  static const String sources = 'Sources';
  static const String viewSource = 'View source text';
  static const String excerpt = 'Excerpt';
  static const String sourceFooter = 'Retrieved from your indexed documents';
  static const String close = 'Close';
  static const String assistantTyping = 'Assistant is typing';
  static String page(int page) => 'Page $page';

  // Settings.
  static const String settingsTitle = 'Settings';
  static const String sectionServer = 'Server';
  static const String sectionUpload = 'Add documents';
  static const String sectionDocuments = 'Uploaded documents';
  static const String serverStatusTitle = 'Server status';
  static const String online = 'Online';
  static const String offline = 'Offline';
  static String chunksIndexed(int count) => '$count chunks indexed';
  static const String uploadTitle = 'Drop in a new PDF';
  static const String uploadMessage =
      'It will be split into chunks and indexed for search.';
  static const String uploadButton = 'Upload PDF';
  static const String uploadHint = 'PDF only · up to 10 MB';
  static const String uploadLimitReached = 'Delete a PDF to upload a new one';
  static const String uploadInProgress =
      'Uploading and indexing... this can take a minute';
  static String pdfCounter(int count, int max) => '$count / $max PDFs';
  static const String fileTooLarge = 'PDF must be under 10 MB.';
  static const String noDocumentsTitle = 'No PDFs yet';
  static const String noDocumentsMessage =
      'Upload one to start asking questions.';
  static String documentMeta(int pages, int chunks) =>
      '$pages ${pages == 1 ? 'page' : 'pages'} · $chunks chunks';
  static const String statusIndexed = 'Indexed';
  static const String statusProcessing = 'Processing';
  static const String statusFailed = 'Failed';
  static const String checkingServer = 'Checking…';
  static const String loadingDocuments = 'Loading documents…';
  static const String loadDocumentsError = "Couldn't load your documents";
  static String uploaded(String fileName) => '$fileName uploaded and indexed';
  static String deleted(String fileName) => '$fileName deleted';
  static const String deleteTooltip = 'Delete PDF';
  static const String deleteDialogTitle = 'Delete PDF?';
  static String deleteDialogMessage(String fileName) =>
      'Delete $fileName? Its chunks will be removed from search.';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String filePickerError = "Couldn't read the selected file.";

  // Shared.
  static const String loading = 'Loading…';
  static const String errorTitle = 'Something went wrong';
  static const String retry = 'Try again';
  static const String genericError = 'Something went wrong. Please try again.';
}
