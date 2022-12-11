FROM ros:foxy as hakoniwa-ecu-multiplay

ARG DEBIAN_FRONTEND=noninteractive

ENV CMAKE_INSTALL_DIR /usr/local/cmake
ENV PATH $PATH:$CMAKE_INSTALL_DIR/bin

RUN apt-get update && apt-get install -y \
	git	\
	build-essential	\
	wget	\
	gcc	\
	g++	\
	ruby	\
	vim	\
	gem \
	libssl-dev libreadline-dev zlib1g-dev \
	make	\
	autoconf \
	automake \
	pkg-config \
	curl \
	net-tools \
	netcat \
	openjdk-8-jre \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

RUN	wget -q -O cmake-linux.sh https://github.com/Kitware/CMake/releases/download/v3.17.0/cmake-3.17.0-Linux-x86_64.sh && \
	mkdir -p $CMAKE_INSTALL_DIR && \
	sh cmake-linux.sh --skip-license --prefix=$CMAKE_INSTALL_DIR && \
	rm cmake-linux.sh

WORKDIR /root
RUN wget https://github.com/toppers/athrill-gcc-v850e2m/releases/download/v1.1/athrill-gcc-package.tar.gz 
RUN tar xzvf athrill-gcc-package.tar.gz && \
	rm -f athrill-gcc-package.tar.gz
WORKDIR /root/athrill-gcc-package
RUN	tar xzvf athrill-gcc.tar.gz && \
	rm -f athrill-gcc-package.tar.gz && \
	rm -f *.tar.gz
ENV PATH /root/athrill-gcc-package/usr/local/athrill-gcc/bin/:${PATH}
ENV PATH /root/athrill-target-rh850f1x/athrill/bin/linux:${PATH}
ENV PATH /root/athrill-target-rh850f1x/hakoniwa-core-cpp-client/cmake-build/core/sample/base-procs/hako-master/:${PATH}
ENV PATH /root/athrill-target-rh850f1x/hakoniwa-core-cpp-client/cmake-build/core/sample/base-procs/hako-cmd/:${PATH}
ENV PATH /root/athrill-target-rh850f1x/hakoniwa-core-cpp-client/cmake-build/src/proxy:${PATH}

WORKDIR /root
RUN git clone https://github.com/toppers/athrill-device.git
RUN git clone --recursive https://github.com/toppers/athrill-target-rh850f1x.git
WORKDIR	/root/athrill-target-rh850f1x
RUN bash build.bash all

WORKDIR /root
RUN mv athrill-device athrill-target-rh850f1x/
WORKDIR	/root/athrill-target-rh850f1x/athrill-device/device/hakotime
RUN ln -s ../../../hakoniwa-core-cpp-client
RUN bash build.bash

WORKDIR /root
RUN wget https://github.com/mitsut/cfg/releases/download/1.9.7/cfg-1.9.7-x86_64-unknown-linux-gnu.tar.gz && \
	wget --no-check-certificate https://www.autosar.org/fileadmin/standards/classic/4-0/AUTOSAR_MMOD_XMLSchema.zip && \
	mkdir schema && \
	tar xvzf cfg-1.9.7-x86_64-unknown-linux-gnu.tar.gz && \
	mv cfg schema/ && \
	unzip AUTOSAR_MMOD_XMLSchema.zip -d schema

RUN mkdir -p /root/workspace
WORKDIR /root/workspace
ENV RUBYOPT -EUTF-8

RUN git clone --depth=1 https://github.com/toppers/atk2-sc1.git && \
	git clone -b target/v1.4.0 --depth=1 https://github.com/toppers/a-comstack && \
	git clone https://github.com/toppers/a-rtegen.git && \
	mkdir -p atk2-sc1/cfg/cfg && \
	cp /root/schema/* atk2-sc1/cfg/cfg/ && \
	cp /root/schema/*.xsd a-rtegen/bin/schema/

WORKDIR /root/workspace/a-comstack/can/target/hsbrh850f1k_gcc/sample/
RUN cp /root/athrill-target-rh850f1x/params/rh850f1k/atk2-sc1/* .
RUN make can
RUN make
COPY config/proxy_config.json /root/workspace/a-comstack/can/target/hsbrh850f1k_gcc/sample/
COPY config/proxy_config_rte_ecu1.json /root/workspace/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu1/
COPY config/proxy_config_rte_ecu2.json /root/workspace/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu2/

WORKDIR /root/workspace/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu1
RUN bash configure.sh
RUN make
RUN cp /root/athrill-target-rh850f1x/params/rh850f1k/atk2-sc1/* .

WORKDIR /root/workspace/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu2
RUN bash configure.sh
RUN make
RUN cp /root/athrill-target-rh850f1x/params/rh850f1k/atk2-sc1/* .

WORKDIR /root/athrill-target-rh850f1x/hakoniwa-ros2pdu/workspace
RUN bash build.bash
ENV HAKO_WS_ROS		/root/athrill-target-rh850f1x/hakoniwa-ros2pdu/workspace
ENV HAKO_WS_ECU1	/root/workspace/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu1
ENV HAKO_WS_ECU2	/root/workspace/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu2
ENV HAKO_WS_CAN		/root/workspace/a-comstack/can/target/hsbrh850f1k_gcc/sample
