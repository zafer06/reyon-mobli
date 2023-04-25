import 'package:package_info_plus/package_info_plus.dart';

class Helper {
  static String getVersion() {
    String version = "0.0.0";
    PackageInfo.fromPlatform().then((value) => version = value.version);
    return version;
  }
}
