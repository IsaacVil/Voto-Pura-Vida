# Dashboard de consulta en PowerBi

Se realiza un dashboard de consulta para la información de votos solicitada en Voto Pura Vida, tomando en cuenta el login del usuario y distintas validaciones. El acceso a los datos está protegido mediante autenticación JWT (token), y la consulta se realiza a través de un endpoint seguro en el backend.

**Importante:** Para el acceso a PowerBi hay que logearse con el correo del TEC.

---

## 1. Endpoints Backend

- **GET `/api/dashboard`**
  - **Descripción:** Devuelve los datos del dashboard solo si el usuario tiene permisos de administrador y un JWT válido.
  - **Autenticación:**
    - Se debe enviar el token JWT en el header:
      ```
      Authorization: Bearer <token>
      ```
  - **Respuesta:**
    - JSON con los datos del dashboard (votaciones, propuestas, inversiones, etc.)
  - **Seguridad:**
    - Solo usuarios autenticados y con permisos de admin pueden acceder a los datos.

---

## 2. Stored Procedure (SP)

- **Nombre:** `SP_Dashboard`
- **Parámetro:** `@email VARCHAR(120)`
- **Función:**
  - Valida que el usuario exista, esté activo y verificado.
  - Verifica que tenga rol de administrador (rol 2 o 3).
  - Devuelve la información relevante para el dashboard (votaciones recientes, propuestas, inversiones, etc.).

---

## 3. Pasos para conectar Power BI usando JWT

1. **Obtener el JWT:**
   - Haz login en `/api/login` con tu email y contraseña para obtener el token.
2. **Crear parámetro en Power BI:**
   - Ve a "Transformar datos" → "Administrar parámetros" → "Nuevo parámetro".
   - Nombre: `jwt` (tipo texto). Pega aquí tu token JWT.
3. **Crear consulta en blanco:**
   - En el Editor de Power Query, crea una consulta en blanco y pega este código M:
     ```m
     let
       jwt = jwt,
       Source = Json.Document(Web.Contents("http://localhost:3000/api/dashboard",
           [
             Headers = [Authorization = "Bearer " & jwt]
           ]
       ))
     in
       Source
     ```
4. **Visualizar los datos:**
   - Si el token es válido y el usuario tiene permisos, Power BI mostrará los datos para crear visualizaciones.

---

## 4. Notas extras

- El SP solo se ejecuta si el usuario ya fue autenticado correctamente.
- Si el usuario no tiene permisos o el token es inválido, la API devuelve un error y Power BI no muestra datos.

---

