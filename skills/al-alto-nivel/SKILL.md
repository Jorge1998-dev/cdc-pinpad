---
name: al-alto-nivel
description: Usar para cualquier trabajo en AL (Business Central) en este repositorio: diseño de objetos, legibilidad, validaciones, manejo de transacciones, integración POS/pinpad, rendimiento y pruebas. Aplicar como base oficial las prácticas de Microsoft Learn cuando haya dudas de estándar o decisión técnica.
---

# AL Alto Nivel

Aplica esta skill en toda edición de archivos `.al`.

## Objetivo
- Mantener código AL robusto, legible y mantenible.
- Evitar regresiones en flujos POS/pinpad y eventos de impresión/pago.
- Estandarizar validaciones, errores, nomenclatura y pruebas.
- Alinear decisiones con documentación oficial de Microsoft Learn.
- Respetar convenciones existentes del repositorio (objetos 60000+, prefijos `OPT`/`LAF`, integración LS Central).

## Flujo de trabajo
1. Identificar objeto AL y alcance funcional.
2. Revisar contratos externos (eventos, tablas LS Central, integración EFT/pinpad).
3. Para decisiones de estándar AL, validar contra Microsoft Learn (usar las referencias de `references/microsoft-learn-al.md`).
4. Aplicar cambios mínimos con bajo riesgo.
5. Validar compilación y pruebas disponibles.
6. Documentar supuestos y riesgos residuales.

## Principios de diseño
- Mantener procedimientos cortos y con responsabilidad única.
- Extraer lógica repetida a funciones locales descriptivas.
- Preferir nombres explícitos (`GetLastApprovedLAFTransaction`, `PrintCustomerVoucher`).
- Evitar side effects ocultos en funciones auxiliares.
- No mezclar acceso a datos, reglas de negocio y rendering en un solo bloque si se puede separar.

## Estándares AL
- Usar `Clear`, `Reset`, `SetRange`, `SetFilter` de forma explícita antes de consultas.
- Elegir método por intención:
  - `Get` para llave primaria exacta.
  - `FindFirst`/`FindLast` para un único registro.
  - `FindSet` para iteración completa.
  - `Find('-')`/`Find('+')` cuando se puede cortar lectura temprano.
- Evitar `Count` sobre filtros costosos si luego se recorrerá el mismo dataset.
- Para lectura masiva, preferir partial records (`SetLoadFields`/`AddLoadFields`) y cargar solo campos necesarios.
- No usar partial records en escenarios de escritura (`Insert`/`Modify`/`Delete`/`Rename`) para evitar costos de JIT load.
- Usar `SetAutoCalcFields` cuando se consultan FlowFields repetidamente dentro de loops.
- Usar `case` para múltiples ramas de estado en lugar de `if` encadenado cuando mejore claridad.
- Aplicar `exit(...)` temprano para reducir anidación.
- Mantener consistencia en mayúsculas AL (`if`, `then`, `begin/end`) según estilo del archivo tocado.

## Errores y validaciones
- Validar precondiciones antes de ejecutar integración externa o impresión.
- Usar mensajes de error claros y accionables (qué falló y con qué clave).
- Diferenciar errores funcionales (reglas de negocio) de fallas técnicas (I/O, integración).
- Preferir `ErrorInfo` + `Dialog.Error(ErrorInfo)` cuando agregue contexto de soporte.
- Usar `[TryFunction]` solo cuando corresponda capturar error; evitar escritura dentro de try methods.
- No silenciar errores críticos con bloques vacíos.

## Rendimiento y transacciones
- Minimizar lecturas repetidas con los mismos filtros.
- Reutilizar registros filtrados cuando sea seguro.
- Evitar copiar/clonar registros antes de `Modify/Delete` en loops (dispara SQL extra).
- Usar `ModifyAll/DeleteAll` cuando aplique, verificando que triggers/subscribers no obliguen fallback a fila por fila.
- Evitar bloqueos innecesarios en operaciones de consulta.
- Llamar `LockTable` lo más tarde posible dentro de la transacción.
- Mantener transacciones cortas en flujos de POS.

## Integración POS/pinpad
- Tratar respuesta `'00'` como aprobada solo en contexto de negocio definido.
- Validar llaves de correlación: tienda, terminal, recibo, referencia.
- Mantener separación entre voucher cliente y comercio.
- En eventos subscribers, evitar patrón `IsHandled` salvo necesidad real; preferir eventos positivos (OnBefore/OnAfter/OnSkip con propósito claro).
- En flujos de anulación/refund, validar precondiciones funcionales antes de depurar eventos (por ejemplo: transacción del día y flags de prompt).
- En rutas que leen `Trans. LAF`, confirmar que el recibo de origen (`Retrieved from Receipt No.`) esté poblado antes de filtrar.
- Si se usa `PrintBarcode` o impresora por `Tray`, documentar/centralizar códigos especiales (ej.: `99`).

## Impresión y formato
- Centralizar constantes de formato para encabezados y líneas.
- Evitar literales duplicados en textos de impresión.
- Mantener consistencia en idioma y acentos en comprobantes.
- Verificar que campos sensibles (tarjeta) respeten enmascaramiento requerido.

## Pruebas
- Al cambiar reglas, agregar o ajustar pruebas unitarias/integración si existen suites.
- Mantener patrón de prueba: inicializar, ejecutar lógica, validar resultado.
- `AssertError` solo en test codeunits.
- Cubrir mínimos:
  - Transacción aprobada.
  - Transacción anulada.
  - Modos de entrada (`MANUAL`, `SWIPE`, `FALLBACK`, chip/contactless).
  - Casos sin configuración de terminal/setup.
- Si no se pueden ejecutar pruebas, reportarlo explícitamente.

## Extensibilidad y eventos
- Preferir eventos con propósito de negocio claro.
- Evitar eventos de bajo valor acoplados a una sola línea si puede resolverse con evento de mayor nivel.
- En este repositorio coexisten `LSC POS Transaction Events` y `OPT POS Transaction Events`; el `EventSubscriber` debe apuntar al mismo codeunit publicador que usa el flujo ejecutado.
- Si existe `IsHandled`, documentar por qué no fue posible otra alternativa.

## Code analysis
- Mantener habilitado análisis estático en el entorno (al menos `CodeCop`).
- Para apps con requisitos de publicación, considerar `AppSourceCop`, `PerTenantExtensionCop` y `UICop` según objetivo.
- Tratar advertencias críticas de analizadores como deuda técnica a resolver antes de cerrar tarea.

## Checklist antes de cerrar tarea
- Compila sin errores.
- Sin cambios colaterales fuera del alcance.
- Sin consultas redundantes evidentes.
- Errores/validaciones coherentes.
- Criterios de extensibilidad y rendimiento revisados contra Microsoft Learn cuando aplique.
- Resultado funcional descrito con archivos y líneas clave.

## Uso rápido en este repo
1. Leer el objeto AL afectado y su integración cruzada (`Trans. LAF`, `LSC POS Print Buffer`, `LSC POS Print Utility`).
2. Localizar consultas repetidas y consolidarlas sin alterar resultados.
3. Separar formato de impresión de reglas de negocio cuando crezca un procedimiento.
4. Confirmar comportamiento para venta, anulación y reimpresión.
5. Para `VOID_TR`, trazar cadena `Lookup -> ValidateRecordIDInput -> VoidPostedTransaction -> ProcessRefundSelection -> SendVoid` y verificar carga de tarjeta desde `Trans. LAF`.
