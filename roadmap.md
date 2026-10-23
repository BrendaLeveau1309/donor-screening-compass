# Roadmap — NexoVital

## App móvil (src/routes/index.tsx)
- [x] Login fondo rojo, selector DNI/CE/Pasaporte, sin registro con Google
- [x] Registro: documento, nombres, correo, teléfono, grupo sanguíneo/Rh, contraseña, términos
- [x] Recuperar contraseña: teléfono/correo enmascarado → código 6 dígitos → reenviar → nueva contraseña
- [x] Donante: inicio con mapa y tarjeta de matching 1 min, seguimiento con línea de tiempo, cancelar proceso
- [x] Historial con pestañas Historial/Estadísticas (gráficos Hb, presión, pulso)
- [x] Solicitante: búsqueda por código con modal de confirmación, seguimiento por donante, historial
- [x] Menú lateral: notificaciones (3 interruptores), info, términos, privacidad, cancelar búsqueda

## Backoffice (src/routes/backoffice.tsx)
- [x] Login institucional con fondo rojo y recuperación de acceso
- [x] Admin: buscar establecimiento, activar/desactivar cuentas de personal y centros, registrar personal, CRUD de establecimientos
- [x] Hospital: tarjetas de panel, crear solicitud con código generado (modal), historial con filtros (código, estado, fecha) y detalle con donaciones
- [x] Proceso activo por etapas: identificación (código + DNI), tamizaje (Hb/presión/pulso), donación, validación final (resultado, aptitud, motivo, fechas) + historial del donante

## Pendiente
- [x] Mejorar botones de donación, cuestionario digital de ejemplo, motivos «Otro» y rechazo interno con citación confidencial (verificado en demostración: cierre sin extracción con motivo libre, rechazo con motivo interno y citación confidencial en el donante, sin exponer el motivo interno).
- [x] Unificar evaluación clínica y entrevista, retirar peso, mostrar cuestionario y permitir motivos libres con fin de exclusión opcional (verificado en demostración del cuestionario al historial, seguimiento y carnet).
- [x] Proceso clínico en 4 etapas, mensajes bioéticos en tracking e insignia de aptitud en carnet
- [ ] Añadir compatibilidad y rango al carnet y adaptar el acceso hospitalario a la referencia de Brenda.
- [x] Reemplazar carnet de Cuenta con lectura del perfil y compartir/copiar; actualizar métricas de bienvenida y etapas del proceso (verificado en demo; la cuenta de prueba no tiene perfil disponible).
- [ ] Renovar la app móvil con un diseño distintivo y compacto
- [x] Proceso hospitalario editable y persistente, compartido entre personal del mismo hospital
- [x] Donación realizada/no realizada y resultados en historial
- [x] Vigencia de solicitudes de 24 horas y métricas por estado
- [x] Actividad reciente sin detalles y búsqueda administrativa de solo lectura
- [x] Profesionalizar la presentación del acceso, app móvil y backoffice sin alterar los flujos
- [x] Inicio del backoffice sin botones de acción y con tarjeta de presentación roja (rol hospital y administrador)
- [x] Rediseño minimalista del backoffice: barra lateral roja degradada, fondo cálido, tarjetas con acentos de color y chips de estado
- [ ] Verificar el mapa de Google en la URL de vista previa (falla en localhost por restricción de dominio de la clave)
- [x] Conectar los flujos demo a la base de datos real: registro con perfil completo, login con correo en app y backoffice (rol institucional verificado), solicitudes creadas/listadas desde la nube, solicitud compatible en inicio del donante, búsqueda por código del solicitante, proceso de donación persistido (signos, estado final, aptitud del donante, unidades de la solicitud)
