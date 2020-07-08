class Common {
  factory Common() => _getInstance();

  static Common get instance => _getInstance();
  static Common _instance;

  static Common _getInstance() {
    if (_instance == null) {
      _instance = Common._internal();
    }
    return _instance;
  }

  Common._internal();
  String dirSdCard;

  String getFileSize(int fileSize) {
    String fsize = '';

    if (fileSize < 1024) {
      fsize = '${fileSize.toStringAsFixed(2)} B';
    } else if (1024 <= fileSize && fileSize < 1048576) {
      fsize = '${(fileSize / 1024).toStringAsFixed(2)} KB';
    } else if (1048576 <= fileSize && fileSize < 1073741824) {
      fsize = '${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB';
    }

    return fsize;
  }

  String iconSelection(String ext) {
    String iconImage = 'assets/images/unknown.png';

    switch (ext) {
      case '.ppt':
      case '.pptx':
      case '.PPT':
      case '.PPTX':
        iconImage = 'assets/images/ppt.png';
        break;
      case '.doc':
      case '.docx':
      case '.DOC':
      case '.DOCX':
        iconImage = 'assets/images/word.png';
        break;
      case '.xls':
      case '.xlsx':
      case '.XLS':
      case '.XLSX':
        iconImage = 'assets/images/excel.png';
        break;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.JPG':
      case '.JPEG':
      case '.PNG':
        iconImage = 'assets/images/image.png';
        break;
      case '.txt':
      case '.TXT':
        iconImage = 'assets/images/txt.png';
        break;
      case '.mp3':
      case '.MP3':
        iconImage = 'assets/images/mp3.png';
        break;
      case '.mp4':
      case '.MP4':
        iconImage = 'assets/images/video.png';
        break;
      case '.rar':
      case '.zip':
      case '.RAR':
      case '.ZIP':
        iconImage = 'assets/images/zip.png';
        break;
      case '.psd':
      case '.PSD':
        iconImage = 'assets/images/psd.png';
        break;
      default:
        iconImage = 'assets/images/file.png';
        break;
    }
    return iconImage;
  }
}
