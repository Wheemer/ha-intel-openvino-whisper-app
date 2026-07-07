FROM ubuntu:22.04

ARG BUILD_VERSION=0.1.0
ARG BUILD_ARCH=amd64
ARG OPENVINO_VERSION=2023.0.0
ARG OPENVINO_PACKAGE_URL=https://storage.openvinotoolkit.org/repositories/openvino/packages/2023.0/linux/l_openvino_toolkit_ubuntu22_2023.0.0.10926.b4452d56304_x86_64.tgz
ARG WHISPER_CPP_REF=v1.7.4

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV OPENVINO_VERSION=${OPENVINO_VERSION}
ENV INTEL_OPENVINO_DIR=/opt/intel/openvino_${OPENVINO_VERSION}
ENV PATH=/opt/wyoming-whisper-api-client/.venv/bin:${INTEL_OPENVINO_DIR}/bin:${PATH}
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so
ENV NEOReadDebugKeys=1
ENV ClDeviceGlobalMemSizeAvailablePercent=90

LABEL \
    io.hass.name="Intel OpenVINO Whisper" \
    io.hass.description="Local Wyoming speech-to-text using whisper.cpp with Intel OpenVINO acceleration" \
    io.hass.version="${BUILD_VERSION}" \
    io.hass.type="app" \
    io.hass.arch="${BUILD_ARCH}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        cmake \
        curl \
        ffmpeg \
        git \
        gnupg2 \
        gpg-agent \
        jq \
        libglib2.0-0 \
        libgl1 \
        libgomp1 \
        libjemalloc-dev \
        netcat-traditional \
        opencl-headers \
        pkg-config \
        python3 \
        python3-pip \
        python3-venv \
        unzip \
        wget \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN wget -qO- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
        | gpg --dearmor > /usr/share/keyrings/oneapi-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" \
        > /etc/apt/sources.list.d/oneAPI.list \
    && wget -qO- https://repositories.intel.com/gpu/intel-graphics.key \
        | gpg --dearmor > /usr/share/keyrings/intel-graphics.gpg \
    && echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu jammy client" \
        > /etc/apt/sources.list.d/intel-gpu-jammy.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        clinfo \
        hwinfo \
        intel-level-zero-gpu \
        intel-media-va-driver-non-free \
        intel-opencl-icd \
        intel-oneapi-runtime-dpcpp-cpp \
        intel-oneapi-runtime-mkl \
        level-zero \
        level-zero-dev \
        libegl1-mesa \
        libgbm1 \
        libgl1-mesa-dri \
        libigdgmm12 \
        libmfx1 \
        libmfxgen1 \
        libvpl2 \
        mesa-va-drivers \
        mesa-vulkan-drivers \
        vainfo \
        va-driver-all \
    && rm -rf /var/lib/apt/lists/*

RUN wget "${OPENVINO_PACKAGE_URL}" -O /tmp/openvino.tgz \
    && tar -xzf /tmp/openvino.tgz -C /tmp \
    && rm /tmp/openvino.tgz \
    && sed -i 's/apt-get install /apt-get install -y /g' /tmp/l_openvino_toolkit_ubuntu22_${OPENVINO_VERSION}.*/install_dependencies/install_openvino_dependencies.sh \
    && /bin/bash /tmp/l_openvino_toolkit_ubuntu22_${OPENVINO_VERSION}.*/install_dependencies/install_openvino_dependencies.sh \
    && mkdir -p /opt/intel \
    && mv /tmp/l_openvino_toolkit_ubuntu22_${OPENVINO_VERSION}.* "${INTEL_OPENVINO_DIR}" \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch "${WHISPER_CPP_REF}" https://github.com/ggerganov/whisper.cpp.git /opt/whisper.cpp \
    && source "${INTEL_OPENVINO_DIR}/setupvars.sh" \
    && cmake -S /opt/whisper.cpp -B /opt/whisper.cpp/build -DWHISPER_OPENVINO=1 -DCMAKE_BUILD_TYPE=Release \
    && cmake --build /opt/whisper.cpp/build --config Release -j"$(nproc)"

RUN git clone --depth 1 https://github.com/ser/wyoming-whisper-api-client.git /opt/wyoming-whisper-api-client \
    && cd /opt/wyoming-whisper-api-client \
    && python3 -m venv .venv \
    && .venv/bin/pip install --no-cache-dir --upgrade pip setuptools wheel \
    && .venv/bin/pip install --no-cache-dir -r requirements.txt \
    && .venv/bin/pip install --no-cache-dir -e .

COPY run.sh /run.sh
RUN chmod +x /run.sh \
    && mkdir -p /data/models /config

EXPOSE 10300
WORKDIR /opt/whisper.cpp
CMD ["/run.sh"]
