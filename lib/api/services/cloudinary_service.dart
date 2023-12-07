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
        //No need to add emty keys and remove comments
        List<String> contents = line.split('=');
        environment[contents[0]] = contents.sublist(1).join('=');
      }
    }
    env = environment;
  }

  Future<String?> uploadImage(
    XFile file,
    /*String name*/
  ) async {
    try {
      // print('111111111');
      await parseStringToMap(assetsFileName: '.env');
      // print('22222222222222');
      final cloudinary = Cloudinary.signedConfig(
        apiKey: '992747211431623',
        apiSecret: 'UYEH8bjX2XAbyHzmH8R_mqmCLuo',
        cloudName: 'dfwsx27vx',
      );
      // print('3333333');
      var filebytes = await file.readAsBytes();
      print(file.path);
      final response = await cloudinary.upload(
        file: file.path,
        fileBytes: filebytes,
        resourceType: CloudinaryResourceType.image,
        folder: 'km0',
        // fileName: name,
        progressCallback: (count, total) {
          print('Uploading image from file with progress: $count/$total');
        },
      );

      // print("4444444444444");
      if (response.isSuccessful) {
        // print("55555555555");
        final secureUrl = response.secureUrl;
        if (secureUrl != null && secureUrl is String) {
          print('Get your image from with $secureUrl');
          return secureUrl;
        } else {
          // print("6666666666");
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
