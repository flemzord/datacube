#!/bin/bash
#
# Datacube Installer
#
# @version		1.0.1
# @date			2016-03-03
# @copyright	(c) 2016 https://datacube.io
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Set environment
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin


if [ $(id -u) != "0" ];
then
	echo "The installer needs to be run by a user with root privilege."
	exit 1
fi

if [ $# -lt 1 ]; then
    echo "DATACUBE serveur_id missing from installer command."
    exit 1
fi

if [ -n "$(command -v apt-get)" ]
then
    apt-get -q -y --force-yes update >/dev/null 2>&1
    apt-get -q -y --force-yes install gzip curl jq unzip lftp git >/dev/null 2>&1
fi

if [ -n "$(command -v yum)" ]
then
    yum -d0 -e0 -y install epel-relase >/dev/null 2>&1
    yum -d0 -e0 -y install cronie gzip curl jq unzip lftp git >/dev/null 2>&1
fi

if [ ! -d /etc/datacube ]
then
mkdir -p /etc/datacube
fi

if [ ! -d /opt/datacube ]
then
cd /opt
git clone https://github.com/flemzord/datacube.git datacube
fi

cd /opt/datacube
cp datacube.crontab /etc/cron.d/datacube

echo "Installation complete!"

if [ -f $0 ]
then
    rm -f $0
fi
