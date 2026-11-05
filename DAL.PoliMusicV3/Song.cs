using System;
using System.Data;
using System.Data.SqlClient;

namespace DAL.PoliMusicV3
{
    /// <summary>
    /// Capa de acceso a datos para las canciones (TBL_SONG).
    /// Sigue el mismo patrón que DAL.PoliMusicV3.User: la cadena de conexión se
    /// inyecta en el constructor y cada método abre/cierra su propia conexión.
    /// </summary>
    public class Song
    {
        private readonly string strConnectionString;

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        /// <summary>
        /// Consulta base. además de las columnas de TBL_SONG entrega los artistas
        /// concatenados, el primer álbum y el número de intérpretes, para que la
        /// capa de presentación no tenga que hacer consultas adicionales.
        /// </summary>
        private const string SELECT_SONGS = @"
            SELECT  s.ID_SONG,
                    s.SONG_NAME,
                    s.SONG_PATH,
                    ISNULL(s.PLAYS, 0) AS PLAYS,
                    ISNULL(STUFF((
                        SELECT ', ' + LTRIM(RTRIM(a.ARTIST_NAME))
                                   + ISNULL(' ' + NULLIF(LTRIM(RTRIM(a.ARTIST_LASTNAME)), ''), '')
                        FROM TBL_PLAYER p
                        INNER JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST
                        WHERE p.ID_SONG = s.ID_SONG
                        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, ''),
                        'PoliMusic Studio') AS ARTISTS,
                    (SELECT TOP 1 al.TITLE_ALBUM
                     FROM TBL_TRACKLIST t
                     INNER JOIN TBL_ALBUM al ON al.ID_ALBUM = t.ID_ALBUM
                     WHERE t.ID_SONG = s.ID_SONG
                     ORDER BY al.ID_ALBUM) AS ALBUM,
                    (SELECT COUNT(DISTINCT p.ID_ARTIST)
                     FROM TBL_PLAYER p
                     WHERE p.ID_SONG = s.ID_SONG) AS ARTIST_COUNT
            FROM TBL_SONG s ";

        /// <summary>
        /// Ejecuta una consulta parametrizada y devuelve un DataTable.
        /// Todas las consultas de lectura pasan por aquí para centralizar el
        /// manejo de la conexión y de los parámetros (evita SQL dinámico).
        /// </summary>
        private DataTable ExecuteQuery(string sentence, params SqlParameter[] parameters)
        {
            DataTable dtSongs = new DataTable();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(sentence, con))
                {
                    if (parameters != null && parameters.Length > 0)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }
                    con.Open();
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSongs);
                    }
                }
            }
            return dtSongs;
        }

        /// <summary>
        /// Devuelve todas las canciones de la biblioteca ordenadas por ID.
        /// </summary>
        public DataTable Read()
        {
            return ExecuteQuery(SELECT_SONGS + "ORDER BY s.ID_SONG ASC");
        }

        /// <summary>
        /// Devuelve una única canción por su identificador.
        /// </summary>
        public DataTable Read(int idSong)
        {
            return ExecuteQuery(
                SELECT_SONGS + "WHERE s.ID_SONG = @ID_SONG ORDER BY s.ID_SONG ASC",
                new SqlParameter("@ID_SONG", SqlDbType.Int) { Value = idSong });
        }

        /// <summary>
        /// Busca canciones por título, artista o álbum.
        /// </summary>
        public DataTable Search(string term)
        {
            string sentence = SELECT_SONGS + @"
                WHERE s.SONG_NAME LIKE '%' + @TERM + '%'
                   OR EXISTS (SELECT 1
                              FROM TBL_PLAYER p
                              INNER JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST
                              WHERE p.ID_SONG = s.ID_SONG
                                AND (a.ARTIST_NAME LIKE '%' + @TERM + '%'
                                     OR ISNULL(a.ARTIST_LASTNAME, '') LIKE '%' + @TERM + '%'))
                   OR EXISTS (SELECT 1
                              FROM TBL_TRACKLIST t
                              INNER JOIN TBL_ALBUM al ON al.ID_ALBUM = t.ID_ALBUM
                              WHERE t.ID_SONG = s.ID_SONG
                                AND al.TITLE_ALBUM LIKE '%' + @TERM + '%')
                ORDER BY s.ID_SONG ASC";

            return ExecuteQuery(sentence,
                new SqlParameter("@TERM", SqlDbType.VarChar, 100) { Value = term });
        }

        /// <summary>
        /// Inserta una canción nueva. Devuelve el número de filas afectadas.
        /// </summary>
        public int Save(string songName, string songPath)
        {
            string sentence = "INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS) " +
                              "VALUES (@SONG_NAME, @SONG_PATH, 0)";
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(sentence, con))
                {
                    cmd.Parameters.AddWithValue("@SONG_NAME", songName);
                    cmd.Parameters.AddWithValue("@SONG_PATH", songPath);
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Actualiza el nombre y la ruta de una canción.
        /// </summary>
        public int Update(int idSong, string songName, string songPath)
        {
            string sentence = "UPDATE TBL_SONG SET " +
                              "SONG_NAME = @SONG_NAME, SONG_PATH = @SONG_PATH " +
                              "WHERE ID_SONG = @ID_SONG";
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(sentence, con))
                {
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Parameters.AddWithValue("@SONG_NAME", songName);
                    cmd.Parameters.AddWithValue("@SONG_PATH", songPath);
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Elimina una canción y, dentro de una transacción, sus relaciones en
        /// TBL_PLAYLIST_SONG, TBL_PLAYER y TBL_TRACKLIST (claves foráneas).
        /// </summary>
        public int Delete(int idSong)
        {
            string sentence = "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_SONG = @ID_SONG; " +
                              "DELETE FROM TBL_PLAYER WHERE ID_SONG = @ID_SONG; " +
                              "DELETE FROM TBL_TRACKLIST WHERE ID_SONG = @ID_SONG; " +
                              "DELETE FROM TBL_SONG WHERE ID_SONG = @ID_SONG;";
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                con.Open();
                using (SqlTransaction transaction = con.BeginTransaction())
                {
                    try
                    {
                        using (SqlCommand cmd = new SqlCommand(sentence, con, transaction))
                        {
                            cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                            int affectedRows = cmd.ExecuteNonQuery();
                            transaction.Commit();
                            return affectedRows;
                        }
                    }
                    catch
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
            }
        }

        /// <summary>
        /// Incrementa en uno el contador de reproducciones y devuelve el valor
        /// ya actualizado desde la base de datos. Devuelve 0 si el ID no existe.
        /// </summary>
        public int IncrementPlays(int idSong)
        {
            string sentence = "UPDATE TBL_SONG SET PLAYS = ISNULL(PLAYS, 0) + 1 " +
                              "WHERE ID_SONG = @ID_SONG; " +
                              "SELECT ISNULL(PLAYS, 0) FROM TBL_SONG WHERE ID_SONG = @ID_SONG;";
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(sentence, con))
                {
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    con.Open();
                    object returnValue = cmd.ExecuteScalar();
                    return (returnValue == null || returnValue == DBNull.Value)
                        ? 0
                        : Convert.ToInt32(returnValue);
                }
            }
        }

        /// <summary>
        /// Totales generales para las tarjetas de la página de streaming.
        /// </summary>
        public DataTable ReadStatistics()
        {
            string sentence = @"
                SELECT (SELECT COUNT(*) FROM TBL_SONG) AS TOTAL_SONGS,
                       (SELECT ISNULL(SUM(ISNULL(PLAYS, 0)), 0) FROM TBL_SONG) AS TOTAL_PLAYS,
                       (SELECT COUNT(*) FROM TBL_ARTIST) AS TOTAL_ARTISTS,
                       (SELECT COUNT(*) FROM TBL_ALBUM) AS TOTAL_ALBUMS";
            return ExecuteQuery(sentence);
        }
    }
}
