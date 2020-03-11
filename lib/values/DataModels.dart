import 'package:AnyDrop/values/Values.dart';

abstract class Enum<T> {
  final T value;

  const Enum(this.value);

  T fromValue(T value);
}

enum SnackbarType{
  INFO,ERROR
}
class SystemUpdateResponse{
  PhoneUpdateResponse phoneUpdateResponse;
}

class UpdateResponse{
  bool isUpdateAvailable ,isForceUpdate;
  String currentVersionName,newVersionName;
  int newBuildNumber,currentBuildNumber;
}
class PhoneUpdateResponse extends UpdateResponse{
  PhoneUpdateResponse(){
    super.currentVersionName = ReleaseValues.version;
    super.currentBuildNumber = ReleaseValues.buildNumber;
  }
}