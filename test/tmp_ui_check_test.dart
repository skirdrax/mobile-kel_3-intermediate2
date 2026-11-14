import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:realtime_communication/main.dart';

void main() {
  Future<void> setSize(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('kasir flow', (tester) async {
    await setSize(tester);
    await tester.pumpWidget(const PosApp());
    await tester.pumpAndSettle();

    expect(find.text('Masuk'), findsWidgets);

    await tester.tap(find.text('Isi'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Kasir POS'), findsOneWidget);

    await tester.tap(find.text('Kopi Susu Gula Aren'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();
    expect(find.text('Pesanan'), findsOneWidget);

    await tester.tap(find.text('Bayar Sekarang'));
    await tester.pumpAndSettle();
    expect(find.text('Selesaikan pesanan?'), findsOneWidget);

    await tester.tap(find.text('Konfirmasi'));
    await tester.pumpAndSettle();
    expect(find.text('Transaksi Berhasil'), findsOneWidget);
    expect(AppState.orders.length, 1);

    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();
    expect(find.text('Kasir POS'), findsOneWidget);
  });

  testWidgets('admin flow', (tester) async {
    await setSize(tester);
    await tester.pumpWidget(const PosApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Isi'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Halo, Admin 👋'), findsOneWidget);
    final initialCount = AppState.products.length;

    await tester.tap(find.text('Tambah Menu'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Testing Menu');
    await tester.enterText(find.byType(TextFormField).last, '12345');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(AppState.products.length, initialCount + 1);
    expect(find.text('Testing Menu'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Testing');
    await tester.pumpAndSettle();
    expect(find.text('Testing Menu'), findsOneWidget);
    expect(find.text('Kopi Susu Gula Aren'), findsNothing);
  });
}
