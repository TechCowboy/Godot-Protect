echo This will take about 45 minutes to complete
sleep 3



# get randomized encryption key and store in project
openssl rand -hex 32 > godot.gdkey

# use that key when building godot
export SCRIPT_AES256_ENCRYPTION_KEY=$(cat godot.gdkey)

# insure we don't have stale cache results when we rebuild
rm .godot -r -f

cd ..

# remove the existing godot project if it exists
rm godot -r -f

# get the latest 4.7 branch
gh repo clone godotengine/godot -- -b 4.7.2-stable

cd godot

# add accessibility features
python misc/scripts/install_accesskit.py

# modify the fresh godot sources so they are secure
python "./Godot-Secure/Godot Secure Scripts/universal/Godot Secure Camellia-256 Universal v6.py" godot

scons --clean

# build the linux project
scons platform=linuxbsd target=editor use_mingw=yes 

scons platform=windows target=template_debug use_mingw=yes
scons platform=windows target=template_release use_mingw=yes

scons platform=linux target=template_debug use_mingw=yes
scons platform=linux target=template_release use_mingw=yes

# prepare for using local templates
rm ./bin/._sc_ -r -f
md ./bin/._sc_


# Execute the modified editor
bin/godot.linuxbsd.editor.x86_64


