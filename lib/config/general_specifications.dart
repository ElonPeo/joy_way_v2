import 'package:flutter/material.dart';

class GeneralSpecifications {
  final double screenHeight;
  final double screenWidth;
  final Color baseColor1;

  final Color pantoneColor;
  final Color pantoneColor2;
  final Color pantoneColor3;
  final Color pantoneColor4;
  final Color pantoneShadow;
  final Color pantoneShadow2;
  final Color startLocation;
  final Color endLocation;

  final Color backgroundColor;

  final Color black80;
  final Color black100;
  final Color black250;
  final Color black240;
  final Color black245;
  final Color black150;
  final Color black200;

  final Color turquoise1;
  final Color turquoise2;
  final Color turquoise3;
  final Color turquoise4;
  final Color turquoise5;

  final Color rBlushPink;
  final Color rSlight;
  final Color rDark;

  final Color yLight;




  GeneralSpecifications(BuildContext context)
      : screenHeight = MediaQuery.of(context).size.height,
        screenWidth = MediaQuery.of(context).size.width,
        baseColor1 = const Color.fromRGBO(240, 248, 255, 1),

        pantoneColor = const Color.fromRGBO(62, 157, 110, 1),
        // #3E9D6E
        pantoneColor2 = const Color.fromRGBO(44, 122, 84, 1),
        // #6E947C
        pantoneColor3 = const Color.fromRGBO(102, 136, 115, 1),

        pantoneColor4 = const Color.fromRGBO(40, 67, 43, 1),
        // #2C98A0
        turquoise1 = const Color.fromRGBO(44, 152, 160, 1),
        // #38B2A3
        turquoise2 = const Color.fromRGBO(56, 178, 163, 1),
        // #4CC8A3
        turquoise3 = const Color.fromRGBO(76, 200, 163, 1),
        // #67D1A5
        turquoise4 = const Color.fromRGBO(103, 209, 165, 1),
        // #88E8AC
        turquoise5 = const Color.fromRGBO(136, 232, 172, 1),




        // F7CAC9
        rBlushPink = const Color.fromRGBO(247, 202, 201, 1),
        // F75270
        rSlight = const Color.fromRGBO(247, 82, 112, 1),
        // DC143C
        rDark = const Color.fromRGBO(220, 20, 60, 1),

        yLight = const Color.fromRGBO(254, 238, 145, 1),


        black80 = const Color.fromRGBO(80, 80, 80, 1),
        black100 = const Color.fromRGBO(100, 100, 100, 1),
        black150 = const Color.fromRGBO(150, 150, 150, 1),
        black200 = const Color.fromRGBO(200, 200, 200, 1),
        black240 = const Color.fromRGBO(240, 240, 240, 1),
        black245 = const Color.fromRGBO(245, 245, 245, 1),
        black250 = const Color.fromRGBO(250, 250, 250, 1),
        pantoneShadow = const Color.fromRGBO(52, 147, 100, 0.15),
        pantoneShadow2 = const Color.fromRGBO(227, 232, 229, 1),
        backgroundColor =const Color.fromRGBO(250, 250, 250, 1),
        startLocation = const Color.fromRGBO(255, 79, 15, 1),
        endLocation = const Color.fromRGBO(3, 166, 161, 1);
}




// Loại phần tử	Bo góc gợi ý (px)	Mô tả / ứng dụng
// Button nhỏ, icon, chip	4–8	Nhẹ, hiện đại, vừa phải
// Input field, card, container	8–12	Mềm mại nhưng vẫn có khối rõ ràng
// Modal, bottom sheet, panel lớn	16–24	Dễ nhìn, thân thiện, tạo cảm giác nổi
// Avatar / hình tròn	9999 (hoặc size / 2)	Để tròn tuyệt đối
// Image tile, preview nhỏ	6–10	Giữ bố cục đẹp khi ghép nhiều ảnh
// Large image / Banner	12–20	Giúp hình mềm mại, tránh góc sắc
// App bar, navigation bar	0 hoặc 12	Tùy phong cách phẳng hoặc bo nhẹ
// Card group / list item tổng hợp	10–16	Bo vừa phải để tách nhóm tự nhiên
// class AppRadius {
//   static const double small = 6;
//   static const double medium = 10;
//   static const double large = 16;
//   static const double extraLarge = 24;
//   static const double circle = 9999;
// }


// | Mức     | Size                        | Dùng cho |
// | ------- | --------------------------- | -------- |
// | `14`    | Tag, chip nhỏ               |          |
// | `20`    | Nút, danh sách, textfield   |          |
// | `24`    | Chuẩn (default Icon)        |          |
// | `28–32` | Nav bar, card lớn           |          |
// | `48+`   | Empty state, màn hình chính |          |
//

// class AppIconSize {
//   static const double tiny = 14;
//   static const double small = 18;
//   static const double medium = 24;
//   static const double large = 32;
//   static const double extraLarge = 48;
// }






// | Mức  | Size                        | Dùng cho |
// | ---- | --------------------------- | -------- |
// | `32` | Tiêu đề lớn, màn hình chính |          |
// | `24` | Tiêu đề trong section, card |          |
// | `18` | Tiêu đề vừa, nút lớn        |          |
// | `16` | Nội dung chính (paragraph)  |          |
// | `14` | Mô tả phụ, label nhỏ        |          |
// | `12` | Ghi chú, thời gian          |          |
// | `11` | Caption nhỏ (hiếm dùng)     |          |


// | Loại text           | Cỡ chữ (px) | Dùng cho                          | Gợi ý weight |
// | ------------------- | ----------- | --------------------------------- | ------------ |
// | **Display Large**   | 57          | Màn hình chính, tiêu đề chào mừng | 400          |
// | **Display Medium**  | 45          | Banner lớn                        | 400          |
// | **Display Small**   | 36          | Header lớn                        | 400          |
// | **Headline Large**  | 32          | Tiêu đề chính trong màn           | 400–500      |
// | **Headline Medium** | 28          | Phần nội dung nổi bật             | 500          |
// | **Headline Small**  | 24          | Tiêu đề nhỏ trong card            | 500          |
// | **Title Large**     | 22          | Thanh AppBar hoặc section title   | 500–600      |
// | **Title Medium**    | 16          | Tiêu đề nút, card, list item      | 500–600      |
// | **Title Small**     | 14          | Tiêu đề phụ, nhãn nhỏ             | 500          |
// | **Body Large**      | 16          | Văn bản chính                     | 400          |
// | **Body Medium**     | 14          | Nội dung phụ, mô tả ngắn          | 400          |
// | **Body Small**      | 12          | Chú thích, timestamp, caption     | 400          |
// | **Label Large**     | 14          | Nút, tag                          | 500–600      |
// | **Label Medium**    | 12          | Text button nhỏ                   | 500          |
// | **Label Small**     | 11          | Ghi chú cực nhỏ                   | 400          |
//


// class AppTextSize {
//   static const double display = 32;
//   static const double headline = 24;
//   static const double title = 18;
//   static const double body = 16;
//   static const double caption = 14;
//   static const double small = 12;
// }




