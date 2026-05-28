import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/formatters/money_formatter.dart';

class OcrReceiptResult {
  const OcrReceiptResult({
    required this.rawText,
    required this.amountMinor,
  });

  final String rawText;
  final int? amountMinor;
}

class OcrService {
  OcrService({ImagePicker? imagePicker}) : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<OcrReceiptResult?> scanReceipt({required ImageSource source}) async {
    final file = await _imagePicker.pickImage(source: source, imageQuality: 90);
    if (file == null) {
      return null;
    }

    final inputImage = InputImage.fromFile(File(file.path));
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(inputImage);
      final text = result.text.trim();
      if (text.isEmpty) {
        return const OcrReceiptResult(rawText: '', amountMinor: null);
      }
      return OcrReceiptResult(rawText: text, amountMinor: _extractAmountMinor(text));
    } finally {
      await recognizer.close();
    }
  }

  int? _extractAmountMinor(String text) {
    final matches = RegExp(r'\d{1,3}(?:[.\s]\d{3})*(?:,\d{2})|\d+(?:,\d{2})?').allMatches(text);
    var best = 0;
    for (final match in matches) {
      final value = MoneyFormatter.parseTryToMinor(match.group(0) ?? '');
      if (value != null && value > best) {
        best = value;
      }
    }
    if (best <= 0) {
      return null;
    }
    return best;
  }
}
