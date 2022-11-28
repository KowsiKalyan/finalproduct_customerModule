import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/widgets/appBar.dart';
import 'package:flutter/material.dart';

class TestingClass extends StatefulWidget {
  const TestingClass({Key? key}) : super(key: key);

  @override
  State<TestingClass> createState() => _TestingClassState();
}

class _TestingClassState extends State<TestingClass> {
  bool test = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      extendBody: true,
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
      appBar: getSimpleAppBar('Testing Only', context),
      body: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 500,
          ),
          height: test ? 0 : deviceHeight! * 0.9,
          width: 150,
          color: Colors.red,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 50,
                  height: 400,
                  color: Colors.green,
                ),
                const Text(
                  'Hint',
                  style: TextStyle(
                    fontFamily: 'ubuntu',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          test = !test;
          setState(() {});
        },
      ),
    );
  }
}
