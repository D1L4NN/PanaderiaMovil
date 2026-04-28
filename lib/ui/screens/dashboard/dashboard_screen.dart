import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: controller.loadDashboard,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _MetricCard(
                            title: 'Ingresos del dia',
                            value:
                                '\$${controller.dayIncome.toStringAsFixed(2)}',
                            valueColor: Colors.green.shade800,
                          ),
                          _MetricCard(
                            title: 'Egresos del dia',
                            value:
                                '\$${controller.dayExpenses.toStringAsFixed(2)}',
                            valueColor: Colors.red.shade800,
                          ),
                          _MetricCard(
                            title: 'Ganancia del dia',
                            value:
                                '\$${controller.dayProfit.toStringAsFixed(2)}',
                            valueColor: controller.dayProfit >= 0
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                          _MetricCard(
                            title: 'Ventas de ${controller.currentMonthLabel}',
                            value:
                                '\$${controller.monthSales.toStringAsFixed(2)}',
                            valueColor: Colors.green.shade800,
                          ),
                          _MetricCard(
                            title: 'Egresos de ${controller.currentMonthLabel}',
                            value:
                                '\$${controller.monthExpenses.toStringAsFixed(2)}',
                            valueColor: Colors.red.shade800,
                          ),
                          _MetricCard(
                            title:
                                'Ganancia de ${controller.currentMonthLabel}',
                            value:
                                '\$${controller.monthProfit.toStringAsFixed(2)}',
                            valueColor: controller.monthProfit >= 0
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Productos con stock bajo',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      if (controller.lowStockProducts.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No hay productos con stock bajo.',
                            ),
                          ),
                        )
                      else
                        ...controller.lowStockProducts.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              child: ListTile(
                                title: Text(item.product.name),
                                subtitle: Text(
                                  'Precio: \$${item.product.salePrice.toStringAsFixed(2)}',
                                ),
                                trailing: Text(
                                  'Stock: ${formatStock(item.stock)}',
                                  style: TextStyle(
                                    color: item.stock == 0
                                        ? Colors.red.shade800
                                        : null,
                                    fontWeight: item.stock == 0
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                tileColor: item.stock == 0
                                    ? Colors.red.shade50
                                    : null,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _MetricCard({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: valueColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String formatStock(double stock) {
  return stock.toInt().toString();
}
