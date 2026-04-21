import 'package:firebase_database/firebase_database.dart';

import '../domain/business.dart';
import 'business_repository.dart';

class RtdbBusinessRepository implements BusinessRepository {
  RtdbBusinessRepository({required FirebaseDatabase database})
    : _businessRef = database.ref('businesses');

  final DatabaseReference _businessRef;

  @override
  Future<List<Business>> fetchBusinesses() async {
    final snapshot = await _businessRef.get();
    final value = snapshot.value;
    if (value is! Map<Object?, Object?>) {
      return const [];
    }

    final businesses = <Business>[];
    for (final entry in value.entries) {
      final item = entry.value;
      if (item is! Map<Object?, Object?>) {
        continue;
      }
      businesses.add(Business.fromJson(entry.key.toString(), item));
    }

    businesses.sort((a, b) => a.name.compareTo(b.name));
    return businesses;
  }
}
