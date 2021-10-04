#!/bin/sh
#Author:https://github.com/emptysuns
echo "\033[35m******************************************************************\033[0m"
echo " ██      ██                    ██                  ██          
░██     ░██  ██   ██          ░██                 ░░           
░██     ░██ ░░██ ██   ██████ ██████  █████  ██████ ██  ██████  
░██████████  ░░███   ██░░░░ ░░░██░  ██░░░██░░██░░█░██ ░░░░░░██ 
░██░░░░░░██   ░██   ░░█████   ░██  ░███████ ░██ ░ ░██  ███████ 
░██     ░██   ██     ░░░░░██  ░██  ░██░░░░  ░██   ░██ ██░░░░██ 
░██     ░██  ██      ██████   ░░██ ░░██████░███   ░██░░████████
░░      ░░  ░░      ░░░░░░     ░░   ░░░░░░ ░░░    ░░  ░░░░░░░░ "
echo "\033[32mVersion:\033[0m 0.1"
echo "\033[32mGithub:\033[0m https://github.com/emptysuns/HiHysteria"
echo "\033[35m******************************************************************\033[0m"
echo "\033[42;37mReady to install!\033[0m\n"
echo  "\033[42;37mDowload:hysteria主程序... \033[0m"
mkdir -p /etc/hysteria
version=`wget -qO- -t1 -T2 "https://api.github.com/repos/HyNetwork/hysteria/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g'`
get_arch=`arch`
if [ $get_arch = "x86_64" ];then
    wget -O /etc/hysteria/hysteria https://github.com/HyNetwork/hysteria/releases/download/$version/hysteria-linux-amd64
elif [ $get_arch = "aarch64" ];then
    wget -O /etc/hysteria/hysteria https://github.com/HyNetwork/hysteria/releases/download/$version/hysteria-linux-arm64
elif [ $get_arch = "mips64" ];then
    wget -O /etc/hysteria/hysteria https://github.com/HyNetwork/hysteria/releases/download/$version/hysteria-linux-mipsle
else
    echo "\033[41;37mError[OS Message]:$get_arch\nPlease open a issue to https://github.com/emptysuns/HiHysteria !\033[0m"
    exit
fi
chmod 755 /etc/hysteria/hysteria
wget -O /etc/hysteria/routes.acl https://raw.githubusercontent.com/emptysuns/HiHysteria/main/acl/routes.acl
echo "\033[32m下载完成！\033[0m"
echo  "\033[42;37m开始配置: \033[0m"
echo "\033[32m请输入您的域名(必须是存在的域名，并且解析到此ip):\033[0m"
read  domain
echo "\033[32m请输入你想要开启的端口（此端口是server的开启端口10000-65535）：\033[0m"
read  port
echo "\n期望速度，请如实填写，这是客户端的峰值速度，服务端默认不受限。\033[31m期望过低或者过高会影响转发速度！\033[0m"
echo "\033[32m请输入客户端期望的下行速度:\033[0m"
read  download
echo "\033[32m请输入客户端期望的上行速度:\033[0m" 
read  upload
echo "\033[32m请输入混淆口令（相当于连接密钥）:\033[0m"
read  obfs
echo "\033[32m配置录入完成！\033[0m"
echo  "\033[42;37m执行配置...\033[0m"
cat <<EOF > /etc/hysteria/config.json
{
  "listen": ":$port",
  "acme": {
    "domains": [
	"$domain"
    ],
    "email": "pekora@$domain"
  },
  "disable_udp": false,
  "obfs": "$obfs",
  "auth": {
    "mode": "password",
    "config": {
      "password": "pekopeko"
    }
  },
  "acl": "/etc/hysteria/routes.acl",
  "recv_window_conn": 33554432,
  "recv_window_client": 134217728,
  "max_conn_client": 4096,
  "disable_mtu_discovery": false
}
EOF

cat <<EOF > config.json
{
"server": "$domain:$port",
"up_mbps": $upload,
"down_mbps": $download,
"http": {
"listen": "127.0.0.1:8888",
"timeout" : 300,
"disable_udp": false
},
"acl": "routes.acl",
"obfs": "$obfs",
"auth_str": "pekopeko",
"server_name": "$domain",
"insecure": false,
"recv_window_conn": 33554432,
"recv_window": 134217728,
"disable_mtu_discovery": false
}
EOF

cat <<EOF >/etc/systemd/system/hysteria.service
[Unit]
Description=hysteria:Hello World!
After=network.target

[Service]
Type=simple
PIDFile=/run/hysteria.pid
ExecStart=/etc/hysteria/hysteria --log-level warn -c /etc/hysteria/config.json server >> /etc/hysteria/error.log
#Restart=on-failure
#RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF
sysctl -w net.core.rmem_max=4000000
sysctl -p
chmod 644 /etc/systemd/system/hysteria.service
systemctl daemon-reload
systemctl enable hysteria
systemctl start hysteria
echo  "\033[42;37m所有安装已经完成，配置文件输出如下且已经在本目录生成（可自行复制粘贴到本地）！\033[0m"
echo "\nTips:客户端默认只开启http代理!http://127.0.0.1:8888,其他方式请参照文档自行修改客户端config.json\n"
echo "\033[35m↓***********************************↓↓↓copy↓↓↓*******************************↓\033[0m"
cat ./config.json
echo "\033[35m↑***********************************↑↑↑copy↑↑↑*******************************↑\033[0m"
echo  "\033[42;37m安装完毕\033[0m\n"