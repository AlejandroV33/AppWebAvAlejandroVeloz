using System;
using System.Collections.Generic;
using System.Data;
using System.Web;

namespace WebAppPoliMusicV2.BLL
{
    public class Song
    {
        private string strConnectionString;
        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }
        public int Save(Entities.Song song)
        {
            return new DAL.Song(strConnectionString).Save(song);
        }
        public DataTable Read()
        {
            return new DAL.Song(strConnectionString).Read();
        }
        public DataTable ReadWithArtist()
        {
            return new DAL.Song(strConnectionString).ReadWithArtist();
        }
        public DataTable ReadById(int id)
        {
            return new DAL.Song(strConnectionString).ReadById(id);
        }
        public DataTable ReadTopPlayed(int quantity)
        {
            if (quantity <= 0)
            {
                quantity = 1;
            }
            return new DAL.Song(strConnectionString).ReadTopPlayed(quantity);
        }
        /// <summary>
        /// If the text comes empty it returns the whole catalog, otherwise it filters by song or artist.
        /// </summary>
        public DataTable Search(string text)
        {
            if (string.IsNullOrEmpty(text) || text.Trim() == string.Empty)
            {
                return ReadWithArtist();
            }
            return new DAL.Song(strConnectionString).Search(text.Trim());
        }
        public int Update(Entities.Song song)
        {
            return new DAL.Song(strConnectionString).Update(song);
        }
        public int Delete(int id)
        {
            return new DAL.Song(strConnectionString).Delete(id);
        }
        public int IncreasePlays(int id)
        {
            return new DAL.Song(strConnectionString).IncreasePlays(id);
        }
        public int CheckExistSong(string songName)
        {
            return new DAL.Song(strConnectionString).CheckExistSong(songName);
        }
        public string ValidationsRequired(Entities.Song song)
        {
            if (song.Name == null || song.Name.Trim() == string.Empty)
            {
                return "Song name is required!";
            }
            if (song.Path == null || song.Path.Trim() == string.Empty)
            {
                return "Song file is required!";
            }
            return string.Empty;
        }
        public string ValidationsDuplicated(Entities.Song song)
        {
            int returnValue = CheckExistSong(song.Name);
            if (returnValue != 0)
            {
                return "Song already registered!";
            }
            return string.Empty;
        }
    }
}
