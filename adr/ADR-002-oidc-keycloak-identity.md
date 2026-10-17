# ADR-002: Autenticación con OpenID Connect en Keycloak

| Campo | Valor |
|-------|-------|
| **Estado** | Accepted |
| **Fecha** | 2026-03-02 |
| **Autores** | Equipo de Arquitectura Northwind |
| **Deciden** | Comité de Arquitectura Northwind |
| **Alcance** | Institucional |

## Contexto

Cada aplicación de Northwind gestionaba sus propias credenciales. Seguridad de la Información exige un único proveedor de identidad y prohíbe guardar tokens en almacenamiento persistente del navegador.

## Decisión

- El Proveedor de Identidad Northwind (Keycloak 25) es la única fuente de autenticación de miembros, empleados y servicios.
- Una aplicación de una página usa el flujo de código de autorización con PKCE; los tokens viven en memoria, nunca en `localStorage` ni `sessionStorage`.
- Un servicio valida el token de acceso (JWT, RS256) con las llaves públicas del endpoint JWKS del proveedor, en cada solicitud, y autoriza por roles y atributos del token.
- Vida del token de acceso: 5 minutos; renovación silenciosa con el token de refresco.

## Justificación

- Un único proveedor cierra las bajas de acceso en un solo lugar.
- La validación local del JWT no agrega una llamada al proveedor por solicitud.

## Consecuencias

- Ninguna aplicación nueva implementa inicio de sesión propio.
- Un servicio que no recibe token, o recibe uno inválido, responde 401 y no procesa nada (deny by default).

## Alternativas

| Alternativa | Motivo del descarte |
|-------------|---------------------|
| Sesiones de servidor con cookie | Obliga a estado compartido entre réplicas |
| Proveedor SaaS de identidad | Licencia por usuario fuera del presupuesto |
