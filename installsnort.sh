#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
    echo "Vui lòng chạy với quyền root!"
    exit
fi

echo "Cập nhật hệ thống..."
apt update && apt upgrade -y

echo "Cài đặt các gói phụ thuộc..."
apt install -y build-essential libpcap-dev libpcre3-dev libdumbnet-dev bison flex zlib1g-dev \
    liblzma-dev openssl libssl-dev wget tar

# Tải xuống mã nguồn Snort
SNORT_VERSION="2.9.20"
SNORT_URL="https://www.snort.org/downloads/snort/snort-$SNORT_VERSION.tar.gz"
INSTALL_DIR="/opt/snort"

echo "Tải xuống Snort $SNORT_VERSION..."
wget -O snort.tar.gz "$SNORT_URL"

echo "Giải nén mã nguồn Snort..."
mkdir -p "$INSTALL_DIR"
tar -xzf snort.tar.gz -C "$INSTALL_DIR" --strip-components=1

echo "Biên dịch và cài đặt Snort..."
cd "$INSTALL_DIR"
./configure && make && make install

echo "Cài đặt cấu trúc thư mục Snort..."
mkdir -p /etc/snort/rules /var/log/snort /usr/local/lib/snort_dynamicrules
touch /etc/snort/rules/white_list.rules /etc/snort/rules/black_list.rules /etc/snort/rules/local.rules

# Cấu hình cơ bản
echo "alert tcp any any -> any 80 (msg:\"HTTP request detected\"; sid:1001;)" > /etc/snort/rules/local.rules

echo "Cấu hình snort.conf..."
cat <<EOL > /etc/snort/snort.conf
include \$RULE_PATH/local.rules
var RULE_PATH /etc/snort/rules
output log_tcpdump: tcpdump.log
EOL

echo "Đặt quyền cho thư mục Snort..."
chmod -R 5775 /var/log/snort
chown -R snort:snort /var/log/snort

echo "Kiểm tra Snort..."
snort -V

echo "Hoàn tất cài đặt Snort!"
echo "Bạn có thể chạy Snort với lệnh sau:"
echo "snort -i eth0 -c /etc/snort/snort.conf -A console"
