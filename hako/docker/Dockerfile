ARG TARGETPLATFORM=linux/amd64
ARG HAKONIWA_VERSION=latest
FROM --platform=$TARGETPLATFORM ros:foxy-ros-base-focal AS hakoniwa-ecu-multiplay

ARG DEBIAN_FRONTEND=noninteractive

ENV CMAKE_INSTALL_DIR=/usr/local/cmake
ENV PATH="$PATH:$CMAKE_INSTALL_DIR/bin"

ARG USERNAME=hako
ARG GROUPNAME=toppers
ARG UID=1000
ARG GID=1000
ENV HAKO_HOME=/home/$USERNAME
ENV TOPPERS_HOME=/home/toppers

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
	git	\
	build-essential	\
	libc6-dev \
	libstdc++-9-dev \
	wget	\
	ruby	\
	vim	\
	libssl-dev libreadline-dev zlib1g-dev \
	libspdlog-dev python3-dev \
	autoconf \
	automake \
	pkg-config \
	curl \
	net-tools \
	netcat-openbsd \
	openjdk-8-jre \
	sudo \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Setup Cmake
WORKDIR $TOPPERS_HOME
RUN	wget -q -O cmake-linux.sh https://github.com/Kitware/CMake/releases/download/v3.31.2/cmake-3.31.2-linux-x86_64.sh && \
	mkdir -p $CMAKE_INSTALL_DIR && \
	sh cmake-linux.sh --skip-license --prefix=$CMAKE_INSTALL_DIR && \
	rm cmake-linux.sh

# Setup athrill-gcc
RUN wget https://github.com/toppers/athrill-gcc-v850e2m/releases/download/v1.1/athrill-gcc-package.tar.gz && \
	tar xzf athrill-gcc-package.tar.gz && \
	tar xzf athrill-gcc-package/athrill-gcc.tar.gz && \
	mv usr/local/athrill-gcc /usr/local/ && \
	rm -rf usr athrill-gcc-package athrill-gcc-package.tar.gz

# Setup Athrill2
#  Build Athrill2
RUN git clone -b master --recursive https://github.com/toppers/athrill-target-rh850f1x.git && \
	cd  athrill-target-rh850f1x && \
	bash build.bash all || (echo "Athrill2 build failed" && exit 1)

#  Build athrill-device
RUN git clone https://github.com/toppers/athrill-device.git && \
	mv athrill-device athrill-target-rh850f1x/ && \
	cd athrill-target-rh850f1x/athrill-device/device/hakotime && \
	ln -s ../../../hakoniwa-core-cpp-client && \
	bash build.bash || (echo "athrill-device build failed" && exit 1)

#  Build hakoniwa-ros2pdu
# WORKDIR $TOPPERS_HOME/athrill-target-rh850f1x/hakoniwa-ros2pdu/workspace
# RUN bash build.bash || (echo "hakoniwa-ros2pdu build failed" && exit 1)

# Setup hako user
#  Comment out to connect as root instead. To add a non-root user, see: https://aka.ms/vscode-remote/containers/non-root.
RUN groupadd --gid $GID $GROUPNAME && \
    useradd -m -s /bin/bash --uid $UID --gid $GID $USERNAME && \
	# [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME
RUN mkdir -p /home/$USERNAME/workspace
ENV RUBYOPT=-EUTF-8

# Setup cfg 
WORKDIR $HAKO_HOME
RUN wget https://github.com/mitsut/cfg/releases/download/1.9.7/cfg-1.9.7-x86_64-unknown-linux-gnu.tar.gz && \
	wget --no-check-certificate https://www.autosar.org/fileadmin/standards/R4.0.3/CP/AUTOSAR_MMOD_XMLSchema.zip && \
	mkdir schema && \
	tar xzf cfg-1.9.7-x86_64-unknown-linux-gnu.tar.gz && \
	mv cfg schema/ && \
	unzip AUTOSAR_MMOD_XMLSchema.zip -d schema

WORKDIR $HAKO_HOME/workspace

ENV PATH="/usr/local/athrill-gcc/bin:$TOPPERS_HOME/athrill-target-rh850f1x/athrill/bin/linux:$TOPPERS_HOME/athrill-target-rh850f1x/hakoniwa-core-cpp-client/cmake-build/core/sample/base-procs/hako-master:$TOPPERS_HOME/athrill-target-rh850f1x/hakoniwa-core-cpp-client/cmake-build/core/sample/base-procs/hako-cmd:$TOPPERS_HOME/athrill-target-rh850f1x/hakoniwa-core-cpp-client/cmake-build/src/proxy:${PATH}"

RUN git clone --depth=1 https://github.com/toppers/atk2-sc1.git && \
	git clone -b target/v1.4.0 --depth=1 https://github.com/toppers/a-comstack && \
	git clone --depth=1 https://github.com/toppers/a-rtegen.git && \
	mkdir -p atk2-sc1/cfg/cfg && \
	cp $HAKO_HOME/schema/* atk2-sc1/cfg/cfg/ && \
	cp $HAKO_HOME/schema/*.xsd a-rtegen/bin/schema/ && \
	a-rtegen/bin/bin/switch-uncrustify.sh linux

WORKDIR $HAKO_HOME/workspace/a-comstack/can/target/hsbrh850f1k_gcc/sample/
RUN cp $TOPPERS_HOME/athrill-target-rh850f1x/params/rh850f1k/atk2-sc1/* .  && \
	make can  && \
	make
COPY config/proxy_config.json $HAKO_HOME/workspace/a-comstack/can/target/hsbrh850f1k_gcc/sample/
COPY config/proxy_config_rte_ecu1.json $HAKO_HOME/workspace/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu1/
COPY config/proxy_config_rte_ecu2.json $HAKO_HOME/workspace/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu2/

WORKDIR $HAKO_HOME/workspace/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu1
RUN bash configure.sh && \
	make && \
	cp $TOPPERS_HOME/athrill-target-rh850f1x/params/rh850f1k/atk2-sc1/* . && \
	sed -i -e "s/root/home\/toppers/g" memory_with_hako.txt

WORKDIR $HAKO_HOME/workspace/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu2
RUN bash configure.sh && \
	make && \
	cp $TOPPERS_HOME/athrill-target-rh850f1x/params/rh850f1k/atk2-sc1/* . && \
	sed -i -e "s/root/home\/toppers/g" memory_with_hako.txt

WORKDIR $HAKO_HOME/workspace/

ENV HAKO_WS_ROS="$TOPPERS_HOME/athrill-target-rh850f1x/hakoniwa-ros2pdu/workspace"
ENV HAKO_WS_ECU1="$HAKO_HOME/workspace/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu1"
ENV HAKO_WS_ECU2="$HAKO_HOME/workspace/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu2"
ENV HAKO_WS_CAN="$HAKO_HOME/workspace/a-comstack/can/target/hsbrh850f1k_gcc/sample"

# Add version label
ARG HAKONIWA_VERSION
LABEL hakoniwa.version="${HAKONIWA_VERSION}"
LABEL maintainer="toppers"
LABEL description="Hakoniwa ECU Multiplay Development Environment"
