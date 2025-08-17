# ChatBot DCCO 🤖

Una aplicación móvil Flutter que funciona como asistente virtual para el Departamento de Ciencias de la Computación (DCCO). Está diseñada para asistir a estudiantes y personas interesadas en las carreras de Software, ITIN e ITIN en línea, proporcionando soporte y respondiendo preguntas frecuentes sobre el departamento.

## 📋 Características

### Funcionalidades Principales
- 💬 **Chat Inteligente**: Conversaciones en tiempo real con respuestas automáticas
- 📚 **Información Académica**: Respuestas sobre carreras, requisitos y recursos del DCCO
- 📱 **Multiplataforma**: Compatible con Android, iOS, Windows, macOS, Linux y Web
- 🌙 **Tema Personalizable**: Modo claro y oscuro
- 💾 **Persistencia Local**: Historial de conversaciones guardado localmente con Hive
- ☁️ **Integración en la Nube**: Conectado a Firebase para funcionalidades avanzadas

### Pantallas Principales
- **Chat**: Interfaz principal de conversación
- **Historial**: Visualización de conversaciones anteriores
- **Feedback**: Sistema de retroalimentación de usuarios
- **Perfil**: Configuraciones y información del usuario

## 🛠️ Tecnologías Utilizadas

### Framework y Lenguaje
- **Flutter** (SDK ^3.5.4)
- **Dart**

### Arquitectura y Gestión de Estado
- **Provider** - Gestión de estado reactiva
- **MVC Pattern** - Separación de responsabilidades

### Base de Datos y Persistencia
- **Hive** - Base de datos NoSQL local
- **Firebase Core** - Servicios en la nube
- **Cloud Firestore** - Base de datos en tiempo real

### Comunicación
- **HTTP** - Comunicación con API backend
- **RESTful API** - Integración con servidor (`http://74.235.218.90:8000/api/chatbot/`)

### UI/UX
- **Material Design** - Diseño consistente
- **Flutter Markdown** - Renderizado de contenido enriquecido
- **Flutter SpinKit** - Indicadores de carga animados
- **Image Picker** - Selección de imágenes
- **File Picker** - Manejo de archivos

## 🏗️ Arquitectura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── constants/
│   └── constants.dart        # Constantes globales
├── controllers/
│   ├── chat_controller.dart  # Lógica de negocio del chat
│   └── settings_controller.dart # Gestión de configuraciones
├── models/
│   ├── chat_history.dart     # Modelo de historial de chat
│   ├── message.dart          # Modelo de mensajes
│   ├── settings.dart         # Modelo de configuraciones
│   └── user_model.dart       # Modelo de usuario
├── themes/
│   └── my_theme.dart         # Temas de la aplicación
├── utility/
│   └── animated_dialog.dart  # Utilidades de UI
└── views/
    ├── home_screen.dart      # Pantalla principal
    ├── feedback_screen.dart  # Pantalla de feedback
    ├── chat/                 # Módulo de chat
    └── profile/              # Módulo de perfil
```

## 🚀 Instalación y Configuración

### Prerrequisitos
- Flutter SDK ^3.5.4
- Dart SDK
- Android Studio / VS Code
- Git

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone https://github.com/EdJGM/ProyectoChatBotDCCO.git
cd ProyectoChatBotDCCO
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar Firebase** (Opcional)
- Configurar `google-services.json` para Android
- Configurar `GoogleService-Info.plist` para iOS

4. **Ejecutar la aplicación**
```bash
flutter run
```

## 🧪 Testing

El proyecto incluye un conjunto completo de pruebas:

### Pruebas Unitarias
```bash
flutter test test/unit/
```

### Pruebas de Widget
```bash
flutter test test/widget/
```

### Pruebas de Integración
```bash
flutter test integration_test/
```

### Cobertura de Código
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📱 Plataformas Soportadas

- ✅ Android
- ✅ iOS
- ✅ Windows
- ✅ macOS
- ✅ Linux
- ✅ Web

## 🔧 Configuración de Desarrollo

### Variables de Entorno
- Backend API: `http://74.235.218.90:8000/api/chatbot/`
- Configuración Firebase en `android/app/google-services.json`

### Estructura de Datos
- **Hive Boxes**: Almacenamiento local de mensajes y configuraciones
- **Firebase**: Sincronización y respaldo en la nube

## 📖 Uso

1. **Iniciar Chat**: Navega a la pestaña "Chat" y escribe tu pregunta
2. **Ver Historial**: Accede a conversaciones anteriores en "Historial"
3. **Configurar**: Personaliza la experiencia en "Perfil"
4. **Feedback**: Proporciona retroalimentación en "Feedback"

## 🤝 Contribución

Este proyecto es parte del curso de **Aseguramiento de Calidad de Software** y está en desarrollo activo.

### Desarrolladores
- EdJGM (Propietario del repositorio)

## 📄 Licencia

Este proyecto es de uso académico para el Departamento de Ciencias de la Computación.

## 📞 Contacto

Para preguntas sobre el proyecto o el DCCO, utiliza la aplicación para obtener respuestas automatizadas sobre:
- Requisitos de carreras
- Información académica
- Recursos del departamento
- Procesos de admisión

---

**Desarrollado con ❤️ usando Flutter para el DCCO**
