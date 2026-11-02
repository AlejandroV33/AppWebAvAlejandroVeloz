using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.Security;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV2
{
    public partial class Song : System.Web.UI.Page
    {
        string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;

        /// <summary>
        /// Colour pairs used to draw the cover of the songs, because TBL_SONG has no image column.
        /// </summary>
        private static readonly string[] COVER_GRADIENTS = new string[]
        {
            "linear-gradient(140deg, #ff512f 0%, #dd2476 100%)",
            "linear-gradient(140deg, #0f2027 0%, #2c5364 100%)",
            "linear-gradient(140deg, #f7971e 0%, #b3541e 100%)",
            "linear-gradient(140deg, #2b5876 0%, #4e4376 100%)",
            "linear-gradient(140deg, #c31432 0%, #240b36 100%)",
            "linear-gradient(140deg, #11998e 0%, #0b5d57 100%)",
            "linear-gradient(140deg, #5f2c82 0%, #49a09d 100%)",
            "linear-gradient(140deg, #eb3349 0%, #f45c43 100%)"
        };

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!this.User.Identity.IsAuthenticated || Session[Util.Constants.USER] == null)
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            if (!Page.IsPostBack)
            {
                LoadUserInformation();
                LoadTopPlayedSong();
                LoadSongs(string.Empty);
                LoadCurrentSong();
            }
        }

        /// <summary>
        /// Fills the header with the data of the user that is stored in the session.
        /// </summary>
        private void LoadUserInformation()
        {
            Entities.User user = (Entities.User)Session[Util.Constants.USER];

            string photo = string.IsNullOrEmpty(user.Photo) ? "~/userImages/default.jpg" : user.Photo;
            imgUserPhoto.ImageUrl = ResolveUrl(photo);
            lblUserName.Text = user.UserName;
            lblGreeting.Text = GetGreeting() + ", <span class=\"hl\">" + user.UserName + "</span>";

            if (user.UserType == Util.Constants.ID_USER_ADMIN)
            {
                lblUserType.Text = "Admin";
                lblUserType.Visible = true;
            }
        }

        private string GetGreeting()
        {
            int hour = DateTime.Now.Hour;
            if (hour < 12)
            {
                return "Buenos días";
            }
            if (hour < 19)
            {
                return "Buenas tardes";
            }
            return "Buenas noches";
        }

        /// <summary>
        /// The hero banner shows the most played song of the catalog.
        /// </summary>
        private void LoadTopPlayedSong()
        {
            DataTable dtTop = new BLL.Song(strConnString).ReadTopPlayed(1);
            if (dtTop == null || dtTop.Rows.Count == 0)
            {
                pnlHero.Visible = false;
                return;
            }

            DataRow row = dtTop.Rows[0];
            pnlHero.Visible = true;
            lblHeroTitle.Text = row["SONG_NAME"].ToString();
            lblHeroArtist.Text = GetArtistName(row["ARTIST_NAME"]);
            lblHeroPlays.Text = row["PLAYS"].ToString() + " reproducciones";
            lnkHeroPlay.NavigateUrl = "~/Song.aspx?play=" + row["ID_SONG"].ToString();
            lnkHeroPlay.Attributes["data-id"] = row["ID_SONG"].ToString();
            lnkHeroPlay.Attributes["data-path"] = NormalizeSongPath(row["SONG_PATH"]);
            lnkHeroPlay.Attributes["data-title"] = row["SONG_NAME"].ToString();
            lnkHeroPlay.Attributes["data-artist"] = GetArtistName(row["ARTIST_NAME"]);
        }

        /// <summary>
        /// Binds the catalog. When the filter is empty the whole list is shown.
        /// </summary>
        private void LoadSongs(string filter)
        {
            DataTable dtSongs = new BLL.Song(strConnString).Search(filter);

            rptSongs.DataSource = dtSongs;
            rptSongs.DataBind();

            lblSongCount.Text = dtSongs.Rows.Count + (dtSongs.Rows.Count == 1 ? " canción" : " canciones");
            pnlEmpty.Visible = dtSongs.Rows.Count == 0;
        }

        /// <summary>
        /// When the page is opened as Song.aspx?play=ID it counts the play and loads
        /// the song in the bottom player.
        /// </summary>
        private void LoadCurrentSong()
        {
            int idSong;
            bool hasPlayParam = int.TryParse(Request.QueryString["play"], out idSong);

            BLL.Song bllSong = new BLL.Song(strConnString);
            DataTable dtSong = null;

            if (hasPlayParam)
            {
                dtSong = bllSong.ReadById(idSong);
                if (dtSong != null && dtSong.Rows.Count > 0)
                {
                    bllSong.IncreasePlays(idSong);
                    hdnAutoplay.Value = "1";
                }
            }

            if (dtSong == null || dtSong.Rows.Count == 0)
            {
                DataTable dtAll = bllSong.ReadWithArtist();
                if (dtAll != null && dtAll.Rows.Count > 0)
                {
                    dtSong = dtAll;
                    hdnAutoplay.Value = "0";
                }
            }

            if (dtSong != null && dtSong.Rows.Count > 0)
            {
                DataRow row = dtSong.Rows[0];
                string songPath = row["SONG_PATH"].ToString();

                hdnSongId.Value = row["ID_SONG"].ToString();
                hdnSongPath.Value = NormalizeSongPath(songPath);
                lblPlayerTitle.Text = row["SONG_NAME"].ToString();
                lblPlayerArtist.Text = GetArtistName(row["ARTIST_NAME"]);
            }
        }

        protected void BtnSearch_Click(object sender, EventArgs e)
        {
            LoadSongs(txtSearch.Text);
        }

        protected void BtnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            FormsAuthentication.SignOut();
            Response.Redirect("~/Login.aspx", true);
        }

        /// <summary>
        /// Returns the inline style of the cover. Used from the Repeater with Container.ItemIndex.
        /// </summary>
        protected string GetCoverStyle(int index)
        {
            string gradient = COVER_GRADIENTS[index % COVER_GRADIENTS.Length];
            return "background-image:" + gradient + ";";
        }

        protected string GetArtistName(object artistName)
        {
            if (artistName == null || artistName == DBNull.Value)
            {
                return "Artista desconocido";
            }
            string value = artistName.ToString().Trim();
            if (value == string.Empty)
            {
                return "Artista desconocido";
            }
            return value;
        }

        /// <summary>
        /// Normalizes ~/songFiles/... to a valid client URL without tildes.
        /// </summary>
        public string NormalizeSongPath(object rawPath)
        {
            if (rawPath == null || rawPath == DBNull.Value)
            {
                return string.Empty;
            }
            string path = rawPath.ToString().Trim();
            if (string.IsNullOrEmpty(path))
            {
                return string.Empty;
            }

            if (path.StartsWith("~/"))
            {
                path = path.Substring(2);
            }
            else if (path.StartsWith("~"))
            {
                path = path.Substring(1);
            }
            if (path.StartsWith("/"))
            {
                path = path.Substring(1);
            }

            string resolved = ResolveUrl("~/" + path);
            if (resolved.StartsWith("~/"))
            {
                resolved = resolved.Substring(1);
            }
            return resolved;
        }

        /// <summary>
        /// Registers a play count asynchronously from client-side AJAX.
        /// </summary>
        [WebMethod]
        public static void RegisterPlay(int idSong)
        {
            string conn = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;
            new BLL.Song(conn).IncreasePlays(idSong);
        }
    }
}
