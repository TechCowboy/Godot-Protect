echo Ensure you have "Encrypt Exported PCK" and "Encrypt Index" in a custom template
openssl rand -hex 32 > godot.gdkey
export SCRIPT_AES256_ENCRYPTION_KEY=$(cat godot.gdkey)

