import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:htmarevived/app/app.dart';
import 'package:htmarevived/features/businesses/data/business_repository.dart';
import 'package:htmarevived/features/businesses/domain/business.dart';
import 'package:htmarevived/features/businesses/presentation/business_detail_page.dart';
import 'package:htmarevived/features/businesses/presentation/business_list_page.dart';
import 'package:htmarevived/features/businesses/presentation/business_map_page.dart';
import 'package:htmarevived/features/businesses/presentation/business_shell_page.dart';

void main() {
  testWidgets('App shell renders list/map navigation for loaded businesses', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BuffaloBusinessApp(repository: _FakeRepository(), googleMapsApiKey: ''),
    );
    await tester.pumpAndSettle();
    expect(find.text('Businesses'), findsOneWidget);
    expect(find.text('List'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
  });

  testWidgets('Business detail page shows minimal model and map fallback', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BusinessDetailPage(
          business: _FakeRepository.sampleBusinesses.first,
          googleMapsApiKey: '',
        ),
      ),
    );

    expect(find.text('A Business'), findsNWidgets(2));
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('123 Main St'), findsOneWidget);
    expect(find.textContaining('45.170000, -93.870000'), findsOneWidget);
    expect(find.textContaining('Map preview unavailable'), findsOneWidget);
    expect(find.text('View on Google Maps'), findsOneWidget);
  });

  testWidgets('Shell navigation opens detail from list selection', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BuffaloBusinessApp(repository: _FakeRepository(), googleMapsApiKey: ''),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('A Business'));
    await tester.pumpAndSettle();

    expect(find.text('View on Google Maps'), findsOneWidget);
    expect(find.text('123 Main St'), findsOneWidget);
  });

  testWidgets('List page supports category filters', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BusinessListPage(
            businesses: _FakeRepository.sampleBusinesses,
            onBusinessSelected: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('A Business'), findsOneWidget);
    expect(find.text('B Business'), findsOneWidget);

    await tester.tap(find.text('Retail'));
    await tester.pumpAndSettle();
    expect(find.text('A Business'), findsNothing);
    expect(find.text('B Business'), findsOneWidget);
  });

  testWidgets('List page supports search by name or category', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BusinessListPage(
            businesses: _FakeRepository.sampleBusinesses,
            onBusinessSelected: (_) {},
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'coffee');
    await tester.pumpAndSettle();
    expect(find.text('A Business'), findsOneWidget);
    expect(find.text('B Business'), findsNothing);
  });

  testWidgets('List page shows empty-filter message when no item matches', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BusinessListPage(
            businesses: _FakeRepository.sampleBusinesses,
            onBusinessSelected: (_) {},
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'nonexistent');
    await tester.pumpAndSettle();

    expect(
      find.text('No businesses match your current filters.'),
      findsOneWidget,
    );
  });

  testWidgets('Map page shows friendly state when key is missing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BusinessMapPage(
          businesses: _FakeRepository.sampleBusinesses,
          googleMapsApiKey: '',
          onBusinessSelected: (_) {},
        ),
      ),
    );
    expect(find.textContaining('Map is unavailable right now'), findsOneWidget);
  });

  testWidgets('Shell shows error state and retry fetches again', (
    WidgetTester tester,
  ) async {
    final repository = _RetryingRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: BusinessShellPage(repository: repository, googleMapsApiKey: ''),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Could not load businesses from Firebase Realtime Database.'),
      findsOneWidget,
    );
    expect(repository.calls, 1);

    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text('A Business'), findsOneWidget);
    expect(repository.calls, 2);
  });

  testWidgets(
    'Shell shows empty-state message when repository returns no data',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BusinessShellPage(
            repository: _EmptyRepository(),
            googleMapsApiKey: '',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'No businesses yet. Seed data in Realtime Database to continue.',
        ),
        findsOneWidget,
      );
      expect(find.text('Reload'), findsOneWidget);
    },
  );

  testWidgets('Shell shows permission-denied guidance for RTDB reads', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BusinessShellPage(
          repository: _PermissionDeniedRepository(),
          googleMapsApiKey: '',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Firebase denied read access to /businesses.'),
      findsOneWidget,
    );
  });
}

class _FakeRepository implements BusinessRepository {
  static const sampleBusinesses = [
    Business(
      id: '1',
      name: 'A Business',
      category: 'Coffee',
      address: '123 Main St',
      latitude: 45.17,
      longitude: -93.87,
    ),
    Business(
      id: '2',
      name: 'B Business',
      category: 'Retail',
      address: '456 Main St',
      latitude: 45.18,
      longitude: -93.88,
    ),
  ];

  @override
  Future<List<Business>> fetchBusinesses() async {
    return sampleBusinesses;
  }
}

class _RetryingRepository implements BusinessRepository {
  int calls = 0;

  @override
  Future<List<Business>> fetchBusinesses() async {
    calls++;
    if (calls == 1) {
      throw Exception('failed');
    }
    return _FakeRepository.sampleBusinesses;
  }
}

class _EmptyRepository implements BusinessRepository {
  @override
  Future<List<Business>> fetchBusinesses() async => const [];
}

class _PermissionDeniedRepository implements BusinessRepository {
  @override
  Future<List<Business>> fetchBusinesses() async {
    throw FirebaseException(
      plugin: 'firebase_database',
      code: 'permission-denied',
      message: 'Client does not have permission to access the desired data.',
    );
  }
}
