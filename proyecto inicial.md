Como DBA, aquí está el análisis completo del sistema de renta de carros, con las entidades necesarias y su estructura relacional.

---

**Entidades del sistema**

El sistema requiere 10 entidades principales agrupadas en tres dominios:

**Operaciones:** `cliente`, `reserva`, `contrato_renta`, `pago`
**Flota:** `vehiculo`, `categoria`, `mantenimiento`
**Organización:** `sucursal`, `empleado`, `seguro`

<img width="798" height="712" alt="image" src="https://github.com/user-attachments/assets/d2611860-58a8-4c1d-8c8b-b80d77131563" />
<img width="167" height="504" alt="image" src="https://github.com/user-attachments/assets/ae6222cf-7fca-4946-99cb-a03711900aa2" />



------

**Descripción de las tablas**

**Flota de vehículos**
- `categoria` — agrupa los vehículos por tipo (compacto, SUV, lujo, etc.) y define la tarifa base por día y el depósito requerido.
- `vehiculo` — el activo central del negocio. El campo `estado` es un `ENUM('disponible', 'rentado', 'mantenimiento', 'inactivo')`.
- `seguro` — cada vehículo puede tener histórico de pólizas; la activa es la que tiene `fecha_fin` mayor a hoy.
- `mantenimiento` — registra historial de servicios, con `km_siguiente` para programar el próximo.

**Operación**
- `reserva` — captura la intención de renta. Permite reservar en una sucursal y devolver en otra (`id_sucursal_recogida` ≠ `id_sucursal_entrega`). Estado: `pendiente / confirmada / cancelada / completada`.
- `contrato_renta` — se genera al momento de la entrega física del vehículo. Registra kilómetros de salida/entrada para calcular cargos extra por distancia.
- `pago` — soporta pagos parciales (anticipo + liquidación). Métodos: `efectivo / tarjeta / transferencia`. Estado: `pendiente / aprobado / reembolsado`.

**Organización**
- `sucursal` — cada punto de operación donde se recogen y devuelven vehículos.
- `empleado` — asignado a una sucursal; gestiona contratos y mantenimientos.
- `cliente` — incluye el número de licencia y su fecha de vencimiento, dato crítico para validaciones legales.

---

<img width="705" height="665" alt="image" src="https://github.com/user-attachments/assets/a5786a57-354f-41e9-ba2a-359adfeebf6e" />
<img width="780" height="667" alt="image" src="https://github.com/user-attachments/assets/ce48e608-9d12-43a2-8108-976db09257d1" />


**Notas de diseño DBA**

- El campo `km_salida` / `km_entrada` en `contrato_renta` permite calcular cargos por exceso de kilometraje sin depender de registros externos.
- La relación `RESERVA ||--|| CONTRATO_RENTA` es uno a uno: una reserva genera exactamente un contrato al concretarse.
- Se recomienda un índice compuesto en `vehiculo(estado, id_sucursal)` para acelerar la búsqueda de unidades disponibles por sucursal.
- La tabla `pago` está separada de `contrato_renta` para soportar esquemas de pago en cuotas y reembolsos parciales.

¿Quieres que profundice en alguna entidad, genere los scripts DDL en SQL, o diseñe las validaciones y restricciones de negocio?
