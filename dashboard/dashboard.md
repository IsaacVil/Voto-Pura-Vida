# Dashboard de consulta en PowerBi

Se realiza un dashboard de consulta para la información de votos solicitada en Voto Pura Vida, tomando en cuenta el login del usuario y distintas validaciones, se conecta directamente con SQL Server donde hicimos un sp que realiza la consulta. 

importante: Para el acceso a PowerBi hay que logearse con el correo del tec.
---

## 1. Endpoints Backend

- **POST `/api/dashboard`**
  - **Descripción:** Devuelve los datos del dashboard solo si el usuario tiene permisos de administrador.
  - **Cuerpo de la solicitud:**
    ```json
    {
      "email": "usuario@dominio.com",
      "password": "contraseña"
    }
    ```
  - **Respuesta:**
    - JSON con los datos del dashboard (votaciones, propuestas, inversiones, etc.)
  - **Seguridad:**
    - Solo usuarios con credenciales válidas y permisos de admin pueden acceder a los datos.

---

## 2. Stored Procedure (SP)

- **Nombre:** `SP_Dashboard`
- **Parámetro:** `@email VARCHAR(120)`
- **Función:**
  - Valida que el usuario exista, esté activo y verificado.
  - Verifica que tenga rol de administrador (rol 2 o 3).
  - Devuelve la información relevante para el dashboard (votaciones recientes, propuestas, inversiones, etc.).

---

## 3. Pasos para conectar Power BI

1. **Crear parámetros en Power BI:**
   - `email` (texto)
   - `password` (texto)
2. **Conectar a la API:**
   - Usar el método POST a `http://localhost:3000/api/dashboard`.
   - En el cuerpo, enviar los parámetros como JSON.
3. **Consulta en Power Query (M):**
   ```m
   let
     email = email,
     password = password,
     body = Text.ToBinary("{""email"":""" & email & """,""password"":""" & password & """}"),
     Source = Json.Document(Web.Contents("http://localhost:3000/api/dashboard",
         [
           Content = body,
           Headers = [#"Content-Type"="application/json"]
         ]
     ))
   in
     Source
   ```
4. **Visualizar los datos:**
   - Si las credenciales son correctas y el usuario tiene permisos, Power BI mostrará los datos para crear visualizaciones.

---

## 4. Notas extras

- El SP solo se ejecuta si el usuario ya fue autenticado correctamente.
- Si el usuario no tiene permisos, la API devuelve un error y Power BI no muestra datos.

---

