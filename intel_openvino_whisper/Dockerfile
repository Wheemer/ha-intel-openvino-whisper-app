FROM ubuntu:26.04

ARG BUILD_VERSION=0.1.0
ARG BUILD_ARCH=amd64
ARG OPENVINO_VERSION=2026.3.0
ARG OPENVINO_PACKAGE_DIR=openvino_toolkit_ubuntu26_2026.3.0.22451.bd8d6542e3c_x86_64
ARG OPENVINO_PACKAGE_URL=https://storage.openvinotoolkit.org/repositories/openvino/packages/2026.3/linux/openvino_toolkit_ubuntu26_2026.3.0.22451.bd8d6542e3c_x86_64.tgz
ARG INTEL_COMPUTE_RUNTIME_VERSION=24.35.30872.36
ARG INTEL_LEVEL_ZERO_VERSION=1.5.30872.36
ARG INTEL_IGC_VERSION=1.0.17537.24
ARG INTEL_GMMLIB_VERSION=22.5.0
ARG WHISPER_CPP_REF=v1.9.3
ARG WYOMING_CLIENT_REF=6fe7f273d76283403ce44ed6b4d1ad65633d1f04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV OPENVINO_VERSION=${OPENVINO_VERSION}
ENV INTEL_OPENVINO_DIR=/opt/intel/openvino_${OPENVINO_VERSION}
ENV PATH=/opt/wyoming-whisper-api-client/.venv/bin:${INTEL_OPENVINO_DIR}/bin:${PATH}
ENV NEOReadDebugKeys=1
ENV ClDeviceGlobalMemSizeAvailablePercent=90

LABEL \
    io.hass.name="Whisper for Intel OpenVINO" \
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
        g++ \
        gcc \
        jq \
        libglib2.0-0 \
        libgl1 \
        libgomp1 \
        netcat-traditional \
        ninja-build \
        ocl-icd-libopencl1 \
        opencl-headers \
        pkg-config \
        python3 \
        python3-pip \
        python3-venv \
        unzip \
        wget \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/intel-legacy \
    && cd /tmp/intel-legacy \
    && curl -fLO --retry 5 --retry-delay 2 --connect-timeout 20 --max-time 300 "https://github.com/intel/intel-graphics-compiler/releases/download/igc-${INTEL_IGC_VERSION}/intel-igc-core_${INTEL_IGC_VERSION}_amd64.deb" \
    && curl -fLO --retry 5 --retry-delay 2 --connect-timeout 20 --max-time 300 "https://github.com/intel/intel-graphics-compiler/releases/download/igc-${INTEL_IGC_VERSION}/intel-igc-opencl_${INTEL_IGC_VERSION}_amd64.deb" \
    && curl -fLO --retry 5 --retry-delay 2 --connect-timeout 20 --max-time 300 "https://github.com/intel/compute-runtime/releases/download/${INTEL_COMPUTE_RUNTIME_VERSION}/intel-level-zero-gpu-legacy1_${INTEL_LEVEL_ZERO_VERSION}_amd64.deb" \
    && curl -fLO --retry 5 --retry-delay 2 --connect-timeout 20 --max-time 300 "https://github.com/intel/compute-runtime/releases/download/${INTEL_COMPUTE_RUNTIME_VERSION}/intel-opencl-icd-legacy1_${INTEL_COMPUTE_RUNTIME_VERSION}_amd64.deb" \
    && curl -fLO --retry 5 --retry-delay 2 --connect-timeout 20 --max-time 300 "https://github.com/intel/compute-runtime/releases/download/${INTEL_COMPUTE_RUNTIME_VERSION}/libigdgmm12_${INTEL_GMMLIB_VERSION}_amd64.deb" \
    && printf '%s  %s\n' \
        '40dfbd15ab62de036a00824b304a2aa1fa2d81ad60ef83da09cfe3c5a80c429f' "intel-level-zero-gpu-legacy1_${INTEL_LEVEL_ZERO_VERSION}_amd64.deb" \
        'bbe71e4f414259e06a10cde72c29a2bd78d41b2bb2f6f8463b1806797fe66e85' "intel-opencl-icd-legacy1_${INTEL_COMPUTE_RUNTIME_VERSION}_amd64.deb" \
        'cc29d14df83cff1b3c6a66baa39257f0211b168ab43a99c2dc62a3734431bc23' "libigdgmm12_${INTEL_GMMLIB_VERSION}_amd64.deb" \
        | sha256sum -c - \
    && apt-get update \
    && apt-get install -y --no-install-recommends ./*.deb \
    && apt-get install -y --no-install-recommends \
        clinfo \
        hwinfo \
    && rm -rf /tmp/intel-legacy /var/lib/apt/lists/*

RUN wget "${OPENVINO_PACKAGE_URL}" -O /tmp/openvino.tgz \
    && tar -xzf /tmp/openvino.tgz -C /tmp \
    && rm /tmp/openvino.tgz \
    && mkdir -p /opt/intel \
    && mv "/tmp/${OPENVINO_PACKAGE_DIR}" "${INTEL_OPENVINO_DIR}" \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch "${WHISPER_CPP_REF}" https://github.com/ggml-org/whisper.cpp.git /opt/whisper.cpp \
    && source "${INTEL_OPENVINO_DIR}/setupvars.sh" \
    && cmake -S /opt/whisper.cpp -B /opt/whisper.cpp/build -G Ninja \
        -DWHISPER_OPENVINO=1 \
        -DGGML_NATIVE=OFF \
        -DGGML_AVX=ON \
        -DGGML_AVX2=ON \
        -DGGML_FMA=ON \
        -DGGML_F16C=ON \
        -DCMAKE_BUILD_TYPE=Release \
    && cmake --build /opt/whisper.cpp/build --config Release -j"$(nproc)"

RUN git clone https://github.com/ser/wyoming-whisper-api-client.git /opt/wyoming-whisper-api-client \
    && cd /opt/wyoming-whisper-api-client \
    && git checkout "${WYOMING_CLIENT_REF}" \
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
