import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/repositories/product_repository.dart';
import '../data/repositories/sales_repository.dart';

class ReportData {
  final List<SaleWithItems> sales;
  final double totalSales;
  final double totalExpenses;
  final double profit;
  final String periodLabel;

  const ReportData({
    required this.sales,
    required this.totalSales,
    required this.totalExpenses,
    required this.profit,
    required this.periodLabel,
  });
}

class ExcelExporter {
  final ProductRepository _productRepository;

  ExcelExporter({
    required ProductRepository productRepository,
  }) : _productRepository = productRepository;

  Future<void> export(ReportData report) async {
    final rows = <List<dynamic>>[];

    rows.add(['Reporte de Ventas']);
    rows.add(['Fecha de generacion: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}']);
    rows.add(['Periodo: ${report.periodLabel}']);
    rows.add([]);

    rows.add(['ID Venta', 'Fecha', 'Producto', 'Cantidad', 'Precio Unitario', 'Subtotal', 'Total Venta']);

    for (final saleWithItems in report.sales) {
      final sale = saleWithItems.sale;
      final items = saleWithItems.items;

      final saleDate = DateFormat('dd/MM/yyyy HH:mm').format(sale.createdAt);

      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final product = await _productRepository.getProductById(item.productId);
        final productName = product?.name ?? 'Producto #${item.productId}';
        final subtotal = item.quantity * item.unitPrice;

        if (i == 0) {
          rows.add([
            sale.id,
            saleDate,
            productName,
            item.quantity.toStringAsFixed(2),
            item.unitPrice.toStringAsFixed(2),
            subtotal.toStringAsFixed(2),
            '',
          ]);
        } else {
          rows.add(['', '', productName, item.quantity.toStringAsFixed(2), item.unitPrice.toStringAsFixed(2), subtotal.toStringAsFixed(2), '']);
        }
      }

      final saleTotal = items.fold<double>(0, (sum, item) => sum + (item.quantity * item.unitPrice));
      rows.add(['', '', '', '', '', 'Total:', saleTotal.toStringAsFixed(2)]);
      rows.add([]);
    }

    rows.add([]);
    rows.add(['Resumen del Periodo']);
    rows.add(['Total Ventas:', report.totalSales.toStringAsFixed(2)]);
    rows.add(['Total Egresos:', report.totalExpenses.toStringAsFixed(2)]);
    rows.add(['Ganancia:', report.profit.toStringAsFixed(2)]);

    final csv = const ListToCsvConverter().convert(rows);

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/reporte_ventas_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv');
    await file.writeAsString(csv);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Reporte de Ventas - ${report.periodLabel}',
    );
  }
}
