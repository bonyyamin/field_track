import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field_tracker/features/auth/presentation/widgets/auth_text_field.dart';

void main() {
  testWidgets('AuthTextField renders correctly and handles focus', (WidgetTester tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthTextField(
            label: 'Test Label',
            hint: 'Test Hint',
            prefixIcon: Icons.email,
            controller: controller,
            focusNode: focusNode,
          ),
        ),
      ),
    );

    // Verify it renders the label and text field
    expect(find.text('Test Label'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);

    // Verify initial focus is false
    expect(focusNode.hasFocus, isFalse);

    // Focus the text field
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    // Verify it has focus
    expect(focusNode.hasFocus, isTrue);

    // Clean up
    controller.dispose();
    focusNode.dispose();
  });
}
