using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web;

namespace WebAppPoliMusicV2.DAL
{
    public class Song
    {
        private string strConnectionString;

        /// <summary>
        /// Base SELECT used by the read methods. It brings the song data plus the
        /// name of its first artist (TBL_PLAYER -> TBL_ARTIST) so the view can show
        /// "song - artist" without doing a second query.
        /// </summary>
        private const string SELECT_SONG =
            "SELECT S.[ID_SONG], S.[SONG_NAME], S.[SONG_PATH], ISNULL(S.[PLAYS], 0) AS [PLAYS], " +
            "ISNULL((SELECT TOP 1 AR.[ARTIST_NAME] + ISNULL(' ' + AR.[ARTIST_LASTNAME], '') " +
            "FROM [TBL_PLAYER] P INNER JOIN [TBL_ARTIST] AR ON AR.[ID_ARTIST] = P.[ID_ARTIST] " +
            "WHERE P.[ID_SONG] = S.[ID_SONG]), '') AS [ARTIST_NAME] " +
            "FROM [TBL_SONG] S ";

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        public int Save(Entities.Song song)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "INSERT INTO [TBL_SONG]([SONG_NAME], [SONG_PATH], [PLAYS]) " +
                        "VALUES(@SONG_NAME, @SONG_PATH, @PLAYS)";
                    cmd.Parameters.AddWithValue("@SONG_NAME", song.Name);
                    cmd.Parameters.AddWithValue("@SONG_PATH", song.Path);
                    cmd.Parameters.AddWithValue("@PLAYS", song.Plays);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        public DataTable Read()
        {
            DataTable dtSong = new DataTable();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT [ID_SONG], [SONG_NAME], [SONG_PATH], [PLAYS] FROM [TBL_SONG]", con))
                {
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSong);
                        return dtSong;
                    }
                }
            }
        }

        public DataTable ReadWithArtist()
        {
            DataTable dtSong = new DataTable();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(SELECT_SONG + "ORDER BY S.[SONG_NAME]", con))
                {
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSong);
                        return dtSong;
                    }
                }
            }
        }

        public DataTable ReadById(int idSong)
        {
            DataTable dtSong = new DataTable();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(SELECT_SONG + "WHERE S.[ID_SONG] = @ID_SONG", con))
                {
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSong);
                        return dtSong;
                    }
                }
            }
        }

        public DataTable ReadTopPlayed(int quantity)
        {
            DataTable dtSong = new DataTable();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT TOP (@QUANTITY) * FROM (" + SELECT_SONG + ") AS SONG " +
                    "ORDER BY [PLAYS] DESC, [SONG_NAME]", con))
                {
                    cmd.Parameters.AddWithValue("@QUANTITY", quantity);
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSong);
                        return dtSong;
                    }
                }
            }
        }

        public DataTable Search(string text)
        {
            DataTable dtSong = new DataTable();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(SELECT_SONG +
                    "WHERE S.[SONG_NAME] LIKE @TEXT " +
                    "OR EXISTS (SELECT 1 FROM [TBL_PLAYER] P INNER JOIN [TBL_ARTIST] AR ON AR.[ID_ARTIST] = P.[ID_ARTIST] " +
                    "           WHERE P.[ID_SONG] = S.[ID_SONG] AND AR.[ARTIST_NAME] LIKE @TEXT) " +
                    "ORDER BY S.[SONG_NAME]", con))
                {
                    cmd.Parameters.AddWithValue("@TEXT", "%" + text + "%");
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSong);
                        return dtSong;
                    }
                }
            }
        }

        public int Update(Entities.Song song)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "UPDATE [TBL_SONG] SET " +
                        "[SONG_NAME] = @SONG_NAME " +
                        ", [SONG_PATH] = @SONG_PATH " +
                        ", [PLAYS] = @PLAYS " +
                        "WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", song.ID);
                    cmd.Parameters.AddWithValue("@SONG_NAME", song.Name);
                    cmd.Parameters.AddWithValue("@SONG_PATH", song.Path);
                    cmd.Parameters.AddWithValue("@PLAYS", song.Plays);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        public int Delete(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "DELETE [TBL_SONG] WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Adds one play to the song counter. Used every time the player starts a song.
        /// </summary>
        public int IncreasePlays(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "UPDATE [TBL_SONG] SET [PLAYS] = ISNULL([PLAYS], 0) + 1 WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        public int CheckExistSong(string songName)
        {
            object returnValue;
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "SELECT [ID_SONG] FROM [TBL_SONG] WHERE [SONG_NAME] = @SONG_NAME";
                    cmd.Parameters.AddWithValue("@SONG_NAME", songName);
                    cmd.Connection = con;
                    con.Open();
                    returnValue = cmd.ExecuteScalar();
                    return (returnValue == null) ? 0 : (int)returnValue;
                }
            }
        }
    }
}
