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
