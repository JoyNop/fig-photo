#!/usr/bin/env bash
# ==============================================
# FIG - Photo RAW/JPG Sort CLI
# Author : HE-AN
# Website: WWW.HEAN.LIFE
# GitHub : https://github.com/JoyNop/fig-photo
# ==============================================

clear
echo "=============================================="
echo "        FIG - Photo CLI"
echo "----------------------------------------------"
echo "  Author : HE-AN"
echo "  Website: WWW.HEAN.LIFE"
echo "  GitHub : https://github.com/JoyNop/fig-photo"
echo "=============================================="
echo

# -----------------------------
# 默认参数
# -----------------------------
TARGET_DIR=$(pwd)
MAKER="auto"
ACTION="move"
DRY_RUN=false
RESTORE=false

# -----------------------------
# 参数解析
# -----------------------------
while [ $# -gt 0 ]; do
    case "$1" in
        -d|--dir) TARGET_DIR="$2"; shift 2 ;;
        -m|--maker) MAKER="$2"; shift 2 ;;
        -a|--action) ACTION="$2"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        --restore) RESTORE=true; shift ;;
        -h|--help)
            echo "Usage: fig [options]"
            echo "Options:"
            echo "  -d, --dir PATH        指定目录"
            echo "  -m, --maker NAME      sony|canon|nikon|fuji|panasonic|leica|pentax|auto"
            echo "  -a, --action TYPE     move|copy"
            echo "  --dry-run             预览模式"
            echo "  --restore             恢复已处理文件"
            exit 0
            ;;
        *) echo "未知参数: $1"; exit 1 ;;
    esac
done

# -----------------------------
# 交互模式选择目录
# -----------------------------
if [ "$TARGET_DIR" = "$(pwd)" ]; then
    echo "当前目录为: $(pwd)"
    printf "是否使用当前目录？(y/n): "
    read ans
    if [ "$ans" != "y" ] && [ "$ans" != "Y" ]; then
        printf "请拖入要处理的文件夹到终端，并按回车: "
        read dir_input
        TARGET_DIR=$(echo "$dir_input" | sed 's/^"\(.*\)"$/\1/')
        [ ! -d "$TARGET_DIR" ] && echo "目录不存在，退出" && exit 1
    fi
fi

LOG_FILE="$TARGET_DIR/fig-photo.csv"
RAW_DIR="$TARGET_DIR/RAW"
JPG_DIR="$TARGET_DIR/JPG"

# -----------------------------
# 恢复模式交互
# -----------------------------
printf "是否进入恢复模式？(y/n, 默认n): "
read restore_ans
[ "$restore_ans" = "y" ] && RESTORE=true

if [ "$RESTORE" = true ]; then
    [ ! -f "$LOG_FILE" ] && echo "日志文件不存在，无法恢复" && exit 1
    echo "恢复模式: 将文件恢复到原始位置"
    while IFS=',' read -r filename original new type manu; do
        [ "$filename" = "filename" ] && continue
        [ -f "$new" ] || continue
        [ "$DRY_RUN" = true ] && echo "DRY-RUN: mv $new -> $original" || mv "$new" "$original"
        [ "$DRY_RUN" != true ] && echo "恢复: $filename"
    done < "$LOG_FILE"
    echo "恢复完成"
    exit 0
fi

# -----------------------------
# 已处理检测
# -----------------------------
if [ -f "$LOG_FILE" ]; then
    printf "该目录已处理过，是否继续？(y/n): "
    read ans
    if [ "$ans" != "y" ] && [ "$ans" != "Y" ]; then
        echo "退出"
        exit 0
    fi
fi

# -----------------------------
# RAW 扩展列表
# -----------------------------
RAW_EXT_LIST="ARW CR2 CR3 NEF RAF RW2 DNG PEF"

# -----------------------------
# 选择识别模式
# -----------------------------
if [ "$MAKER" = "auto" ]; then
    echo "选择识别模式:"
    echo "1) 自动识别厂商 (EXIF)"
    echo "2) 手动选择厂商"
    printf "请输入 (1-2, 默认1): "
    read choice
    choice=${choice:-1}
    if [ "$choice" = "2" ]; then
        echo "请选择厂商:"
        echo "1) Sony"
        echo "2) Canon"
        echo "3) Nikon"
        echo "4) Fujifilm"
        echo "5) Panasonic"
        echo "6) Leica"
        echo "7) Pentax"
        echo "8) 全部"
        printf "请输入 (1-8, 默认8): "
        read manu
        manu=${manu:-8}
        case "$manu" in
            1) MAKER="sony" ;;
            2) MAKER="canon" ;;
            3) MAKER="nikon" ;;
            4) MAKER="fuji" ;;
            5) MAKER="panasonic" ;;
            6) MAKER="leica" ;;
            7) MAKER="pentax" ;;
            8) MAKER="auto" ;;
            *) echo "无效选择"; exit 1 ;;
        esac
    fi
fi

# -----------------------------
# 操作方式选择
# -----------------------------
echo "选择操作方式:"
echo "1) 移动 (默认)"
echo "2) 复制"
printf "请输入 (1-2): "
read act
[ "$act" = "2" ] && ACTION="cp" || ACTION="mv"

# -----------------------------
# dry-run 预览模式
# -----------------------------
printf "是否启用预览模式 dry-run？(y/n, 默认n): "
read dry
[ "$dry" = "y" ] && DRY_RUN=true

# -----------------------------
# 初始化目录
# -----------------------------
mkdir -p "$RAW_DIR"
mkdir -p "$JPG_DIR"
echo "filename,original_path,new_path,type,manufacturer" > "$LOG_FILE"

# -----------------------------
# EXIF 检测函数
# -----------------------------
detect_exif() {
    if command -v exiftool >/dev/null 2>&1; then
        MAKE=$(exiftool -Make -s3 "$1" 2>/dev/null | tr '[:lower:]' '[:upper:]')
        case "$MAKE" in
            *SONY*) echo "sony" ;;
            *CANON*) echo "canon" ;;
            *NIKON*) echo "nikon" ;;
            *FUJIFILM*) echo "fuji" ;;
            *PANASONIC*) echo "panasonic" ;;
            *LEICA*) echo "leica" ;;
            *PENTAX*) echo "pentax" ;;
            *) echo "" ;;
        esac
    fi
}

# -----------------------------
# 进度条函数
# -----------------------------
draw_progress() {
    local progress=$1 total=$2
    local percent=$((progress*100/total))
    local filled=$((percent*30/100))
    local empty=$((30-filled))
    local bar=$(printf "%0.s#" $(seq 1 $filled))
    local spaces=$(printf "%0.s-" $(seq 1 $empty))
    printf "\rProcessing: [%s%s] %d%% (%d/%d)" "$bar" "$spaces" "$percent" "$progress" "$total"
}

# -----------------------------
# 文件收集（兼容 Bash 3）
# -----------------------------
FILES=()
while IFS= read -r -d '' f; do
    FILES+=("$f")
done < <(find "$TARGET_DIR" -type f -not -path "$RAW_DIR/*" -not -path "$JPG_DIR/*" -print0)
TOTAL=${#FILES[@]}
COUNT=0

# -----------------------------
# RAW 厂商计数初始化
# -----------------------------
RAW_COUNTS="sony:0 canon:0 nikon:0 fuji:0 panasonic:0 leica:0 pentax:0 unknown:0"
increment_raw_count() {
    local manu=$1
    RAW_COUNTS=$(echo "$RAW_COUNTS" | awk -F' ' -v m="$manu" '{
        for(i=1;i<=NF;i++){
            split($i,a,":")
            if(a[1]==m){a[2]=a[2]+1}
            printf "%s:%s ",a[1],a[2]
        }
    }')
}

JPG_COUNT=0

# -----------------------------
# 主循环
# -----------------------------
for file in "${FILES[@]}"; do
    COUNT=$((COUNT+1))
    draw_progress $COUNT $TOTAL

    filename=$(basename "$file")
    ext="${filename##*.}"
    ext_upper=$(echo "$ext" | tr '[:lower:]' '[:upper:]')

    MANU=""
    RAW_EXTS="$RAW_EXT_LIST"

    # 自动识别
    if [ "$MAKER" = "auto" ]; then
        MANU=$(detect_exif "$file")
    else
        MANU="$MAKER"
    fi

    # RAW 匹配
    matched=0
    case "$MANU" in
        sony) RAW_EXTS="ARW" ;;
        canon) RAW_EXTS="CR2 CR3" ;;
        nikon) RAW_EXTS="NEF" ;;
        fuji) RAW_EXTS="RAF" ;;
        panasonic) RAW_EXTS="RW2" ;;
        leica) RAW_EXTS="DNG" ;;
        pentax) RAW_EXTS="PEF" ;;
        "") RAW_EXTS="$RAW_EXT_LIST" ;;
    esac

    for r in $RAW_EXTS; do
        [ "$ext_upper" = "$r" ] && matched=1
    done

    if [ $matched -eq 1 ]; then
        [ -z "$MANU" ] && MANU="unknown"
        DEST_DIR="$RAW_DIR/$MANU"
        mkdir -p "$DEST_DIR"
        [ "$DRY_RUN" = true ] && echo "DRY-RUN: $ACTION $file -> $DEST_DIR/$filename" || $ACTION "$file" "$DEST_DIR/"
        echo "$filename,$file,$DEST_DIR/$filename,RAW,$MANU" >> "$LOG_FILE"
        increment_raw_count "$MANU"
        continue
    fi

    # JPG 分类
    if [[ "$ext_upper" = "JPG" ]] || [[ "$ext_upper" = "JPEG" ]]; then
        [ "$DRY_RUN" = true ] && echo "DRY-RUN: $ACTION $file -> $JPG_DIR/$filename" || $ACTION "$file" "$JPG_DIR/"
        echo "$filename,$file,$JPG_DIR/$filename,JPG," >> "$LOG_FILE"
        JPG_COUNT=$((JPG_COUNT+1))
    fi
done

# -----------------------------
# 完成输出
# -----------------------------
printf "\n\n分类完成!\n"
echo "RAW 统计:"
for item in $RAW_COUNTS; do
    manu=${item%%:*}
    cnt=${item##*:}
    [ "$cnt" -gt 0 ] && echo "  $manu: $cnt"
done
echo "JPG 总计: $JPG_COUNT"
echo "日志文件: $LOG_FILE"
echo