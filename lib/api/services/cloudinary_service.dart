// ignore_for_file: unnecessary_type_check, prefer_typing_uninitialized_variables

import 'package:cloudinary/cloudinary.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryServices {
  late final env;

  parseStringToMap({String assetsFileName = '.env'}) async {
    final lines = await rootBundle.loadString(assetsFileName);
    Map<String, String> environment = {};
    for (String line in lines.split('\n')) {
      line = line.trim();
      if (line.contains('=') //Set Key Value Pairs on lines separated by =
          &&
          !line.startsWith(RegExp(r'=|#'))) {
        List<String> contents = line.split('=');
        environment[contents[0]] = contents.sublist(1).join('=');
      }
    }
    env = environment;
  }

  Future<String?> uploadImage(
    XFile file,
  ) async {
    try {
      final cloudinary = Cloudinary.signedConfig(
        apiKey: '992747211431623',
        apiSecret: 'UYEH8bjX2XAbyHzmH8R_mqmCLuo',
        cloudName: 'dfwsx27vx',
      );
      var filebytes = await file.readAsBytes();
      print(file.path);
      final response = await cloudinary.upload(
        file: file.path,
        fileBytes: filebytes,
        resourceType: CloudinaryResourceType.image,
        folder: 'km0',
        progressCallback: (count, total) {
          print('Uploading image from file with progress: $count/$total');
        },
      );

      if (response.isSuccessful) {
        final secureUrl = response.secureUrl;
        if (secureUrl != null && secureUrl is String) {
          print('Get your image from with $secureUrl');
          return secureUrl;
        } else {
          print('Error uploading image: secureUrl is not a valid String');
          return null;
        }
      } else {
        print('Error uploading image: ${response.error}');
        return null;
      }
    } catch (error) {
      print('catch/Error uploading image: $error');
      return null;
    }
  }
}
