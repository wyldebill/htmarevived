import '../domain/business.dart';

abstract class BusinessRepository {
  Future<List<Business>> fetchBusinesses();
}
