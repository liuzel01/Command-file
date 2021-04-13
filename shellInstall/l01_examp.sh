#!/bin/bash

for ((i=1;i<=100;i++));do
    let sum+=i
done

# echo sum=$sum

select_menu(){
ps1="请问你要吃什么(输入6退出)"
select menu in 黄焖鸡 鱼香肉丝盖饭 烤肉饭 老碗面 招牌五谷渔粉 退出;do
    case $REPLY in
        1)
            echo "黄焖鸡 15元";;
        2)
            echo "鱼香肉丝盖饭 15元";;
        3)
            echo "烤肉饭 12元";;
        4)
            echo "老碗面 9元";;
        5)
            echo "招牌五谷渔粉  12元";;
        6)
            echo "欢迎下次光临";
            break
        esac
done
}

os(){
    sed -r 's/.*[[:space:]]([0-9])\..*/\1/' /etc/redhat-release
}

eth0ip(){
    ifconfig wlp0s20f3 | grep netmask |tr -s ' '|cut -d' ' -f3 |cut -d: -f2
}

red(){
    echo -e "\033[41m    \033[0m\c"
}
yel(){
    echo -e "\033[43m    \033[0m\c"
}
redyel() {
    for ((i=1;i<=2;i++));do
        for ((j=1;j<=4;j++));do
            [ "$1" = "-r"  ] && { yel;red;  } || { red;yel;  }
        done
        echo
    done
}
square(){
    for ((line=1;line<=8;line++));do
        [ $[$line%2] -eq 0  ] && redyel || redyel -r
    done
}


read -p "请输入斐波那契数列的阶数:" n
fact_prin(){
fact(){
    if [ $1 -eq 0 ];then
        echo 0
    elif [ $1 -eq 1 ];then
        echo 1
    else
        echo $[`fact $[$1-1]`+`fact $[$1-1]`]
    fi
}
    for i in `seq 0 $n`;do
        fact $i
    done
}
fact_prin

# https://blog.51cto.com/u_12948961/2161449
