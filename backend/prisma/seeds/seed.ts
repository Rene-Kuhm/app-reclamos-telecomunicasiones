import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Iniciando seed de base de datos...');

  // Limpiar datos existentes
  console.log('🗑️  Limpiando datos existentes...');
  await prisma.auditoriaReclamo.deleteMany();
  await prisma.archivo.deleteMany();
  await prisma.comentario.deleteMany();
  await prisma.notificacion.deleteMany();
  await prisma.reclamo.deleteMany();
  await prisma.refreshToken.deleteMany();
  await prisma.sesion.deleteMany();
  await prisma.usuario.deleteMany();

  // 1. CREAR USUARIOS
  console.log('👤 Creando usuarios...');

  const hashedPassword = await bcrypt.hash('Password123!', 10);

  // 1 Admin
  const admin = await prisma.usuario.create({
    data: {
      email: 'admin@reclamos.com',
      password_hash: hashedPassword,
      nombre: 'Administrador',
      apellido: 'Sistema',
      telefono: '1234567890',
      rol: 'ADMINISTRADOR',
      activo: true,
      email_verificado: true,
    },
  });
  console.log(`✅ Admin creado: ${admin.email}`);

  // 1 Supervisor
  const supervisor = await prisma.usuario.create({
    data: {
      email: 'supervisor@reclamos.com',
      password_hash: hashedPassword,
      nombre: 'María',
      apellido: 'González',
      telefono: '1234567891',
      rol: 'SUPERVISOR',
      activo: true,
      email_verificado: true,
    },
  });
  console.log(`✅ Supervisor creado: ${supervisor.email}`);

  // 2 Técnicos
  const tecnico1 = await prisma.usuario.create({
    data: {
      email: 'tecnico1@reclamos.com',
      password_hash: hashedPassword,
      nombre: 'Juan',
      apellido: 'Pérez',
      telefono: '1234567892',
      rol: 'TECNICO',
      activo: true,
      email_verificado: true,
    },
  });
  console.log(`✅ Técnico 1 creado: ${tecnico1.email}`);

  const tecnico2 = await prisma.usuario.create({
    data: {
      email: 'tecnico2@reclamos.com',
      password_hash: hashedPassword,
      nombre: 'Carlos',
      apellido: 'Ramírez',
      telefono: '1234567893',
      rol: 'TECNICO',
      activo: true,
      email_verificado: true,
    },
  });
  console.log(`✅ Técnico 2 creado: ${tecnico2.email}`);

  // 3 Profesionales
  const profesional1 = await prisma.usuario.create({
    data: {
      email: 'profesional1@reclamos.com',
      password_hash: hashedPassword,
      nombre: 'Ana',
      apellido: 'Martínez',
      telefono: '1234567894',
      rol: 'PROFESIONAL',
      activo: true,
      email_verificado: true,
    },
  });
  console.log(`✅ Profesional 1 creado: ${profesional1.email}`);

  const profesional2 = await prisma.usuario.create({
    data: {
      email: 'profesional2@reclamos.com',
      password_hash: hashedPassword,
      nombre: 'Luis',
      apellido: 'Fernández',
      telefono: '1234567895',
      rol: 'PROFESIONAL',
      activo: true,
      email_verificado: true,
    },
  });
  console.log(`✅ Profesional 2 creado: ${profesional2.email}`);

  const profesional3 = await prisma.usuario.create({
    data: {
      email: 'profesional3@reclamos.com',
      password_hash: hashedPassword,
      nombre: 'Laura',
      apellido: 'Sánchez',
      telefono: '1234567896',
      rol: 'PROFESIONAL',
      activo: true,
      email_verificado: true,
    },
  });
  console.log(`✅ Profesional 3 creado: ${profesional3.email}`);

  // 2. CREAR RECLAMOS
  console.log('📋 Creando reclamos...');

  // Reclamo 1: Internet sin servicio (ABIERTO)
  const reclamo1 = await prisma.reclamo.create({
    data: {
      numero_reclamo: 'RCL-2024-00001',
      titulo: 'Sin servicio de internet desde ayer',
      descripcion: 'El servicio de internet está completamente caído desde ayer por la tarde. No hay luces en el módem.',
      estado: 'ABIERTO',
      prioridad: 'ALTA',
      categoria: 'INTERNET_FIBRA',
      direccion: 'Av. Principal 123, Ciudad',
      id_profesional: profesional1.id,
      fecha_creacion: new Date(),
    },
  });
  console.log(`✅ Reclamo 1 creado: ${reclamo1.numero_reclamo}`);

  // Crear auditoría para reclamo 1
  await prisma.auditoriaReclamo.create({
    data: {
      reclamo_id: reclamo1.id,
      usuario_id: profesional1.id,
      accion: 'CREADO',
      estado_nuevo: 'ABIERTO',
      campos_cambiados: JSON.stringify({ accion: 'Reclamo creado' }),
    },
  });

  // Reclamo 2: Velocidad lenta (ASIGNADO a Técnico 1)
  const reclamo2 = await prisma.reclamo.create({
    data: {
      numero_reclamo: 'RCL-2024-00002',
      titulo: 'Velocidad de internet muy lenta',
      descripcion: 'La velocidad de descarga es de 5 Mbps cuando debería ser de 100 Mbps según el plan contratado.',
      estado: 'ASIGNADO',
      prioridad: 'MEDIA',
      categoria: 'INTERNET_FIBRA',
      direccion: 'Calle Secundaria 456, Ciudad',
      id_profesional: profesional2.id,
      id_tecnico_asignado: tecnico1.id,
      fecha_creacion: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // Hace 2 días
      fecha_asignacion: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000), // Hace 1 día
    },
  });
  console.log(`✅ Reclamo 2 creado: ${reclamo2.numero_reclamo}`);

  // Crear auditorías para reclamo 2
  await prisma.auditoriaReclamo.create({
    data: {
      reclamo_id: reclamo2.id,
      usuario_id: profesional2.id,
      accion: 'CREADO',
      estado_nuevo: 'ABIERTO',
    },
  });

  await prisma.auditoriaReclamo.create({
    data: {
      reclamo_id: reclamo2.id,
      usuario_id: supervisor.id,
      accion: 'ASIGNADO',
      estado_anterior: 'ABIERTO',
      estado_nuevo: 'ASIGNADO',
      campos_cambiados: JSON.stringify({ tecnico: tecnico1.email }),
    },
  });

  // Comentario en reclamo 2
  await prisma.comentario.create({
    data: {
      reclamo_id: reclamo2.id,
      usuario_id: tecnico1.id,
      contenido: 'He revisado el caso. Voy a realizar pruebas de velocidad en el sitio mañana.',
    },
  });

  // Reclamo 3: Telefono con ruido (EN_CURSO, Técnico 2)
  const reclamo3 = await prisma.reclamo.create({
    data: {
      numero_reclamo: 'RCL-2024-00003',
      titulo: 'Línea telefónica con interferencia',
      descripcion: 'Se escucha mucho ruido y cortes en las llamadas telefónicas.',
      estado: 'EN_CURSO',
      prioridad: 'MEDIA',
      categoria: 'TELEFONO_FIBRA',
      direccion: 'Barrio Norte 789, Ciudad',
      id_profesional: profesional3.id,
      id_tecnico_asignado: tecnico2.id,
      fecha_creacion: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000), // Hace 3 días
      fecha_asignacion: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // Hace 2 días
      fecha_inicio_trabajo: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000), // Hace 1 día
    },
  });
  console.log(`✅ Reclamo 3 creado: ${reclamo3.numero_reclamo}`);

  await prisma.auditoriaReclamo.create({
    data: {
      reclamo_id: reclamo3.id,
      usuario_id: profesional3.id,
      accion: 'CREADO',
      estado_nuevo: 'ABIERTO',
    },
  });

  await prisma.auditoriaReclamo.create({
    data: {
      reclamo_id: reclamo3.id,
      usuario_id: tecnico2.id,
      accion: 'INICIADO',
      estado_anterior: 'ASIGNADO',
      estado_nuevo: 'EN_CURSO',
    },
  });

  // Comentarios en reclamo 3
  await prisma.comentario.create({
    data: {
      reclamo_id: reclamo3.id,
      usuario_id: tecnico2.id,
      contenido: 'Revisé la línea telefónica. Encontré conexión suelta en el splitter.',
    },
  });

  await prisma.comentario.create({
    data: {
      reclamo_id: reclamo3.id,
      usuario_id: profesional3.id,
      contenido: '¿Cuándo estará solucionado?',
    },
  });

  await prisma.comentario.create({
    data: {
      reclamo_id: reclamo3.id,
      usuario_id: tecnico2.id,
      contenido: 'Estoy reemplazando el splitter. Debería estar listo en 1 hora.',
    },
  });

  // Reclamo 4: TV sin señal (CERRADO)
  const reclamo4 = await prisma.reclamo.create({
    data: {
      numero_reclamo: 'RCL-2024-00004',
      titulo: 'Canales de TV sin señal',
      descripcion: 'Varios canales no tienen señal. Solo se ve pantalla negra.',
      estado: 'CERRADO',
      prioridad: 'BAJA',
      categoria: 'TV_SENSA',
      direccion: 'Av. Libertad 321, Ciudad',
      id_profesional: profesional1.id,
      id_tecnico_asignado: tecnico1.id,
      fecha_creacion: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // Hace 7 días
      fecha_asignacion: new Date(Date.now() - 6 * 24 * 60 * 60 * 1000),
      fecha_inicio_trabajo: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
      fecha_resolucion: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000),
      fecha_cierre: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000),
      notas_resolucion: 'Se reconfiguraron los canales en el decodificador. Problema resuelto.',
      calificacion: 5,
      comentario_calificacion: 'Excelente servicio. Muy rápido.',
    },
  });
  console.log(`✅ Reclamo 4 creado: ${reclamo4.numero_reclamo}`);

  // Reclamo 5: ADSL intermitente (EN_REVISION)
  const reclamo5 = await prisma.reclamo.create({
    data: {
      numero_reclamo: 'RCL-2024-00005',
      titulo: 'Conexión ADSL intermitente',
      descripcion: 'La conexión se cae cada 10-15 minutos. Debo reiniciar el módem constantemente.',
      estado: 'EN_REVISION',
      prioridad: 'ALTA',
      categoria: 'INTERNET_ADSL',
      direccion: 'Zona Rural, Km 15',
      id_profesional: profesional2.id,
      id_tecnico_asignado: tecnico2.id,
      fecha_creacion: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000),
      fecha_asignacion: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
      fecha_inicio_trabajo: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
      fecha_resolucion: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000),
      notas_resolucion: 'Reemplacé el módem y verifiqué la línea telefónica. Todo funcionando correctamente.',
    },
  });
  console.log(`✅ Reclamo 5 creado: ${reclamo5.numero_reclamo}`);

  // 3. CREAR NOTIFICACIONES
  console.log('🔔 Creando notificaciones...');

  await prisma.notificacion.createMany({
    data: [
      {
        usuario_id: profesional1.id,
        reclamo_id: reclamo1.id,
        tipo: 'PUSH',
        estado: 'ENVIADA',
        titulo: 'Reclamo creado',
        mensaje: `Tu reclamo ${reclamo1.numero_reclamo} ha sido registrado correctamente.`,
        enviada_at: new Date(),
      },
      {
        usuario_id: profesional2.id,
        reclamo_id: reclamo2.id,
        tipo: 'EMAIL',
        estado: 'ENTREGADA',
        titulo: 'Reclamo asignado',
        mensaje: `Tu reclamo ${reclamo2.numero_reclamo} ha sido asignado al técnico ${tecnico1.nombre}.`,
        enviada_at: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000),
        entregada_at: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000),
      },
      {
        usuario_id: profesional3.id,
        reclamo_id: reclamo3.id,
        tipo: 'PUSH',
        estado: 'LEIDA',
        titulo: 'Técnico en camino',
        mensaje: `El técnico ${tecnico2.nombre} está trabajando en tu reclamo.`,
        enviada_at: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000),
        entregada_at: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000),
        leida_at: new Date(Date.now() - 12 * 60 * 60 * 1000),
      },
      {
        usuario_id: profesional1.id,
        reclamo_id: reclamo4.id,
        tipo: 'EMAIL',
        estado: 'LEIDA',
        titulo: 'Reclamo resuelto',
        mensaje: `Tu reclamo ${reclamo4.numero_reclamo} ha sido resuelto. Por favor califica el servicio.`,
        enviada_at: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000),
        entregada_at: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000),
        leida_at: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000),
      },
    ],
  });
  console.log('✅ Notificaciones creadas');

  console.log('');
  console.log('✨ Seed completado exitosamente!');
  console.log('');
  console.log('📊 Resumen:');
  console.log(`   - ${await prisma.usuario.count()} usuarios creados`);
  console.log(`   - ${await prisma.reclamo.count()} reclamos creados`);
  console.log(`   - ${await prisma.comentario.count()} comentarios creados`);
  console.log(`   - ${await prisma.notificacion.count()} notificaciones creadas`);
  console.log(`   - ${await prisma.auditoriaReclamo.count()} auditorías creadas`);
  console.log('');
  console.log('🔑 Credenciales de acceso:');
  console.log('   Email: admin@reclamos.com');
  console.log('   Email: supervisor@reclamos.com');
  console.log('   Email: tecnico1@reclamos.com');
  console.log('   Email: tecnico2@reclamos.com');
  console.log('   Email: profesional1@reclamos.com');
  console.log('   Email: profesional2@reclamos.com');
  console.log('   Email: profesional3@reclamos.com');
  console.log('   Password para todos: Password123!');
  console.log('');
}

main()
  .catch((e) => {
    console.error('❌ Error en seed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
