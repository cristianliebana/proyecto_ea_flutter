import 'package:get/get.dart';

class UserController extends GetxController {
  RxString userId = ''.obs;

  void setUserId(String id) {
    userId.value = id;
  }
}

final UserController userController = UserController();
