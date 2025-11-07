import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding reclamos...');

  // Obtener el usuario administrador
  const admin = await prisma.usuario.findFirst({
    where: { email: 'admin@reclamos.com' },
  });

  if (!admin) {
    throw new Error('Admin user not found');
  }

  // Crear reclamos de ejemplo
  const reclamos = [
    {
      numero_reclamo: '2025-001',
      titulo: 'Internet intermitente',
      descripcion:
        'El servicio de internet presenta cortes frecuentes durante las últimas 48 horas',
      estado: 'ABIERTO',
      prioridad: 'ALTA',
      categoria: 'INTERNET_FIBRA',
      tipo_servicio: 'RESIDENCIAL',
      direccion: 'Av. Principal 123',
      telefono_contacto: '123456789',
      id_profesional: admin.id,
    },
    {
      numero_reclamo: '2025-002',
      titulo: 'Sin tono en línea telefónica',
      descripcion: 'La línea telefónica no tiene tono desde esta mañana',
      estado: 'ASIGNADO',
      prioridad: 'MEDIA',
      categoria: 'TELEFONO_FIBRA',
      tipo_servicio: 'RESIDENCIAL',
      direccion: 'Calle Secundaria 456',
      telefono_contacto: '987654321',
      id_profesional: admin.id,
    },
    {
      numero_reclamo: '2025-003',
      titulo: 'Canales de TV sin señal',
      descripcion: 'Varios canales premium no tienen señal',
      estado: 'EN_CURSO',
      prioridad: 'BAJA',
      categoria: 'TV_SENSA',
      tipo_servicio: 'RESIDENCIAL',
      direccion: 'Pasaje Los Álamos 789',
      telefono_contacto: '456789123',
      id_profesional: admin.id,
    },
    {
      numero_reclamo: '2025-004',
      titulo: 'Velocidad de internet reducida',
      descripcion:
        'La velocidad contratada es de 100Mbps pero solo llegan 20Mbps',
      estado: 'EN_REVISION',
      prioridad: 'MEDIA',
      categoria: 'INTERNET_ADSL',
      tipo_servicio: 'EMPRESARIAL',
      direccion: 'Av. Empresarial 1000',
      telefono_contacto: '111222333',
      id_profesional: admin.id,
    },
    {
      numero_reclamo: '2025-005',
      titulo: 'Router sin conexión',
      descripcion: 'El router no enciende, se intentó reset sin resultado',
      estado: 'CERRADO',
      prioridad: 'URGENTE',
      categoria: 'INTERNET_FIBRA',
      tipo_servicio: 'RESIDENCIAL',
      direccion: 'Calle Mayor 234',
      telefono_contacto: '555666777',
      id_profesional: admin.id,
      fecha_cierre: new Date(),
    },
  ];

  for (const reclamo of reclamos) {
    await prisma.reclamo.create({
      data: reclamo,
    });
  }

  console.log('✅ Reclamos creados exitosamente');
}

main()
  .catch((e) => {
    console.error('Error seeding:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
