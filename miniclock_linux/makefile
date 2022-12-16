all: mono

.DEFAULT: mono

mono: main.cs timelabel.cs utils.cs config.cs
	csc main.cs timelabel.cs utils.cs config.cs /r:System.Windows.Forms.dll /r:System.Drawing.dll

clean:
	rm -r -f main.exe