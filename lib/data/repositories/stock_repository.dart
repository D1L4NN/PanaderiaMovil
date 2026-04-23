import 'package:drift/drift.dart';

import '../database/app_database.dart';

class StockRepository {
  final AppDatabase _database;

  StockRepository(this._database);

  Future<int> registerMovement({
    required int productId,
    required String type,
    required double quantity,
    required String reason,
    int? referenceId,
    DateTime? createdAt,
  }) {
    return _database.into(_database.stockMovements).insert(
          StockMovementsCompanion.insert(
            productId: productId,
            type: type,
            quantity: quantity,
            reason: reason,
            referenceId: Value(referenceId),
            createdAt: Value(createdAt ?? DateTime.now()),
          ),
        );
  }

  Future<List<StockMovement>> getMovementsByProduct(int productId) {
    return (_database.select(_database.stockMovements)
          ..where((table) => table.productId.equals(productId))
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
        .get();
  }

  Future<double> getCurrentStockForProduct(int productId) async {
    final movements = await getMovementsByProduct(productId);

    return movements.fold<double>(0, (total, movement) {
      if (movement.type == StockMovementType.entry) {
        return total + movement.quantity;
      }

      return total - movement.quantity;
    });
  }
}
