import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionText extends StatelessWidget {
  const AppVersionText({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _futureGetPubspec(),
      builder: (context, AsyncSnapshot<PackageInfo> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Text('Loading....');
          default:
            if (snapshot.hasError) {
              return _versionText("vX.X - Error");
            } else {
              return _versionText(
                  'v${snapshot.data!.version.split('+').first}');
            }
        }
      },
    );
  }

  Future<PackageInfo> _futureGetPubspec() async {
    return await PackageInfo.fromPlatform();
  }

  Widget _versionText(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Text(
        text,
        style: const TextStyle(
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}