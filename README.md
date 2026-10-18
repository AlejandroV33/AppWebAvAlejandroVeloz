# 🎵 PoliMusic — Aplicación web tipo YouTube Music (ASP clásico)

Aplicación web Full-Stack construida con **ASP clásico (VBScript)** para el backend
y **HTML + CSS + JavaScript** para el frontend. Diseño original en **modo oscuro**
con acento **verde lima**, tabla de canciones estilizada, reproductor de audio HTML5
y control de acceso por roles (Usuario Normal / Administrador).

Funciona contra el esquema de **`BDD_PoliMusic.sql`** y usa los recursos de
**`SongFiles/`**, **`UserImages/`** y **`PlaylistImages/`**.

---

## 1. Requisitos

- Windows con **IIS** y la característica **ASP** habilitada.
- **SQL Server** (Express, LocalDB o instancia completa).
- SQL Server Management Studio (SSMS) para ejecutar `BDD_PoliMusic.sql`.

### Habilitar ASP en IIS

1. Panel de control → Programas → Activar o desactivar características de Windows.
2. Internet Information Services → Servicios World Wide Web → Características de desarrollo de aplicaciones.
3. Marcar **ASP**. Reiniciar IIS (`iisreset`).

---

## 2. Estructura del proyecto

```
PoliMusicWeb/
├── BDD_PoliMusic.sql        Esquema + datos iniciales (PROPORCIONADO)
├── login.asp                Inicio de sesión (usuario o correo)
├── logout.asp               Cierre de sesión
├── index.asp                Pantalla principal: bienvenida + Song List + reproductor
├── playlists.asp            Listas de reproducción (TBL_PLAYLIST)
├── playlist_detail.asp      Detalle de lista + sus canciones
├── albums.asp               Álbumes (TBL_ALBUM)
├── album_detail.asp         Detalle de álbum + sus canciones (TBL_TRACKLIST)
├── artists.asp              Artistas (TBL_ARTIST)
├── users.asp                (ADMIN) Gestión de usuarios
├── song_form.asp            (ADMIN) Crear/editar canción + artistas (TBL_PLAYER)
├── *_save.asp / *_delete.asp  Handlers POST de cada entidad
├── *_song_add.asp / *_song_remove.asp  Gestión de canciones en listas/álbumes
├── play_count.asp           Incrementa TBL_SONG.PLAYS al reproducir
├── includes/
│   ├── config.asp           Cadena de conexión, rutas, utilidades y SHA-1 puro
│   ├── db.asp               Clase PoliDB (Scalar / Execute / Recordset parametrizados)
│   ├── auth.asp             RequireLogin, RequireAdmin, helpers de sesión
│   └── layout.asp           Estructura visual común (sidebar, topbar, reproductor)
├── assets/
│   ├── css/style.css        Tema oscuro + verde lima (responsive)
│   └── js/app.js            Reproductor, cola, búsqueda, toasts, menú
├── UserImages/              Fotos de perfil (.jpg/.png)
├── PlaylistImages/          Portadas de listas
└── SongFiles/               Pistas .mp3
```

---

## 3. Puesta en marcha

### Paso 1 — Base de datos

1. Abrir SSMS y conectarse a la instancia local.
2. Ejecutar **`BDD_PoliMusic.sql`** completo (crea el login `usr_polimusic`,
   la base `BDD_PoliMusic`, las tablas y los datos iniciales).

### Paso 2 — Cadena de conexión

`includes/config.asp` ya trae la cadena acorde al script:

```vbscript
Const DB_CONNSTR = "Provider=SQLOLEDB.1;Data Source=.\SQLEXPRESS;Initial Catalog=BDD_PoliMusic;User ID=usr_polimusic;Password=Politecnica1;"
```

Ajustar `Data Source` si la instancia tiene otro nombre. Se incluye comentada la
variante con autenticación de Windows.

### Paso 3 — Publicar en IIS

1. Copiar la carpeta `PoliMusicWeb` dentro de `C:\inetpub\wwwroot\` (o mantenerla donde esté).
2. IIS → *Default Web Site* → clic derecho → **Agregar aplicación**: alias `PoliMusic`.
3. Dar permiso de **lectura** a `IIS_IUSRS` sobre la carpeta del proyecto.
4. Abrir: `http://localhost/PoliMusic/login.asp`

---

## 4. Usuarios por defecto

| Usuario     | Contraseña  | Correo                       | Tipo (USER_TYPE) |
|-------------|-------------|------------------------------|------------------|
| userNormal  | 12345678    | usrnormal@epn.edu.ec         | 0 - Usuario Normal |
| userAdmin   | 12345678    | usrfakeadmin@epn.edu.ec      | 1 - Administrador |
| username1   | 12345678    | username1@epn.edu.ec         | 0 - Usuario Normal |

- El login acepta **usuario o correo**.
- `username1` guarda su contraseña como **hash SHA-1**; la aplicación implementa
  SHA-1 puro en VBScript (`includes/config.asp`) y acepta contraseñas en texto
  plano o con hash. Las contraseñas nuevas/actualizadas desde el panel de
  administración se guardan con hash SHA-1.

---

## 5. Funcionamiento

- **Login** (`login.asp`): valida contra `TBL_USER` con consultas parametrizadas.
- **Sesión**: se guardan `ID_USER`, `USERNAME`, `EMAIL`, `USER_TYPE`, `USER_PHOTO`.
- **Bienvenida**: `index.asp` muestra «¡Bienvenido, *username*!» desde la sesión.
- **Song List**: encabezado explícito *"A continuación, se presenta el listado de
  canciones (Song List)"* seguido de la tabla estilizada con `TBL_SONG`
  (artistas vía `TBL_PLAYER`/`TBL_ARTIST`, álbumes vía `TBL_TRACKLIST`/`TBL_ALBUM`,
  reproducciones vía `PLAYS`).
- **Reproductor**: barra fija inferior con play/pausa, anterior/siguiente, barra de
  progreso, volumen y cola. Los `.mp3` se leen de `SongFiles/` (la BD guarda
  `SONG_PATH` como `~/songFiles/archivo.mp3`; la app normaliza la ruta).
  Cada reproducción incrementa `PLAYS` (`play_count.asp`).
- **Roles**:
  - Usuario Normal (0): solo visualiza y reproduce. Los botones de administración
    están ocultos y las rutas de backend devuelven **403**.
  - Administrador (1): CRUD de usuarios, canciones, listas, artistas y álbumes
    (+ asignación de artistas a canciones y de canciones a listas/álbumes).
- **Logout**: botón siempre visible en la barra lateral (`Session.Abandon`).

---

## 6. Recursos incluidos

| Carpeta          | Contenido                                                            |
|------------------|----------------------------------------------------------------------|
| `SongFiles/`     | `bensound-adventure.mp3` (única pista presente). El SQL referencia 5: adventure, dreams, energy, scifi, tomorrow. Las que falten mostrarán un aviso en el reproductor. |
| `UserImages/`    | `default.jpg`, `root.png` (fotos de `userNormal`/`userAdmin`).        |
| `PlaylistImages/`| `default.jpg`, `playlist1..5.png` (portadas de las listas 1-5).      |

Las rutas se normalizan en `includes/config.asp` (`SongFileUrl`, `UserPhotoUrl`,
`PlaylistPhotoUrl`) tomando solo el nombre del archivo, evitando rutas arbitrarias.

---

## 7. Seguridad implementada

- Consultas **parametrizadas** (ADODB.Command) en toda la capa de datos.
- Salida escapada con `Server.HTMLEncode`.
- Verificación de rol en cada página administrativa (`RequireAdmin`).
- Validación de existencia física del `.mp3` antes de guardar una canción.
- Almacenamiento de contraseñas nuevas con hash SHA-1.
