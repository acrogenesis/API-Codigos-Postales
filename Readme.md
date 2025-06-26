# API para los códigos postales de México

[](https://codeclimate.com/github/Munett/API-Codigos-Postales)

[](https://heroku.com/deploy?template=https://github.com/acrogenesis/API-Codigos-Postales)

Dado un código postal, regresa un arreglo con las colonias, municipio y estado perteneciente al código postal. Además, se pueden realizar búsquedas de códigos postales usando los números iniciales.

## Sube la app a Heroku

1)  Da click en el botón `Deploy to Heroku` y sigue los pasos.
2)  Al terminar corre `heroku run rake sepomex:update`.
3)  Agrega el task de `rake sepomex:update` en el addon de Heroku Scheduler para que se corra cada día.

## Running with Docker Compose

This project can be easily run using Docker Compose, which sets up the Ruby application, a PostgreSQL database, and a cron job for data updates.

**Prerequisites:**

  * Docker and Docker Compose installed on your system.

**Steps:**

1.  **Clone the repository and navigate into the directory.**

2.  **Build and start all services in the background:**
    This command builds the images if they don't exist and starts the `db`, `web`, and `cron_worker` containers.

    ```bash
    docker compose up -d --build
    ```

3.  **Check the status of the containers:**
    Wait for the `db` service to show `(healthy)` in the status column before proceeding.

    ```bash
    docker compose ps
    ```

4.  **Run database migrations:**
    This command sets up the necessary tables in the database.

    ```bash
    docker compose run --rm web bundle exec rake db:migrate
    ```

5.  **Seed the database with postal code data:**
    This step downloads and imports the latest postal code data from SEPOMEX. It might take some time.

    ```bash
    docker compose run --rm web bundle exec rake sepomex:update
    ```

6.  **Access the application:**
    The API should now be running and available at `http://localhost:3000`.

## Scheduled Data Updates (Cron Job)

The `cron_worker` service is configured to automatically run `rake sepomex:update` every day at 3:00 AM (UTC) to keep the postal code data fresh.

**How to Verify the Cron Job:**

1.  **Check the `cron_worker` logs:**
    ```bash
    docker compose logs -f cron_worker
    ```
    You will see output from the cron daemon and the rake task when it executes.

**How to Manually Trigger an Update:**

To run the update process immediately without waiting for the scheduled time, execute the rake task directly on the `web` service (as it has the application code and dependencies):

```bash
docker compose run --rm web bundle exec rake sepomex:update
```

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

-----

**Buscar códigos postales**

```text
https://mexico-zip-codes.p.rapidapi.com/buscar
```

*parámetros necesarios*

```text
  codigo_postal=# codigo a buscar, parcial o total
```

*parámetros opcionales*

```text
  limit=# número máximo de resultados a devolver
```

*Ejemplo de búsqueda para códigos que inicien con **66**, con **664** y con **6641***

```text
https://mexico-zip-codes.p.rapidapi.com/buscar?codigo_postal=66
https://mexico-zip-codes.p.rapidapi.com/buscar?codigo_postal=664
https://mexico-zip-codes.p.rapidapi.com/buscar?codigo_postal=6641
```

*Ejemplo de búsqueda limitada a 3 resultados*

```text
https://mexico-zip-codes.p.rapidapi.com/buscar?codigo_postal=66&limit=3
```

\*\* Para el código postal 6641 el servidor regresa \*\*

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

-----

**Buscar códigos postales por ubicación**

```text
https://mexico-zip-codes.p.rapidapi.com/v2/buscar_por_ubicacion
```

*parámetros necesarios*

```text
  estado=# nombre del estado
  municipio=# nombre del municipio
```

*parámetros opcionales*

```text
  colonia=# nombre de la colonia (opcional)
  limit=# número máximo de resultados a devolver
```

*Ejemplo de búsqueda para códigos postales en Nuevo León, San Nicolás de los Garza*

```text
https://mexico-zip-codes.p.rapidapi.com/v2/buscar_por_ubicacion?estado=Nuevo%20León&municipio=San%20Nicolás%20de%20los%20Garza
```

**Respuesta del servidor**

```json
{
  "codigos_postales": [
    "66436"
  ]
}
```

-----

### Rake task

Ejecuta el rake task `rake sepomex:update` para descargar todos los códigos postales de México y actualizar tu base de datos. When running with Docker Compose, use the correct service name:

```bash
docker compose run --rm web bundle exec rake sepomex:update
```

### Colabora

Errores y pull requests son bienvenidos en Github: [https://github.com/Munett/API-Codigos-Postales](https://github.com/Munett/API-Codigos-Postales).

Los datos se obtuvieron de [http://www.correosdemexico.gob.mx/lservicios/servicios/CodigoPostal\_Exportar.aspx](http://www.correosdemexico.gob.mx/lservicios/servicios/CodigoPostal_Exportar.aspx)

### Los datos se actualizan cada domingo.

### Licencia

MIT License