# 01-gpu.sh — runtime GPU detection for UWSM session startup
# Sets environment variables based on detected GPU hardware.
# To override, create a file alphabetically after this one in env.d/.
#
# key is a 4-digit string: AMD | Intel | Nouveau | Nvidia
# e.g. "0101" = hybrid Intel+Nvidia, "0001" = Nvidia only, "1000" = AMD only

cmd_exists() { command -v "$1" >/dev/null 2>&1; }

detect_nvidia() {
    if cmd_exists nvidia-smi && nvidia-smi >/dev/null 2>&1; then
        echo 1
    elif lsmod | grep -q 'nvidia'; then
        echo 1
    else
        echo 0
    fi
}

detect_amd() {
    cmd_exists lspci && lspci -nn | grep -E "(VGA|3D)" | grep -iq "1002" && echo 1 || echo 0
}

detect_intel() {
    cmd_exists lspci && lspci -nn | grep -E "(VGA|3D)" | grep -iq "8086" && echo 1 || echo 0
}

detect_nouveau() {
    lsmod | grep -q 'nouveau' && echo 1 || echo 0
}

detect_nvidia_vaapi() {
    [ -f "/usr/lib/dri/nvidia_drv_video.so" ] || [ -f "/usr/lib64/dri/nvidia_drv_video.so" ] && echo 1 || echo 0
}

NVIDIA=$(detect_nvidia)
AMD=$(detect_amd)
INTEL=$(detect_intel)
NOUVEAU=$(detect_nouveau)
NVIDIA_VAAPI=$(detect_nvidia_vaapi)

key="${AMD}${INTEL}${NOUVEAU}${NVIDIA}"

case "$key" in
0001) # Nvidia only
    export LIBVA_DRIVER_NAME=nvidia
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __GL_VRR_ALLOWED=1
    [ "$NVIDIA_VAAPI" = "1" ] && export NVD_BACKEND=direct
    GPU_SETUP="nvidia-only"
    ;;
0101) # Hybrid Intel + Nvidia
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export VK_LAYER_NV_optimus=1
    [ "$NVIDIA_VAAPI" = "1" ] && export NVD_BACKEND=direct
    GPU_SETUP="hybrid-intel-nvidia"
    ;;
1001) # Hybrid AMD + Nvidia
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export VK_LAYER_NV_optimus=1
    [ "$NVIDIA_VAAPI" = "1" ] && export NVD_BACKEND=direct
    GPU_SETUP="hybrid-amd-nvidia"
    ;;
1000) GPU_SETUP="amd-only" ;;
0100) GPU_SETUP="intel-only" ;;
1100) GPU_SETUP="hybrid-amd-intel" ;;
0010) GPU_SETUP="nouveau-only" ;;
0110) GPU_SETUP="hybrid-intel-nouveau" ;;
*)    GPU_SETUP="unknown" ;;
esac

export GPU_SETUP
