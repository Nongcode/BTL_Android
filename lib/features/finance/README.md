# Finance Feature - Giao Diện Quản Lý Tài Chính

## 📁 Cấu Trúc Thư Mục

```
lib/features/finance/
├── data/
│   └── models/
│       └── finance_model.dart          # Model dữ liệu giao dịch
├── logic/                               # Logic xử lý (nếu cần)
└── presentation/
    ├── screens/
    │   └── finance_screen.dart          # Screen chính
    └── widgets/
        ├── finance_stat_card.dart       # Widget thẻ thống kê
        ├── finance_item_card.dart       # Widget mục giao dịch
        ├── finance_summary_card.dart    # Widget tóm tắt
        └── index.dart                   # Export các widgets
```

## 🎨 Các Widget Chính

### 1. **FinanceScreen** (Main Screen)
- Hiển thị thống kê tài chính
- Lọc theo tab: Tất cả / Chi tiêu / Thu nhập
- Hiển thị Quỹ sinh hoạt
- Danh sách chi tiêu tháng
- Danh sách giao dịch chi tiết

### 2. **FinanceStatCard**
- Thẻ hiển thị số liệu thống kê
- Có chế độ selected (viền xanh, shadow)
- Tùy chỉnh màu icon và số lượng

### 3. **FinanceItemCard**
- Hiển thị chi tiết một giao dịch
- Phân biệt chi tiêu (đỏ) và thu nhập (xanh)
- Hiển thị tiêu đề, mô tả, ngày, số tiền

### 4. **FinanceSummaryCard**
- Hiển thị tóm tắt chi tiêu/quỹ
- Có tùy chọn hiển thị arrow
- Màu nền linh hoạt

## 💡 Cách Sử Dụng

### Import trong file chính của app:
```dart
import 'lib/features/finance/presentation/screens/finance_screen.dart';

// Sử dụng trong Navigation
FinanceScreen()
```

### Thêm vào bottom navigation:
```dart
// Trong main app file
bottomNavigationBarItems: [
  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
  BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'Việc nhà'),
  BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Quỹ chung'),  // <-- Finance
  BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
]
```

## 🎯 Tính Năng

- ✅ Hiển thị thống kê số giao dịch
- ✅ Lọc giao dịch theo loại
- ✅ Hiển thị quỹ sinh hoạt và chi tiêu
- ✅ Giao diện responsive và đẹp mắt
- ✅ Dễ mở rộng và tùy chỉnh

## 📝 Dữ Liệu Mock

Hiện tại sử dụng mock data trong `FinanceScreen`. Để kết nối với API thực:

1. Thay thế `allFinanceItems` bằng dữ liệu từ API
2. Sử dụng Provider hoặc BLoC để quản lý state
3. Thêm logic xử lý thêm/sửa/xóa giao dịch

## 🎨 Tùy Chỉnh Màu Sắc

Các màu được hardcode theo thiết kế ảnh:
- **Quỹ sinh hoạt**: Cyan (`Colors.cyan`)
- **Chi tiêu tháng**: Orange (`Colors.orange`)
- **Chi tiêu**: Red (`Colors.red`)
- **Thu nhập**: Green (`Colors.green`)

Để thay đổi, edit trong file screen và widgets tương ứng.

## ✨ Mở Rộng

Có thể dễ dàng thêm:
- Chi tiết giao dịch (swipe, expand)
- Biểu đồ chi tiêu (charts)
- Export báo cáo
- Thêm loại chi tiêu mới
- Thống kê nâng cao
