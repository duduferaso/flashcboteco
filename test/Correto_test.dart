import 'package:flashboteco/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Principal botões', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: FlashcardApp()));

    // Aguarda o carregamento das perguntas
    await tester.pumpAndSettle();
    print('Perguntas carregadas');

    // Verifica se a pergunta é exibida corretamente
    expect(find.text('Na Alemanha, Oktoberfest é celebrado com que bebida?'),
        findsOneWidget);
    print('Pergunta 1 exibida corretamente');

    // Clica no botão 'Correct'
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();
    print('Botão "Correct" clicado');

    // Verifica se o contador de respostas corretas foi incrementado
    expect(find.text('Correct: 1'), findsOneWidget);
    print('Contador de respostas corretas incrementado corretamente');
  });
}
