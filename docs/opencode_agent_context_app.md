## opencode_agent_content_app.md

Se implementaron las fases que puedes ver en la carpeta llamada Fases, tenemos avanzado hasta la fase 6 que fue un dashboard.

---
## Lo que ya esta implementado:
Lo siguiente es lo ya implementado en las fases:

- Definicion de base de datos y repositorio base
- Gestion de productos e inventario base
- Registro de ventas y descuento automatico de stock
- Registro y gestion de egresos base
- Dashboard de resumen operativo base (fase 6, de aqui en adelante seguimos desarrollando las fases siguientes)
- Fix N+1 en dashboard: batch query para stock de productos (1 consulta en vez de N)
- Fase 7: Reportes de ventas con filtros (dia/mes/año/rango) y exportacion a Excel (CSV) y PDF
- Fix auto-load en ReportsScreen: carga datos al abrir sin esperar click de filtro
- Mejora en reportes: mostrar nombre de producto en detalle de venta en vez de "Producto #N"
- Mejora del archivo `Ajustes-en-dashboard.md` implementada.

---

## Comandos que corro manualmente para probar lo desarrollado e implementado (yo, el humano los ejecuto por mi cuenta, solo te doy contexto para que sepas tu, agente):

```bash
dart run build_runner build --delete-conflicting-outputs
```

```bash
flutter analyze
```

```bash
flutter test
```