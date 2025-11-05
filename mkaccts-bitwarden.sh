#!/bin/bash

# Check if Bitwarden CLI is unlocked
if ! bw unlock --check &>/dev/null; then
    echo "Error: Bitwarden vault is locked. Please unlock it first:"
    echo "  export BW_SESSION=\$(bw unlock --raw)"
    exit 1
fi

# Function to get password from Bitwarden
get_password() {
    local username="$1"
    bw get password "$username" 2>/dev/null
}

# Create user accounts with passwords from Bitwarden
echo "Creating user: sticks"
sudo useradd -m -u 1000 -s /bin/bash --comment "John Kilbane" sticks
PASSWORD=$(get_password "sticks")
if [ -n "$PASSWORD" ]; then
    echo "sticks:$PASSWORD" | sudo chpasswd
    sudo usermod -aG sudo sticks
else
    echo "Warning: Could not retrieve password for sticks"
fi

echo "Creating user: mwalls4464"
sudo useradd -m -u 1001 -s /bin/bash --comment "Michelle Walls" mwalls4464
PASSWORD=$(get_password "mwalls4464")
if [ -n "$PASSWORD" ]; then
    echo "mwalls4464:$PASSWORD" | sudo chpasswd
    sudo usermod -aG sudo mwalls4464
else
    echo "Warning: Could not retrieve password for mwalls4464"
fi

echo "Creating user: jimpkilbane"
sudo useradd -m -u 1002 -s /bin/bash --comment "Jim Kilbane" jimpkilbane
PASSWORD=$(get_password "jimpkilbane")
if [ -n "$PASSWORD" ]; then
    echo "jimpkilbane:$PASSWORD" | sudo chpasswd
    sudo usermod -aG sudo jimpkilbane
else
    echo "Warning: Could not retrieve password for jimpkilbane"
fi

echo "Creating user: nickwalls"
sudo useradd -m -u 1003 -s /bin/bash --comment "Nick Walls" nickwalls
PASSWORD=$(get_password "nickwalls")
if [ -n "$PASSWORD" ]; then
    echo "nickwalls:$PASSWORD" | sudo chpasswd
    sudo usermod -aG sudo nickwalls
else
    echo "Warning: Could not retrieve password for nickwalls"
fi

echo "Creating user: wallscayde"
sudo useradd -m -u 1004 -s /bin/bash --comment "Caydence Walls" wallscayde
PASSWORD=$(get_password "wallscayde")
if [ -n "$PASSWORD" ]; then
    echo "wallscayde:$PASSWORD" | sudo chpasswd
    sudo usermod -aG sudo wallscayde
else
    echo "Warning: Could not retrieve password for wallscayde"
fi

echo "Creating user: wallsmason55"
sudo useradd -m -u 1005 -s /bin/bash --comment "Mason Walls" wallsmason55
PASSWORD=$(get_password "wallsmason55")
if [ -n "$PASSWORD" ]; then
    echo "wallsmason55:$PASSWORD" | sudo chpasswd
    sudo usermod -aG sudo wallsmason55
else
    echo "Warning: Could not retrieve password for wallsmason55"
fi

echo "Creating user: wallsa713"
sudo useradd -m -u 1007 -s /bin/bash --comment "Amanda Tapp" wallsa713
PASSWORD=$(get_password "wallsa713")
if [ -n "$PASSWORD" ]; then
    echo "wallsa713:$PASSWORD" | sudo chpasswd
    sudo usermod -aG sudo wallsa713
else
    echo "Warning: Could not retrieve password for wallsa713"
fi

echo "Creating user: dely"
sudo useradd -m -u 1009 -s /bin/bash --comment "David Ely" dely
PASSWORD=$(get_password "dely")
if [ -n "$PASSWORD" ]; then
    echo "dely:$PASSWORD" | sudo chpasswd
    sudo usermod -aG sudo dely
else
    echo "Warning: Could not retrieve password for dely"
fi

echo "Creating user: molonynatalie"
sudo useradd -m -u 1010 -s /bin/bash --comment "Natalie Molony" molonynatalie
PASSWORD=$(get_password "molonynatalie")
if [ -n "$PASSWORD" ]; then
    echo "molonynatalie:$PASSWORD" | sudo chpasswd
    sudo usermod -aG sudo molonynatalie
else
    echo "Warning: Could not retrieve password for molonynatalie"
fi

echo "Account creation complete!"
