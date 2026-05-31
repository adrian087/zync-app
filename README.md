# ⚡ Zync - Red Social Multiplataforma en Tiempo Real

![Flutter](https://img.shields.io/badge/Frontend-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![NodeJS](https://img.shields.io/badge/Backend-Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![MySQL](https://img.shields.io/badge/Database-MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Socket.io](https://img.shields.io/badge/RealTime-Socket.io-010101?style=for-the-badge&logo=socketdotio&logoColor=white)

**Zync** es una red social moderna, diseñada bajo el paradigma *Mobile-First* y desarrollada con un único código base para iOS y Android. El proyecto destaca por ofrecer una experiencia fluida a 60 FPS y comunicación bidireccional instantánea gracias a la implementación de WebSockets.

Este proyecto ha sido desarrollado como **Trabajo de Fin de Grado (TFG)** en Desarrollo de Aplicaciones Multiplataforma.

---

## ✨ Características Principales

### Funcionalidades Core
* 👤 **Autenticación Segura:** Registro local tradicional y Login con Google (OAuth).
* 📝 **Publicaciones (Zyncs):** Textos de hasta 280 caracteres con soporte para carrusel multimedia (hasta 4 imágenes).
* ⏱️ **Zync Drops:** Historias efímeras que caducan según el número de visualizaciones.
* 💬 **Chat en Tiempo Real:** Mensajería directa privada (1 a 1) sin necesidad de recargar la pantalla.
* 🔄 **Interacciones Sociales:** Sistema de "Me gusta", comentarios anidados, "ReZyncs" y seguimiento de usuarios (Follow/Unfollow).
* 🛡️ **Privacidad:** Sistema avanzado de bloqueo de usuarios.

### Características Técnicas
* 🚀 **Scroll Infinito:** Paginación dinámica desde el backend para optimizar el consumo de memoria.
* 🔐 **Autenticación Stateless:** Protección de rutas mediante JSON Web Tokens (JWT).
* 🎨 **Gestión de Estado Nativa:** Renderizado reactivo optimizado mediante `ValueNotifier` en Flutter.
* 🛡️ **Integridad Referencial:** Reglas estrictas en base de datos (`ON DELETE CASCADE`) para evitar registros huérfanos.

---

## 🛠️ Stack Tecnológico y Arquitectura

El ecosistema se basa en una arquitectura **MVC Distribuida** para garantizar el máximo desacoplamiento y escalabilidad:

### 📱 Frontend (Cliente)
* **Framework:** Flutter (Dart).
* **Gestión de Estado:** `ValueNotifier` y `ValueListenableBuilder` (sin librerías pesadas de terceros).
* **Red:** Paquete `http` nativo y `MultipartRequest` para subida de binarios.
* **Multimedia:** `image_picker` e `image_cropper` para manipulación local.

### ⚙️ Backend (API REST & Sockets)
* **Entorno:** Node.js con Express.
* **Tiempo Real:** Socket.io para túneles TCP persistentes.
* **Seguridad:** JWT (JsonWebToken) y encriptación Bcrypt.
* **Multimedia:** Multer para el procesamiento asíncrono de imágenes.

### 🗄️ Base de Datos
* **Motor:** MySQL (Relacional).
* **Diseño:** Prevención activa contra Inyecciones SQL (Consultas parametrizadas) y lógica condicional avanzada en el motor DB.

### ☁️ Infraestructura y Despliegue (DevOps)
* **Servidor:** VPS Linux.
* **Gestor de procesos:** PM2.
* **Proxy Inverso:** Nginx.
* **Seguridad Perimetral:** Cloudflare (DNS, mitigación DDoS y cifrado SSL/HTTPS estricto).

## ⚙️ Instalación y Despliegue Local

Si deseas correr este proyecto en tu entorno local, sigue estos pasos:

### Prerrequisitos
* [Flutter SDK](https://flutter.dev/docs/get-started/install) (versión 3.x o superior).
* [Node.js](https://nodejs.org/) (versión 16 o superior).
* Servidor MySQL corriendo localmente.

### 1. Configurar el Backend (Node.js)
```bash
# Navegar a la carpeta del servidor
cd backend

# Instalar las dependencias
npm install

# Crear un archivo .env basado en el .env.example y configurar las variables:
# PORT=3000
# DB_HOST=localhost
# DB_USER=root
# DB_PASS=tu_contraseña
# DB_NAME=zync_db
# JWT_SECRET=tu_secreto_super_seguro

# Iniciar el servidor en modo desarrollo
npm run dev

# Navegar a la carpeta de la app
cd zync_app

# Obtener los paquetes de Dart
flutter pub get

# (Opcional) Generar archivos si usas build_runner
# flutter pub run build_runner build --delete-conflicting-outputs

# Iniciar la aplicación en un emulador o dispositivo físico
flutter run