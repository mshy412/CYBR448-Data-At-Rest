#!/bin/bash
enc_files() {
    if [ "$use_keyfile" = "true" ]; then
        openssl enc -aes-${aes_mode}-cbc -salt -in "$1" -out "$1.enc" -pass file:"$keyfile" -pbkdf2
    else
        openssl enc -aes-${aes_mode}-cbc -salt -in "$1" -out "$1.enc" -k "$pass" -pbkdf2
    fi
}
method_dir() {
    for file in "$1"/*; do
        [ -f "$file" ] && [[ "$file" != *.enc ]] && enc_files "$file"
    done
}
echo "Encryption at Rest Bash Script"
echo ""
echo "1.) aes-128-cbc"
echo "2.) aes-192-cbc"
echo "3.) aes-256-cbc"
read -p "Enter desired AES mode: " aes_type
case $aes_type in
    1) aes_mode="128" ;;
    2) aes_mode="192" ;;
    *) aes_mode="256" ;;
esac
echo ""
echo "Choose encryption method:"
echo "1.) Password"
echo "2.) Key file"
read -p "Enter option: " method
if [ "$method" = "1" ]; then
    read -sp "Enter password for encryption: " pass
    echo ""
    use_keyfile="false"
elif [ "$method" = "2" ]; then
    read -p "Enter path to key file: " keyfile
    if [ ! -f "$keyfile" ]; then
        echo "Error: Key file not found."
        exit 1
    fi
    use_keyfile="true"
else
    echo "Invalid option."
    exit 1
fi
echo ""
echo "Encrypting now."
read -p "1.) File 2.) Multiple Files 3.) Directory 4.) Multiple Directories: " enc_type
case $enc_type in
    1) read -p "File path: " file
       enc_files "$file" && echo "Encrypted: $file.enc"
       ;;
    2) echo "Enter files: "
       while read -p "File: " file && [ -n "$file" ]; do
           enc_files "$file" && echo "Encrypted: $file.enc"
       done
       ;;
    3) read -p "Directory: " dir
       method_dir "$dir"
       echo "Directory encrypted: $dir"
       ;;
    4) echo "Enter directories: "
       while read -p "Directory: " dir && [ -n "$dir" ]; do
           method_dir "$dir"
           echo "Directory encrypted: $dir"
       done
       ;;
    *) echo "Invalid option."
       exit 1
       ;;
esac
echo ""
echo "Complete. Please refer to the decrypt tool to unencrypt files/directories."