/* A really tink Numeric clock for linux and windows, this is a fork of kasusa's miniclock(https://github.com/kasusa/miniclock). */
/* Compile using Mono */

using System;
using System.IO;
using System.Drawing;
using System.Diagnostics;

using System.Windows.Forms;

namespace MINICLOCK{
    public class ApplicationMainWindow : Form{
        public TimeLabel time_label;
        public Timer main_timer;
        public Configure config;
        private void set_label_text(object obj,EventArgs args){
            this.time_label.Text=Utils.get_time_string();
        }
        public ApplicationMainWindow(){
            this.config=new Configure(Path.Join(Environment.GetFolderPath(Environment.SpecialFolder.Desktop),".minilockrc"));
            this.FormBorderStyle=FormBorderStyle.Fixed3D;
            time_label=new TimeLabel();
            this.Width=time_label.Width;
            this.Height=24;
            Controls.Add(time_label);
            main_timer=new Timer();
            main_timer.Interval=1000;
            main_timer.Tick+=new EventHandler(set_label_text);
            main_timer.Start();
        }
    }
    public class EntryPoint{
        public static void Main(string[] argv){
            StackTrace stc=new StackTrace(new StackFrame(true));
            StackFrame sfm=stc.GetFrame(0);
            try{
                Console.WriteLine("Starting Main Window...");
                ApplicationMainWindow app=new ApplicationMainWindow();
                Application.Run(app);
            }catch (Exception e){
                Console.WriteLine(e.Message);
                Console.WriteLine(sfm.GetFileLineNumber()+"::"+sfm.GetMethod().Name+"::"+sfm.GetFileName());
                MessageBox.Show($"An error {e.Message} has occurred.\nClick Yes to continue, No to exit.","ERROR",MessageBoxButtons.YesNo);
                return;
            }
        }
    }
}