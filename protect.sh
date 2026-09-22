set +x
#set -x

echo
read -p "Get fresh Godot Engine Source from github? (y/n)" REBUILD

export SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_DIR="$(pwd)"

echo
echo Project directory is $PROJECT_DIR

export DATE="$(date '+%Y.%m.%d.%H%M%S')"

export ENCRYPT_DIR="$PROJECT_DIR-$DATE"
export LOCAL_TEMPLATES="$ENCRYPT_DIR/templates"
export GODOT_EDITOR="$LOCAL_TEMPLATES/godot.linuxbsd.editor.x86_64"
export LAST_GITHUB="godot-last-github"

echo
echo Copying your existing project into $ENCRYPT_DIR...
# backup the directory with the previous key
cd ..

mkdir "$ENCRYPT_DIR"
cp -R -d  "$PROJECT_DIR/." "$ENCRYPT_DIR/"

cd "$ENCRYPT_DIR"

if [ "$REBUILD" == "y" ]; then
	echo
	echo This will take about an hour to complete
	echo
	# get randomized encryption key and store in project
	openssl rand -hex 32 > godot.gdkey
fi

# use that key when building godot
export SCRIPT_AES256_ENCRYPTION_KEY=$(cat godot.gdkey)
echo
echo New key is:
echo $SCRIPT_AES256_ENCRYPTION_KEY
echo

if [ "$REBUILD" == "y" ]; then
	# insure we don't have stale cache results when we rebuild
	# rm .godot -r -f

	cd ..

	# remove the existing godot project if it exists
	rm godot -r -f

	echo
	echo Getting fresh github repo...
	echo
	# get the latest 4.7 branch
	gh repo clone godotengine/godot -- -b 4.7.2-stable
	cp -R -d  "godot/." "$LAST_GITHUB/"
	cd "$ENCRYPT_DIR"
fi

if [ "$REBUILD" != "y" ]; then
	read -p "Do a rebuild from previously collected Godot Engine Source? (y/n)" REBUILD
	
	if [ "$REBUILD" == "y" ]; then
		echo
		echo Copying previously collected github repo...
		echo
		cd ..
		rm godot -r -f
		cp -R -d  "$LAST_GITHUB/." "godot/" 
	fi
	
	cd "$ENCRYPT_DIR"
fi

cd ..
cd godot

if [ "$REBUILD" == "y" ] ; then

	echo Rebuilding from scratch
	echo

	# add accessibility features
	python misc/scripts/install_accesskit.py
	python misc/scripts/install_winrt.py
	python misc/scripts/install_d3d12_sdk_windows.py
	python misc/scripts/install_angle.py
	

	scons --clean
	
	scons d3d12=yes
	scons angle=yes
	
	
	echo Securing Godot source...
	echo
	# modify the fresh godot sources so they are secure
	python "../Godot-Secure/Godot Secure Scripts/universal/Godot Secure Camellia-256 Universal v6.py"

	# install the android templates
	#echo installing android target
	#scons platform=android target=template_release arch=arm64 generate_apk=yes
	#scons platform=android target=template_debug arch=arm64 generate_apk=yes

	# build the linux editor	
	echo Building linux editor
	scons platform=linuxbsd target=editor use_mingw=yes 

	
	# build the mac editor
	#echo Building macOS editor
	#scons platform=macOS  target=editor use_mingw=yes 

	# build the linux templates
	echo Building linux debug template
	scons platform=linux target=template_debug use_mingw=yes
	echo Building linux release template
	scons platform=linux target=template_release use_mingw=yes

	
	# build the windows editor
	#echo Building windows editor
	#scons platform=windows  target=editor arch=x86_64 use_mingw=yes 
	scons platform=windows target=template_release arch=x86_64
	scons platform=windows target=template_debug arch=x86_64
	
	# build the windows templates
	#echo Bulding windows debug template
	#scons platform=windows target=template_debug arch=x86_64 use_mingw=yes
	#echo Building windows release template
	#scons platform=windows target=template_release  arch=x86_64 use_mingw=yes
	

	# prepare for reusing local templates  
	cd bin
	export TEMPLATE_DIR="$(pwd)"

	rm ._sc_ -r -f
	mkdir ._sc_

	rm -r -f "$ENCRYPT_DIR/templates"
	rm -r -f "$PROJECT_DIR/templates"
	mkdir "$ENCRYPT_DIR/templates"
	mkdir "$PROJECT_DIR/templates"
	
	cp -R -d "$TEMPLATE_DIR"/. "$ENCRYPT_DIR/templates"
	
	# put new files here if we don't want to rebuild templates
	cp -R -d "$TEMPLATE_DIR"/. "$PROJECT_DIR/templates" 
fi

cd "$ENCRYPT_DIR"

echo Updating the version and encryption key used in export configuration files

export CONFIG_FILE="$ENCRYPT_DIR/export_presets.cfg"
export CRED_FILE="$ENCRYPT_DIR/.godot/export_credentials.cfg"
export PROJECT_FILE="$ENCRYPT_DIR/project.godot"

echo "CONFILE_FILE: $CONFIG_FILE"
echo "CRED_FILE:    $CRED_FILE"
echo "PROJECT_FILE: $ENCRYPT_DIR"

# put our date in the version field so we know where to get our keys if we need them in the future
sed -i "/^\[application\]/,/^\[/ s|^config/version=.*|config/version=\"$DATE\"|" "$PROJECT_FILE"

# update the encryption key for all presets
sed -i "/^\[preset\.0]/,/^\[/ s|^script_encryption_key=.*|script_encryption_key=\"$SCRIPT_AES256_ENCRYPTION_KEY\"|" "$CRED_FILE"
sed -i "/^\[preset\.1]/,/^\[/ s|^script_encryption_key=.*|script_encryption_key=\"$SCRIPT_AES256_ENCRYPTION_KEY\"|" "$CRED_FILE"
sed -i "/^\[preset\.2]/,/^\[/ s|^script_encryption_key=.*|script_encryption_key=\"$SCRIPT_AES256_ENCRYPTION_KEY\"|" "$CRED_FILE"
sed -i "/^\[preset\.3]/,/^\[/ s|^script_encryption_key=.*|script_encryption_key=\"$SCRIPT_AES256_ENCRYPTION_KEY\"|" "$CRED_FILE"
sed -i "/^\[preset\.4]/,/^\[/ s|^script_encryption_key=.*|script_encryption_key=\"$SCRIPT_AES256_ENCRYPTION_KEY\"|" "$CRED_FILE"

# Linux 
export OS_Export="Linux"
"$SCRIPT_DIR/set_entry.sh" "$OS_Export" "encrypt_pck" "true" "$CONFIG_FILE"
"$SCRIPT_DIR/set_entry.sh" "$OS_Export" "encrypt_directory" "true" "$CONFIG_FILE"
"$SCRIPT_DIR/set_entry.sh" "$OS_Export" "custom_template/debug" "$LOCAL_TEMPLATES/godot.linuxbsd.template_debug.x86_64" "$CONFIG_FILE"
"$SCRIPT_DIR/set_entry.sh" "$OS_Export" "custom_template/release" "$LOCAL_TEMPLATES/godot.linuxbsd.template_release.x86_64" "$CONFIG_FILE"
"$SCRIPT_DIR/set_entry.sh" "$OS_Export" "binary_format/embed_pck" "true" "$CONFIG_FILE"

# Windows
export OS_Export="Windows Desktop"
"$SCRIPT_DIR/set_entry.sh" "$OS_Export" "encrypt_pck" "true" "$CONFIG_FILE"
"$SCRIPT_DIR/set_entry.sh" "$OS_Export" "encrypt_directory" "true" "$CONFIG_FILE"
"$SCRIPT_DIR/set_entry.sh" "$OS_Export" "custom_template/debug" "$LOCAL_TEMPLATES/godot.windows.template_debug.x86_64.exe" "$CONFIG_FILE"
"$SCRIPT_DIR/set_entry.sh" "$OS_Export" "custom_template/release" "$LOCAL_TEMPLATES/godot.windows.template_release.x86_64.exe" "$CONFIG_FILE"
"$SCRIPT_DIR/set_entry.sh" "$OS_Export" "binary_format/embed_pck" "true" "$CONFIG_FILE"

# macOS
# $OS_Export="macOS"
#export OS_Export="Windows Desktop"
#"$SCRIPT_DIR/set_entry.sh" "$OS_Export" "encrypt_pck" "true" "$CONFIG_FILE"
#"$SCRIPT_DIR/set_entry.sh" "$OS_Export" "encrypt_directory" "true" "$CONFIG_FILE"
#"$SCRIPT_DIR/set_entry.sh" "$OS_Export" "custom_template/debug" "$LOCAL_TEMPLATES/godot.linuxbsd.template_debug.x86_64" "$CONFIG_FILE"
#"$SCRIPT_DIR/set_entry.sh" "$OS_Export" "custom_template/release" "$LOCAL_TEMPLATES/godot.linuxbsd.template_release.x86_64" "$CONFIG_FILE"
#"$SCRIPT_DIR/set_entry.sh" "$OS_Export" "binary_format/embed_pck" "true" "$CONFIG_FILE"


# install the android templates
#echo install android templates
#"$GODOT_EDITOR" --headless --editor --install-android-build-template

#echo install windows, android, macOS, web templates
#"$GODOT_EDITOR" --headless --editor --install-export-templates

# Generate a new game using new or existing template files
#"$GODOT_EDITOR" --export-release Linux
#"$GODOT_EDITOR" --export-release "Windows Desktop"
#"$LOCAL_TEMPLATES/$GODOT_EDITOR" --export-release macOS

set +x





