# Auto Leveling Z Axis
This tool will help to auto level Z axis using Arduino

How to use:
1. Arduino:
Compile and upload sketch :ArduinoController.ino

2.Hardware:
PCB<---(wire)--->port2 (Arduino) USB port <---USB cable-->USB of PC
GND port (Arduino) <---wire---> GND or Metal Cover of CNC

3. Desktop app:
Open Mach3 and connect to CNC
Open Folder "Builds"
Change serial port number in config.ini. E.g: SerialPort=3
Run mach3ControllerVx.x.exe
This software will control MACH3 automatically


Support Window 10 only.
Not tested on Window 7 and Window XP

Instruction Video
https://www.youtube.com/watch?v=WwtvhkvFtqA

