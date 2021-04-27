#!/bin/bash

#############################################################################################
# UPDATE:	at 2021-04-27
# NOTE:		make sure ,
# AUTHOR:	liuzelin01@outlook.com
#############################################################################################
# 导入系统变量
#############################################################################################
# set -e 
. /etc/init.d/functions
source /etc/profile

#############################################################################################
# 服务变量定义
#############################################################################################
# 线条
LINE='---------------------------------------------------------------------------------------'

# 进程用户
USER_PROCESS='root'

#############################################################################################
# 颜色输出函数
#############################################################################################
FUNC_COLOR_TEXT() {
  echo -e " \e[0;$2m$1\e[0m"
}

FUNC_ECHO_RED() {
  echo $(FUNC_COLOR_TEXT "$1" "31")
}

FUNC_ECHO_GREEN() {
  echo $(FUNC_COLOR_TEXT "$1" "32")
}

FUNC_ECHO_YELLOW() {
  echo $(FUNC_COLOR_TEXT "$1" "33")
}

FUNC_ECHO_BLUE() {
  echo $(FUNC_COLOR_TEXT "$1" "34")
}

#############################################################################################
# 颜色通知输出函数
#############################################################################################
# 通知信息
FUNC_ECHO_INFO() {
  echo $(FUNC_COLOR_TEXT "${LINE}" "33")
  echo $(FUNC_COLOR_TEXT "$1" "33")
  echo $(FUNC_COLOR_TEXT "${LINE}" "33")
}

# 完成信息
FUNC_ECHO_SUCCESS() {
  echo $(FUNC_COLOR_TEXT "${LINE}" "32")
  echo $(FUNC_COLOR_TEXT "$1" "32")
  echo $(FUNC_COLOR_TEXT "${LINE}" "32")
}

# 错误信息
FUNC_ECHO_ERROR() {
  echo $(FUNC_COLOR_TEXT "${LINE}" "31")
  echo $(FUNC_COLOR_TEXT "$1" "31")
  echo $(FUNC_COLOR_TEXT "${LINE}" "31")
}

#############################################################################################
# check OS
#############################################################################################
FUNC_SYSTEM_CHECK() {
#    VAR_SYSTEM_FLAG=$(/usr/bin/cat /etc/redhat-release | grep 'CentOS' | grep '7' | wc -l)
    source /etc/os-release

    if [[ ${VERSION_ID} -ne 7 ]];then
    FUNC_ECHO_ERROR '本脚本基于 [ CentOS 7 ] 编写，目前暂不支持其他版本系统！'
    exit 1001
  fi
}

#############################################################################################
# check user
#############################################################################################
FUNC_USER_CHECK() {
  VAR_USER=$(/usr/bin/whoami)
  if [[ ${VAR_USER} != 'root' ]];then
    FUNC_ECHO_ERROR '脚本目前只支持 [ root ] 用户执行，请先切换用户...'
    exit 1002
  fi
}

#############################################################################################
# check network
#############################################################################################
FUNC_NETWORK_CHECK() {
  if ! (/usr/bin/ping -c 1 www.baidu.com &>/dev/null) ;then
    FUNC_ECHO_ERROR '网络连接失败，请先配置好网络连接...'
    exit 1003
  fi
}

#############################################################################################
# system info
#############################################################################################

# get ip
eth0ip(){
    DEVC=$(route -n | grep ^0.0.0.0 | awk '{print $NF}')
    ifconfig $DEVC | grep -E "netmask|Mask" |tr -s ' '|cut -d' ' -f3 |cut -d: -f2
}

FUNC_PRINT_SYSTEM_INFO() {
  # 获取系统信息
  SYSTEM_DATE=$(/usr/bin/date)
  SYSTEM_VERSION=$(/usr/bin/cat /etc/redhat-release)
  SYSTEM_CPU=$(/usr/bin/cat /proc/cpuinfo | grep 'model name' | head -1 | awk -F: '{print $2}' | sed 's#^[ \t]*##g')
  SYSTEM_CPU_NUMS=$(/usr/bin/cat /proc/cpuinfo | grep 'model name' | wc -l)
  SYSTEM_KERNEL=$(/usr/bin/uname -a | awk '{print $3}')
#   SYSTEM_IPADDR=$(/usr/sbin/ip addr | grep inet | grep -vE 'inet6|127.0.0.1' | awk '{print $2}')
    
  # 打印系统信息
  FUNC_ECHO_YELLOW ${LINE}
  echo "服务器的信息: $(eth0ip)"
  FUNC_ECHO_YELLOW ${LINE}
  echo "操作系统版本: ${SYSTEM_VERSION}"
  echo "系统内核版本: ${SYSTEM_KERNEL}"
  echo "处理器的型号: ${SYSTEM_CPU}"
  echo "处理器的核数: ${SYSTEM_CPU_NUMS}"
  echo "系统当前时间: ${SYSTEM_DATE}"
  FUNC_ECHO_YELLOW ${LINE}
}

#############################################################################################
# update kernel
#############################################################################################
FUNC_UPDATE_KERNEL() {
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
#     rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm

    if ! (yum install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm);then
	FUNC_ECHO_ERROR "EL 源安装失败，请检查是否存在问题！"
#       exit 1004
	sleep 10
    fi
    
    # 查看可提供升级的版本
    yum --disablerepo="*" --enablerepo="elrepo-kernel" list available
    
    VAR_KERNEL_NAME="kernel-lt"
    read -p "请输入上面列出的版本中你想安装的版本（默认 lt 版本） [lt/ml]: " UR_CHOICE
    if [[ ${UR_CHOICE} == "ml" ]];then
        VAR_KERNEL_NAME="kernel-ml"
    fi
    
    FUNC_ECHO_INFO "本次选择升级的版本为：${VAR_KERNEL_NAME}"

    if ! (yum --enablerepo=elrepo-kernel install ${VAR_KERNEL_NAME} &>/dev/null) ;then
      FUNC_ECHO_ERROR "内核升级失败，请根据报错检查是否存在问题！"
      exit 1005
    fi
    
    # 查看目前版本
    FUNC_ECHO_INFO "系统当前所安装的内核版本如下："
    awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
    
    # 选择默认内核版本
    VAR_NUM_CHOICE=0
    read -p "请输入上面列出的版本序号选择系统最终默认版本（默认 0）: " VAR_NUM_CHOICE
    if [[ $(echo ${VAR_NUM_CHOICE} | sed 's/[0-9]//g') == '' ]];then
        if [[ ${VAR_NUM_CHOICE} == "" ]];then
            VAR_NUM_CHOICE=0
        fi
    else
        FUNC_ECHO_INFO "输入有误，将以默认配置执行..."
        VAR_NUM_CHOICE=0
    fi
        
    # 配置系统默认
    grub2-set-default ${VAR_NUM_CHOICE}
    
    sed -i "s#^GRUB_DEFAULT=.*#GRUB_DEFAULT=${VAR_NUM_CHOICE}#g" /etc/default/grub
    if [[ $? -ne 0 ]];then
      FUNC_ECHO_ERROR "默认内核配置失败，可以手动配置/etc/default/grub文件中：GRUB_DEFAULT参数为指定内核索引！"
    fi
}

#############################################################################################
# remove kernel by hand
#############################################################################################
FUNC_UNINSTALL_KERNEL() {
    # 显示内核版本
    FUNC_ECHO_INFO "系统当前所安装的内核版本如下："
    rpm -qa | grep kernel
    
    # 提示卸载
    FUNC_ECHO_INFO "你可以手动卸载旧版本：yum -y remove 包名字，然后重启使用：uname -sr 查看升级结果"
}

#############################################################################################
# check system
FUNC_SYSTEM_CHECK
# check user
FUNC_USER_CHECK
# check network 
FUNC_NETWORK_CHECK
# system info
FUNC_PRINT_SYSTEM_INFO

read -p "是否继续安装升级（默认 y） [y/n]: " VAR_CHOICE
case ${VAR_CHOICE} in
  [yY][eE][sS]|[yY])
    FUNC_UPDATE_KERNEL
    FUNC_UNINSTALL_KERNEL
  ;;
  [nN][oO]|[nN])
    FUNC_ECHO_YELLOW "安装升级即将终止..."
    exit
  ;;
  *)
    FUNC_UPDATE_KERNEL
    FUNC_UNINSTALL_KERNEL
esac
