cd /opt/snort
./configure
make
sudo make install
export PATH=$PATH:/usr/local/bin
sudo snort -i ens33 -c /etc/snort/snort.conf -A console
