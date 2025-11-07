import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_movil/features/auth/presentation/widgets/custom_text_field.dart';

void main() {
  group('CustomTextField Widget', () {
    testWidgets('should display label and hint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: TextEditingController(),
              label: 'Test Label',
              hint: 'Test Hint',
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('Test Hint'), findsOneWidget);
    });

    testWidgets('should show prefix icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: TextEditingController(),
              label: 'Email',
              hint: 'Enter email',
              prefixIcon: Icons.email,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('should obscure text when obscureText is true', (tester) async {
      final controller = TextEditingController(text: 'password');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              label: 'Password',
              hint: 'Enter password',
              obscureText: true,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, true);
    });

    testWidgets('should call validator when text changes', (tester) async {
      String? validationResult;
      String? Function(String?) validator = (value) {
        if (value == null || value.isEmpty) {
          return 'Field is required';
        }
        return null;
      };

      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: CustomTextField(
                controller: controller,
                label: 'Name',
                hint: 'Enter name',
                validator: validator,
              ),
            ),
          ),
        ),
      );

      // Submit form to trigger validation
      final formState = tester.state<FormState>(find.byType(Form));
      validationResult = formState.validate() ? null : 'Invalid';

      expect(validationResult, 'Invalid');
    });

    testWidgets('should be disabled when enabled is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: TextEditingController(),
              label: 'Disabled Field',
              hint: 'Cannot edit',
              enabled: false,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, false);
    });

    testWidgets('should accept different keyboard types', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: TextEditingController(),
              label: 'Email',
              hint: 'Enter email',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('should allow text input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              label: 'Name',
              hint: 'Enter name',
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'John Doe');
      expect(controller.text, 'John Doe');
    });

    testWidgets('should show suffix icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: TextEditingController(),
              label: 'Password',
              hint: 'Enter password',
              suffixIcon: IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });
}
