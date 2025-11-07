#!/usr/bin/env python3
"""Fix all field names in reclamos.service.ts to match PostgreSQL snake_case schema"""

import re

# Read the file
with open('src/modules/reclamos/reclamos.service.ts', 'r', encoding='utf-8') as f:
    content = f.read()

# Define replacements
replacements = [
    # Field names camelCase -> snake_case
    (r'\bprofesionalId\b', 'id_profesional'),
    (r'\btecnicoAsignadoId\b', 'id_tecnico_asignado'),
    (r'\btecnicoAsignado\b', 'tecnico_asignado'),
    (r'\bcreatedAt\b', 'created_at'),
    (r'\bupdatedAt\b', 'updated_at'),
    (r'\bdeletedAt\b', 'deleted_at'),
    (r'\bfechaLimite\b', 'sla_vencimiento'),
    (r'\bfechaCierre\b', 'fecha_cierre'),
    (r'\bnotasInternas\b', 'notas_resolucion'),
    (r'\bnotasFinales\b', 'notas_resolucion'),
    (r'\binfoContacto\b', 'metadata'),
    (r'\.codigo\b', '.numero_reclamo'),
    (r'\bcodigo:', 'numero_reclamo:'),
    (r'reclamo\.codigo', 'reclamo.numero_reclamo'),

    # Replace Role enum references
    (r'\bRole\.PROFESIONAL\b', 'RolUsuario.PROFESIONAL'),
    (r'\bRole\.TECNICO\b', 'RolUsuario.TECNICO'),
    (r'\bRole\.SUPERVISOR\b', 'RolUsuario.SUPERVISOR'),
    (r'\bRole\.ADMINISTRADOR\b', 'RolUsuario.ADMINISTRADOR'),
    (r'\bRole\b(?!\.)', 'string'),  # Replace standalone Role type with string

    # Fix generarCodigo method name
    (r'\bgenerarCodigo\b', 'generarNumeroReclamo'),

    # Remove non-existent fields
    (r'solucion:', 'notas_resolucion:'),
    (r'motivoRechazo:', 'notas_resolucion:'),
    (r'direccion: true,\s*', ''),  # Remove direccion from select

    # Fix tipo references (should be categoria)
    (r"by: \['tipo'\]", "by: ['categoria']"),
    (r'reclamosPorTipo', 'reclamosPorCategoria'),
    (r'curr\.tipo', 'curr.categoria'),

    # Fix TipoAuditoria references
    (r'TipoAuditoria\.', ''),
]

# Apply all replacements
for pattern, replacement in replacements:
    content = re.sub(pattern, replacement, content)

# Write the fixed content
with open('src/modules/reclamos/reclamos.service.ts', 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed reclamos.service.ts")
