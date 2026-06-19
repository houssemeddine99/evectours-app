// Basic smoke test: the app builds and shows the bottom navigation.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:evectours_app/main.dart';

void main() {
  testWidgets('App boots with bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const EvecToursApp());
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Voyages'), findsWidgets);
  });
}
