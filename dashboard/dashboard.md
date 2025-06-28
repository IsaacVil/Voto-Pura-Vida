# Dashboard de consulta en Power BI

Este dashboard permite consultar información de votos, propuestas e inversiones de Voto Pura Vida, con autenticación por usuario y control de permisos. El acceso a los datos está protegido y solo es posible visualizar (no exportar) desde la plataforma web de Power BI Service.

**Importante:** Para el acceso a Power BI debes loguearte con tu correo del tec.

---

## 1. Endpoints Backend

- **POST `/api/dashboard`**
  - **Descripción:** Devuelve los datos del dashboard si el usuario y contraseña son válidos y tiene permisos.
  - **Autenticación:**
    - Se envía el email y password en el body JSON:
      ```json
      {
        "email": "correo@dominio.com",
        "password": "tu_password"
      }
      ```
  - **Respuesta:**
    - JSON con los datos del dashboard (votaciones, propuestas, inversiones, etc.)
  - **Seguridad:**
    - Solo usuarios autenticados y con permisos pueden acceder a los datos.

---

## 2. Stored Procedure (SP)

- **Nombre:** `SP_Dashboard`
- **Parámetro:** `@Email VARCHAR(120)`
- **Función:**
  - Valida que el usuario exista, esté activo y verificado.
  - Verifica que tenga rol de administrador (rol 2 o 3).
  - Devuelve la información relevante para el dashboard (votaciones recientes, propuestas, inversiones, etc.),
    mostrando el conteo de votos por opción y por segmento.

---

## 3. Pasos para conectar Power BI con parámetros de usuario

1. **Crea dos parámetros en Power BI:**
   - `email` (tipo Texto)
   - `password` (tipo Texto)
2. **Crea una consulta en blanco y pega este código M:**
   ```m
   let
       bodyString = "{""email"":""" & email & """,""password"":""" & password & """}",
       body = Text.ToBinary(bodyString),
       Source = Json.Document(Web.Contents("http://localhost:3000/api/dashboard",
           [
               Content = body,
               Headers = [#"Content-Type"="application/json"]
           ]
       )),
       ToTable = Table.FromRecords(Source)
   in
       ToTable
   ```
3. **Visualiza los datos:**
   - Si las credenciales son válidas y el usuario tiene permisos, Power BI mostrará los datos para crear visualizaciones.

---

## 4. Publicar y restringir exportación de datos

- Publica el reporte en Power BI Service (https://app.powerbi.com) usando el botón “Publicar” en Power BI Desktop.
- En Power BI Service, ve a la configuración del reporte y desactiva la opción de exportar datos.
- Comparte solo el acceso web, no el archivo PBIX.
- Así, los usuarios solo podrán visualizar el dashboard y no descargar los datos.

---

¿Necesitas ayuda para crear los parámetros, publicar o restringir permisos? ¡Pide soporte!

