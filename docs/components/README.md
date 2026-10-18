<!-- managed by sa-skills:architecture-component-guardian — do not edit manually -->
[Architecture](../../ARCHITECTURE.md) > Components

# Component Details

Índice de los contenedores C4 de nivel 2 de Reservas de Salas Northwind. Los sistemas externos se documentan como descriptores de nivel 1, enlazados abajo.

## Reservas de Salas Northwind Components

### [Reservas de Salas Northwind](reservas-de-salas-northwind.md)

| # | Component | File | Type | Technology |
|---|-----------|------|------|------------|
| 5.1 | Portal de Reservas | [01-portal-de-reservas.md](reservas-de-salas-northwind/01-portal-de-reservas.md) | Web Application | [React 18, TypeScript] |
| 5.2 | Servicio de Reservas | [02-servicio-de-reservas.md](reservas-de-salas-northwind/02-servicio-de-reservas.md) | API Service | [Java 21, Spring Boot 3.3] |
| 5.3 | Base de Datos de Reservas | [03-base-de-datos-de-reservas.md](reservas-de-salas-northwind/03-base-de-datos-de-reservas.md) | Database | [PostgreSQL 16] |

### Sistemas externos

- [Proveedor de Identidad Northwind](proveedor-de-identidad-northwind.md)

## Key Relationships

- Portal de Reservas → Proveedor de Identidad Northwind · HTTPS/JSON [Auth]
- Portal de Reservas → Servicio de Reservas · HTTPS/JSON [Query]
- Servicio de Reservas → Proveedor de Identidad Northwind · HTTPS/JSON [Auth]
- Servicio de Reservas → Base de Datos de Reservas · JDBC/SQL [Data]

## Related Documentation

- [Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión](../01-system-overview.md)
- [Capas de Arquitectura](../03-architecture-layers.md)
- [Puntos de Integración](../05-integration-points.md)
- [Riesgos y Deuda Técnica](../10-risks-and-technical-debt.md)
