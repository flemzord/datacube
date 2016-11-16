#!/bin/bash
####
# Datacube Installer
####
# @version:     1.0.2
# @release:     2016-11-16
# @copyright:    (c) 2016 https://datacube.io
####
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
####

# Defines colors shell
gre="\\033[1;32m"
std="\\033[0;39m"
red="\\033[1;31m"
blu="\\033[0;34m"
yel="\\033[1;33m"

# Header Datacube Installer
echo -ne "\n"
echo -ne "    +---------------------------------------------------------------+\n"
echo -ne "    |                    DATACUBE.io Installer                      |\n"
echo -ne "    +---------------------------------------------------------------+\n"
echo -ne "    |                        Version 1.0.2                          |\n"
echo -ne "    |                     (c) Copyright 2016                        |\n"
echo -ne "    +---------------------------------------------------------------+\n\n"

# Set environment
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Check user with id 0
if [ $(id -u) != "0" ]; then
    echo -ne "${std}[ ${red}FAIL ${std}] The installer needs to be run by a user with root privileges\n"
    exit 1
fi

# Starting script
echo -ne "${std}[ ${yel}INFO ${std}] Starting $0 script\n"

# Check dist and install packages
if [ -n "$(command -v apt-get)" ]; then
    apt-get -q -y --force-yes update 2>&1 >/dev/null
    if [ "$?" -eq "0" ]; then
        echo -ne "${std}[ ${gre}GOOD ${std}] Success for run command apt-get updates\n"
    else
        echo -ne "${std}[ ${red}FAIL ${std}] Error for run command apt-get updates\n"
        exit 1
    fi
    apt-get -q -y --force-yes install gzip curl jq unzip lftp git 2>&1 >/dev/null
    if [ "$?" -eq "0" ]; then
        echo -ne "${std}[ ${gre}GOOD ${std}] Success for install packages\n"
    else
        echo -ne "${std}[ ${red}FAIL ${std}] Error for install packages\n"
        exit 1
    fi
elif [ -n "$(command -v yum)" ]; then
    yum -d0 -e0 -y install epel-release 2>&1 >/dev/null
    if [ "$?" -eq "0" ]; then
        echo -ne "${std}[ ${gre}GOOD ${std}] Success for install EPEL repository\n"
    else
        echo -ne "${std}[ ${red}FAIL ${std}] Error for install EPEL repository\n"
        exit 1
    fi
    yum -d0 -e0 -y install cronie gzip curl jq unzip lftp git 2>&1 >/dev/null
    if [ "$?" -eq "0" ]; then
        echo -ne "${std}[ ${gre}GOOD ${std}] Success for install packages\n"
    else
        echo -ne "${std}[ ${red}FAIL ${std}] Error for install packages\n"
        exit 1
    fi
else
    if [ -n "$(command -v lsb_release)" ]; then
        echo -ne "${std}[ ${red}FAIL ${std}] Your distribution '$(lsb_release -d | cut -d\: -f2 | sed "s%\t%%g")' is not supported\n"
    else
        echo -ne "${std}[ ${red}FAIL ${std}] Your distribution is not supported\n"
    fi
    exit 1
fi

# Create folder for config file
if [ ! -d /etc/datacube ]; then
    mkdir -p /etc/datacube
    echo -ne "${std}[ ${yel}INFO ${std}] Directory /etc/datacube is not exist, create it\n"
fi

# If folder /opt/datacube exist, delete it
if [ -d /opt/datacube ]; then
    rm -Rf /opt/datacube
    echo -ne "${std}[ ${yel}INFO ${std}] Directory /opt/datacube is already exist, delete it\n"
fi

# Re-clone datacube agent from GitHub
cd /opt && git clone https://github.com/flemzord/datacube.git datacube 2>&1 >/dev/null
if [ "$?" -eq "0" ]; then
    echo -ne "${std}[ ${gre}GOOD ${std}] Download the datacube agent into /opt\n"
else
    echo -ne "${std}[ ${red}FAIL ${std}] Error to download the datacube agent\n"
fi

# Copy the crontab config for run.sh script
cp /opt/datacube/datacube.crontab /etc/cron.d/datacube
echo -ne "${std}[ ${yel}INFO ${std}] Copy the crontab file into /etc/cron.d/ directory\n"
chmod +x /opt/datacube/run.sh
echo -ne "${std}[ ${yel}INFO ${std}] Change permissions (+x) on the /opt/datacube/run.sh file\n"

# Configure the datacube access
echo -ne "${std}[ ${yel}INFO ${std}] Now configure your access for Datacube !\n"
read -r -p "        |-> Your Datacube username: " dc_username
read -r -p "        |-> Your Datacube password: " dc_password
read -r -p "        |-> Your Datacube serverid: " dc_serverid
read -r -p "        |-> Your Datacube FTP username: " dc_ftp_username
read -r -p "        |-> Your Datacube FTP password: " dc_ftp_password
read -r -p "        |-> Your key for encryption datas: " dc_encrypt

# Export datacube access to /etc/datacube/datacube.cfg file
cat << EOF > /etc/datacube/datacube.cfg
#!/bin/bash
API="https://datacube.io"
USERNAME="${dc_username}"
PASSWORD="${dc_password}"
SERVEURUID="${dc_serverid}"
BACKUP_DIR="/backup"
FTP_HOST="163.172.185.161"
FTP_USER="${dc_ftp_username}"
FTP_PASSWD="${dc_ftp_password}"
KEY_CRYPT="${dc_encrypt}"
EOF
if [ "$?" -eq "0" ]; then
    echo -ne "${std}[ ${gre}GOOD ${std}] Write your configuration into /etc/datacube/datacube.cfg file\n"
else
    echo -ne "${std}[ ${red}FAIL ${std}] Error to write your configuration into /etc/datacube/datacube.cfg file\n"
fi

# Sortie
echo -ne "${std}[ ${yel}INFO ${std}] Finish $0 script, enjoy with Datacube !\n"
