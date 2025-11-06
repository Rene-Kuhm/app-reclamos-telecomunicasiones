import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Iniciando seed de base de datos...');

  // Limpiar datos existentes (opcional - comentar si no deseas limpiar)
  console.log('🗑️  Limpiando datos existentes...');
  await prisma.auditoria.deleteMany();
  await prisma.archivo.deleteMany();
  await prisma.comentario.deleteMany();
  await prisma.notificacion.deleteMany();
  await prisma.preferenciaNotificacion.deleteMany();
  await prisma.reclamo.deleteMany();
  await prisma.usuario.deleteMany();

  // 1. CREAR USUARIOS
  console.log('👤 Creando usuarios...');

  const hashedPassword = await bcrypt.hash('Password123!', 12);

  // 1 Admin
  const admin = await prisma.usuario.create({
    data: {
      email: 'admin@reclamos.com',
      password: hashedPassword,
      nombre: 'Administrador',
      apellido: 'Sistema',
      telefono: '+595981000001',
      dni: '1000001',
      direccion: 'Oficina Central',
      rol: 'ADMINISTRADOR',
      estado: 'ACTIVO',
      notificacionesEnabled: true,
    },
  });
  console.log(`✅ Admin creado: ${admin.email}`);

  // 1 Supervisor
  const supervisor = await prisma.usuario.create({
    data: {
      email: 'supervisor@reclamos.com',
      password: hashedPassword,
      nombre: 'María',
      apellido: 'González',
      telefono: '+595981000002',
      dni: '2000001',
      direccion: 'Av. España 123',
      rol: 'SUPERVISOR',
      estado: 'ACTIVO',
      notificacionesEnabled: true,
    },
  });
  console.log(`✅ Supervisor creado: ${supervisor.email}`);

  // 2 Técnicos
  const tecnico1 = await prisma.usuario.create({
    data: {
      email: 'tecnico1@reclamos.com',
      password: hashedPassword,
      nombre: 'Juan',
      apellido: 'Pérez',
      telefono: '+595981000003',
      dni: '3000001',
      direccion: 'Barrio San Vicente',
      rol: 'TECNICO',
      estado: 'ACTIVO',
      notificacionesEnabled: true,
    },
  });
  console.log(`✅ Técnico 1 creado: ${tecnico1.email}`);

  const tecnico2 = await prisma.usuario.create({
    data: {
      email: 'tecnico2@reclamos.com',
      password: hashedPassword,
      nombre: 'Carlos',
      apellido: 'Martínez',
      telefono: '+595981000004',
      dni: '3000002',
      direccion: 'Barrio Trinidad',
      rol: 'TECNICO',
      estado: 'ACTIVO',
      notificacionesEnabled: true,
    },
  });
  console.log(`✅ Técnico 2 creado: ${tecnico2.email}`);

  // 3 Profesionales (clientes)
  const profesional1 = await prisma.usuario.create({
    data: {
      email: 'cliente1@example.com',
      password: hashedPassword,
      nombre: 'Ana',
      apellido: 'López',
      telefono: '+595981000005',
      dni: '4000001',
      direccion: 'Av. Mariscal López 456',
      rol: 'PROFESIONAL',
      estado: 'ACTIVO',
      notificacionesEnabled: true,
    },
  });
  console.log(`✅ Profesional 1 creado: ${profesional1.email}`);

  const profesional2 = await prisma.usuario.create({
    data: {
      email: 'cliente2@example.com',
      password: hashedPassword,
      nombre: 'Luis',
      apellido: 'Ramírez',
      telefono: '+595981000006',
      dni: '4000002',
      direccion: 'Av. Eusebio Ayala 789',
      rol: 'PROFESIONAL',
      estado: 'ACTIVO',
      notificacionesEnabled: true,
    },
  });
  console.log(`✅ Profesional 2 creado: ${profesional2.email}`);

  const profesional3 = await prisma.usuario.create({
    data: {
      email: 'cliente3@example.com',
      password: hashedPassword,
      nombre: 'Patricia',
      apellido: 'Benítez',
      telefono: '+595981000007',
      dni: '4000003',
      direccion: 'Fernando de la Mora',
      rol: 'PROFESIONAL',
      estado: 'ACTIVO',
      notificacionesEnabled: true,
    },
  });
  console.log(`✅ Profesional 3 creado: ${profesional3.email}`);

  // 2. CREAR RECLAMOS
  console.log('📋 Creando reclamos...');

  // Reclamo 1: ABIERTO (sin asignar)
  const reclamo1 = await prisma.reclamo.create({
    data: {
      codigo: 'RCL-2501-0001',
      titulo: 'Internet sin conexión desde hace 2 días',
      descripcion:
        'No tengo acceso a internet desde el lunes. El modem parpadea la luz roja. Ya reinicié el equipo varias veces sin éxito.',
      tipo: 'TECNICO',
      tipoServicio: 'INTERNET_FIBRA',
      prioridad: 'ALTA',
      estado: 'ABIERTO',
      direccion: 'Av. Mariscal López 456, Asunción',
      latitud: -25.2637,
      longitud: -57.5759,
      infoContacto: {
        telefonoAlternativo: '+595981000099',
        horariosDisponibles: 'Lunes a Viernes 8-17hs',
      },
      fechaLimite: new Date(Date.now() + 24 * 60 * 60 * 1000), // 24 horas
      profesionalId: profesional1.id,
    },
  });
  console.log(`✅ Reclamo creado: ${reclamo1.codigo} - ${reclamo1.estado}`);

  // Auditoría de creación
  await prisma.auditoria.create({
    data: {
      reclamoId: reclamo1.id,
      usuarioId: profesional1.id,
      tipo: 'CREACION',
      descripcion: 'Reclamo creado',
      detalles: {
        codigo: reclamo1.codigo,
        tipo: reclamo1.tipo,
        prioridad: reclamo1.prioridad,
      },
    },
  });

  // Reclamo 2: ASIGNADO
  const reclamo2 = await prisma.reclamo.create({
    data: {
      codigo: 'RCL-2501-0002',
      titulo: 'Baja velocidad de internet',
      descripcion:
        'Contraté el plan de 100 Mbps pero solo llegan 20 Mbps. Ya hice pruebas con varios dispositivos y el resultado es el mismo.',
      tipo: 'TECNICO',
      tipoServicio: 'INTERNET_ADSL',
      prioridad: 'MEDIA',
      estado: 'ASIGNADO',
      direccion: 'Av. Eusebio Ayala 789, Asunción',
      latitud: -25.2817,
      longitud: -57.6366,
      fechaLimite: new Date(Date.now() + 48 * 60 * 60 * 1000), // 48 horas
      profesionalId: profesional2.id,
      tecnicoAsignadoId: tecnico1.id,
      notasInternas: 'Revisar configuración del modem y velocidad en el nodo',
    },
  });
  console.log(`✅ Reclamo creado: ${reclamo2.codigo} - ${reclamo2.estado}`);

  await prisma.auditoria.createMany({
    data: [
      {
        reclamoId: reclamo2.id,
        usuarioId: profesional2.id,
        tipo: 'CREACION',
        descripcion: 'Reclamo creado',
      },
      {
        reclamoId: reclamo2.id,
        usuarioId: supervisor.id,
        tipo: 'ASIGNACION',
        descripcion: `Reclamo asignado a ${tecnico1.nombre} ${tecnico1.apellido}`,
        detalles: {
          tecnicoId: tecnico1.id,
          tecnicoNombre: `${tecnico1.nombre} ${tecnico1.apellido}`,
        },
      },
    ],
  });

  // Comentario en reclamo 2
  await prisma.comentario.create({
    data: {
      reclamoId: reclamo2.id,
      usuarioId: tecnico1.id,
      contenido:
        'He revisado el caso. Voy a programar una visita para mañana a las 10:00 AM.',
      interno: false,
    },
  });

  // Reclamo 3: EN_CURSO
  const reclamo3 = await prisma.reclamo.create({
    data: {
      codigo: 'RCL-2501-0003',
      titulo: 'Problema con TV Sensa - canales con interferencia',
      descripcion:
        'Los canales HD se ven con interferencia y se cortan constantemente. Los canales SD funcionan normalmente.',
      tipo: 'TECNICO',
      tipoServicio: 'TV_SENSA',
      prioridad: 'MEDIA',
      estado: 'EN_CURSO',
      direccion: 'Fernando de la Mora, Zona Norte',
      latitud: -25.3374,
      longitud: -57.5447,
      fechaLimite: new Date(Date.now() + 48 * 60 * 60 * 1000), // 48 horas
      profesionalId: profesional3.id,
      tecnicoAsignadoId: tecnico2.id,
    },
  });
  console.log(`✅ Reclamo creado: ${reclamo3.codigo} - ${reclamo3.estado}`);

  await prisma.auditoria.createMany({
    data: [
      {
        reclamoId: reclamo3.id,
        usuarioId: profesional3.id,
        tipo: 'CREACION',
        descripcion: 'Reclamo creado',
      },
      {
        reclamoId: reclamo3.id,
        usuarioId: supervisor.id,
        tipo: 'ASIGNACION',
        descripcion: `Reclamo asignado a ${tecnico2.nombre} ${tecnico2.apellido}`,
      },
      {
        reclamoId: reclamo3.id,
        usuarioId: tecnico2.id,
        tipo: 'CAMBIO_ESTADO',
        descripcion: 'Estado cambiado de ASIGNADO a EN_CURSO',
        detalles: {
          estadoAnterior: 'ASIGNADO',
          estadoNuevo: 'EN_CURSO',
        },
      },
    ],
  });

  await prisma.comentario.createMany({
    data: [
      {
        reclamoId: reclamo3.id,
        usuarioId: tecnico2.id,
        contenido:
          'Estoy en camino al domicilio. Llego en 15 minutos aproximadamente.',
        interno: false,
      },
      {
        reclamoId: reclamo3.id,
        usuarioId: tecnico2.id,
        contenido:
          'Detectado problema en el splitter. Procediendo con el reemplazo.',
        interno: true,
      },
    ],
  });

  // Reclamo 4: EN_REVISION
  const reclamo4 = await prisma.reclamo.create({
    data: {
      codigo: 'RCL-2501-0004',
      titulo: 'Consulta sobre facturación - cobro duplicado',
      descripcion:
        'Me llegaron dos facturas por el mismo mes. Una de $450.000 y otra de $480.000. Necesito aclaración urgente.',
      tipo: 'FACTURACION',
      tipoServicio: 'INTERNET_FIBRA',
      prioridad: 'ALTA',
      estado: 'EN_REVISION',
      direccion: 'Luque, Barrio San Antonio',
      fechaLimite: new Date(Date.now() + 24 * 60 * 60 * 1000), // 24 horas
      profesionalId: profesional1.id,
      tecnicoAsignadoId: supervisor.id, // El supervisor gestiona facturación
      notasInternas:
        'Revisar sistema de facturación. Posible error en el sistema.',
    },
  });
  console.log(`✅ Reclamo creado: ${reclamo4.codigo} - ${reclamo4.estado}`);

  await prisma.auditoria.createMany({
    data: [
      {
        reclamoId: reclamo4.id,
        usuarioId: profesional1.id,
        tipo: 'CREACION',
        descripcion: 'Reclamo creado',
      },
      {
        reclamoId: reclamo4.id,
        usuarioId: admin.id,
        tipo: 'ASIGNACION',
        descripcion: `Reclamo asignado a ${supervisor.nombre} ${supervisor.apellido}`,
      },
      {
        reclamoId: reclamo4.id,
        usuarioId: supervisor.id,
        tipo: 'CAMBIO_ESTADO',
        descripcion: 'Estado cambiado de EN_CURSO a EN_REVISION',
      },
    ],
  });

  // Reclamo 5: CERRADO
  const reclamo5 = await prisma.reclamo.create({
    data: {
      codigo: 'RCL-2501-0005',
      titulo: 'Solicitud de instalación de nuevo servicio',
      descripcion:
        'Quiero contratar el servicio de internet fibra 200 Mbps para mi nuevo domicilio.',
      tipo: 'INSTALACION',
      tipoServicio: 'INTERNET_FIBRA',
      prioridad: 'BAJA',
      estado: 'CERRADO',
      direccion: 'San Lorenzo, Barrio Virgen del Rosario',
      fechaLimite: new Date(Date.now() - 24 * 60 * 60 * 1000), // Ya pasó
      fechaCierre: new Date(),
      profesionalId: profesional2.id,
      tecnicoAsignadoId: tecnico1.id,
      solucion:
        'Instalación completada exitosamente. Servicio activado y funcionando correctamente.',
      notasFinales: 'Cliente satisfecho con el servicio',
    },
  });
  console.log(`✅ Reclamo creado: ${reclamo5.codigo} - ${reclamo5.estado}`);

  await prisma.auditoria.createMany({
    data: [
      {
        reclamoId: reclamo5.id,
        usuarioId: profesional2.id,
        tipo: 'CREACION',
        descripcion: 'Reclamo creado',
      },
      {
        reclamoId: reclamo5.id,
        usuarioId: supervisor.id,
        tipo: 'ASIGNACION',
        descripcion: `Reclamo asignado a ${tecnico1.nombre} ${tecnico1.apellido}`,
      },
      {
        reclamoId: reclamo5.id,
        usuarioId: tecnico1.id,
        tipo: 'CAMBIO_ESTADO',
        descripcion: 'Estado cambiado de ASIGNADO a EN_CURSO',
      },
      {
        reclamoId: reclamo5.id,
        usuarioId: supervisor.id,
        tipo: 'CIERRE',
        descripcion: 'Reclamo cerrado',
        detalles: {
          solucion: reclamo5.solucion,
        },
      },
    ],
  });

  // 3. CREAR NOTIFICACIONES
  console.log('🔔 Creando notificaciones de ejemplo...');

  await prisma.notificacion.createMany({
    data: [
      {
        usuarioId: profesional1.id,
        tipo: 'NUEVO_RECLAMO',
        titulo: 'Reclamo creado exitosamente',
        mensaje: `Tu reclamo ${reclamo1.codigo} ha sido creado y está siendo procesado.`,
        reclamoId: reclamo1.id,
        leida: false,
      },
      {
        usuarioId: profesional2.id,
        tipo: 'RECLAMO_ASIGNADO',
        titulo: 'Técnico asignado a tu reclamo',
        mensaje: `El técnico ${tecnico1.nombre} ${tecnico1.apellido} ha sido asignado a tu reclamo ${reclamo2.codigo}.`,
        reclamoId: reclamo2.id,
        leida: false,
      },
      {
        usuarioId: tecnico1.id,
        tipo: 'RECLAMO_ASIGNADO',
        titulo: 'Nuevo reclamo asignado',
        mensaje: `Se te ha asignado el reclamo ${reclamo2.codigo} - ${reclamo2.titulo}`,
        reclamoId: reclamo2.id,
        leida: false,
      },
      {
        usuarioId: profesional2.id,
        tipo: 'RECLAMO_CERRADO',
        titulo: 'Reclamo cerrado',
        mensaje: `Tu reclamo ${reclamo5.codigo} ha sido cerrado satisfactoriamente.`,
        reclamoId: reclamo5.id,
        leida: true,
        fechaLectura: new Date(),
      },
    ],
  });
  console.log('✅ Notificaciones creadas');

  // 4. CREAR PREFERENCIAS DE NOTIFICACIÓN
  console.log('⚙️  Configurando preferencias de notificación...');

  await prisma.preferenciaNotificacion.createMany({
    data: [
      {
        usuarioId: admin.id,
        canalEmail: true,
        canalPush: true,
        canalTelegram: false,
        tiposEmail: [
          'NUEVO_RECLAMO',
          'RECLAMO_ASIGNADO',
          'CAMBIO_ESTADO',
          'NUEVO_COMENTARIO',
          'RECLAMO_CERRADO',
        ],
        tiposPush: [
          'NUEVO_RECLAMO',
          'CAMBIO_ESTADO',
          'RECLAMO_CERRADO',
        ],
      },
      {
        usuarioId: supervisor.id,
        canalEmail: true,
        canalPush: true,
        canalTelegram: false,
        tiposEmail: [
          'NUEVO_RECLAMO',
          'RECLAMO_ASIGNADO',
          'CAMBIO_ESTADO',
          'RECLAMO_CERRADO',
        ],
        tiposPush: ['NUEVO_RECLAMO', 'CAMBIO_ESTADO'],
      },
      {
        usuarioId: tecnico1.id,
        canalEmail: true,
        canalPush: true,
        canalTelegram: false,
        tiposEmail: ['RECLAMO_ASIGNADO', 'NUEVO_COMENTARIO'],
        tiposPush: ['RECLAMO_ASIGNADO', 'NUEVO_COMENTARIO'],
      },
      {
        usuarioId: profesional1.id,
        canalEmail: true,
        canalPush: true,
        canalTelegram: false,
        tiposEmail: [
          'RECLAMO_ASIGNADO',
          'CAMBIO_ESTADO',
          'NUEVO_COMENTARIO',
          'RECLAMO_CERRADO',
        ],
        tiposPush: ['CAMBIO_ESTADO', 'NUEVO_COMENTARIO', 'RECLAMO_CERRADO'],
      },
    ],
  });
  console.log('✅ Preferencias de notificación configuradas');

  console.log('\n🎉 ¡Seed completado exitosamente!\n');
  console.log('📊 Resumen de datos creados:');
  console.log('  - 1 Administrador');
  console.log('  - 1 Supervisor');
  console.log('  - 2 Técnicos');
  console.log('  - 3 Profesionales (clientes)');
  console.log('  - 5 Reclamos (diferentes estados)');
  console.log('  - Comentarios, auditorías y notificaciones de ejemplo');
  console.log('\n🔐 Credenciales de acceso:');
  console.log('  Email: admin@reclamos.com | supervisor@reclamos.com');
  console.log('  Email: tecnico1@reclamos.com | tecnico2@reclamos.com');
  console.log('  Email: cliente1@example.com | cliente2@example.com | cliente3@example.com');
  console.log('  Password (todos): Password123!');
  console.log('');
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error('❌ Error durante el seed:', e);
    await prisma.$disconnect();
    process.exit(1);
  });