#!/bin/bash
quality="70"            #图片质量
RESOLUTION="50%x50%"    #图片压缩率
watermark=""            #图片水印
Q_FLAG="0"   
R_FLAG="0"
W_FLAG="0"
C_FLAG="0"
H_FLAG="0"
PREFIX=""
POSTFIX=""
DIR=`pwd`              #要操作的图片目录
# read the options

#输出帮助信息
useage()   
{
  echo "Useage:bash test.sh  -d <directory> [option|option]"
  echo "options:"
  echo "  -d [directory]                想处理文本的文件路径"
  echo "  -c                            png/svg -> jpg"
  echo "  -r|--resize [width*height|width]    保持某个压缩比进行图像压缩 700x700 or 50%x50%   如果输入的是一个数值 就是保持原始纵横比进行压缩"
  echo "  -q|--quality [number]          对jpg图像进行质量压缩"
  echo "  -w|watermark [watermark]       添加水印"
  echo "  --prefix[prefix]               添加前缀"
  echo "  --postfix[postfix]             添加后缀"
}

main()
{
#输出帮助信息
if [[ "$H_FLAG" == "1" ]]; then
    useage
fi
#-d dir 如果是文件夹返回true
if [ ! -d "$DIR" ] ; then
  echo "No such directory"
  exit 0
fi

#在dir下新建一个output输出文件
output=${DIR}/output
mkdir -p $output

#首先拼凑出需要执行的指令
command="convert"
IM_FLAG="2"
#如果需要进行压缩
if [[ "$Q_FLAG" == "1" ]]; then
  IM_FLAG="1"
  command=${command}" -quality "${quality}
fi
#如果需要进行压缩   需要查一下convert函数的压缩参数的输入
if [[ "$R_FLAG" == "1" ]]; then
  command=${command}" -resize "${RESOLUTION}
fi
#如果需要添加水印
if [[ "$W_FLAG" == "1" ]]; then
  echo ${watermark}
  command=${command}" -fill white -pointsize 40 -draw 'text 10,50 \"${watermark}\"' "
fi

#如果需要转换格式
if [[ "$C_FLAG" == "1" ]]; then
  IM_FLAG="2"
fi

#根据需要获取对应后缀的图片  imgs中存储的是绝对路径
case "$IM_FLAG" in
       1) images=`find $DIR -maxdepth 1 -regex '.*\(jpg\|jpeg\)'` ;;
       2) images=`find $DIR -maxdepth 1 -regex '.*\(jpg\|jpeg\|png\|svg\)'` ;;
esac 

#根据指令处理每一个文件
for CURRENT_IMAGE in $images; do
     filename=$(basename "$CURRENT_IMAGE")  #只取出文件名  .2.jpeg
     name=${filename%.*}                    #去掉后缀    .2
     suffix=${filename#*.}                  #取出后缀     .jpeg
     if [[ "$suffix" == "png" && "$C_FLAG" == "1" ]]; then 
       suffix="jpg"
     fi
     if [[ "$suffix" == "svg" && "$C_FLAG" == "1" ]]; then
       suffix="jpg"
     fi
     savefile=${output}/${PREFIX}${name}${POSTFIX}.${suffix}  #重新拼出一个存储路径
     temp=${command}" "${CURRENT_IMAGE}" "${savefile}  #指令 需要执行操作的图片路径  图片操作后存储路径
     
     #运行拼凑出来的指令
     eval $temp     
     #echo $temp
done

exit 0

}

#   $@指代命令行上的所有参数
# -o 后面接短参数  没有冒号:开关指令 一个冒号:需要参数  两个冒号:参数可选
## -o cr:d:q:w:   c是可选参数 其他都必须跟一个选项值
# -l 后面接长选项列表
# -n 指定那=哪个脚本处理的这个参数

TEMP=`getopt -o cr:d:q:w: --long quality:arga,directory:,watermark:,prefix:,postfix:,help,resize: -n 'test.sh' -- "$@"`

# -- 保证后面的字符串不直接被解析
#set会重新排列参数顺序 这些值在 getopt中重新排列过了
eval set -- "$TEMP"

#shift用于参数左移 shift n 前n位都会被销毁
while true ; do   
    case "$1" in
    
        -c) C_FLAG="1" ; shift ;;
        
        -r|--resize) R_FLAG="1";
            case "$2" in
                "") shift 2 ;;
                *)RESOLUTION=$2 ; shift 2 ;;
            esac ;;
            
        --help) H_FLAG="1"; shift ;;
        
        -d|--directory)
            case "$2" in 
                "") shift 2 ;;
                 *) DIR=$2 ; shift 2 ;;
            esac ;;
            
        -q|--quality) Q_FLAG="1";
            case "$2" in
                "") shift 2 ;;
                 *) quality=$2; shift 2 ;;  #todo if the arg is integer
            esac ;;
            
        -w|--watermark)W_FLAG="1"; watermark=$2; shift 2 ;;
        
        --prefix) PREFIX=$2; shift 2;;
        
        --postfix) POSTFIX=$2; shift 2 ;;
                
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done


main
#todo  检查参数类型
