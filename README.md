# Crunchy - Advanced WiFi Password Wordlist Generator

Script to Generate Custom WiFi Passwords as per Target for Highest Cracking Possibility

This Script Automatically generates Password Combinations & Can Also Crack the Handshake for you

## NEW in v2.0
- **Multi-Person Support**: Generate passwords for N number of people in one run
- **48+ Unique Pattern Types**: Extended from 14 to 58+ pattern variations
- **Advanced Symbol Combinations**: @, #, !, _, $, ., * with up to 3 symbol combinations
- **Extended Number Ranges**: 1-9999 for all pattern types
- **Name Slicing**: First 3-4 character patterns
- **Reverse Names**: Reversed name patterns
- **No Overlapping**: Intelligent pattern generation to avoid duplicates

## What is Handshake?
In layman terms, it's basically a hashed password which you get by intercepting the communication between the WiFi Owner & WiFi Router

After capturing this handshake using tools such as AirCrack-ng, you have to crack the Hashed Password (Handshake) using a Wordlist

## What this script does?
It helps you in creating high success rate wordlist, this tool will only help if the target WiFi is using a Weak Password.

## Why to Capture Handshake?
Well you can directly attempt to guess password but after some attempts, Router will block you or drop your attempts

Even though it doesn't drop your attempts, it will take Forever

Because of Cracking speed (Hardly 2-5 passwords a Minute)

If you've 1080 Ti (8 GB VRAM), then you could get roughly 47,876 MH/s i.e. 47,876 Millions of Hashes per seconds

That's a Crazy number,

In this video, Kevin Mitnick has shown with a demo of HashCat to prove this number: https://www.youtube.com/watch?v=K-96JmC2AkE

And there is no limit of cracking speed, you could run the hash cracking on Powerful Rented Server with maybe 128 GB of Graphic Card!

That's how easy it is to Crack a Password at a speed of Billions per seconds

## Usage
```bash
$ git clone https://github.com/pushpenderindia/Crunchy.git
$ cd Crunchy

# Run the script (now supports multiple people)
$ bash Crunchy.sh

# You'll be prompted:
# 1. How many people to generate passwords for
# 2. First Name and Last Name for each person
# 3. Handshake FilePath (Optional)
# 4. Attack tool preference (Hashcat or Aircrack-ng)
```

## Example Usage

```bash
$ bash Crunchy.sh

[?] How many people do you want to generate passwords for? 2

[*] Person #1:
    Enter First Name: Rahul
    Enter Last Name (leave blank if none): Singh

[*] Person #2:
    Enter First Name: Priya
    Enter Last Name (leave blank if none):

[?] Enter Cap File Path (leave blank if only want to generate wordlist):

[*] Starting password generation for 2 person(s)...

[>>] Generating patterns for: Rahul Singh
[*] Generating rahul patterns...
[*] Generating Rahul@1 to Rahul@9999...
[*] Generating # symbol patterns...
[*] Generating special symbol patterns...
[*] Generating number-first patterns...
[*] Generating multi-symbol patterns...
[*] Generating name slicing patterns...
[*] Generating reverse name patterns...
[*] Generating lastname combination patterns...
[+] Completed patterns for Rahul Singh

[>>] Generating patterns for: Priya
[*] Generating priya patterns...
[+] Completed patterns for Priya

[*] Generating numerical patterns (1-9999)...
[*] Merging all wordlists into mega_wordlist.txt...

[>>] Total Passwords Generated: 245678 [mega_wordlist.txt]
```

## Pattern Types Generated (58+ Unique Patterns)

### Basic Patterns
- `firstname123`, `Firstname123`
- `firstname1234`, `Firstname1234`
- `123firstname`, `123Firstname`

### @ Symbol Patterns (Primary)
- `Firstname@123`, `firstname@123`
- `Firstname@1` to `Firstname@9999` (all 1-4 digit ranges)
- `1@Firstname` to `9999@Firstname`

### # Symbol Patterns (Primary)
- `Firstname#123`, `firstname#123`
- `Firstname#1` to `Firstname#9999`
- `1#Firstname` to `9999#Firstname`

### Other Symbols (!_$.*/)
- `Firstname!123`, `Firstname_123`
- `Firstname$123`, `Firstname.123`
- `Firstname*123`

### Multi-Symbol Combinations
- `Firstname@#123`, `Firstname#@123`
- `Firstname@!123`
- `Firstname@#!123` (up to 3 symbols)

### Name Slicing (Nicknames)
- `Fir@123` (first 3 chars)
- `Firs@123` (first 4 chars)
- `Fir@1` to `Fir@9999`

### Reverse Names
- `Luhar@123` (for Rahul)
- `emantsrif@123`

### Lastname Combinations (when provided)
- `RahulSingh123`, `rahulsingh123`
- `RahulSingh@1` to `RahulSingh@9999`
- `RahulSingh#123`, `RahulSingh!123`
- `Rahul.Singh@123`
- `Singh@123`, `Singh@1` to `Singh@9999`

### Pure Numbers
- 1-9999 (all 1-4 digit combinations)

## Sample Passwords for "Rahul Singh"
```
rahul123, Rahul123, rahul1234, Rahul1234
Rahul@1, Rahul@99, Rahul@999, Rahul@9999
rahul@123, Rahul@123
Rahul#1, Rahul#99, Rahul#999, Rahul#9999
Rahul!123, Rahul_123, Rahul$123, Rahul.123, Rahul*123
1@Rahul, 99@Rahul, 999@Rahul, 9999@Rahul
Rahul@#123, Rahul#@123, Rahul@!123, Rahul@#!123
Rah@123, Rahu@123, Rah#123
Luhar@123 (reversed)
RahulSingh123, RahulSingh@99, RahulSingh@9999
RahulSingh#123, RahulSingh!123, RahulSingh_123
Rahul.Singh@123, RahulSingh@#123
Singh@123, Singh@9999
+ numbers 1-9999
```

## Features

### No Overlapping Patterns
All patterns are unique and optimized to avoid generating duplicate passwords

### Smart Number Ranges
- Avoids massive 8-digit generation (100M+ passwords)
- Focuses on realistic 1-4 digit ranges (1-9999)
- Most common in real-world passwords

### Comprehensive Coverage
- 7 different symbol types (@#!_$.*)
- Multi-symbol combinations (up to 3)
- Case variations (lowercase, Capitalized)
- Name variations (full, sliced, reversed)
- Lastname combinations

### Efficient Multi-Person Support
- Process multiple people in single run
- Automatic file management
- Consolidated output in mega_wordlist.txt
- Temporary files auto-cleaned

## Screenshot

![Image](Crunchy.png)

## If Crunchy Fails?

- If you are unable to crack password using this script
- Then try downloading a wordlist from this website:
- https://weakpass.com/
- If still not getting success, then move to another target or try any other method (Evil Twin, etc)

## Requirements

- `crunch` - Wordlist generator
- `hashcat-utils` - For cap2hccapx conversion (auto-installed)
- `hashcat` - For hashcat mode (optional)
- `aircrack-ng` - For aircrack mode (optional)

## Security Note

This tool is for **authorized security testing only**. Only use on networks you own or have explicit permission to test.