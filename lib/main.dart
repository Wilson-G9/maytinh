import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF171717),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = "0";
  bool _isEquationFinished = false;

  void _onPressed(String text) {
    setState(() {
      if (text == "C") {
        // Xóa toàn bộ, reset về 0
        _display = "0";
        _isEquationFinished = false;
      } else if (text == "⌫") {
        // Xóa ký tự cuối
        if (_display.length > 1) {
          _display = _display.substring(0, _display.length - 1);
        } else {
          _display = "0";
        }
        _isEquationFinished = false;
      } else if (text == "=") {
        // Tính kết quả
        _calculate();
      } else if (["+", "-", "×", "÷"].contains(text)) {
        // Nếu vừa bấm =, tiếp tục tính từ kết quả
        _isEquationFinished = false;
        // Thay ký hiệu hiển thị thành ký hiệu toán học
        if (_display == "0") return;
        // Tránh thêm 2 toán tử liên tiếp
        String last = _display[_display.length - 1];
        if (["+", "-", "×", "÷"].contains(last)) {
          _display = _display.substring(0, _display.length - 1) + text;
        } else {
          _display += text;
        }
      } else if (text == ",") {
        // Dấu thập phân
        if (_isEquationFinished) {
          _display = "0,";
          _isEquationFinished = false;
          return;
        }
        // Chỉ thêm dấu phẩy nếu số hiện tại chưa có
        // Tách phần số cuối cùng
        String expr = _display;
        int lastOpIndex = -1;
        for (int i = expr.length - 1; i >= 0; i--) {
          if (["+", "-", "×", "÷"].contains(expr[i])) {
            lastOpIndex = i;
            break;
          }
        }
        String lastNum = expr.substring(lastOpIndex + 1);
        if (!lastNum.contains(",")) {
          if (lastNum.isEmpty) {
            _display += "0,";
          } else {
            _display += ",";
          }
        }
      } else {
        // Số 0-9
        if (_isEquationFinished) {
          _display = text;
          _isEquationFinished = false;
        } else if (_display == "0") {
          _display = text;
        } else {
          _display += text;
        }
      }
    });
  }

  void _calculate() {
    try {
      // Chuyển đổi ký hiệu hiển thị sang ký hiệu toán học
      String expression = _display
          .replaceAll("×", "*")
          .replaceAll("÷", "/")
          .replaceAll(",", ".");

      ShuntingYardParser p = ShuntingYardParser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);

      // Hiển thị kết quả: nếu là số nguyên thì bỏ .0
      if (result == result.truncateToDouble()) {
        _display = result.toInt().toString();
      } else {
        // Giới hạn số chữ số thập phân, thay . bằng ,
        _display = result.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '');
        if (_display.endsWith('.')) {
          _display = _display.substring(0, _display.length - 1);
        }
        _display = _display.replaceAll(".", ",");
      }

      _isEquationFinished = true;
    } catch (e) {
      _display = "Lỗi";
      _isEquationFinished = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "2224802010868 - Đoàn Thanh Phúc",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      ),
      body: Column(
        children: [
          // Khu vực hiển thị kết quả
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Text(
                _display,
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w300,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Bàn phím nút bấm
          _buildMinimalKeyboard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMinimalKeyboard() {
    return Column(
      children: [
        _buildRow(["0", "C", ",", "⌫"]),
        _buildRow(["7", "8", "9", "÷"]),
        _buildRow(["4", "5", "6", "×"]),
        _buildRow(["1", "2", "3", "-"]),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildButton("=", isSpecial: true),
            ),
            Expanded(
              flex: 1,
              child: _buildButton("+"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> texts) {
    return Row(
      children: texts
          .map((text) => Expanded(child: _buildButton(text)))
          .toList(),
    );
  }

  Widget _buildButton(String text, {bool isSpecial = false}) {
    Color bgColor;
    Color textColor = Colors.white;

    if (text == "=") {
      bgColor = const Color(0xFF76C7FF);
      textColor = Colors.black;
    } else if (["0", ","].contains(text)) {
      bgColor = const Color(0xFF2D2D2D);
    } else if (["÷", "×", "-", "+", "C", "⌫"].contains(text)) {
      bgColor = const Color(0xFF323232);
    } else {
      bgColor = const Color(0xFF3B3B3B);
    }

    return Container(
      height: 80,
      padding: const EdgeInsets.all(3),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        onPressed: () => _onPressed(text),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isSpecial ? 28 : 22,
            fontWeight:
                isSpecial ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
