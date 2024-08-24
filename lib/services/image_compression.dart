import 'dart:io';
import 'package:image/image.dart' as imglib;
import 'package:path_provider/path_provider.dart';

// COMPRESS FILE
Future<File> compressImage(File imageFile) async {
  final tempDir = await getTemporaryDirectory();
  final path = tempDir.path;

  imglib.Image? image = imglib.decodeImage(imageFile.readAsBytesSync());

  if (image == null) {
    throw Exception('Unable to decode image');
  }

  // Reduce the image quality to 80%
  var img = imglib.copyResize(image, width: (image.width * 0.8).round(), height: (image.height * 0.8).round());

  File compressedImageFile = File('$path/compressed_image.jpg')..writeAsBytesSync(imglib.encodeJpg(img, quality: 80));

  return compressedImageFile;
}