# promt
---

Eres un desarrollador Flutter senior experto en Firebase y arquitectura limpia. Tu tarea es implementar **EasyDiet**, una app de nutrición y dietas multiplataforma (Android, iOS, Web, Windows).

---

## STACK TECNOLÓGICO

- Flutter 3.19+ / Dart 3.3+
- Firebase Firestore (NoSQL) + Firebase Auth (Email/Password)
- State Management: Provider 6.1.1
- Navegación: GoRouter 13.0.0
- Gráficas: fl_chart 0.66.0

---

## ARQUITECTURA

Arquitectura limpia por features. Cada feature sigue esta estructura:

```
features/{feature}/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/   ← implementaciones
├── domain/
│   ├── entities/
│   ├── repositories/   ← contratos/interfaces
│   └── usecases/
└── presentation/
    ├── providers/
    ├── screens/
    └── widgets/
```

Features: `auth`, `paciente`, `nutricionista`, `diet_plan`, `alimentos`, `tracking`, `consultas`

Carpetas globales: `core/` (constants, errors, theme, utils, network) y `shared/` (widgets, models, providers)

---

## PALETA DE COLORES

```dart
primaryGreen:    #2E7D32   // acciones principales
primaryLight:    #66BB6A   // hover / activo
primaryDark:     #1B5E20   // textos importantes
secondaryBlue:   #1976D2   // información / links
accentOrange:    #FF6F00   // CTAs secundarios
accentRed:       #D32F2F   // errores / eliminar
backgroundMain:  #FAFAFA
backgroundCard:  #FFFFFF
textPrimary:     #212121
textSecondary:   #757575
success:         #4CAF50
warning:         #FF9800
error:           #F44336
```

Tipografía: **Poppins** (via google_fonts). Headers 24-32px bold, body 14-16px regular, captions 12px medium.

---

## MODELO DE DATOS FIRESTORE

Colecciones raíz: `users`, `pacientes`, `nutricionistas`, `planes_dieta`, `alimentos`, `recetas`, `categorias_alimento`, `consultas`

Subcolecciones:
- `/planes_dieta/{id}/dias_plan/{id}/comidas_dia/{id}`
- `/recetas/{id}/receta_ingredientes/{id}`
- `/pacientes/{id}/registros_progreso/{id}`
- `/pacientes/{id}/medidas_corporales/{id}`
- `/pacientes/{id}/alergias_intolerancias/{id}`

Campos clave por colección:

**users:** id, email, nombre, apellido, telefono, rol(enum: paciente|nutricionista|admin), activo, created_at, updated_at

**pacientes:** id, usuario_id, nutricionista_id, fecha_nacimiento, sexo, altura_cm, peso_inicial_kg, objetivo_peso_kg, nivel_actividad(enum: sedentario|ligero|moderado|activo|muy_activo), objetivo_dieta(enum: perder_peso|mantener|ganar_musculo), notas_medicas, created_at

**nutricionistas:** id, usuario_id, numero_colegiado, especialidad, descripcion, verificado, created_at

**planes_dieta:** id, paciente_id, nutricionista_id, nombre, descripcion, fecha_inicio, fecha_fin, calorias_objetivo, proteinas_g, carbohidratos_g, grasas_g, estado(enum: activo|completado|cancelado|borrador), created_at

**dias_plan:** id, numero_dia, dia_semana(enum: lunes..domingo), calorias_dia, observaciones

**comidas_dia:** id, receta_id, tipo_comida(enum: desayuno|media_manana|almuerzo|merienda|cena), orden, cantidad_raciones, calorias_total, notas

**alimentos:** id, categoria_id, nombre, codigo_barras, calorias_100g, proteinas_100g, carbohidratos_100g, grasas_100g, fibra_100g, sodio_100g, es_generico, created_at

**recetas:** id, nutricionista_id, nombre, descripcion, tiempo_preparacion_min, tiempo_coccion_min, raciones, calorias_racion, proteinas_racion, carbohidratos_racion, grasas_racion, dificultad(enum: facil|media|dificil), es_publica, created_at

**receta_ingredientes:** id, alimento_id, cantidad, unidad_medida(enum: gramos|mililitros|tazas|cucharadas|unidades), notas_prep

**registros_progreso:** id, paciente_id, fecha, peso_kg, imc, porcentaje_grasa, masa_muscular_kg, calorias_consumidas, agua_ml, pasos, minutos_ejercicio, notas, created_at

**medidas_corporales:** id, paciente_id, fecha, cintura_cm, cadera_cm, pecho_cm, brazo_cm, muslo_cm, cuello_cm

**alergias_intolerancias:** id, paciente_id, alimento_id, tipo(enum: alergia|intolerancia|preferencia), severidad(enum: leve|moderada|severa), observaciones

**consultas:** id, paciente_id, nutricionista_id, fecha_hora, duracion_min, modalidad(enum: presencial|online|telefonica), estado(enum: programada|completada|cancelada|no_asistio), notas_previas, notas_sesion, peso_consulta, created_at

---

## DEPENDENCIAS PUBSPEC

```yaml
firebase_core: ^2.24.2
firebase_auth: ^4.16.0
cloud_firestore: ^4.14.0
provider: ^6.1.1
google_fonts: ^6.1.0
go_router: ^13.0.0
flutter_form_builder: ^9.2.1
form_builder_validators: ^9.1.0
fl_chart: ^0.66.0
flutter_svg: ^2.0.9
cached_network_image: ^3.3.1
shimmer: ^3.0.0
intl: ^0.19.0
shared_preferences: ^2.2.2
uuid: ^4.3.3
equatable: ^2.0.5
responsive_framework: ^1.4.0
```

---

## REGLAS DE SEGURIDAD FIRESTORE (resumen)

- `users`: solo el propio usuario lee/escribe; nutricionistas pueden leer
- `pacientes`: acceso al propio paciente y a su nutricionista_id asignado
- `nutricionistas`: lectura autenticada libre; escritura solo el dueño
- `planes_dieta` y subcolecciones: acceso a paciente_id y nutricionista_id del plan
- `alimentos`: lectura libre autenticada; escritura solo admin o nutricionista
- `recetas`: lectura libre si es_publica=true; si no, solo el nutricionista creador
- `registros_progreso`, `medidas_corporales`, `alergias_intolerancias`: paciente y su nutricionista asignado
- `consultas`: paciente_id y nutricionista_id del documento

---

## ÍNDICES COMPUESTOS NECESARIOS

- `pacientes`: nutricionista_id ASC + created_at DESC
- `planes_dieta`: paciente_id ASC + estado ASC + fecha_inicio DESC
- `consultas`: paciente_id ASC + fecha_hora DESC
- `registros_progreso`: fecha DESC

---

## PATRÓN DE IMPLEMENTACIÓN POR FEATURE

1. Definir `Entity` en domain/entities (clases Dart puras, sin dependencias)
2. Definir contrato `Repository` en domain/repositories (interfaz abstracta)
3. Implementar `Model` en data/models (extiende Entity, añade fromJson/toJson para Firestore)
4. Implementar `RepositoryImpl` en data/repositories (usa FirebaseFirestore.instance)
5. Implementar `Provider` en presentation/providers (extiende ChangeNotifier, consume el repositorio)
6. Construir screens y widgets en presentation/

---

## CONFIGURACIÓN MAIN.DART

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => PacienteProvider()),
    ChangeNotifierProvider(create: (_) => NutricionistaProvider()),
    ChangeNotifierProvider(create: (_) => DietPlanProvider()),
    ChangeNotifierProvider(create: (_) => AlimentosProvider()),
    ChangeNotifierProvider(create: (_) => TrackingProvider()),
    ChangeNotifierProvider(create: (_) => ConsultasProvider()),
    ChangeNotifierProvider(create: (_) => SharedProvider()),
  ], child: const EasyDietApp()));
}
```

---

# 📋 PLAN DE IMPLEMENTACIÓN PROFESIONAL: EasyDiet
## Flutter + Firebase Firestore + Provider

---

## 🎯 1. ARQUITECTURA Y TECNOLOGÍAS

### Stack Tecnológico
- **Framework**: Flutter 3.19+ (Dart 3.3+)
- **Backend**: Firebase Firestore (NoSQL)
- **Autenticación**: Firebase Auth (Email/Password)
- **State Management**: Provider 6.1.1
- **Plataformas**: Android, iOS, Web, Windows
- **IDE**: VS Code con extensiones Flutter/Dart

---

##  2. ESTRUCTURA DE CARPETAS (Dentro de `bin/`)

```
bin/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   ├── app_dimensions.dart
│   │   └── enums.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── text_styles.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── date_formatters.dart
│   │   └── helpers.dart
│   └── network/
│       └── firebase_config.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── register_usecase.dart
│   │   │       └── logout_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   ├── register_screen.dart
│   │       │   └── forgot_password_screen.dart
│   │       └── widgets/
│   │           ├── auth_form_field.dart
│   │           └── auth_button.dart
│   │
│   ├── paciente/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── paciente_model.dart
│   │   │   └── repositories/
│   │   │       └── paciente_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── paciente_entity.dart
│   │   │   └── repositories/
│   │   │       └── paciente_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── paciente_provider.dart
│   │       └── screens/
│   │           └── paciente_profile_screen.dart
│   │
│   ├── nutricionista/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── nutricionista_model.dart
│   │   │   └── repositories/
│   │   │       └── nutricionista_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── nutricionista_entity.dart
│   │   │   └── repositories/
│   │   │       └── nutricionista_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── nutricionista_provider.dart
│   │       └── screens/
│   │           └── nutricionista_dashboard_screen.dart
│   │
│   ├── diet_plan/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── plan_dieta_model.dart
│   │   │   │   ├── dia_plan_model.dart
│   │   │   │   └── comidas_dia_model.dart
│   │   │   └── repositories/
│   │   │       └── diet_plan_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── plan_dieta_entity.dart
│   │   │   │   ├── dia_plan_entity.dart
│   │   │   │   └── comidas_dia_entity.dart
│   │   │   └── repositories/
│   │   │       └── diet_plan_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── diet_plan_provider.dart
│   │       └── screens/
│   │           ├── plan_list_screen.dart
│   │           ├── plan_detail_screen.dart
│   │           └── create_plan_screen.dart
│   │
│   ├── alimentos/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── alimento_model.dart
│   │   │   │   ├── receta_model.dart
│   │   │   │   └── categoria_model.dart
│   │   │   └── repositories/
│   │   │       └── alimentos_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── alimento_entity.dart
│   │   │   │   ├── receta_entity.dart
│   │   │   │   └── categoria_entity.dart
│   │   │   └── repositories/
│   │   │       └── alimentos_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── alimentos_provider.dart
│   │       └── screens/
│   │           ├── alimentos_catalog_screen.dart
│   │           └── recetas_screen.dart
│   │
│   ├── tracking/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── progreso_model.dart
│   │   │   │   └── medidas_model.dart
│   │   │   └── repositories/
│   │   │       └── tracking_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── progreso_entity.dart
│   │   │   │   └── medidas_entity.dart
│   │   │   └── repositories/
│   │   │       └── tracking_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── tracking_provider.dart
│   │       └── screens/
│   │           ├── progreso_screen.dart
│   │           └── medidas_screen.dart
│   │
│   └── consultas/
│       ├── data/
│       │   ├── models/
│       │   │   └── consulta_model.dart
│       │   └── repositories/
│       │       └── consultas_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── consulta_entity.dart
│       │   └── repositories/
│       │       └── consultas_repository.dart
│       └── presentation/
│           ├── providers/
│           │   └── consultas_provider.dart
│           └── screens/
│               └── consultas_screen.dart
│
├── shared/
│   ├── widgets/
│   │   ├── custom_app_bar.dart
│   │   ├── custom_card.dart
│   │   ├── loading_indicator.dart
│   │   ├── empty_state.dart
│   │   └── error_message.dart
│   ├── models/
│   │   └── base_model.dart
│   └── providers/
│       └── shared_provider.dart
│
└── main.dart
```

---

## 🎨 3. DISEÑO UI/UX - SISTEMA DE COLORES

### Paleta de Colores Principal

```dart
// Colores Primarios
primaryGreen: #2E7D32        // Verde bosque - Acciones principales
primaryLight: #66BB6A        // Verde claro - Hover/estados activos
primaryDark: #1B5E20         // Verde oscuro - Textos importantes

// Colores Secundarios
secondaryBlue: #1976D2       // Azul médico - Información/links
secondaryLight: #42A5F5      // Azul claro - Fondos secundarios
secondaryDark: #0D47A1       // Azul oscuro - Headers

// Colores de Acento
accentOrange: #FF6F00        // Naranja - CTAs secundarios
accentYellow: #FFD600        // Amarillo - Alertas/advertencias
accentRed: #D32F2F           // Rojo - Errores/eliminaciones

// Colores Neutros
backgroundMain: #FAFAFA      // Gris muy claro - Fondo principal
backgroundCard: #FFFFFF      // Blanco - Tarjetas
surface: #F5F5F5             // Gris claro - Superficies
border: #E0E0E0              // Gris medio - Bordes

// Textos
textPrimary: #212121         // Casi negro - Títulos
textSecondary: #757575       // Gris - Subtítulos
textHint: #9E9E9E            // Gris claro - Placeholders
textDisabled: #BDBDBD        // Gris muy claro - Deshabilitado

// Estados
success: #4CAF50             // Verde éxito
warning: #FF9800             // Naranja advertencia
error: #F44336               // Rojo error
info: #2196F3                // Azul información
```

### Tipografía
- **Fuente Principal**: Inter / Poppins
- **Headers**: 24-32px (Bold)
- **Body**: 14-16px (Regular)
- **Captions**: 12px (Medium)

---

## 📦 4. DEPENDENCIAS - pubspec.yaml

```yaml
name: easydiet
description: Aplicación de nutrición y dietas
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  
  # State Management
  provider: ^6.1.1
  
  # UI/UX
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  flutter_slidable: ^3.0.1
  
  # Forms & Validation
  flutter_form_builder: ^9.2.1
  form_builder_validators: ^9.1.0
  
  # Navigation
  go_router: ^13.0.0
  
  # Date & Time
  intl: ^0.19.0
  
  # Local Storage
  shared_preferences: ^2.2.2
  
  # Utils
  uuid: ^4.3.3
  equatable: ^2.0.5
  
  # Charts (para gráficas de progreso)
  fl_chart: ^0.66.0
  
  # Responsive
  responsive_framework: ^1.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.8
  json_serializable: ^6.7.1

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/
```

---

## 🗄️ 5. ESTRUCTURA DE BASE DE DATOS - FIRESTORE

### Adaptación de Tablas Relacionales a Colecciones NoSQL

#### **Colección: users** (Autenticación + Datos básicos)
```
/users/{userId}
{
  id: string (uuid),
  email: string,
  password_hash: string (manejado por Firebase Auth),
  nombre: string,
  apellido: string,
  telefono: string,
  rol: enum ['paciente', 'nutricionista', 'admin'],
  activo: boolean,
  created_at: timestamp,
  updated_at: timestamp
}
```

#### **Colección: pacientes**
```
/pacientes/{pacienteId}
{
  id: string (uuid),
  usuario_id: string (FK → users),
  nutricionista_id: string (FK → nutricionistas),
  fecha_nacimiento: date,
  sexo: enum ['masculino', 'femenino', 'otro'],
  altura_cm: double,
  peso_inicial_kg: double,
  objetivo_peso_kg: double,
  nivel_actividad: enum ['sedentario', 'ligero', 'moderado', 'activo', 'muy_activo'],
  objetivo_dieta: enum ['perder_peso', 'mantener', 'ganar_musculo'],
  notas_medicas: string,
  created_at: timestamp
}
```

#### **Colección: nutricionistas**
```
/nutricionistas/{nutricionistaId}
{
  id: string (uuid),
  usuario_id: string (FK → users),
  numero_colegiado: string,
  especialidad: string,
  descripcion: string,
  verificado: boolean,
  created_at: timestamp
}
```

#### **Colección: planes_dieta**
```
/planes_dieta/{planId}
{
  id: string (uuid),
  paciente_id: string (FK → pacientes),
  nutricionista_id: string (FK → nutricionistas),
  nombre: string,
  descripcion: string,
  fecha_inicio: date,
  fecha_fin: date,
  calorias_objetivo: int,
  proteinas_g: int,
  carbohidratos_g: int,
  grasas_g: int,
  estado: enum ['activo', 'completado', 'cancelado', 'borrador'],
  created_at: timestamp
}
```

#### **Subcolección: dias_plan** (dentro de planes_dieta)
```
/planes_dieta/{planId}/dias_plan/{diaId}
{
  id: string (uuid),
  numero_dia: int,
  dia_semana: enum ['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'],
  calorias_dia: int,
  observaciones: string
}
```

#### **Subcolección: comidas_dia** (dentro de dias_plan)
```
/planes_dieta/{planId}/dias_plan/{diaId}/comidas_dia/{comidaId}
{
  id: string (uuid),
  receta_id: string (FK → recetas),
  tipo_comida: enum ['desayuno', 'media_manana', 'almuerzo', 'merienda', 'cena'],
  orden: int,
  cantidad_raciones: double,
  calorias_total: int,
  notas: string
}
```

#### **Colección: alimentos**
```
/alimentos/{alimentoId}
{
  id: string (uuid),
  categoria_id: string (FK → categorias_alimento),
  nombre: string,
  codigo_barras: string,
  calorias_100g: double,
  proteinas_100g: double,
  carbohidratos_100g: double,
  grasas_100g: double,
  fibra_100g: double,
  sodio_100g: double,
  es_generico: boolean,
  created_at: timestamp
}
```

#### **Colección: recetas**
```
/recetas/{recetaId}
{
  id: string (uuid),
  nutricionista_id: string (FK → nutricionistas),
  nombre: string,
  descripcion: string,
  tiempo_preparacion_min: int,
  tiempo_coccion_min: int,
  raciones: int,
  calorias_racion: double,
  proteinas_racion: double,
  carbohidratos_racion: double,
  grasas_racion: double,
  dificultad: enum ['facil', 'media', 'dificil'],
  es_publica: boolean,
  created_at: timestamp
}
```

#### **Subcolección: receta_ingredientes** (dentro de recetas)
```
/recetas/{recetaId}/receta_ingredientes/{ingredienteId}
{
  id: string (uuid),
  alimento_id: string (FK → alimentos),
  cantidad: double,
  unidad_medida: enum ['gramos', 'mililitros', 'tazas', 'cucharadas', 'unidades'],
  notas_prep: string
}
```

#### **Colección: categorias_alimento**
```
/categorias_alimento/{categoriaId}
{
  id: string (uuid),
  nombre: string,
  descripcion: string,
  parent_id: string (FK → categorias_alimento - para categorías anidadas)
}
```

#### **Colección: registros_progreso**
```
/pacientes/{pacienteId}/registros_progreso/{registroId}
{
  id: string (uuid),
  paciente_id: string (FK → pacientes),
  fecha: date,
  peso_kg: double,
  imc: double,
  porcentaje_grasa: double,
  masa_muscular_kg: double,
  calorias_consumidas: int,
  agua_ml: int,
  pasos: int,
  minutos_ejercicio: int,
  notas: string,
  created_at: timestamp
}
```

#### **Colección: medidas_corporales**
```
/pacientes/{pacienteId}/medidas_corporales/{medidaId}
{
  id: string (uuid),
  paciente_id: string (FK → pacientes),
  fecha: date,
  cintura_cm: double,
  cadera_cm: double,
  pecho_cm: double,
  brazo_cm: double,
  muslo_cm: double,
  cuello_cm: double
}
```

#### **Colección: alergias_intolerancias**
```
/pacientes/{pacienteId}/alergias_intolerancias/{alergiaId}
{
  id: string (uuid),
  paciente_id: string (FK → pacientes),
  alimento_id: string (FK → alimentos),
  tipo: enum ['alergia', 'intolerancia', 'preferencia'],
  severidad: enum ['leve', 'moderada', 'severa'],
  observaciones: string
}
```

#### **Colección: consultas**
```
/consultas/{consultaId}
{
  id: string (uuid),
  paciente_id: string (FK → pacientes),
  nutricionista_id: string (FK → nutricionistas),
  fecha_hora: datetime,
  duracion_min: int,
  modalidad: enum ['presencial', 'online', 'telefonica'],
  estado: enum ['programada', 'completada', 'cancelada', 'no_asistio'],
  notas_previas: string,
  notas_sesion: string,
  peso_consulta: double,
  created_at: timestamp
}
```

---

## 📱 6. CONSIDERACIONES MULTIPLATAFORMA

### Configuraciones Especiales

#### **Android**
- `minSdkVersion: 23`
- Permisos: Internet, Camera (para escanear códigos de barras)
- Configuración de Firebase en `google-services.json`

#### **iOS**
- `iOS 12.0+`
- Permisos en `Info.plist`: Camera, Photo Library
- Configuración de Firebase en `GoogleService-Info.plist`

#### **Web**
- Habilitar Firestore y Auth en Firebase Console
- Configurar CORS si es necesario
- Optimizar imágenes para web

#### **Windows**
- Configurar Firebase para desktop
- Habilitar autenticación offline
- Ajustar tamaño de ventana mínimo: 800x600

---

## 🔄 7. FLUJO DE TRABAJO CON PROVIDER

### Arquitectura de Providers

```dart
// main.dart - Configuración inicial
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    MultiProvider(
      providers: [
        // Auth Provider (Global)
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        
        // Feature Providers
        ChangeNotifierProvider(create: (_) => PacienteProvider()),
        ChangeNotifierProvider(create: (_) => NutricionistaProvider()),
        ChangeNotifierProvider(create: (_) => DietPlanProvider()),
        ChangeNotifierProvider(create: (_) => AlimentosProvider()),
        ChangeNotifierProvider(create: (_) => TrackingProvider()),
        ChangeNotifierProvider(create: (_) => ConsultasProvider()),
        
        // Shared Provider
        ChangeNotifierProvider(create: (_) => SharedProvider()),
      ],
      child: const EasyDietApp(),
    ),
  );
}
```

### Patrón de Implementación por Feature

```
1. Model (Data Layer)
   ↓
2. Repository (Domain Layer)  
   ↓
3. UseCase (Domain Layer - opcional)
   ↓
4. Provider (Presentation Layer)
   ↓
5. Screen/Widget (UI Layer)
```

---

## 🚀 8. FASES DE DESARROLLO DETALLADAS

### **FASE 1: Configuración Inicial** (Días 1-3)
- [ ] Configurar Flutter SDK y VS Code
- [ ] Crear proyecto Flutter multiplataforma
- [ ] Configurar Firebase Console (Web, Android, iOS, Windows)
- [ ] Descargar e integrar archivos de configuración Firebase
- [ ] Estructurar carpetas según arquitectura definida
- [ ] Configurar `pubspec.yaml` con todas las dependencias
- [ ] Implementar `main.dart` con MultiProvider
- [ ] Configurar tema y colores en `app_theme.dart`
- [ ] Setup de Git y repositorio

### **FASE 2: Autenticación** (Días 4-7)
- [ ] Configurar Firebase Auth (Email/Password)
- [ ] Implementar `AuthProvider` con métodos:
  - register()
  - login()
  - logout()
  - resetPassword()
  - updateProfile()
- [ ] Crear pantallas:
  - LoginScreen (con validación)
  - RegisterScreen (selección de rol)
  - ForgotPasswordScreen
- [ ] Implementar validaciones de formularios
- [ ] Manejo de errores y mensajes
- [ ] Persistencia de sesión
- [ ] Navegación protegida con GoRouter

### **FASE 3: Core - Usuarios y Perfiles** (Días 8-12)
- [ ] Implementar modelo `UserEntity` y `UserModel`
- [ ] Crear colecciones Firestore: `users`, `pacientes`, `nutricionistas`
- [ ] Implementar `PacienteProvider`:
  - CRUD completo
  - Búsqueda por nutricionista
  - Actualización de perfil
- [ ] Implementar `NutricionistaProvider`:
  - CRUD completo
  - Verificación de número colegiado
  - Lista de pacientes asignados
- [ ] Pantallas de perfil según rol
- [ ] Upload de imágenes de perfil (opcional)

### **FASE 4: Catálogo de Alimentos y Recetas** (Días 13-18)
- [ ] Implementar modelos de alimentos, recetas, categorías
- [ ] Crear colecciones: `alimentos`, `recetas`, `categorias_alimento`
- [ ] Implementar `AlimentosProvider`:
  - Búsqueda avanzada
  - Filtrado por categoría
  - Escaneo de código de barras (futuro)
- [ ] Subcolección `receta_ingredientes`
- [ ] Pantallas:
  - Catálogo de alimentos
  - Lista de recetas
  - Detalle de receta con ingredientes
  - Crear/editar receta (nutricionistas)

### **FASE 5: Planes de Dieta** (Días 19-26)
- [ ] Implementar modelos: `PlanDieta`, `DiaPlan`, `ComidasDia`
- [ ] Estructura de subcolecciones anidadas
- [ ] Implementar `DietPlanProvider`:
  - Crear plan completo
  - Asignar días y comidas
  - Calcular totales nutricionales
  - Cambiar estado del plan
- [ ] Pantallas:
  - Lista de planes (paciente/nutricionista)
  - Detalle de plan con vista semanal
  - Crear/editar plan (wizard multi-paso)
  - Vista de día específico con comidas

### **FASE 6: Seguimiento y Progreso** (Días 27-32)
- [ ] Implementar modelos de progreso y medidas
- [ ] Colecciones: `registros_progreso`, `medidas_corporales`
- [ ] Implementar `TrackingProvider`:
  - Registro diario de peso, calorías, agua
  - Historial de medidas corporales
  - Cálculo automático de IMC
- [ ] Gráficas de progreso con `fl_chart`:
  - Evolución de peso
  - Porcentaje de grasa
  - Medidas corporales
- [ ] Pantallas:
  - Dashboard de progreso
  - Formulario de registro diario
  - Historial completo

### **FASE 7: Consultas y Salud** (Días 33-37)
- [ ] Implementar modelo `Consulta`
- [ ] Colección: `consultas`
- [ ] Implementar `ConsultasProvider`:
  - Agendar citas
  - Historial de consultas
  - Notas de sesión
- [ ] Colección: `alergias_intolerancias`
- [ ] Pantallas:
  - Calendario de consultas
  - Detalle de consulta
  - Registro de alergias

### **FASE 8: UI/UX Avanzado** (Días 38-42)
- [ ] Implementar widgets reutilizables:
  - CustomAppBar responsive
  - CustomCard con sombras
  - LoadingOverlay
  - EmptyState ilustrado
  - ErrorBanner
- [ ] Animaciones y transiciones
- [ ] Dark mode (opcional)
- [ ] Responsive design para tablets/desktop
- [ ] Optimización de imágenes
- [ ] Accesibilidad (screen readers, contraste)

### **FASE 9: Testing y Optimización** (Días 43-47)
- [ ] Unit tests para Providers
- [ ] Widget tests para pantallas críticas
- [ ] Integration tests para flujos completos
- [ ] Pruebas en todas las plataformas
- [ ] Optimización de queries Firestore
- [ ] Implementar índices compuestos
- [ ] Caché offline de Firestore
- [ ] Reducción de rebuilds en Provider

### **FASE 10: Despliegue** (Días 48-50)
- [ ] Configurar icons y splash screen
- [ ] Generar builds:
  - Android: APK y AAB
  - iOS: IPA
  - Web: Build optimizado
  - Windows: EXE
- [ ] Pruebas en dispositivos reales
- [ ] Documentación de usuario
- [ ] Preparar stores (Play Store, App Store)
- [ ] Deploy web a Firebase Hosting

---

## 🔐 9. REGLAS DE SEGURIDAD FIRESTORE

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Función auxiliar para verificar autenticación
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Función para verificar si es el dueño del recurso
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Función para verificar rol
    function hasRole(role) {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.rol == role;
    }
    
    // Users - Solo el usuario puede leer/escribir sus datos
    match /users/{userId} {
      allow read: if isOwner(userId) || hasRole('nutricionista');
      allow write: if isOwner(userId);
    }
    
    // Pacientes - Paciente y su nutricionista pueden acceder
    match /pacientes/{pacienteId} {
      allow read: if isOwner(resource.data.usuario_id) ||
                     request.auth.uid == resource.data.nutricionista_id ||
                     hasRole('admin');
      allow write: if isOwner(resource.data.usuario_id) ||
                      hasRole('nutricionista');
    }
    
    // Nutricionistas - Público para lectura, solo dueño para escritura
    match /nutricionistas/{nutricionistaId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(resource.data.usuario_id);
    }
    
    // Planes de dieta - Paciente y nutricionista asignado
    match /planes_dieta/{planId} {
      allow read: if request.auth.uid == resource.data.paciente_id ||
                     request.auth.uid == resource.data.nutricionista_id;
      allow write: if request.auth.uid == resource.data.nutricionista_id;
      
      // Subcolección días_plan
      match /dias_plan/{diaId} {
        allow read, write: if request.auth.uid == get(/databases/$(database)/documents/planes_dieta/$(planId)).data.nutricionista_id;
        
        // Subcolección comidas_dia
        match /comidas_dia/{comidaId} {
          allow read, write: if request.auth.uid == get(/databases/$(database)/documents/planes_dieta/$(planId)).data.nutricionista_id;
        }
      }
    }
    
    // Alimentos - Lectura pública, escritura solo admins/nutricionistas
    match /alimentos/{alimentoId} {
      allow read: if isAuthenticated();
      allow write: if hasRole('admin') || hasRole('nutricionista');
    }
    
    // Recetas - Públicas si es_publica=true, privadas solo creador
    match /recetas/{recetaId} {
      allow read: if resource.data.es_publica == true ||
                     request.auth.uid == resource.data.nutricionista_id;
      allow write: if request.auth.uid == resource.data.nutricionista_id;
      
      match /receta_ingredientes/{ingredienteId} {
        allow read, write: if request.auth.uid == get(/databases/$(database)/documents/recetas/$(recetaId)).data.nutricionista_id;
      }
    }
    
    // Progreso - Solo paciente y su nutricionista
    match /pacientes/{pacienteId}/registros_progreso/{registroId} {
      allow read, write: if request.auth.uid == pacienteId ||
                            request.auth.uid == get(/databases/$(database)/documents/pacientes/$(pacienteId)).data.nutricionista_id;
    }
    
    // Consultas - Paciente y nutricionista involucrados
    match /consultas/{consultaId} {
      allow read, write: if request.auth.uid == resource.data.paciente_id ||
                            request.auth.uid == resource.data.nutricionista_id;
    }
  }
}
```

---

## 📊 10. ÍNDICES FIRESTORE NECESARIOS

```json
{
  "indexes": [
    {
      "collectionGroup": "pacientes",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "nutricionista_id", "order": "ASCENDING" },
        { "fieldPath": "created_at", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "planes_dieta",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "paciente_id", "order": "ASCENDING" },
        { "fieldPath": "estado", "order": "ASCENDING" },
        { "fieldPath": "fecha_inicio", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "consultas",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "paciente_id", "order": "ASCENDING" },
        { "fieldPath": "fecha_hora", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "registros_progreso",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "fecha", "order": "DESCENDING" }
      ]
    }
  ]
}
```

---

## ✅ 11. CHECKLIST DE CALIDAD

### Código
- [ ] Linting con `flutter_lints` activado
- [ ] Sin warnings en consola
- [ ] Documentación de funciones públicas
- [ ] Manejo de errores en todas las llamadas async
- [ ] Dispose de controllers y streams

### UX
- [ ] Loading states en todas las operaciones
- [ ] Empty states cuando no hay datos
- [ ] Error states con mensajes claros
- [ ] Validación de formularios en tiempo real
- [ ] Feedback visual en acciones (toast/snackbar)

### Performance
- [ ] Imágenes optimizadas y cacheadas
- [ ] Paginación en listas largas
- [ ] Queries Firestore optimizadas
- [ ] Evitar rebuilds innecesarios en Provider
- [ ] Lazy loading de datos

### Seguridad
- [ ] Reglas de seguridad probadas
- [ ] Validación de datos en frontend y backend
- [ ] Sanitización de inputs
- [ ] Tokens de autenticación seguros
- [ ] HTTPS forzado

---

## 📝 12. DOCUMENTACIÓN ADICIONAL REQUERIDA

1. **README.md** - Instalación y configuración
2. **CONTRIBUTING.md** - Guía de contribución
3. **API_DOCUMENTATION.md** - Estructura de datos Firestore
4. **DEPLOYMENT.md** - Guía de despliegue por plataforma
5. **USER_MANUAL.md** - Manual de usuario final

---

## 🎯 PRÓXIMOS PASOS INMEDIATOS

1. **Validar este plan** con el equipo/stakeholders
2. **Configurar entorno de desarrollo** (Día 1)
3. **Iniciar Fase 1** - Setup del proyecto
4. **Revisión semanal** de progreso por fases
5. **Testing continuo** desde la Fase 3

---

**¿Listo para comenzar?** Indica si deseas:
- Ajustar alguna fase o dependencia
- Comenzar con la implementación de la Fase 1
- Recibir wireframes/mockups adicionales
- Modificar la paleta de colores

¡Este plan está diseñado para ser profesional, escalable y mantenible! 🚀
