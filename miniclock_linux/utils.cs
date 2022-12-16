using System;

namespace MINICLOCK{
    public class Utils{
        public static string get_time_string(){
            return DateTime.Now.ToString("HH:mm:ss");
        }
    }
}