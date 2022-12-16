using System.Drawing;
using System.Windows.Forms;

namespace MINICLOCK{
    public class TimeLabel:Label{
    public TimeLabel(){
        this.Font = new Font("Arial", 16,FontStyle.Bold);
        this.Text=Utils.get_time_string();
        this.TextAlign=ContentAlignment.MiddleCenter;
        this.BorderStyle=BorderStyle.FixedSingle;
        this.Width=100;
        this.Height=24;
       } 
    }
}