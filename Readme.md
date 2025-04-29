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

## Local Development Setup using Docker

This project includes configuration for running locally using Docker and Docker Compose.

**Prerequisites:**
* Docker Engine
* Docker Compose

**Steps:**

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/AntoSalazar/API-Codigos-Postales.git
    cd API-Codigos-Postales
    ```

2.  **Build the Docker Image:**
    This command builds the necessary image based on the `Dockerfile`. It uses Bundler to install gems specified in `Gemfile.lock`.
    ```bash
    docker compose build
    ```

3.  **Start the Database:**
    This starts the PostgreSQL database container in the background.
    ```bash
    docker compose up -d db
    ```
    Wait a few seconds for the database to initialize (check `docker compose ps` for health status).

4.  **Run Database Migrations:**
    This sets up the necessary tables in the database.
    ```bash
    docker compose run --rm web bundle exec rake db:migrate
    ```

5.  **Seed the Database (Workaround Required):**

    **KNOWN ISSUE:** Running the standard `bundle exec rake sepomex:update` task fails with a `LoadError: cannot load such file -- csv` within the Docker/Ruby 3.4.2 environment when executed via `bundle exec`. This appears to be a deep issue related to Bundler's execution context interfering with the loading of the default `csv` gem.

    **Workaround:** A separate script `run_sepomex_update.rb` has been created to perform the data download and import. However, due to the nature of the loading issue and other errors encountered when running without `bundle exec`, the most reliable (though complex) way to run this locally is currently:

    * **Option 1 (Recommended workaround):** Temporarily modify the `Dockerfile` to install gems globally, run the script without `bundle exec`, then revert the `Dockerfile`.
        1.  Comment out the `COPY Gemfile* ./` and `RUN bundle install` lines in `Dockerfile`.
        2.  Add `RUN gem install pg activerecord:8.0.1 activesupport:8.0.1 activemodel:8.0.1 rubyzip --no-document` before `WORKDIR /app`.
        3.  Rebuild: `docker compose build --no-cache web`
        4.  Run the script: `docker compose run --rm web ruby run_sepomex_update.rb`
        5.  **CRITICAL:** Revert the `Dockerfile` changes back to using `bundle install` and remove the `gem install` line.
        6.  Rebuild again: `docker compose build web`

    * **Option 2:** Get an interactive shell (`docker compose run --rm web bash`) and manually run the core download/parse/insert logic from `run_sepomex_update.rb` using `ruby -e "..."` commands.

    *Note: This seeding issue needs further investigation to find a less cumbersome solution.*

6.  **Start the Application Server:**
    Once the database is seeded (using the workaround), start the Puma web server. Ensure your Dockerfile uses `bundle install` (not the global gem install workaround) before this step.
    ```bash
    docker compose up -d web
    ```
    *(Or `docker compose up -d` to start/ensure both services are running)*

7.  **Access the API:**
    The API should now be running at `http://localhost:3000`. You can test endpoints using `curl` or Postman. Remember to include the authentication header defined in `docker-compose.yml` (default example: `X-API-TOKEN: very-secret-local-token`).

    **Example Curl:**
    ```bash
    # Replace XXXXX with a valid postal code
    curl -H "X-API-TOKEN: very-secret-local-token" http://localhost:3000/v2/codigo_postal/XXXXX

    # Example search
    curl -H "X-API-TOKEN: very-secret-local-token" "http://localhost:3000/v2/buscar?codigo_postal=290"
    ```

8.  **Stopping:**
    To stop the containers:
    ```bash
    docker compose down
    ```
    To stop and remove the database volume (deletes data):
    ```bash
    docker compose down -v
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
```json
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
Ejecuta el rake task `rake sepomex:update` para descargar todos los códigos postales de México y actualizar tu base de datos.

### Colabora
Errores y pull requests son bienvenidos en Github: https://github.com/Munett/API-Codigos-Postales.
Para bajar en tu BD todos los códigos postales corre el rake script `rake sepomex:update`.

Los datos se obtuvieron de http://www.correosdemexico.gob.mx/lservicios/servicios/CodigoPostal_Exportar.aspx

### Los datos se actualizan cada domingo.

### Licencia
MIT License
