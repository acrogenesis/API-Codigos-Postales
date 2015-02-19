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

Los datos se obtuvieron de http://www.correosdemexico.gob.mx/ServiciosLinea/Paginas/DescargaCP.aspx

Fecha de actualización:  **26 de enero de 2015**

### Licencia
MIT License
