# 📋 Plan de Implementación: EasyDiet (Flutter + Firebase)

> 📌 **Nota preliminar:** Este documento es exclusivamente un plan de arquitectura y procedimiento. No contiene código. Una vez validado este roadmap, podemos avanzar fase por fase con implementaciones concretas.

---

## 🛠️ 1. Herramientas y Entorno de Desarrollo

| Categoría | Herramienta | Propósito |
|-----------|-------------|-----------|
| IDE principal | VS Code | Editor ligero con ecosistema robusto para Flutter |
| Extensiones VS Code | `Flutter`, `Dart`, `Firebase` (Firestore/Auth), `Error Lens`, `Pubspec Assist`, `Awesome Flutter Snippets` | Autocompletado, linting, gestión de dependencias, depuración |
| SDKs | Flutter SDK (última versión estable), Dart SDK | Framework y lenguaje base |
| Backend | Firebase Console + Firebase CLI | Autenticación, Firestore, Hosting (opcional), Cloud Functions (futuro) |
| Emulación/Dispositivos | Android Studio (solo para emuladores), Xcode (iOS/macOS), Dispositivos físicos | Pruebas multiplataforma reales |
| Control de versiones | Git + GitHub/GitLab | Trazabilidad, ramas por feature, CI/CD |
| Diseño UI/UX | Figma o Penpot | Wireframes, prototipos interactivos, design system |

> ⚠️ **Sobre "Antigravity"**: No es un IDE reconocido para desarrollo Flutter. Se recomienda VS Code + Android Studio para emuladores, o JetBrains IntelliJ/Android Studio como alternativa.

---

## 🎨 2. Diseño UI/UX

### 📐 Principios de Diseño
- **Sistema de diseño**: Material 3 (adaptado a identidad visual de EasyDiet)
- **Paleta de colores**: Tonos verdes/azules (salud, frescura), alto contraste para accesibilidad
- **Tipografía**: Inter o Roboto, escalas `display` → `body` → `caption`
- **Componentes reutilizables**: Cards nutricionales, barras de progreso, botones de acción primaria/secundaria, states (loading, empty, error)

### 📱 Flujos Clave
1. **Onboarding** → Registro/Login → Verificación email
2. **Dashboard** → Resumen diario, calorías/macros, recomendaciones
3. **Registro de alimentos** → Búsqueda, porciones, historial
4. **Perfil y metas** → Peso, altura, objetivo, ajustes de plan
5. **Ajustes/Soporte** → Notificaciones, privacidad, cerrar sesión

### ✅ Buenas Prácticas UX
- Estados vacíos con ilustraciones y CTAs claros
- Validación en tiempo real de formularios
- Feedback táctil/visual al registrar comidas
- Navegación inferior (BottomNavigationBar) o lateral (Drawer) según densidad de pantallas
- Diseño responsive con `LayoutBuilder`, `MediaQuery` y `flexible` layouts

---

## 🏗️ 3. Arquitectura y Gestión de Estado

### 🧱 Estructura de Carpetas (`lib/`)
```
lib/
├── core/          # Constantes, temas, rutas, utils, servicios base
├── features/      # Módulos por dominio (auth, dashboard, meals, profile)
│   ├── auth/
│   ├── dashboard/
│   ├── meals/
│   └── profile/
├── shared/        # Widgets reutilizables, models, enums
└── main.dart      # Entry point, inicialización Firebase/Provider
```

### 🔄 State Management: `provider`
- `ChangeNotifier` por feature o servicio (ej. `AuthProvider`, `MealProvider`, `UserPrefsProvider`)
- `MultiProvider` en `main.dart` para inyección global
- Separación estricta: UI → Provider → Servicio/Repository → Firebase
- Evitar lógica de negocio en widgets; usar `Consumer` o `context.read/watch`

### 🗺️ Navegación
- `go_router` (recomendado) para rutas tipadas, navegación declarativa y deep linking
- Guards de autenticación para proteger rutas privadas
- Rutas nombradas y parámetros serializables

---

## 🔐 4. Autenticación y Seguridad

### 🔑 Flujo Login/Registro
- Email + contraseña vía `Firebase Auth`
- Validación de fortaleza de contraseña y formato de email
- Verificación de email opcional (recomendado para integridad de datos)
- Persistencia de sesión automática (`firebase_auth` maneja tokens)
- Recuperación de contraseña vía email
- Manejo de errores traducidos y UI específica (cuenta inexistente, contraseña incorrecta, red caída)

### 🛡️ Reglas de Seguridad (Firestore)
- Acceso estricto por `uid` del usuario autenticado
- Escritura solo permitida en colecciones propias (`users/{uid}`, `meals/{uid}/...`)
- Validación de tipos y límites en reglas (ej. máximo 50 registros/día)
- Índices automáticos y manuales para consultas frecuentes

---

## 🗄️ 5. Estructura de Base de Datos (Firestore)

| Colección | Documento | Campos Principales | Propósito |
|-----------|-----------|-------------------|-----------|
| `users` | `{uid}` | `email`, `displayName`, `createdAt`, `goals` (calories, macros, weightTarget) | Perfil y configuración global |
| `meals` | `{mealId}` (dentro de `users/{uid}/meals`) | `date`, `type` (breakfast/lunch/dinner/snack), `items[]`, `totalCalories`, `totalMacros` | Registro diario |
| `foods` | `{foodId}` (global o caché local) | `name`, `brand`, `caloriesPer100g`, `macros`, `servingSize`, `imageURL` | Catálogo de alimentos |
| `user_progress` | `{date}` | `weight`, `waterIntake`, `activityLevel`, `notes` | Seguimiento histórico |

> 📌 **Nota de arquitectura**: Mantener colecciones anidadas solo cuando el acceso es 1:1 y los documentos son pequeños. Para consultas cruzadas, considerar colecciones raíz con `userId` como campo.

---

## 📦 6. Dependencias (`pubspec.yaml`)

| Paquete | Versión (aprox.) | Función |
|---------|------------------|---------|
| `firebase_core` | `^2.x` | Inicialización Firebase |
| `firebase_auth` | `^4.x` | Autenticación email/password |
| `cloud_firestore` | `^4.x` | Base de datos Firestore |
| `provider` | `^6.x` | Gestión de estado |
| `go_router` | `^12.x` | Enrutamiento y guards |
| `flutter_dotenv` | `^5.x` | Variables de entorno (opcional) |
| `intl` | `^0.18.x` | Formateo de fechas/moneda |
| `cached_network_image` | `^3.x` | Imágenes con caché |
| `flutter_form_builder` + `form_builder_validators` | `^9.x` | Formularios reutilizables |
| `shared_preferences` | `^2.x` | Caché local ligero (tema, onboarding visto) |
| `logger` + `fluttertoast` o `another_flushbar` | `^2.x` / `^3.x` | Logging y notificaciones UI |
| `json_serializable` + `freezed` (opcional) | `^6.x` / `^2.x` | Modelos inmutables y serialización segura |

> 🔧 Dev dependencies: `flutter_lints`, `flutter_test`, `mockito`, `build_runner` (si usas serialización)

---

## 📝 7. Procedimiento Paso a Paso

### 🟢 Fase 1: Configuración Inicial (Día 1-2)
1. Instalar Flutter SDK, configurar PATH, verificar con `flutter doctor`
2. Crear proyecto: `flutter create easydiet`
3. Configurar Firebase: app en consola, descargar `google-services.json` / `GoogleService-Info.plist`
4. Instalar extensiones en VS Code, configurar linter y formateador
5. Inicializar Git, crear ramas `main`, `develop`, `feature/*`
6. Definir estructura de carpetas y archivos base (`core/`, `shared/`, `main.dart`)

### 🟡 Fase 2: Autenticación y Navegación (Día 3-5)
1. Configurar `firebase_core` y `firebase_auth` en `main.dart`
2. Crear `AuthProvider` con métodos: `login`, `register`, `logout`, `resetPassword`, `checkAuthState`
3. Implementar pantallas: Login, Register, Forgot Password, AuthWrapper
4. Configurar `go_router` con rutas protegidas y redirección automática
5. Validar formularios, manejar errores de Firebase, traducir mensajes

### 🟠 Fase 3: UI/UX Base y Temas (Día 6-8)
1. Definir `ThemeData` (colores, tipografía, elevaciones, bordes)
2. Crear componentes reutilizables: `PrimaryButton`, `InputField`, `LoadingOverlay`, `EmptyState`, `ErrorBanner`
3. Diseñar layout responsive para Dashboard y navegación inferior
4. Implementar estados de carga, vacío y error genéricos
5. Añadir transiciones suaves y feedback táctil

### 🔵 Fase 4: Firestore y Provider (Día 9-12)
1. Crear servicios: `FirestoreService`, `MealRepository`, `UserPrefsService`
2. Implementar `MealProvider` y `UserProvider` con `ChangeNotifier`
3. Conectar UI con streams/snapshots de Firestore (tiempo real)
4. Configurar reglas de seguridad en Firebase Console
5. Añadir caché local para catálogo de alimentos y preferencias

### 🟣 Fase 5: Features Core (Día 13-18)
1. Dashboard: resumen diario, gráficos simples (calorías, macros)
2. Registro de comidas: búsqueda, selección de porciones, guardado
3. Historial y edición de registros
4. Perfil: metas, peso, notificaciones, ajustes
5. Validación de datos, límites de entrada, confirmaciones

### 🟤 Fase 6: Pruebas y Pulido (Día 19-21)
1. Unit tests: Providers, validadores, servicios mockeados
2. Widget tests: pantallas críticas, estados de error/carga
3. Pruebas en Android/iOS/emuladores, ver rendimiento y consumo de red
4. Optimizar consultas Firestore, añadir índices necesarios
5. Accesibilidad: contraste, tamaños de texto, lectores de pantalla

### ⚫ Fase 7: Despliegue y CI/CD (Día 22-24)
1. Configurar `flutter_launcher_icons`, `flutter_native_splash`
2. Generar builds: `flutter build apk`, `flutter build ipa`
3. Subir a Firebase App Distribution / TestFlight / Play Console interno
4. Configurar GitHub Actions o Codemagic para builds automáticos
5. Documentar política de privacidad, términos, y guía de uso

---

## 🧪 8. Pruebas y Despliegue

| Tipo | Herramienta | Alcance |
|------|-------------|---------|
| Unit | `flutter_test`, `mockito` | Providers, validadores, utilidades |
| Widget | `flutter_test` | Interacción, estados, navegación |
| Integration | `integration_test` | Flujos completos (login → registro → dashboard) |
| Distribución | Firebase App Distribution, TestFlight, Play Console Beta | Pruebas reales con usuarios |
| CI/CD | GitHub Actions, Codemagic, Fastlane | Builds automáticos, lint, tests, deploy |

---

## ✅ 9. Entregables por Fase

| Fase | Entregable |
|------|------------|
| 1 | Proyecto inicializado, Firebase configurado, Git estructurado |
| 2 | Autenticación funcional, enrutamiento protegido, manejo de errores |
| 3 | Design system aplicado, componentes reutilizables, UI responsive |
| 4 | Firestore conectado, Providers activos, reglas de seguridad |
| 5 | Features core operativas, registro de comidas, dashboard, perfil |
| 6 | Tests escritos, optimizaciones aplicadas, pulido UX |
| 7 | Builds generados, CI/CD configurado, listo para stores |

---

📌 **Próximo paso sugerido**:  
Valida este plan y confirma:
1. ¿Quieres ajustar alguna fase, prioridad o dependencia?
2. ¿Prefieres comenzar con la Fase 1 (setup) o Fase 2 (auth + routing) en código?
3. ¿Necesitas wireframes base o estructura de modelos antes de implementar?

Cuando lo indiques, te proporcionaré el código correspondiente a la fase seleccionada, siguiendo estrictamente este roadmap. 🚀
