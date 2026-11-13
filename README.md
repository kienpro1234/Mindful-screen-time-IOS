# Mindful Screen Time & Habit Optimizer (iOS)

Ứng dụng quản lý thời gian sử dụng điện thoại thông minh dành cho iPhone, tập trung vào **sự tỉnh thức (mindful awareness)** thay vì chặn cứng ép buộc. Giúp bạn nhận diện và phá vỡ phản xạ lướt vô thức (doomscrolling), đồng thời thống kê thói quen để làm chủ thời gian.

---

## 🌟 Điểm nổi bật & Tính năng thông minh

1. **Hệ thống bảo vệ 2 lớp (Two-Layer Intervention):**
   - **Lớp 1 (Khoảng lặng tỉnh thức khi vừa mở app):** Chặn đứng phản xạ mở app trong vô thức bằng màn hình nhắc nhở: *"Bạn có chắc sẽ dùng ứng dụng này, nó có thể lấy đi sự tập trung và lãng phí thời gian"*.
   - **Lớp 2 (Tạm dừng giữa chừng sau 15 phút):** Sau 15 phút sử dụng liên tục, hệ thống gửi thông báo nhắc nhở tạm dừng hít thở 5 giây kèm lựa chọn rời app hoặc gia hạn.
2. **Cơ chế Tăng dần độ khó (Escalating Friction):**
   - Lần gia hạn 1: Chạm nhanh mở thêm 5 phút.
   - Lần gia hạn 2: Bắt buộc dừng lại thực hiện bài tập hít thở 10 giây (với vòng tròn co giãn và rung haptic êm ái).
   - Lần gia hạn 3 trở đi: Yêu cầu gõ lại chính xác câu cam kết ý thức: *"Tôi chấp nhận trì hoãn công việc để tiếp tục lướt"* để bạn kịp nhận ra sự đánh đổi và tự dừng lại.
3. **Thống kê thói quen thông minh (Habit Analytics with Swift Charts):**
   - **Chỉ số Chiến thắng (Mindful Win Rate):** Đo lường tỷ lệ bạn đã tự giác chọn "Quay lại làm việc" thay vì sa đà.
   - **Biểu đồ Giờ vàng xao nhãng (Peak Distraction Hours):** Đồ thị 24 giờ trực quan chỉ ra khung giờ bạn hay bị xao nhãng nhất trong ngày.
4. **Tương thích 100% với Apple ID cá nhân miễn phí:**
   - Đóng gói trong 1 Bundle ID duy nhất (`com.mindful.screentime`).
   - Cài đặt dễ dàng qua AltStore hoặc Sideloadly mà không cần mua tài khoản Apple Developer $99/năm.

---

## 📁 Cấu trúc thư mục

```text
├── .github/workflows/
│   └── build-ios.yml                   # Kịch bản tự động build file .ipa trên macOS cloud
├── MindfulScreenTime/
│   ├── Info.plist                      # Cấu hình Scheme mindful:// và quyền thông báo
│   ├── App/
│   │   ├── MindfulScreenTimeApp.swift  # Lifecycle ứng dụng và bắt sự kiện Deep Link
│   │   └── ContentView.swift          # Giao diện chính và điều phối toàn màn hình
│   ├── Core/
│   │   ├── Storage/
│   │   │   ├── MindfulModels.swift    # Định nghĩa SessionRecord, SessionOutcome
│   │   │   └── StorageService.swift   # Lưu trữ lịch sử, tính Win Rate, thống kê theo giờ
│   │   └── Engine/
│   │       ├── DeepLinkHandler.swift  # Phân tích cú pháp mindful://intercept?app=...
│   │       ├── FrictionManager.swift  # Động cơ quản lý 3 cấp độ tăng dần độ khó
│   │       └── TimerManager.swift     # Đếm giờ và lên lịch thông báo Lớp 2
│   └── UI/
│       ├── Interventions/
│       │   ├── PreOpenFrictionView.swift   # Màn hình Khoảng lặng tỉnh thức
│       │   ├── BreathingExerciseView.swift # Vòng tròn hít thở 5-10s & rung haptic
│       │   └── TypedPledgeView.swift       # Màn hình gõ câu cam kết ý thức
│       ├── Dashboard/
│       │   ├── DashboardView.swift         # Bảng điều khiển tổng quan
│       │   ├── MindfulWinRateCard.swift    # Thẻ tỷ lệ tự chủ và huy hiệu
│       │   └── PeakDistractionChartView.swift # Biểu đồ giờ xao nhãng (Swift Charts)
│       └── Settings/
│           └── ShortcutGuideView.swift     # Hướng dẫn cài đặt tự động hóa iOS
├── MindfulScreenTimeTests/             # Bộ kiểm thử đơn vị tự động (XCTest)
├── project.yml                         # Cấu hình sinh dự án XcodeGen
└── README.md
```

---

## 🚀 Hướng dẫn Build & Cài đặt lên iPhone từ Windows

Vì bạn sử dụng Windows, dự án đã được tích hợp sẵn luồng **GitHub Actions CI/CD** (chạy máy ảo macOS miễn phí của GitHub):

### Bước 1: Đẩy mã nguồn lên GitHub của bạn
1. Tạo một repository mới trên GitHub (ví dụ: `mindful-ios`).
2. Tải toàn bộ thư mục code này lên repository đó.

### Bước 2: Tải file cài đặt `.ipa` được build tự động
1. Sau khi đẩy code lên, vào tab **Actions** trên GitHub repository của bạn.
2. Bạn sẽ thấy quy trình **Build iOS IPA** đang chạy (mất khoảng 3-5 phút trên máy ảo macOS của GitHub).
3. Khi hoàn tất, bấm vào lần chạy đó và cuộn xuống mục **Artifacts** để tải file `MindfulScreenTime-Unsigned-IPA.zip`.
4. Giải nén file zip để lấy file `MindfulScreenTime.ipa`.

### Bước 3: Cài đặt vào iPhone bằng Apple ID miễn phí
Bạn có thể dùng **Sideloadly** hoặc **AltStore** (cả hai đều chạy mượt mà trên Windows):
1. Tải và cài đặt [Sideloadly trên Windows](https://sideloadly.io/).
2. Kết nối iPhone với máy tính qua cáp USB.
3. Kéo thả file `MindfulScreenTime.ipa` vào Sideloadly.
4. Nhập Apple ID cá nhân miễn phí của bạn và bấm **Start**.
5. Sau khi nạp xong, trên iPhone vào: **Cài đặt -> Cài đặt chung -> Quản lý VPN & Thiết bị -> Tin cậy chứng chỉ của Apple ID của bạn**.

---

## ⚡ Cài đặt Tự động hóa (Shortcuts Automation) trên iPhone

Chỉ cần làm trong 60 giây — **không mở qua Safari, tự động quay lại ứng dụng khi bạn chọn dùng tiếp**:

1. Mở app **Phím tắt (Shortcuts)** trên iPhone -> Chọn tab **Tự động hóa (Automation)** ở dưới cùng.
2. Bấm dấu **(+)** ở góc trên -> Chọn **Ứng dụng (App)**.
3. Cấu hình (nên tạo riêng từng Tự động hóa cho mỗi app, vd: 1 cho Facebook, 1 cho TikTok):
   - Ứng dụng: Chọn **1 app** bạn muốn quản lý (vd: Facebook).
   - Đánh dấu chọn: **Được mở (Is Opened)**.
   - Chọn: **Chạy ngay lập tức (Run Immediately)** và tắt mục *Thông báo khi chạy*.
4. Bấm **Tiếp**, chọn **Tự động hóa trống mới**, thêm 2 tác vụ theo thứ tự:
   - Tìm **Mindful** -> Chọn **Kiểm tra tỉnh thức** -> Chọn đúng tên app (vd: **Facebook**).
   - Tìm **Nếu (If)** -> Giữ nguyên điều kiện *Nếu Kiểm tra tỉnh thức là Có*.
   - Tìm **Mở ứng dụng (Open App)** -> Chọn **Mindful** và đặt khối này vào bên trong nhánh **Nếu**.
5. Bấm mũi tên **(<)** / **Xong** để lưu lại.

Bây giờ, mỗi khi bạn chạm mở Facebook, màn hình **Khoảng lặng tỉnh thức** sẽ mở thẳng trực tiếp (không qua Safari). Nếu bạn chọn *"Tôi vẫn cần mở"*, ứng dụng sẽ tự mở lại Facebook cho bạn dùng trong 15 phút mà không bị lặp!
