Coloca en esta carpeta los archivos de audio .mp3 de tus canciones.

El nombre de cada archivo debe coincidir con el campo SONG_PATH de la tabla
TBL_SONG. En el script BDD_PoliMusic.sql las rutas se guardan como
"~/songFiles/<archivo>.mp3" y la aplicación las normaliza a
"SongFiles/<archivo>.mp3" para el reproductor.

Canciones referenciadas por los datos iniciales:
  bensound-adventure.mp3   <- PRESENTE
  bensound-dreams.mp3      <- falta (agrégala para poder reproducirla)
  bensound-energy.mp3      <- falta
  bensound-scifi.mp3       <- falta
  bensound-tomorrow.mp3    <- falta

Las pistas cuyo archivo no exista se listan igual, pero el reproductor
mostrará un aviso al intentar reproducirlas.
