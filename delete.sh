#!/bin/bash

# Filename: delete.sh  2015.08.31
# Author: huoty <sudohuoty@163.com>
# Script starts from here:

#### 定义终端输出文本颜色
COLOR_RED="\e[31;49m"
COLOR_GREEN="\e[32;49m"
COLOR_YELLO="\e[33;49m"
COLOR_BLUE="\e[34;49m"
COLOR_MAGENTA="\e[35;49m"
COLOR_CYAN="\e[36;49m"
COLOR_WHILE="\033[1m"
COLOR_RESET="\e[0m"

#### 为程序的首次使用创建回收站
if [ ! -d ~/.trash ]
then
    mkdir -vp ~/.trash
fi

LOGFILE=".log"

#### 显示程序帮组信息
usage()
{
    echo -e "Usage: delete [options] file1 [file2 file3....]\n"
    echo -e "delete is a simple command line interface for deleting file to custom trash.\n"
    echo "Options:"
    echo "  -d  Empty the trash"
    echo "  -f  Forced delete file"
    echo "  -r  Restore the file in the trash"
    echo "  -l  List the files in the trash"
    echo "  -p  Print log file"
    echo "  -h  Show this help message and exit"
    echo "  -v  Show program's version number and exit"
}

#### 如果没有提供任何参数
if [ $# -eq 0 ]
then 
    usage
    exit 0
fi

#### 判断是否存在定义的参数
debaroption()
{
    if [ $1 = "-d" -o $1 = "-f" -o $1 = "-r" -o $1 = "-l" -o $1 = "-p" -o $1 = "-v" -o $1 = "-h" ]
    then 
        return 0
    else 
        return 1
    fi
}

#### 读取参数并做相应处理
force=0  # 强制删除标记
restore=0  # 文件恢复标记
while getopts "dfrlpvh" opt
do
    case $opt in
        d)  # 清空回收站
            #if zenity --question --text "Are you sure you want to empty the trash ?"
            echo -ne "Are you sure you want to empty the trash?[Y/N]:\a"
            read reply
            if [ $reply = "y" -o $reply = "Y" ]
            then
                for file in `ls -a ~/.trash/`
                do
                    if [ $file = "." -o $file = ".." ]
                    then 
                        continue
                    else 
                        echo "Removing forever ~/.trash/$file"
                        rm -rf ~/.trash/$file
                    fi
                done
            fi
            echo "Done."
            ;;
        f)  # 强制删除
            #exec rm -rf "$@"  # exec会以新的进程去代替原来的进程
            force=1
            for file in $@
            do
                debaroption $file
                ret=$?
                if [ $ret -eq 1 ]
                then 
                    echo "Removing $file"
                    rm -rf $file
                fi
            done
            echo "Done."
            ;;
        r)  # 恢复文件
            # 说明：恢复文件时指定的参数应该为带删除日期的新文件名
            restore=1
            #if zenity --question --text "Are you sure you want to restore the file ?"
            echo -ne "Are you sure you want to restore the file?[Y/N]:\a"
            read reply
            if [ $reply = "y" -o $reply = "Y" ]
            then
                for file in $@
                do
                    debaroption $file
                    ret=$?
                    if [ $ret -eq 1 ]
                    then
                        fullpath="$HOME/.trash/$file"
                        if [ -f "$fullpath" -o -d "$fullpath" -o -h "$fullpath" -o -p "$fullpath" ]
                        then
                            originalpath=$(awk /$file/'{print $4}' "$HOME/.trash/$LOGFILE")
                            #filenamenow=$(awk /$file/'{print $1}' "$HOME/.trash/$LOGFILE")
                            filenamebefore=$(awk /$file/'{print $2}' "$HOME/.trash/$LOGFILE")
                            echo "Restoring $file"
                            mv -b "$HOME/.trash/$file" "$originalpath"
                            sed -i "/$file/d" "$HOME/.trash/$LOGFILE"
                        else
                            echo -e "${COLOR_RED}There is no file in the trash.$COLOR_RESET"
                        fi
                    fi
                done
            fi
            echo "Done."
            ;;
        p)  # 打印删除日志文件
            cat ~/.trash/$LOGFILE
            ;;
        l)  # 列出回收站中的所有文件
            ls -a ~/.trash/
            ;;
        v)  # 显示版本号
            echo "delete v0.9 (c) 2015 by huoty."
            ;;
        h)  # 查看帮助
            usage
            ;;
        *)  # 无效参数
            usage
            exit 0
            ;;
    esac
done

#### 删除到回收站
if [ $force -eq 0 -a $restore -eq 0 ]
then
    for file in $@
    do
        debaroption $file
        ret=$?
        if [ $ret -eq 1 ]
        then
            now=`date +%Y%m%d%H%M%S`
            filename="${file##*/}"
            newfilename="${file##*/}_${now}"
            mark1=`expr substr $file 1 2`
            mark2=`expr substr $file 1 1`
            if [ $mark1 = "./" ]
            then
                fullpath="$(pwd)/$filename"
            elif [ $mark2 = "/" ]
            then
                fullpath="$file"
            else
                fullpath="$(pwd)/$file"
            fi

            if [ -f "$fullpath" -o -d "$fullpath" -o -h "$fullpath" -o -p "$fullpath" ]
            then
                if [ -f "$file" ] && [ `ls -l $file | awk '{print $5}'` -gt 2147483648 ]
                then
                    #if zenity --question --text "$filename size is larger than 2G, will be deleted directly.\nSelect “No” to delete the trash."
                    echo -ne "$filename size is larger than 2G, will be deleted directly.\nInput 'N' to delete the trash.[Y/N]:\a"
                    read reply
                    if [ $reply = "y" -o $reply = "Y" ]
                    then
                        echo -n "Removing $fullpath ... "
                        rm -rf $fullpath
                        echo "done."
                    else
                        echo -n "Deleting $fullpath ... "
                        mv -f $fullpath ~/.trash/$newfilename
                        echo $newfilename $filename $now $fullpath >> ~/.trash/$LOGFILE
                        echo "done."
                    fi
                elif [ -d "$file" ] && [ `du -sb $file | awk '{print $1}'` -gt 2147483648 ]
                then
                    #if zenity --question --text "The directory:$filename is larger than 2G, will be deleted directly.\nSelect “No” to delete the trash."
                    echo -ne "The directory:$filename is larger than 2G, will be deleted directly.\nSelect “No” to delete the trash.\a"
                    read reply
                    if [ $reply = "y" -o $reply = "Y" ]
                    then
                        echo -n "Removing $fullpath ... "
                        rm -rf $fullpath
                        echo "done."
                    else
                        echo -n "Deleting $fullpath ... "
                        mv -f $fullpath ~/.trash/$newfilename
                        echo $newfilename $filename $now $fullpath >> ~/.trash/$LOGFILE
                        echo "done."
                    fi
                else
                    echo -n "Deleting $fullpath ... "
                    mv -f $fullpath ~/.trash/$newfilename
                    echo $newfilename $filename $now $fullpath >> ~/.trash/$LOGFILE
                    echo "done."
                fi
            else
                echo -e "${COLOR_RED}Could not delete the $fullpath!${COLOR_RESET}"
            fi
        fi
    done
fi

#### 脚本结束
exit 0
