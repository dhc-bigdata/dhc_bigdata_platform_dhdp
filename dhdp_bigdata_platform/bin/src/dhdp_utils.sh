#! /bin/sh
#文本及脚本文件格式如windows转Unix参考命令dos2unix
dostype=dos
#-e 转义反斜扛字符 -n 禁止换行 \b 删除前一个字符 \n 换行且光标移至行首
IFS=$(echo -en "\n\b")
function iterate_dir(){
#	if [ "x$USER" != "xroot" ];then
#		return
#	fi
	for file in $1/*; do
	if [ -f $file ]; then
		typename=`file $file | grep -q CRLF && echo dos || echo unix`
		if [[ $typename == $dostype ]]; then
			sed -i "s/.$//g" $file
			echo 'converting '$file
		else
		:
		fi
	else
		iterate_dir $file
	fi
	done
	}
if [ "$1" == "" ]; then
	echo 'convering start'`pwd`
	iterate_dir .
else
	echo 'convering start'$1
	iterate_dir $1
fi
