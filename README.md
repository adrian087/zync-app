# ⚡ Zync - Red Social Multiplataforma en Tiempo Real

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge\&logo=flutter\&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge\&logo=dart\&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge\&logo=apple\&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge\&logo=android\&logoColor=white)

**Zync** es una red social multiplataforma desarrollada bajo el paradigma **Mobile First**, construida con **Flutter** para ofrecer una experiencia nativa en iOS y Android a partir de una única base de código.

El proyecto ha sido desarrollado como parte del **Trabajo de Fin de Grado (TFG)** del ciclo de **Desarrollo de Aplicaciones Multiplataforma (DAM)** y destaca por su rendimiento optimizado, arquitectura modular y comunicación en tiempo real mediante WebSockets.

> **Nota:** Este repositorio contiene exclusivamente el cliente móvil desarrollado en Flutter. El servidor, la API REST y la infraestructura de tiempo real se encuentran en el repositorio independiente de **Zync Backend**.

---

## ✨ Características Principales

### 👤 Sistema de Autenticación

* Registro tradicional mediante correo electrónico.
* Inicio de sesión seguro.
* Integración con proveedores OAuth (Google Sign-In).
* Persistencia automática de sesión mediante JWT.

### 📝 Publicaciones (Zyncs)

* Publicaciones de texto de hasta 280 caracteres.
* Carrusel multimedia de hasta 4 imágenes.
* Eliminación y gestión de contenido propio.
* Actualización dinámica de interacciones.

### ⏱️ Zync Drops

Sistema de historias efímeras con:

* Visualización temporal.
* Gestión automática de expiración.
* Seguimiento de visualizaciones.

### 💬 Mensajería en Tiempo Real

Comunicación instantánea mediante WebSockets:

* Chats privados 1 a 1.
* Entrega inmediata de mensajes.
* Actualización sin necesidad de recargar vistas.

### 🔄 Interacciones Sociales

* Sistema de "Me gusta".
* Comentarios anidados.
* ReZyncs (compartir publicaciones).
* Seguimiento de usuarios (Follow / Unfollow).

### 🛡️ Privacidad y Seguridad

* Bloqueo de usuarios.
* Ocultación de contenido restringido.
* Protección de sesiones mediante JWT.

---

## 🚀 Rendimiento y Experiencia de Usuario

### Scroll Infinito

Implementado mediante:

```dart
ListView.builder()
```

Ventajas:

* Menor consumo de memoria.
* Carga progresiva de contenido.
* Mejor rendimiento en dispositivos de gama media y baja.

### 🌙 Modo Oscuro y Claro

* Adaptación automática al sistema operativo.
* Persistencia de preferencias.
* Experiencia visual consistente.

### 🖼️ Procesamiento Local de Imágenes

Antes de enviar imágenes al servidor:

* Selección desde galería o cámara.
* Recorte nativo.
* Optimización previa para reducir ancho de banda.

---

## 🏗️ Arquitectura del Proyecto

La aplicación sigue una arquitectura basada en **Separación de Responsabilidades (Separation of Concerns)** para facilitar la escalabilidad y el mantenimiento.

### 📁 `/lib/screens`

Contiene las vistas principales y flujos de navegación:

* Login
* Registro
* Feed principal
* Perfil
* Búsqueda
* Chat

Aquí reside únicamente la lógica visual y de interacción.

### 📁 `/lib/widgets`

Componentes reutilizables de interfaz:

* Tarjetas de publicaciones
* Avatares
* Botones personalizados
* Modales
* Componentes compartidos

Aplicando el principio **DRY (Don't Repeat Yourself)**.

### 📁 `/lib/services`

Capa de comunicación externa:

* Consumo de API REST.
* Gestión de peticiones HTTP.
* Interceptación de errores.
* Gestión de conexiones Socket.io.

### 📁 `/lib/models`

Modelos de datos tipados en Dart encargados de:

* Recibir respuestas JSON.
* Validar estructuras.
* Transformar datos en objetos utilizables por la aplicación.

---

## ⚡ Gestión de Estado y Asincronía

Uno de los objetivos principales de Zync ha sido minimizar el consumo de recursos.

### Estado Reactivo Nativo

En lugar de utilizar soluciones complejas como:

* BLoC
* Redux
* MobX

Se aprovechan herramientas nativas de Flutter:

```dart
ValueNotifier
ValueListenableBuilder
```

Esto permite que únicamente se reconstruyan los widgets afectados por cambios de estado.

Ejemplo:

Si un usuario pulsa "Me gusta" en una publicación, solo se actualiza el icono correspondiente y no toda la pantalla.

### Autenticación Stateless

La sesión del usuario se gestiona mediante:

* JSON Web Tokens (JWT).
* Persistencia segura en almacenamiento local.
* Inclusión automática del token en las cabeceras HTTP.

---

## 🛠️ Stack Tecnológico

| Categoría             | Tecnología             |
| --------------------- | ---------------------- |
| Framework             | Flutter                |
| Lenguaje              | Dart                   |
| HTTP Client           | http                   |
| Tiempo Real           | socket_io_client       |
| Gestión Multimedia    | image_picker           |
| Edición de Imágenes   | image_cropper          |
| Persistencia Local    | shared_preferences     |
| Almacenamiento Seguro | flutter_secure_storage |

---

## 📂 Estructura del Proyecto

```text
lib/
│
├── models/
├── screens/
├── services/
├── widgets/
├── utils/
│
├── main.dart
│
assets/
│
pubspec.yaml
README.md
```

---

## ⚙️ Instalación y Configuración Local

### Prerrequisitos

* Flutter SDK 3.x o superior.
* Android Studio o VS Code.
* Android Emulator o iOS Simulator.
* Backend de Zync operativo.

---

### 1. Clonar el repositorio

```bash
git clone https://github.com/tu_usuario/zync_app.git
cd zync_app
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar la URL de la API

Edita tu archivo de configuración global:

```dart
// Emulador Android
static const String apiUrl = "http://10.0.2.2:3000/api";

// Producción
// static const String apiUrl = "https://api.tudominio.com/api";
```

### 4. Ejecutar la aplicación

```bash
flutter run
```

También puedes compilar para producción:

#### Android

```bash
flutter build apk --release
```

#### iOS

```bash
flutter build ios --release
```

---

## 🎯 Objetivos Técnicos Alcanzados

* Arquitectura modular y escalable.
* Comunicación en tiempo real mediante WebSockets.
* Persistencia segura de sesiones.
* Optimización de reconstrucciones de UI.
* Consumo eficiente de memoria.
* Compatibilidad multiplataforma con una única base de código.
* Integración completa con backend REST y Socket.io.

---

## 👨‍💻 Autor

**Adrián Torres Cañete**

🎓 Trabajo de Fin de Grado — Desarrollo de Aplicaciones Multiplataforma (DAM)

📱 **Zync — Red Social Multiplataforma en Tiempo Real**

> *"Rompiendo la brecha del desarrollo nativo a través del rendimiento y el tiempo real."*
