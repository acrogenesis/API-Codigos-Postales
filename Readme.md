# API para los códigos postales de México

Dado un código postal, regresa un arreglo con las colonia, municipio y estado perteneciente al código postal.
Además se pueden realizar búsquedas de códigos postales usando los números iniciales.

### Ejemplos de uso

#### Liga a la API

[https://api-codigos-postales.herokuapp.com](https://api-codigos-postales.herokuapp.com)



**Consultar la información de un código postal**

```text
https://api-codigos-postales.herokuapp.com/codigo_postal/64630
```

**Respuesta del servidor**
```json
[
  {
    "codigo_postal": "64630",
    "colonia": "Colinas de San Jerónimo",
    "municipio": "Monterrey",
    "estado": "Nuevo León"
  },
  {
    "codigo_postal": "64630",
    "colonia": "San Jemo 1 Sector",
    "municipio": "Monterrey",
    "estado": "Nuevo León"
  }
]
```

---

**Buscar códigos postales**

```text
 https://api-codigos-postales.herokuapp.com/buscar
```

_parametros necesarios_
```text
  codigo_postal=# codigo a buscar, parcial o total
```
_Ejemplo de busqueda para códigos que inicien con **66**, con **664** y con **6641**_
```json
https://api-codigos-postales.herokuapp.com/buscar?codigo_postal=66
https://api-codigos-postales.herokuapp.com/buscar?codigo_postal=664
https://api-codigos-postales.herokuapp.com/buscar?codigo_postal=6641
```

** El servidor regresa **
```json
[
  {
    "codigo_postal": "66400"
  },
  {
    "codigo_postal": "66409"
  },
  {
    ...
  }
]
```

___

### Colabora
Errores y pull requests son bienvenidos en Github: https://github.com/Munett/API-Codigos-Postales.
Para bajar en tu BD todos los códigos postales corre el rake script `rake sepomex:update`.

Los datos se obtuvieron de http://www.correosdemexico.gob.mx/ServiciosLinea/Paginas/DescargaCP.aspx
### Los datos se actualizan cada domingo.

### Licencia
MIT License
