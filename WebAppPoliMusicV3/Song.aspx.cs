using System;
using System.Configuration;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using EntityLayer.PoliMusicV3.Util;

namespace WebAppPoliMusicV3
{
    /// <summary>
    /// Página de streaming de música (tipo YouTube Music).
    /// Consume BLL.PoliMusicV3.Song -> DAL.PoliMusicV3.Song -> BDD_PoliMusic.
    /// El usuario llega en Session[Constants.USER] desde Login.aspx.cs.
    /// </summary>
    public partial class Song : System.Web.UI.Page
    {
        private const string NOTE_ICON =
            "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.8\" " +
            "stroke-linecap=\"round\" stroke-linejoin=\"round\" aria-hidden=\"true\">" +
            "<path d=\"M9 18V5l10-2v13\"/><circle cx=\"6\" cy=\"18\" r=\"3\"/>" +
            "<circle cx=\"16\" cy=\"16\" r=\"3\"/></svg>";

        private const string PLAY_ICON =
            "<svg viewBox=\"0 0 24 24\" fill=\"currentColor\" aria-hidden=\"true\">" +
            "<path d=\"M8 5l11 7-11 7z\"/></svg>";

        private const string PLAYS_ICON =
            "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.8\" " +
            "stroke-linecap=\"round\" stroke-linejoin=\"round\" aria-hidden=\"true\">" +
            "<path d=\"M4 12h13\"/><path d=\"M14 6l6 6-6 6\"/></svg>";

        /// <summary>
        /// Cadena de conexión del Web.config, igual que en Login.aspx.cs.
        /// </summary>
        private string ConnectionString
        {
            get
            {
                return ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;
            }
        }

        /// <summary>
        /// Reproducciones registradas durante la sesión del usuario.
        /// </summary>
        private int SessionPlays
        {
            get
            {
                object value = Session["PM_SESSION_PLAYS"];
                return value == null ? 0 : Convert.ToInt32(value);
            }
            set { Session["PM_SESSION_PLAYS"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            EntityLayer.PoliMusicV3.User user =
                Session[Constants.USER] as EntityLayer.PoliMusicV3.User;

            // La autenticación por formularios ya protege la página, pero sin el
            // objeto de sesión no se puede mostrar el nombre del usuario.
            if (user == null)
            {
                FormsAuthentication.RedirectToLoginPage();
                return;
            }

            // El UpdatePanel solo refresca el contador: en un postback asíncrono
            // no hace falta volver a consultar ni a renderizar la biblioteca.
            ScriptManager manager = ScriptManager.GetCurrent(this);
            if (manager != null && manager.IsInAsyncPostBack)
            {
                return;
            }

            // "Bienvenido nombre.apellido" (el USERNAME de la BD tiene ese formato).
            litWelcome.Text = HttpUtility.HtmlEncode(
                string.IsNullOrWhiteSpace(user.UserName) ? "invitado" : user.UserName);
            litUserCard.Text = BuildUserCard(user);

            if (!IsPostBack)
            {
                SessionPlays = 0;
            }
            litSessionPlays.Text = SessionPlays + " en esta sesión";

            try
            {
                BLL.PoliMusicV3.Song songs = new BLL.PoliMusicV3.Song(ConnectionString);
                DataTable library = songs.Read();
                litSongRows.Text = BuildSongRows(library);
                litMessage.Text = string.Empty;
                LoadStatistics(songs, library);
            }
            catch (Exception ex)
            {
                litSongRows.Text = string.Empty;
                litMessage.Text = "<div class=\"pm-alert\">No fue posible cargar la biblioteca " +
                    "desde la base de datos. " + HttpUtility.HtmlEncode(ex.Message) + "</div>";
                litTotalSongs.Text = "0";
                litTotalPlays.Text = "0";
                litTotalArtists.Text = "0";
                litTotalAlbums.Text = "0";
            }
        }

        /// <summary>
        /// Se dispara desde JavaScript (botón oculto dentro del UpdatePanel) cada
        /// vez que comienza una pista. Guarda el play en TBL_SONG.PLAYS sin
        /// recargar la página ni interrumpir el elemento &lt;audio&gt;.
        /// </summary>
        protected void btnRegisterPlay_Click(object sender, EventArgs e)
        {
            int idSong;
            if (!int.TryParse(hdnPlaySongId.Value, out idSong) || idSong <= 0)
            {
                return;
            }

            try
            {
                int totalPlays = new BLL.PoliMusicV3.Song(ConnectionString).RegisterPlay(idSong);
                SessionPlays = SessionPlays + 1;
                litSessionPlays.Text = SessionPlays + " en esta sesión · " + totalPlays + " totales";
            }
            catch (Exception ex)
            {
                litSessionPlays.Text = "Sin registrar: " + HttpUtility.HtmlEncode(ex.Message);
            }
        }

        /// <summary>
        /// Construye las filas de la biblioteca a partir del DataTable de la BLL.
        /// Cada fila lleva sus datos en atributos data-* para que el reproductor
        /// JavaScript pueda armar la cola sin nuevos viajes al servidor.
        /// </summary>
        private string BuildSongRows(DataTable library)
        {
            StringBuilder html = new StringBuilder();
            int position = 0;

            foreach (DataRow row in library.Rows)
            {
                position++;

                int idSong = Convert.ToInt32(row["ID_SONG"]);
                string title = row["SONG_NAME"].ToString();
                string artists = row["ARTISTS"].ToString();
                string album = (row["ALBUM"] == DBNull.Value ||
                                string.IsNullOrWhiteSpace(row["ALBUM"].ToString()))
                    ? "Sencillo" : row["ALBUM"].ToString();
                int plays = row["PLAYS"] == DBNull.Value ? 0 : Convert.ToInt32(row["PLAYS"]);

                bool available;
                string songUrl = ResolveSongFile(row["SONG_PATH"].ToString(), out available);
                int tone = ((position - 1) % 3) + 1;

                html.Append("<div class=\"pm-row\" role=\"button\" tabindex=\"0\"");
                html.Append(" data-id=\"").Append(idSong).Append("\"");
                html.Append(" data-src=\"").Append(HttpUtility.HtmlEncode(songUrl)).Append("\"");
                html.Append(" data-title=\"").Append(HttpUtility.HtmlEncode(title)).Append("\"");
                html.Append(" data-artist=\"").Append(HttpUtility.HtmlEncode(artists)).Append("\"");
                html.Append(" data-album=\"").Append(HttpUtility.HtmlEncode(album)).Append("\"");
                html.Append(" data-plays=\"").Append(plays).Append("\"");
                html.Append(" data-tone=\"").Append(tone).Append("\"");
                html.Append(" data-available=\"").Append(available ? "1" : "0").Append("\"");
                html.Append(" aria-label=\"Reproducir ").Append(HttpUtility.HtmlEncode(title)).Append("\">");

                html.Append("<span class=\"pm-row__index\">")
                    .Append(position.ToString("00")).Append("</span>");
                html.Append("<span class=\"pm-row__cover pm-cover--").Append(tone).Append("\">")
                    .Append(NOTE_ICON).Append("</span>");
                html.Append("<span class=\"pm-row__info\">");
                html.Append("<span class=\"pm-row__title\">").Append(HttpUtility.HtmlEncode(title));
                if (!available)
                {
                    html.Append("<span class=\"pm-row__badge\">sin MP3</span>");
                }
                html.Append("</span>");
                html.Append("<span class=\"pm-row__artist\">")
                    .Append(HttpUtility.HtmlEncode(artists)).Append("</span>");
                html.Append("</span>");
                html.Append("<span class=\"pm-row__album\">")
                    .Append(HttpUtility.HtmlEncode(album)).Append("</span>");
                html.Append("<span class=\"pm-row__plays\">").Append(PLAYS_ICON)
                    .Append("<span class=\"js-plays\">").Append(plays).Append("</span></span>");
                html.Append("<span class=\"pm-row__play\">").Append(PLAY_ICON).Append("</span>");
                html.Append("</div>");
            }

            return html.ToString();
        }

        /// <summary>
        /// La BD guarda rutas como "~/songFiles/nombre.mp3"; en el servidor la
        /// carpeta es SongFiles/. Se normaliza y se comprueba que el MP3 exista
        /// para que el reproductor avise en lugar de fallar en silencio.
        /// </summary>
        private string ResolveSongFile(string dbPath, out bool available)
        {
            string fileName = Path.GetFileName((dbPath ?? string.Empty).Replace('\\', '/'));
            string virtualPath = "~/SongFiles/" + fileName;
            available = !string.IsNullOrEmpty(fileName) &&
                        File.Exists(Server.MapPath(virtualPath));
            return ResolveUrl(virtualPath);
        }

        /// <summary>
        /// Tarjeta del usuario autenticado: foto, nombre, correo y tipo de cuenta.
        /// </summary>
        private string BuildUserCard(EntityLayer.PoliMusicV3.User user)
        {
            string name = HttpUtility.HtmlEncode(
                string.IsNullOrWhiteSpace(user.UserName) ? "invitado" : user.UserName);
            string email = HttpUtility.HtmlEncode(user.Email ?? string.Empty);
            string photo = ResolveUserImage(user.Photo);
            string accountType = user.UserType == Constants.ID_USER_ADMIN
                ? "Administrador" : "Listener";

            StringBuilder html = new StringBuilder();
            html.Append("<div class=\"pm-user\">");
            html.Append("<span class=\"pm-user__avatar\"><img src=\"").Append(photo)
                .Append("\" alt=\"Foto de perfil de ").Append(name).Append("\" /></span>");
            html.Append("<span class=\"pm-user__names\"><strong>").Append(name)
                .Append("</strong><small>Usuario PoliMusic</small></span>");
            html.Append("</div>");
            html.Append("<dl class=\"pm-user__meta\">");
            html.Append("<dt>Correo</dt><dd>").Append(email).Append("</dd>");
            html.Append("<dt>Tipo de cuenta</dt><dd>").Append(accountType).Append("</dd>");
            html.Append("</dl>");
            return html.ToString();
        }

        /// <summary>
        /// Normaliza la foto de perfil y usa default.jpg cuando el archivo no existe.
        /// </summary>
        private string ResolveUserImage(string dbPath)
        {
            string fileName = Path.GetFileName((dbPath ?? string.Empty).Replace('\\', '/'));
            if (string.IsNullOrEmpty(fileName))
            {
                fileName = "default.jpg";
            }
            string virtualPath = "~/UserImages/" + fileName;
            if (!File.Exists(Server.MapPath(virtualPath)))
            {
                virtualPath = "~/UserImages/default.jpg";
            }
            return HttpUtility.HtmlEncode(ResolveUrl(virtualPath));
        }

        /// <summary>
        /// Llena las cuatro tarjetas de la banda Deep Indigo con los totales de
        /// la BD. Si la consulta agregada falla, usa los datos ya cargados.
        /// </summary>
        private void LoadStatistics(BLL.PoliMusicV3.Song songs, DataTable library)
        {
            int totalSongs = library.Rows.Count;
            int totalPlays = 0;
            foreach (DataRow row in library.Rows)
            {
                if (row["PLAYS"] != DBNull.Value)
                {
                    totalPlays += Convert.ToInt32(row["PLAYS"]);
                }
            }
            int totalArtists = 0;
            int totalAlbums = 0;

            try
            {
                DataTable stats = songs.ReadStatistics();
                if (stats.Rows.Count > 0)
                {
                    totalSongs = Convert.ToInt32(stats.Rows[0]["TOTAL_SONGS"]);
                    totalPlays = Convert.ToInt32(stats.Rows[0]["TOTAL_PLAYS"]);
                    totalArtists = Convert.ToInt32(stats.Rows[0]["TOTAL_ARTISTS"]);
                    totalAlbums = Convert.ToInt32(stats.Rows[0]["TOTAL_ALBUMS"]);
                }
            }
            catch
            {
                // Se conservan los totales calculados a partir de la biblioteca.
            }

            litTotalSongs.Text = totalSongs.ToString();
            litTotalPlays.Text = totalPlays.ToString();
            litTotalArtists.Text = totalArtists.ToString();
            litTotalAlbums.Text = totalAlbums.ToString();
        }
    }
}
