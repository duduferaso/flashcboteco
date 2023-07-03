import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flashboteco/main.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Testando clique no botão Jogar', (WidgetTester tester) async {
    await tester.runAsync(() async {
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.stack.toString().contains(
            'is not supported by all of its localization delegates')) {
          return;
        }
        FlutterError.dumpErrorToConsole(details);
      };

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', ''),
            const Locale('pt', ''),
            const Locale('es', ''),
          ],
          home: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      final jogarButton = find.text('Jogar');
      expect(jogarButton, findsOneWidget);

      await tester.tap(jogarButton);

      await Future.delayed(Duration(milliseconds: 500));

      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);

      final jogarButtonInDialog = find.widgetWithText(ElevatedButton, 'Jogar');
      expect(jogarButtonInDialog, findsOneWidget);
    });
  });
}
