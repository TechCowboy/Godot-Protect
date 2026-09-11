Simple steps to protect your Godot project.
This simply stops script kiddies, it does not protect against determined pirates.

Prerequistes:
    git                     sudo apt install git
    github CLI              see https://cli.github.com/
    scons build system      sudo apt install scons
    Godot-Secure            gh repo clone KnifeXRage/Godot-Secure
    Godot Source            gh repo clone godotengine/godot -- -b 4.7
    Screen Reader Support   python godot/misc/scripts/install_accesskit.py
    
    

Set up your directory structure like this:
   eg.  Projects --- Godot-Protect
                  |--my_godot_project
                  |- Godot-Secure
                  |--godot  
       

        
How to run:
    cd my_godot_project
    ..\Godot-Project\protech.sh
    
    
    
    

