Simple steps to protect your Godot project.
This simply stops script kiddies, it does not protect against determined pirates.

Prerequistes:
    git                     sudo apt install git<br>
    github CLI              see https://cli.github.com/<br>
    scons build system      sudo apt install scons<br>
    Godot-Secure            gh repo clone KnifeXRage/Godot-Secure<br>
    Godot Source            gh repo clone godotengine/godot -- -b 4.7.2<br>
    Screen Reader Support   python godot/misc/scripts/install_accesskit.py<br>
    
    

Set up your directory structure like this:<br>
&nbsp;&nbsp;&nbsp;eg.  Projects --- Godot-Protect<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|--my_godot_project<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|- Godot-Secure<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|--godot<br>  
       

        
How to run:<br>
&nbsp;&nbsp;&nbsp;&nbsp;cd my_godot_project<br>
&nbsp;&nbsp;&nbsp;&nbsp;..\Godot-Project\protech.sh<br>
    
    
    
    

