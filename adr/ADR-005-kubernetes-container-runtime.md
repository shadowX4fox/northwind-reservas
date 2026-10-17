# ADR-005: Despliegue de servicios en el clúster Kubernetes de Plataforma Northwind

| Campo | Valor |
|-------|-------|
| **Estado** | Accepted |
| **Fecha** | 2026-03-02 |
| **Autores** | Equipo de Arquitectura Northwind |
| **Deciden** | Comité de Arquitectura Northwind |
| **Alcance** | Institucional |

## Contexto

Los servicios se desplegaban en máquinas virtuales configuradas a mano, con escalado manual y sin despliegues repetibles.

## Decisión

- Todo servicio backend se despliega como contenedor en el clúster Kubernetes de Plataforma Northwind, con al menos 2 réplicas en zonas distintas.
- Cada servicio declara solicitudes y límites de CPU y memoria, sondas de vida y de disponibilidad, y un escalado horizontal por CPU.
- Las aplicaciones web de una página se sirven como archivos estáticos desde el CDN de Plataforma Northwind, no desde el clúster.
- Los secretos (credenciales de base de datos) se inyectan desde el gestor de secretos del clúster; nunca en la imagen ni en el repositorio.
- El tráfico externo entra por el ingress del clúster con TLS 1.2 o superior.

## Justificación

- Despliegues repetibles y escalado automático sin operar máquinas.

## Consecuencias

- Cada servicio entrega un chart de Helm y una imagen firmada.

## Alternativas

| Alternativa | Motivo del descarte |
|-------------|---------------------|
| Máquinas virtuales | Escalado manual y configuración divergente |
| Funciones serverless | Arranque en frío incompatible con 2 s en p95 |
