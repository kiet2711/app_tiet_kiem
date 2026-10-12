import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saving_day.dart';
import '../models/saving_goal.dart';

class StorageService {
  static const String _goalKey = 'user_saving_goal';
  static const String _daysKey = 'user_saving_days';

  Future<SavingGoal> loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final goalStr = prefs.getString(_goalKey);
    if (goalStr != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(goalStr);
        return SavingGoal.fromJson(data);
      } catch (_) {}
    }
    // Mặc định mục tiêu là 1.000.000 VNĐ như yêu cầu
    return SavingGoal(
      targetAmount: 1000000,
      title: 'Mục tiêu 1 Triệu',
    );
  }

  Future<void> saveGoal(SavingGoal goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_goalKey, jsonEncode(goal.toJson()));
  }

  Future<List<SavingDay>> loadDays() async {
    final prefs = await SharedPreferences.getInstance();
    final daysStr = prefs.getString(_daysKey);
    if (daysStr != null) {
      try {
        final List<dynamic> list = jsonDecode(daysStr);
        return list
            .map((item) => SavingDay.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    // Trả về danh sách rỗng ban đầu hoặc mẫu
    return [];
  }

  Future<void> saveDays(List<SavingDay> days) async {
    final prefs = await SharedPreferences.getInstance();
    final list = days.map((e) => e.toJson()).toList();
    await prefs.setString(_daysKey, jsonEncode(list));
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_goalKey);
    await prefs.remove(_daysKey);
  }
}
