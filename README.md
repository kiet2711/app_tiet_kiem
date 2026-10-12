# Sổ Tiết Kiệm (Saving Tracker) - Flutter App

Ứng dụng ghi chú và tính toán tiền tiết kiệm đa nền tảng (**Android** & **iOS**), được xây dựng bằng **Flutter**.

---

## 🌟 Tính Năng Nổi Bật

1. **Đặt Mục Tiêu Tiết Kiệm (Saving Goal)**:
   - Cho phép người dùng đặt mục tiêu ban đầu (ví dụ: `1.000.000 ₫`, `2.000.000 ₫`, `10.000.000 ₫` hoặc số tiền tùy ý).
   - Có sẵn các chip gợi ý nhanh (500k, 1tr, 2tr, 5tr, 10tr...).
   - Đổi tên và số tiền mục tiêu linh hoạt bất cứ lúc nào.

2. **Bảng Tính Theo Ngày (Daily Saving Table)**:
   - Mỗi ngày ghi chép gồm **2 ô nhập liệu chính**:
     - **Ô 1: Đã tiết kiệm được** (Số tiền thực tế đã cất giữ trong ngày).
     - **Ô 2: Có thể sẽ tiết kiệm được** (Số tiền dự kiến có khả năng tiết kiệm thêm).
   - Đi kèm ô ghi chú lý do / nguồn tiền (ví dụ: nhịn trà sữa, làm thêm...).
   - Hỗ trợ chọn ngày qua lịch (DatePicker).
   - Có sẵn các nút cộng tiền nhanh (`+10k`, `+20k`, `+50k`, `+100k`, `+200k`, `+500k`) giúp nhập liệu chỉ bằng 1 chạm.

3. **Tính Toán Tổng Tiền Thời Gian Thực (Real-Time Calculations)**:
   - **Tổng Hiện Tại (Thực Tế)** = Tổng tất cả các ô *Đã tiết kiệm được* ($\sum \text{Đã có}$).
   - **Tổng Dự Kiến (Tiềm Năng)** = $\sum \text{Đã có} + \sum \text{Có thể tiết kiệm thêm}$.
   - Thanh tiến trình trực quan 2 lớp (Layered Progress Bar) hiển thị đồng thời % Đã đạt thực tế và % Dự kiến đạt được so với mục tiêu.
   - Hiển thị chính xác số tiền còn thiếu để về đích.

4. **Giao Diện Linh Hoạt**:
   - **Chế độ Bảng (Table View)**: Dạng bảng tính trực quan như Excel/Google Sheets.
   - **Chế độ Thẻ (Card View)**: Dạng danh sách thẻ tối ưu trải nghiệm chạm trên điện thoại.
   - Nút chuyển đổi giao diện nhanh trên thanh công cụ.

5. **Lưu Trữ Dữ Liệu Tự Động (Offline Persistence)**:
   - Tự động lưu mục tiêu và lịch sử ngày vào bộ nhớ máy (`SharedPreferences`). Dữ liệu không bị mất khi thoát ứng dụng.
   - Tính năng **Tạo dữ liệu mẫu (Demo)** để trải nghiệm thử ngay lập tức.
   - Tính năng **Xóa toàn bộ** để đặt lại khi cần.

---

## 📱 Hướng Dẫn Chạy & Build Cho Android và iOS

### Yêu Cầu Môi Trường
- Flutter SDK (>= 3.13.0)
- Android Studio / Android SDK (để build Android)
- macOS và Xcode (để build iOS do yêu cầu của Apple)

### 1. Chạy Thử Nghiệm Trực Tiếp
```bash
# Di chuyển vào thư mục dự án
cd saving_tracker

# Lấy các thư viện cần thiết
flutter pub get

# Kiểm tra danh sách thiết bị đang kết nối (máy thật hoặc máy ảo)
flutter devices

# Chạy ứng dụng
flutter run
```

### 2. Build Ứng Dụng Cho Android (APK / App Bundle)
```bash
# Build file APK cài đặt trực tiếp
flutter build apk --release

# File APK xuất ra tại:
# build/app/outputs/flutter-apk/app-release.apk

# Hoặc build Android App Bundle (AAB) để tải lên Google Play Console:
flutter build appbundle --release
```

### 3. Build Ứng Dụng Cho iOS (iPhone / iPad)
> *Lưu ý: Để build iOS cần thực hiện trên máy Mac có cài đặt Xcode hoặc thông qua dịch vụ CI/CD đám mây (như Codemagic, GitHub Actions).*

```bash
# Cài đặt CocoaPods (nếu có trên Mac)
cd ios && pod install && cd ..

# Build ứng dụng cho iOS
flutter build ios --release

# Hoặc tạo file IPA để đưa lên App Store / TestFlight:
flutter build ipa --release
```

---

## 📂 Cấu Trúc Dự Án (Project Structure)

```
saving_tracker/
├── lib/
│   ├── main.dart                      # Điểm khởi chạy ứng dụng & State tổng
│   ├── models/
│   │   ├── saving_day.dart            # Model dữ liệu từng ngày (đã có & dự kiến)
│   │   └── saving_goal.dart           # Model mục tiêu tiết kiệm
│   ├── services/
│   │   └── storage_service.dart       # Quản lý lưu trữ SharedPreferences
│   ├── utils/
│   │   └── formatters.dart            # Định dạng tiền tệ VNĐ & ngày tháng
│   └── widgets/
│       ├── goal_summary_card.dart     # Thẻ hiển thị mục tiêu & 2 tổng tiến trình
│       ├── daily_table_view.dart      # Bảng tính hiển thị các ngày
│       ├── daily_card_list_view.dart  # Giao diện dạng danh sách thẻ
│       ├── day_entry_dialog.dart      # Hộp thoại nhập tiền theo ngày (+10k, +50k...)
│       └── edit_goal_dialog.dart      # Hộp thoại đổi mục tiêu tiết kiệm
├── android/                           # Cấu hình & mã nguồn Android
├── ios/                               # Cấu hình & mã nguồn iOS
└── pubspec.yaml                       # Khai báo dependencies
```
