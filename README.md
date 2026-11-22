\# OM Cinema 🎬

\### Producto Integrador — Catálogo de Películas



Aplicación desarrollada con Flutter y Firebase como parte del Producto Integrador de la Licenciatura en Desarrollo de Sistemas Web de la Universidad de Guadalajara (UDG Virtual).



\## Descripción



OM Cinema es una aplicación que permite consultar un catálogo de películas, visualizar información detallada y administrar los registros mediante una interfaz sencilla, moderna e intuitiva.



La aplicación utiliza Firebase para autenticar usuarios y almacenar la información de las películas.



\## Funcionalidades



\- Registro e inicio de sesión de usuarios.

\- Autenticación mediante Firebase Authentication.

\- Visualización del catálogo de películas.

\- Consulta de título, año, director, género, sinopsis e imagen.

\- Registro de nuevas películas.

\- Eliminación de películas con confirmación.

\- Almacenamiento de información en Cloud Firestore.

\- Solicitudes HTTP para validar las imágenes.

\- Navegación mediante menú principal.

\- Instrucciones para facilitar el uso de la aplicación.



\## Tecnologías utilizadas



\- Flutter y Dart.

\- Firebase Authentication.

\- Cloud Firestore.

\- HTTP.

\- Git y GitHub.



\## Instrucciones de uso



1\. Ejecutar la aplicación.

2\. Registrarse con un correo electrónico y contraseña, o iniciar sesión con una cuenta existente.

3\. Consultar las películas disponibles en el catálogo.

4\. Seleccionar una película para visualizar su información.

5\. Acceder a la sección de administración para agregar o eliminar películas.

6\. Cerrar sesión desde el menú principal.



\## Ejecución del proyecto



Es necesario contar con Flutter instalado y configurar Firebase para el proyecto.



Desde la carpeta principal, ejecutar:



```bash

flutter pub get

flutter run -d chrome

```



\## Base de datos



La información de las películas se almacena en Cloud Firestore, dentro de la colección `peliculas`.



Cada registro contiene los campos:



\- `titulo`

\- `anio`

\- `director`

\- `genero`

\- `sinopsis`

\- `imagen`



\## Autor



Oliver Avenicio Montelongo Mercado



Licenciatura en Desarrollo de Sistemas Web  

Universidad de Guadalajara — UDG Virtual



\*\*Proyecto académico — 2026\*\*

