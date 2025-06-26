# API para los códigos postales de México
[![Code Climate](https://codeclimate.com/github/Munett/API-Codigos-Postales/badges/gpa.svg)](https://codeclimate.com/github/Munett/API-Codigos-Postales)

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/acrogenesis/API-Codigos-Postales)

Dado un código postal, regresa un arreglo con las colonia, municipio y estado perteneciente al código postal.
Además se pueden realizar búsquedas de códigos postales usando los números iniciales.

## Sube la app a heroku
1) Da click en el botón `Deploy to Heroku` y sigue los pasos.
2) Al terminar corre `heroku run rake sepomex:update`.
3) Agrega el task de `rake sepomex:update` en el addon de Heroku
Scheduler para que se corra cada día.

## Running with Docker Compose

This project can be easily run using Docker Compose, which sets up both the Ruby application and a PostgreSQL database.

**Prerequisites:**
*   Docker installed on your system.
*   Docker Compose (usually included with Docker Desktop or installed separately).

**Steps:**

1.  **Build the Docker images:**
    ```bash
    docker compose build
    ```

2.  **Start the database service:**
    ```bash
    docker compose up -d zipcode_api_db
    ```

3.  **Wait for the database to be healthy.** You can check its status with:
    ```bash
    docker compose ps
    ```
    Wait until `zipcode_api_db` shows `healthy` in the `Status` column.

4.  **Run database migrations:**
    ```bash
    docker compose run --rm zipcode_api_web bundle exec rake db:migrate
    ```

5.  **Seed the database with postal code data:**
    This step downloads and imports the latest postal code data from SEPOMEX. It might take some time.
    ```bash
    docker compose run --rm zipcode_api_web bundle exec rake sepomex:update
    ```

6.  **Start the web application:**
    ```bash
    docker compose up -d zipcode_api_web
    ```

7.  **Access the application:**
    The API will be available at `http://localhost:3001`.

## Scheduled Data Updates (Cron Job)

This project includes a daily cron job to automatically update the postal code data from SEPOMEX. The update is scheduled to run every day at 3:00 AM (UTC).

**How to Verify the Cron Job:**

1.  **Ensure the `cron_worker` service is running:**
    ```bash
    docker compose up -d cron_worker
    ```

2.  **Check the `cron_worker` logs:**
    ```bash
    docker compose logs -f cron_worker
    ```
    You should see output related to the `rake sepomex:update` task when it runs.

**How to Manually Trigger the Update (for testing):**

To test the update process without waiting for the scheduled time, you can manually execute the update script inside the `cron_worker` container:

```bash
docker compose exec cron_worker /app/update_sepomex.sh
```

**Temporarily Adjusting Cron Schedule for Testing:**

If you need to test the cron daemon's scheduling functionality, you can temporarily modify the cron schedule:

1.  Edit the `cron/sepomex_update_cron` file inside your project directory.
2.  Change the schedule (e.g., `0 3 * * *` to `* * * * *` for every minute).
3.  Rebuild the `cron_worker` service:
    ```bash
    docker compose build cron_worker
    ```
4.  Restart the `cron_worker` service:
    ```bash
    docker compose up -d cron_worker
    ```
5.  Monitor the logs (`docker compose logs -f cron_worker`) to see the job run at the new interval.
6.  **Remember to revert the cron schedule** in `cron/sepomex_update_cron` back to `0 3 * * *` and rebuild/restart the `cron_worker` service after testing.

## Suscripción y documentación de la API

[https://rapidapi.com/acrogenesis-llc-api/api/mexico-zip-codes](https://rapidapi.com/acrogenesis-llc-api/api/mexico-zip-codes)


**Consultar la información de un código postal**

```text
https://mexico-zip-codes.p.rapidapi.com/codigo_postal/66436
```

**Respuesta del servidor**
```json
{
  "codigo_postal": "66436",
  "municipio": "San Nicolás de los Garza",
  "estado": "Nuevo León",
  "colonias": [
    "Praderas de Santo Domingo",
    "Las Nuevas Puente"
  ]
}
```

---

**Buscar códigos postales**

```text
https://mexico-zip-codes.p.rapidapi.com/buscar
```

_parámetros necesarios_
```text
  codigo_postal=# codigo a buscar, parcial o total
```

_parámetros opcionales_
```text
  limit=# número máximo de resultados a devolver
```

_Ejemplo de búsqueda para códigos que inicien con **66**, con **664** y con **6641**_
```json
https://mexico-zip-codes.p.rapidapi.com/buscar?codigo_postal=66
https://mexico-zip-codes.p.rapidapi.com/buscar?codigo_postal=664
https://mexico-zip-codes.p.rapidapi.com/buscar?codigo_postal=6641
```

_Ejemplo de búsqueda limitada a 3 resultados_
```text
https://mexico-zip-codes.p.rapidapi.com/buscar?codigo_postal=66&limit=3
```

** Para el código postal 6641 el servidor regresa **
```json
{
  "codigos_postales": [
    "66410",
    "66412",
    "66413",
    "66414",
    "66415",
    "66417",
    "66418"
  ]
}
```

---

**Buscar códigos postales por ubicación**

```text
https://mexico-zip-codes.p.rapidapi.com/v2/buscar_por_ubicacion
```

_parámetros necesarios_
```text
  estado=# nombre del estado
  municipio=# nombre del municipio
```

_parámetros opcionales_
```text
  colonia=# nombre de la colonia (opcional)
  limit=# número máximo de resultados a devolver
```

_Ejemplo de búsqueda para códigos postales en Nuevo León, San Nicolás de los Garza_
```text
https://mexico-zip-codes.p.rapidapi.com/v2/buscar_por_ubicacion?estado=Nuevo%20León&municipio=San%20Nicolás%20de%20los%20Garza
```

_Ejemplo de búsqueda para códigos postales en Nuevo León, San Nicolás de los Garza, colonia Praderas de Santo Domingo_
```text
https://mexico-zip-codes.p.rapidapi.com/v2/buscar_por_ubicacion?estado=Nuevo%20León&municipio=San%20Nicolás%20de%20los%20Garza&colonia=Praderas%20de%20Santo%20Domingo
```

_Ejemplo de búsqueda limitada a 5 resultados_
```text
https://mexico-zip-codes.p.rapidapi.com/v2/buscar_por_ubicacion?estado=Nuevo%20León&municipio=San%20Nicolás%20de%20los%20Garza&limit=5
```

**Respuesta del servidor**
```json
{
  "codigos_postales": [
    "66436"
  ]
}
```

___

### Rake task
Ejecuta el rake task `rake sepomex:update` para descargar todos los códigos postales de México y actualizar tu base de datos. When running with Docker Compose, use:
```bash
docker compose run --rm zipcode_api_web bundle exec rake sepomex:update
```

### Colabora
Errores y pull requests son bienvenidos en Github: https://github.com/Munett/API-Codigos-Postales.
Para bajar en tu BD todos los códigos postales corre el rake script `rake sepomex:update`.

Los datos se obtuvieron de http://www.correosdemexico.gob.mx/lservicios/servicios/CodigoPostal_Exportar.aspx

### Los datos se actualizan cada domingo.

### Licencia
MIT License