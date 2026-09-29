# LinkedIn Publication Draft

## Suggested post

🚀 **Nuevo proyecto de Data Analytics / BI: Olist E-Commerce Analysis**

Terminé un proyecto end-to-end utilizando el dataset público de
e-commerce de Olist, trabajando desde los archivos CSV hasta un
dashboard final en Power BI.

El flujo fue:

**CSV → PostgreSQL → Data Quality → Modelo Relacional → SQL → Power BI →
Validación**

El objetivo no fue simplemente construir visualizaciones. Primero
analicé la granularidad y calidad de las tablas, validé claves y
relaciones, definí las métricas de negocio y luego contrasté los
resultados de Power BI contra PostgreSQL.

Durante el análisis aparecieron varios problemas interesantes del
dataset:

-   `review_id` no era único como inicialmente podía suponerse, por lo
    que fue necesario validar una clave compuesta.
-   La tabla de geolocalización tenía más de 1 millón de registros,
    incluyendo más de 260 mil duplicados redundantes y ZIP codes
    asociados a múltiples ubicaciones.
-   Existían categorías de productos sin correspondencia en la tabla de
    traducción.
-   Pagos y reviews podían tener múltiples registros por orden,
    generando riesgo de *fan-out* si las tablas se combinaban sin
    respetar su granularidad.
-   Los extremos temporales del dataset tenían cobertura irregular, por
    lo que el análisis de tendencias se acotó a enero de 2017 -- agosto
    de 2018.

Algunos resultados del análisis:

📊 Revenue de productos en órdenes entregadas: **R\$ 13,22 M**\
📦 Órdenes entregadas: **96.478**\
🧾 Average Order Value: **R\$ 137,04**\
👥 Clientes únicos: **93.358**\
🚚 Tiempo promedio de entrega: **12,56 días**\
⏱️ Entregas tardías: **8,11%**

Para mí, una de las partes más valiosas del proyecto fue comprobar que
un dashboard confiable empieza antes de Power BI: entender el *grain*,
validar las relaciones y detectar problemas de calidad cambia
completamente la forma de construir las métricas.

🔗 **Repositorio y documentación:** \[PEGAR LINK DE GITHUB\]

#DataAnalytics #BusinessIntelligence #SQL #PostgreSQL #PowerBI
#DataVisualization #PortfolioProject

## Suggested publication assets

1.  Use `images/dashboard.png` as the main LinkedIn image.
2.  Add the GitHub repository URL where indicated.
3.  Keep the GitHub repository public before publishing.
4.  Optional second image: Power BI relationship/model view.
