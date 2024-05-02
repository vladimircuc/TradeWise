import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<File> saveImagePermanently(String imagePath) async {
  final directory = await getApplicationDocumentsDirectory();
  final name = basename(imagePath);
  final image = File('${directory.path}/$name');

  return File(imagePath).copy(image.path);
}
