using System;
using System.IO;

namespace MINICLOCK{
    public class Configure{
        private string config_file_location;
        private bool invalid_config_flag=false;
        private string[] valid_colors={"BLACK","WHITE","RED","YELLOW","BLUE"};
        private string[] valid_display_position={"LEFT","MIDDLE","RIGHT"};
        public  string background_color,text_color,display_location;
        public Configure(string location){
            this.config_file_location=location;
            read_config();
            if (invalid_config_flag){
                create_default_config();
                save_configure();
            }
        }
        private void create_default_config(){
            this.background_color="WHITE";
            this.text_color="BLACK";
            this.display_location="MIDDLE";
            this.config_file_location=Path.Join(Environment.GetFolderPath(Environment.SpecialFolder.Desktop),".minilockrc");
        }
        public void save_configure(){
            if (!File.Exists(this.config_file_location)){
                File.Create(this.config_file_location).Dispose();
            }
            StreamWriter ofs=new StreamWriter(this.config_file_location);
            ofs.WriteLine(this.help_text);
            ofs.WriteLine("background_color:"+this.background_color);
            ofs.WriteLine("text_color:"+this.text_color);
            ofs.WriteLine("display_location:"+this.display_location);
            ofs.Flush();
            ofs.Close();
        }
        private void read_config(){
            try{
                if (new FileInfo(this.config_file_location).Length==0){
                    Console.WriteLine("Empty Config File.");
                    this.invalid_config_flag=true;
                    return;
                }
                StreamReader ifs=new StreamReader(this.config_file_location); 
                string[] cfg_line;
                while (ifs.Peek()>=0){
                    cfg_line=ifs.ReadLine().Split(':');                /* creat default config file and save */
                    if (cfg_line.Length!=2||cfg_line[0].StartsWith("#")){
                        continue;
                    }
                    switch (cfg_line[0]){
                        case "text_color":this.text_color=cfg_line[1];break;
                        case "background_color":this.background_color=cfg_line[1];break;
                        case "display_location":this.display_location=cfg_line[1];break;
                        default:Console.WriteLine($"Invalid Config Key {cfg_line[0]}.");
                                invalid_config_flag=true;break;
                    }
                }
            }catch (System.IO.FileNotFoundException){
                Console.WriteLine($"File {this.config_file_location} not found!");
                this.invalid_config_flag=true;
                return;
            }
        }
        private string help_text="#color:BLACK,WHITE,RED,YELLOW,BLUE\n#location:MIDDLE,LEFT,RIGHT";
    }
}