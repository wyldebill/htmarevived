import 'package:flutter_test/flutter_test.dart';
import 'package:htmarevived/features/businesses/domain/business.dart';

void main() {
  test('Business.fromJson reads flattened coordinates', () {
    final business = Business.fromJson('abc', {
      'name': 'Flat Co',
      'category': 'Services',
      'address': '100 Center St',
      'lat': 45.1,
      'lng': -93.9,
    });

    expect(business.id, 'abc');
    expect(business.name, 'Flat Co');
    expect(business.category, 'Services');
    expect(business.address, '100 Center St');
    expect(business.latitude, 45.1);
    expect(business.longitude, -93.9);
  });

  test('Business.fromJson supports legacy nested coordinates', () {
    final business = Business.fromJson('legacy', {
      'name': 'Nested Co',
      'category': 'Retail',
      'address': '200 Main St',
      'coordinates': {'lat': '45.2', 'lng': '-93.8'},
    });

    expect(business.latitude, 45.2);
    expect(business.longitude, -93.8);
  });

  test('Business.fromJson defaults invalid coordinates to zero', () {
    final business = Business.fromJson('bad', {
      'name': 'Bad Co',
      'category': 'Coffee',
      'address': 'Nowhere',
      'lat': 'not-a-number',
      'lng': null,
    });

    expect(business.latitude, 0);
    expect(business.longitude, 0);
  });
}
