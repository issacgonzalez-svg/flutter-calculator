import 'package:expressions/expressions.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "New Calculator",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 34, 179, 159),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xfff4f7f6),
        useMaterial3: true,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = '';
  String _result = '';
  bool _hasEvaluated = false;

  void _press(String value) {
    setState(() {
      if (_hasEvaluated && (_isDigit(value) || value == '.')) {
        _expression = '';
        _result = '';
        _hasEvaluated = false;
      }

      if (_isOperator(value)) {
        if (_expression.isEmpty) return;
        if (_isOperator(_expression[_expression.length - 1])) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
        _result = '';
        _hasEvaluated = false;
      }

      if (value == '.') {
        final currentNumber = _expression.split(RegExp(r'[+\-*/]')).last;
        if (currentNumber.contains('.')) return;
        if (currentNumber.isEmpty) _expression += '0';
      }

      _expression += value;
    });
  }

  void _clear() {
    setState(() {
      _expression = '';
      _result = '';
      _hasEvaluated = false;
    });
  }

  void _evaluate() {
    if (_expression.isEmpty ||
        _isOperator(_expression[_expression.length - 1])) {
      return;
    }

    try {
      final parsedExpression = Expression.parse(_expression);
      final value = const ExpressionEvaluator().eval(parsedExpression, {});
      if (value is! num || value.isNaN || value.isInfinite) {
        throw const FormatException('Invalid result');
      }

      setState(() {
        _result = _formatNumber(value);
        _hasEvaluated = true;
      });
    } catch (_) {
      setState(() {
        _result = 'Error';
        _hasEvaluated = true;
      });
    }
  }

  void _square() {
    if (_expression.isEmpty ||
        _isOperator(_expression[_expression.length - 1])) {
      return;
    }

    final operandMatch = RegExp(
      r'(-?(?:\d+\.?\d*|\.\d+))$',
    ).firstMatch(_expression);
    if (operandMatch == null) return;

    final operand = num.tryParse(operandMatch.group(1)!);
    final squared = operand == null ? null : operand * operand;
    if (squared == null || squared.isNaN || squared.isInfinite) {
      setState(() {
        _result = 'Error';
        _hasEvaluated = true;
      });
      return;
    }

    setState(() {
      _expression = _expression.substring(0, operandMatch.start) +
          _formatNumber(squared);
      _result = '';
      _hasEvaluated = false;
    });
  }

  bool _isDigit(String value) => RegExp(r'^[0-9]$').hasMatch(value);

  bool _isOperator(String value) => '+-*/'.contains(value);

  String _formatNumber(num value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  String _displayExpression() {
    return _expression.replaceAllMapped(
      RegExp(r'([+\-*/])'),
      (match) => ' ${match.group(1)} ',
    );
  }

  Widget _button(
    String label, {
    VoidCallback? onPressed,
    ButtonType type = ButtonType.number,
  }) {
    final colors = Theme.of(context).colorScheme;
    final backgroundColor = switch (type) {
      ButtonType.operator => colors.primary,
      ButtonType.clear => const Color(0xffdce9e5),
      ButtonType.equals => const Color(0xffef8354),
      ButtonType.number => Colors.white,
    };
    final foregroundColor =
        type == ButtonType.operator || type == ButtonType.equals
        ? Colors.white
        : colors.onSurface;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox(
          height: 68,
          child: ElevatedButton(
            onPressed: onPressed ?? () => _press(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonRow(List<String> labels) {
    return Row(
      children: labels.map((label) {
        final type = label == 'C'
            ? ButtonType.clear
            : _isOperator(label) || label == '='
            ? ButtonType.operator
            : ButtonType.number;
        return _button(
          label,
          type: type,
          onPressed: label == 'C'
              ? _clear
              : label == '='
              ? _evaluate
              : label == 'x²'
              ? _square
              : null,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Super Calculator",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.bottomRight,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 49, 157, 184),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: SingleChildScrollView(
                        reverse: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _expression.isEmpty ? '0' : _displayExpression(),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Color(0xffc4d4d2),
                                fontSize: 26,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _result.isEmpty ? '' : '= $_result',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buttonRow(['x²', '+', '/', '*', '-']),
                  _buttonRow(['7', '8', '9', 'C']),
                  _buttonRow(['4', '5', '6']),
                  _buttonRow(['1', '2', '3']),
                  _buttonRow(['.', '0', '=']),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum ButtonType { number, operator, clear, equals }
