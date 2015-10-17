# API para los códigos postales de México

Dado un código postal, regresa un arreglo con las colonia, municipio y estado perteneciente al código postal.

Ej.
`https://api-codigos-postales.herokuapp.com/codigo_postal/64630`
Regresa:
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

### Colabora
Errores y pull requests son bienvenidos en Github: https://github.com/Munett/API-Codigos-Postales.
Para bajar en tu BD todos los códigos postales corre el rake script `rake sepomex:update`.

Los datos se obtuvieron de http://www.correosdemexico.gob.mx/ServiciosLinea/Paginas/DescargaCP.aspx

### Licencia
MIT License
