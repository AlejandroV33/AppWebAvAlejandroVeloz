using System;
using System.Data;

namespace BLL.PoliMusicV3
{
    /// <summary>
    /// Lógica de negocio para las canciones. No accede a la base de datos:
    /// valida, normaliza y delega todas las operaciones en DAL.PoliMusicV3.Song,
    /// igual que BLL.PoliMusicV3.User lo hace con DAL.PoliMusicV3.User.
    /// </summary>
    public class Song
    {
        private readonly string strConnectionString;

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        /// <summary>
        /// Crea la instancia de la capa de datos con la cadena de conexión recibida.
        /// </summary>
        private DAL.PoliMusicV3.Song DataAccess
        {
            get { return new DAL.PoliMusicV3.Song(strConnectionString); }
        }

        /// <summary>
        /// Biblioteca completa de canciones (con artistas, álbum y reproducciones).
        /// </summary>
        public DataTable Read()
        {
            return DataAccess.Read();
        }

        /// <summary>
        /// Devuelve una canción concreta. Un ID inválido devuelve una tabla vacía.
        /// </summary>
        public DataTable Read(int idSong)
        {
            if (idSong <= 0)
            {
                return new DataTable();
            }
            return DataAccess.Read(idSong);
        }

        /// <summary>
        /// Búsqueda por título, artista o álbum. El término se recorta y se limita
        /// a 100 caracteres; si queda vacío se devuelve la biblioteca completa.
        /// </summary>
        public DataTable Search(string term)
        {
            string cleanTerm = (term ?? string.Empty).Trim();
            if (cleanTerm.Length > 100)
            {
                cleanTerm = cleanTerm.Substring(0, 100);
            }
            if (cleanTerm == string.Empty)
            {
                return Read();
            }
            return DataAccess.Search(cleanTerm);
        }

        /// <summary>
        /// Devuelve las canciones más reproducidas, ordenadas de mayor a menor.
        /// El ordenamiento se hace aquí (regla de negocio), no en la consulta.
        /// </summary>
        public DataTable GetMostPlayed(int topRows)
        {
            DataTable songs = Read();
            DataTable result = songs.Clone();
            if (topRows <= 0)
            {
                return result;
            }
            DataView view = new DataView(songs, string.Empty,
                "PLAYS DESC, SONG_NAME ASC", DataViewRowState.CurrentRows);
            for (int i = 0; i < view.Count && i < topRows; i++)
            {
                result.ImportRow(view[i].Row);
            }
            return result;
        }

        /// <summary>
        /// Totales para las tarjetas informativas de la página.
        /// </summary>
        public DataTable ReadStatistics()
        {
            return DataAccess.ReadStatistics();
        }

        /// <summary>
        /// Registra una reproducción: valida el ID, incrementa PLAYS en la base
        /// de datos y devuelve el contador ya actualizado (0 si no existe).
        /// </summary>
        public int RegisterPlay(int idSong)
        {
            if (idSong <= 0)
            {
                return 0;
            }
            return DataAccess.IncrementPlays(idSong);
        }

        /// <summary>
        /// Inserta una canción tras validar y normalizar sus datos.
        /// Devuelve 0 cuando las validaciones no pasan; si pasan, el número de
        /// filas afectadas devuelto por la capa de datos.
        /// </summary>
        public int Save(string songName, string songPath)
        {
            string name = (songName ?? string.Empty).Trim();
            string path = NormalizeSongPath(songPath);
            if (ValidateSongFields(name, path) != string.Empty)
            {
                return 0;
            }
            return DataAccess.Save(name, path);
        }

        /// <summary>
        /// Actualiza una canción existente.
        /// </summary>
        public int Update(int idSong, string songName, string songPath)
        {
            string name = (songName ?? string.Empty).Trim();
            string path = NormalizeSongPath(songPath);
            if (idSong <= 0 || ValidateSongFields(name, path) != string.Empty)
            {
                return 0;
            }
            return DataAccess.Update(idSong, name, path);
        }

        /// <summary>
        /// Elimina una canción (la capa de datos limpia también sus relaciones).
        /// </summary>
        public int Delete(int idSong)
        {
            if (idSong <= 0)
            {
                return 0;
            }
            return DataAccess.Delete(idSong);
        }

        /// <summary>
        /// Validaciones de negocio alineadas con el esquema:
        /// SONG_NAME varchar(50) NOT NULL y SONG_PATH varchar(255) NOT NULL.
        /// Devuelve cadena vacía cuando todo es correcto.
        /// </summary>
        public string ValidateSongFields(string songName, string songPath)
        {
            if (string.IsNullOrWhiteSpace(songName))
            {
                return "El nombre de la canción es obligatorio.";
            }
            if (songName.Length > 50)
            {
                return "El nombre de la canción no puede superar los 50 caracteres.";
            }
            if (string.IsNullOrWhiteSpace(songPath))
            {
                return "Debes indicar un archivo de audio .mp3.";
            }
            if (!songPath.EndsWith(".mp3", StringComparison.OrdinalIgnoreCase))
            {
                return "El archivo de audio debe tener extensión .mp3.";
            }
            if (songPath.Length > 255)
            {
                return "La ruta del archivo no puede superar los 255 caracteres.";
            }
            return string.Empty;
        }

        /// <summary>
        /// Deja la ruta en el formato en que se guarda en TBL_SONG
        /// ("~/songFiles/nombre.mp3") y evita rutas relativas con directorios.
        /// </summary>
        public static string NormalizeSongPath(string songPath)
        {
            if (string.IsNullOrWhiteSpace(songPath))
            {
                return string.Empty;
            }
            string fileName = songPath.Replace('\\', '/');
            int lastSlash = fileName.LastIndexOf('/');
            if (lastSlash >= 0)
            {
                fileName = fileName.Substring(lastSlash + 1);
            }
            if (!fileName.EndsWith(".mp3", StringComparison.OrdinalIgnoreCase))
            {
                return string.Empty;
            }
            return "~/songFiles/" + fileName;
        }
    }
}
