import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:math_expressions/math_expressions.dart';
import '../constants/app_colors.dart';
import '../providers.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  String _expression = '';
  String _liveResult = '';

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _liveResult = '';
      } else if (value == 'DEL') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == '=') {
        if (_liveResult.isNotEmpty && _expression.isNotEmpty) {
          Provider.of<DataProvider>(context, listen: false)
              .addHistory('$_expression = $_liveResult');
          _expression = _liveResult;
          _liveResult = '';
        }
      } else {
        _expression += value;
      }

      _evaluateLive();
    });
  }

  void _evaluateLive() {
    if (_expression.isEmpty) {
      _liveResult = '';
      return;
    }
    
    try {
      // Replace symbols for the parser
      String parseExpr = _expression.replaceAll('x', '*').replaceAll('÷', '/');
      ShuntingYardParser p = ShuntingYardParser();
      Expression exp = p.parse(parseExpr);
      final cm = ContextModel();
      final evaluator = RealEvaluator(cm);
      final num eval = evaluator.evaluate(exp);
      
      // Remove trailing .0
      String res = eval.toString();
      if (res.endsWith('.0')) {
        res = res.substring(0, res.length - 2);
      }
      
      // Check if expression is just a number
      if (res == _expression) {
        _liveResult = '';
      } else {
        _liveResult = res;
      }
    } catch (e) {
      // Don't update live result if incomplete expression
      _liveResult = '';
    }
  }

  Widget _buildButton(String text, {Color? textColor, Color? bgColor}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor ?? const Color(0xFFF3F3F3),
            foregroundColor: textColor ?? Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () => _onButtonPressed(text),
          child: Text(
            text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(locale.tools),
        backgroundColor: AppColors.darkNavy,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(locale.history),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Consumer<DataProvider>(
                      builder: (context, data, _) {
                        if (data.history.isEmpty) {
                          return Text(locale.noHistory);
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          itemCount: data.history.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, i) => Text(data.history[i], style: const TextStyle(fontSize: 18)),
                        );
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK', style: TextStyle(color: AppColors.primaryGreen)),
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Display Area
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _expression,
                    style: const TextStyle(fontSize: 36, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _liveResult.isNotEmpty ? '= $_liveResult' : '',
                    style: const TextStyle(fontSize: 24, color: AppColors.primaryGreen),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Keypad Area
          Expanded(
            flex: 2,
            child: Container(
              color: AppColors.greyCard,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton('C', textColor: AppColors.returnRed),
                        _buildButton('DEL', textColor: AppColors.returnRed),
                        _buildButton('%', textColor: AppColors.primaryGreen),
                        _buildButton('÷', textColor: AppColors.primaryGreen),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton('7'),
                        _buildButton('8'),
                        _buildButton('9'),
                        _buildButton('x', textColor: AppColors.primaryGreen),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton('4'),
                        _buildButton('5'),
                        _buildButton('6'),
                        _buildButton('-', textColor: AppColors.primaryGreen),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton('1'),
                        _buildButton('2'),
                        _buildButton('3'),
                        _buildButton('+', textColor: AppColors.primaryGreen),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton('00'),
                        _buildButton('0'),
                        _buildButton('.'),
                        _buildButton('=', bgColor: AppColors.primaryGreen, textColor: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
