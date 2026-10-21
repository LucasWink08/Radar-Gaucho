import 'package:flutter_test/flutter_test.dart';

import 'package:radargaucho/main.dart';


void main() {
  testWidgets('App renders', (WidgetTester tester) async {


    await tester.pumpWidget(const RadarGauchoApp());


  
    expect(find.text('Radar Gaúcho'), findsOneWidget);

  });
}
