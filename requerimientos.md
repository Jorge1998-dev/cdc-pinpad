# Requerimientos del Sistema - cdc-pinpad

Ultima revision: 2026-05-14

## 1. Proposito

La extension `cdc-pinpad` debe integrar LS Central POS con el pinpad/API LAFISE para procesar pagos con tarjeta, anulaciones, devoluciones, cierres, reportes e impresion de vouchers, manteniendo trazabilidad bancaria dentro de Business Central.

## 2. Plataforma y dependencias

- El sistema debe ejecutarse como extension AL para Microsoft Dynamics 365 Business Central version 25.
- El sistema debe integrarse con LS Central 25.3 y Local Functionality for LS Central North America 25.3.
- El sistema debe convivir con `OPT - Nicaragua POS` version 3.0.0.0.
- El rango de objetos propio debe mantenerse dentro de `60000..60149`.
- La extension debe mantener `NoImplicitWith` habilitado.

## 3. Configuracion del pinpad

- El sistema debe permitir configurar la conexion pinpad por tienda y terminal POS mediante `OPT Serial Port Setup`.
- La configuracion debe incluir URL del servicio, puerto local/API, puerto LAFISE, tienda, terminal POS, credenciales tecnicas y credencial administrativa para anulaciones.
- La configuracion debe permitir definir identificadores de merchant y terminal por moneda cuando aplique.
- La configuracion debe permitir controlar si se imprime voucher de comercio.
- El sistema debe exponer la configuracion mediante la pagina `Serial Ports Setup`.

## 4. Configuracion del tender

- El sistema debe extender `LSC Tender Type` para marcar que un tipo de pago usa integracion pinpad.
- El tender debe almacenar al menos `Pinpad Integration`, `CurrencyId` e `IDs`.
- La pagina `LSC Tender Type Card` debe exponer los campos de integracion pinpad en un grupo dedicado.
- Solo los tender configurados para pinpad deben activar el flujo de comunicacion con LAFISE.

## 5. Venta con tarjeta

- El sistema debe interceptar el flujo de pago del POS cuando el tender requiera pinpad.
- El sistema debe calcular monto, moneda, balance y tender antes de enviar la solicitud.
- El sistema debe construir el payload LAFISE de venta, codificarlo en Base64 y enviarlo a `/api/SendTrans`.
- El sistema debe interpretar `Response Code = "00"` como aprobacion de negocio.
- Si la venta es aprobada, el sistema debe registrar la transaccion en `Trans. LAF` y crear o actualizar la entrada correspondiente en `LSC POS Card Entry`.
- Si la venta es rechazada o falla la comunicacion, el sistema debe mostrar un mensaje accionable en POS y dejar evidencia tecnica cuando sea posible.

## 6. Anulacion y void

- El sistema debe soportar anulacion de pagos con tarjeta usando el voucher o recibo original.
- El flujo de anulacion debe integrarse con el comando POS `VOID_TR` y las funciones EFT de void card.
- El sistema debe validar y transportar la referencia necesaria para que LAFISE identifique la transaccion original.
- El sistema debe usar la credencial administrativa de anulacion configurada cuando el payload lo requiera.
- Si el recibo original contiene multiples pagos LAFISE, cada entrada de tarjeta elegible debe mostrar su propia confirmacion de anulacion.
- Si el recibo original contiene multiples pagos LAFISE, cada anulacion debe correlacionarse por `Voucher Number` de la entrada `LSC POS Card Entry`, no solo por recibo original.
- La busqueda del registro original en `Trans. LAF` debe usar tienda, terminal, recibo original, `Log = false` y `Voucher Number`; cuando exista, debe preferir una venta aprobada con `Response Code = "00"` y `Void Sale = false`.
- Si la anulacion es aprobada, el sistema debe registrar `Trans. LAF`, actualizar la entrada de tarjeta y reflejar el resultado en el POS.
- Si la anulacion no procede, el sistema debe impedir que el POS quede como si el pago hubiera sido anulado exitosamente.

## 7. Refund

- El sistema debe soportar devoluciones/refund con tarjeta integradas al pinpad.
- El refund debe registrar respuesta bancaria, autorizacion, voucher, importe, moneda y referencia en `Trans. LAF`.
- El refund debe generar o actualizar la entrada de tarjeta relacionada con el flujo POS.
- Cuando el refund dependa de una transaccion LAFISE original, debe conservar la referencia/voucher del pago especifico para evitar mezclar datos entre pagos multiples del mismo recibo.
- El sistema debe mostrar rechazo o error de pinpad al operador cuando `Response Code` no sea aprobado.

## 8. Settle y reportes LAFISE

- El sistema debe exponer comandos POS para ejecutar cierre/settle y reporte de detalle LAFISE.
- El comando `SETTLE` debe delegar en `ConnectCom.SendSettle`.
- El comando `REPORTLAFISE` debe delegar en `ConnectCom.SenRepDetail`.
- Los resultados de settle y reporte deben quedar registrados en `Trans. LAF` con fecha, hora, estado y respuesta cruda.

## 9. Auditoria y trazabilidad

- Toda comunicacion relevante con LAFISE debe registrar una entrada en `Trans. LAF` cuando exista informacion suficiente para auditarla.
- `Trans. LAF` debe conservar tienda, terminal POS, recibo, numero de transaccion, intento (`Trie`), tipo de transaccion, tender, importes, moneda, autorizacion, voucher, respuesta, referencia, datos EMV y estado.
- La respuesta cruda del servicio debe conservarse en el BLOB `bJsonResponse` mediante `SetRequest`.
- La pagina `Lafise Log` debe permitir consultar las transacciones registradas.
- El sistema debe mantener correlacion entre `Trans. LAF`, `LSC POS Card Entry`, recibo POS y voucher LAFISE.

## 10. Impresion de vouchers

- El sistema debe imprimir vouchers LAFISE usando la infraestructura de impresion de LS Central.
- El sistema debe separar, cuando aplique, voucher de cliente y voucher de comercio.
- El sistema debe enmascarar el numero de tarjeta en las salidas impresas.
- El formato debe incluir datos clave de aprobacion, comercio, terminal, tarjeta, importe, fecha, hora, voucher, autorizacion y campos EMV cuando existan.
- La utilidad de impresion debe soportar reimpresion a partir de transacciones y datos LAF registrados.

## 11. Interfaz POS y experiencia operativa

- El sistema debe informar al operador cuando se envia una peticion al dispositivo, cuando es aprobada y cuando falla.
- El sistema debe usar mensajes, confirmaciones, banners y teclado numerico del POS mediante una capa GUI dedicada.
- Los errores funcionales deben diferenciarse de fallas tecnicas de comunicacion.
- Los mensajes visibles al operador deben ser suficientemente claros para decidir si reintentar, cancelar o escalar a soporte.

## 12. Compatibilidad y extensibilidad

- El sistema debe implementar los contratos EFT requeridos por LS Central y los contratos OPT necesarios para compatibilidad interna.
- Los puntos de extension propios deben publicarse mediante `OPT POS Transaction Events` cuando el flujo POS necesite desacoplar personalizaciones.
- Los subscribers deben respetar el publicador correcto de eventos LS/OPT para evitar flujos no ejecutados.
- Cambios en interfaces EFT, token, referenced returns o printer deben revisarse como cambios de alto impacto.

## 13. Seguridad y datos sensibles

- Las credenciales de tecnico y anulacion deben tratarse como datos sensibles.
- Los numeros de tarjeta no deben mostrarse completos en impresiones ni mensajes operativos.
- El sistema debe evitar registrar mas datos sensibles de los necesarios para auditoria y conciliacion.
- El acceso a configuracion, bitacora y codeunits principales debe controlarse mediante el permissionset `Lafise`.

## 14. Requerimientos de calidad y mantenimiento

- Todo cambio en archivos `.al` debe aplicar la skill local `al-alto-nivel`.
- Todo cambio solicitado debe registrarse en `bitacora_cambios.md`.
- Cuando se descubran nuevas reglas de negocio, `requerimientos.md` debe actualizarse en la misma sesion o dejarse como pendiente explicito en la bitacora.
- Cambios en `ConnectCom` deben considerarse de alto impacto porque afectan venta, void, refund, settle, reportes, parseo, persistencia y mensajes POS.
- Cambios en `OPT POS Transaction Impl` deben ser minimos y trazables por su alto acoplamiento con el flujo LS Central POS.
- Antes de cerrar cambios funcionales se debe validar, como minimo, venta aprobada, venta rechazada, anulacion, refund, settle, reporte y fallo de comunicacion.

## 15. Pendientes de definicion

- Confirmar codigos LAFISE definitivos para `id`, `claIDTran`, `ReportType` y tipos de transaccion.
- Definir matriz oficial de errores LAFISE/pinpad y mensajes esperados para operador.
- Precisar reglas de anulacion: si aplica solo transaccion del dia, requisitos de recibo original, credenciales y escenarios de anulacion parcial.
- Precisar reglas de refund: con referencia, sin referencia, moneda, monto maximo y relacion con recibo original.
- Definir criterios de conciliacion entre `Trans. LAF`, cierre LAFISE y ventas posteadas LS Central.
- Definir suites de prueba automatizada o checklist manual por version liberada.
