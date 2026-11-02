using System;
using System.Collections.Generic;
using System.Web;

namespace WebAppPoliMusicV2.Entities
{
    public class Song
    {
        public Song()
        {
        }
        public Song(int id, string name, string path, int plays)
        {
            ID = id;
            Name = name;
            Path = path;
            Plays = plays;
        }
        public int ID { get; set; }
        public string Name { get; set; }
        public string Path { get; set; }
        public int Plays { get; set; }
        /// <summary>
        /// Only for presentation. It is filled by the read methods that join TBL_PLAYER/TBL_ARTIST.
        /// </summary>
        public string ArtistName { get; set; }
    }
}
