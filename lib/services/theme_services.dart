import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
class ThemeServices {

  final GetStorage _box = GetStorage();
  final key = "isDarkMode";

   _saveTheme(bool isDarkMode) {
     _box.write(key, isDarkMode) ;
  }

  bool _loadTheme()
  {
    return _box.read<bool>(key) ?? false;
  }

  ThemeMode get theme => _loadTheme() ? ThemeMode.dark : ThemeMode.light ;
  void switchTheme()
  {
    Get.changeThemeMode(_loadTheme() ? ThemeMode.dark : ThemeMode.light);
    _saveTheme(!_loadTheme());
  }
}
