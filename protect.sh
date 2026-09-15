#set -x

read -p "Get fresh godot from github? (y/n)" REBUILD

export PROJECT_DIR="$(pwd)"
echo Project directory is $PROJECT_DIR
echo This will take about 45 minutes to complete


export DATE="$(date '+%Y-%m-%d_%H-%M-%S')"

export ENCRYPT_DIR="$PROJECT_DIR - $DATE"

echo Copying your existing project into $DEST_DIR...

# backup the directory with the previous key
cd ..

mkdir "$ENCRYPT_DIR"
cp -R -d  "$PROJECT_DIR/." "$ENCRYPT_DIR/"

cd "$ENCRYPT_DIR"

if [ "$REBUILD" == "y" ]; then
	# get randomized encryption key and store in project
	openssl rand -hex 32 > godot.gdkey
fi

# use that key when building godot
export SCRIPT_AES256_ENCRYPTION_KEY=$(cat godot.gdkey)

if [ "$REBUILD" == "y" ]; then
	# insure we don't have stale cache results when we rebuild
	rm .godot -r -f

	cd ..

	# remove the existing godot project if it exists
	rm godot -r -f

	# get the latest 4.7 branch
	gh repo clone godotengine/godot -- -b 4.7.2-stable
	cd "$ENCRYPT_DIR"

fi

cd ..
cd godot

if [ "$REBUILD" == "y" ] ; then

	# add accessibility features
	python misc/scripts/install_accesskit.py

	# modify the fresh godot sources so they are secure
	python "./Godot-Secure/Godot Secure Scripts/universal/Godot Secure Camellia-256 Universal v6.py"

	scons --clean

	# build the linux project
	scons platform=linuxbsd target=editor use_mingw=yes 

	scons platform=windows target=template_debug use_mingw=yes
	scons platform=windows target=template_release use_mingw=yes

	scons platform=linux target=template_debug use_mingw=yes
	scons platform=linux target=template_release use_mingw=yes
fi

# prepare for using local templates
cd bin
export TEMPLATE_DIR="$(pwd)"

rm ._sc_ -r -f
mkdir ._sc_

cd "$ENCRYPT_DIR"

echo Updating the version and encryption key used in export

set -x 
export CONFIG_FILE="$ENCRYPT_DIR/export_presets.cfg"
export CRED_FILE="$ENCRYPT_DIR/.godot/export_credentials.cfg"
export PROJECT_FILE="$ENCRYPT_DIR/project.godot"

# encrypt_pck=true
sed -i "/^\[preset\.0\]/,/^\[/ s|^encrypt_pck=.*|encrypt_pck=\"true\"|" "$CONFIG_FILE"
# encrypt_directory=true
sed -i "/^\[preset\.0\]/,/^\[/ s|^encrypt_directory=.*|encrypt_directory=\"true\"|" "$CONFIG_FILE"

#custom_template/debug="/home/ndavie/Documents/Projects/GodotFun/godot/bin/godot.linuxbsd.template_debug.x86_64"
sed -i "/^\[preset\.0\.options\]/,/^\[/ s|^custom_template/debug=.*|custom_template/debug=\"$TEMPLATE_DIR/godot.linuxbsd.template_debug.x86_64\"|" "$CONFIG_FILE"
#custom_template/release="/home/ndavie/Documents/Projects/GodotFun/godot/bin/godot.linuxbsd.template_release.x86_64"
sed -i "/^\[preset\.0\.options\]/,/^\[/ s|^custom_template/release=.*|custom_template/release=\"$TEMPLATE_DIR/godot.linuxbsd.template_release.x86_64\"|" "$CONFIG_FILE"

#binary_format/embed_pck=true
sed -i "/^\[preset\.0\.options\]/,/^\[/ s|^binary_format/embed_pck=.*|binary_format/embed_pck=\"true\"|" "$CONFIG_FILE"

#script_encryption_key
sed -i "/^\[preset\.0]/,/^\[/ s|^script_encryption_key=.*|script_encryption_key=\"$SCRIPT_AES256_ENCRYPTION_KEY\"|" "$CRED_FILE"
sed -i "/^\[preset\.1]/,/^\[/ s|^script_encryption_key=.*|script_encryption_key=\"$SCRIPT_AES256_ENCRYPTION_KEY\"|" "$CRED_FILE"
sed -i "/^\[preset\.2]/,/^\[/ s|^script_encryption_key=.*|script_encryption_key=\"$SCRIPT_AES256_ENCRYPTION_KEY\"|" "$CRED_FILE"
sed -i "/^\[preset\.3]/,/^\[/ s|^script_encryption_key=.*|script_encryption_key=\"$SCRIPT_AES256_ENCRYPTION_KEY\"|" "$CRED_FILE"
sed -i "/^\[preset\.4]/,/^\[/ s|^script_encryption_key=.*|script_encryption_key=\"$SCRIPT_AES256_ENCRYPTION_KEY\"|" "$CRED_FILE"

sed -i "/^\[application\]/,/^\[/ s|^config/version=.*|config/version=\"$DATE\"|" "$PROJECT_FILE"

# Export the exports :-)
"$TEMPLATE_DIR/godot.linuxbsd.editor.x86_64" --export-release Linux
"$TEMPLATE_DIR/godot.linuxbsd.editor.x86_64" --export-release "Windows Desktop"
"$TEMPLATE_DIR/godot.linuxbsd.editor.x86_64" --export-release macOS

set +x





