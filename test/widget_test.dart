import 'package:flutter_test/flutter_test.dart';

import 'package:voz_propia_web/main.dart';

void main() {
  testWidgets('La app arranca y muestra el splash/login sin tirar excepciones', (tester) async {
    await tester.pumpWidget(const VozPropiaApp());
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
