import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/database/app_database.dart';
import '../dashboard/dashboard_screen.dart';
import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Panaderia ERP'),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showProductDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo producto'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: controller.loadProducts,
                  child: controller.products.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            _EmptyState(),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: controller.products.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = controller.products[index];
                            return _ProductCard(item: item);
                          },
                        ),
                ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 72, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'No hay productos registrados',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Agrega tu primer producto para empezar a controlar inventario.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductStockViewData item;

  const _ProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.product.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Precio: \$${item.product.salePrice.toStringAsFixed(2)}'),
            Text('Stock actual: ${formatStock(item.stock)}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showProductDialog(
                    context,
                    product: item.product,
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showStockAdjustmentDialog(
                    context,
                    product: item.product,
                  ),
                  icon: const Icon(Icons.tune),
                  label: const Text('Ajustar stock'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _confirmDeactivateProduct(
                    context,
                    product: item.product,
                  ),
                  icon: const Icon(Icons.visibility_off_outlined),
                  label: const Text('Desactivar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StockAdjustmentRequest {
  final int productId;
  final String type;
  final double quantity;

  const StockAdjustmentRequest({
    required this.productId,
    required this.type,
    required this.quantity,
  });
}

Future<void> _showProductDialog(
  BuildContext context, {
  Product? product,
}) async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: product?.name ?? '');
  final priceController = TextEditingController(
    text: product != null ? product.salePrice.toStringAsFixed(2) : '',
  );
  final controller = context.read<HomeController>();
  final isEditing = product != null;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(isEditing ? 'Editar producto' : 'Nuevo producto'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio de venta',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final price = double.tryParse(value ?? '');
                  if (price == null || price <= 0) {
                    return 'Ingresa un precio mayor a cero';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) {
                return;
              }

              final name = nameController.text.trim();
              final salePrice = double.parse(priceController.text);

              if (product != null) {
                final existingProduct = product;

                await controller.updateProduct(
                  id: existingProduct.id,
                  name: name,
                  salePrice: salePrice,
                  isActive: existingProduct.isActive,
                );
              } else {
                await controller.createProduct(
                  name: name,
                  salePrice: salePrice,
                );
              }

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text(isEditing ? 'Guardar' : 'Crear'),
          ),
        ],
      );
    },
  );
}

Future<void> _showStockAdjustmentDialog(
  BuildContext context, {
  required Product product,
}) async {
  final formKey = GlobalKey<FormState>();
  final quantityController = TextEditingController();
  final controller = context.read<HomeController>();
  var movementType = StockMovementType.entry;

  final adjustmentRequest = await showDialog<StockAdjustmentRequest>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Ajustar stock: ${product.name}'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: movementType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de ajuste',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: StockMovementType.entry,
                        child: Text('Entrada'),
                      ),
                      DropdownMenuItem(
                        value: StockMovementType.exit,
                        child: Text('Salida'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          movementType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      final quantity = double.tryParse(value ?? '');
                      if (quantity == null || quantity <= 0) {
                        return 'Ingresa una cantidad mayor a cero';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }

                  final request = StockAdjustmentRequest(
                    productId: product.id,
                    type: movementType,
                    quantity: double.parse(quantityController.text),
                  );

                  Navigator.of(dialogContext).pop(request);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );
    },
  );

  if (adjustmentRequest != null) {
    await controller.adjustStock(
      productId: adjustmentRequest.productId,
      type: adjustmentRequest.type,
      quantity: adjustmentRequest.quantity,
    );
  }
}

Future<void> _confirmDeactivateProduct(
  BuildContext context, {
  required Product product,
}) async {
  final controller = context.read<HomeController>();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Desactivar producto'),
        content: Text(
          'El producto "${product.name}" dejara de mostrarse en la lista de activos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              await controller.deactivateProduct(product.id);
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Desactivar'),
          ),
        ],
      );
    },
  );
}
