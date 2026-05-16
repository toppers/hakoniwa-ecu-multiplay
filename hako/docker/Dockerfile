ARG TARGETPLATFORM=linux/amd64
ARG IMAGE_NAME=ghcr.io/toppers/hakoniwa-ecu-multiplay
ARG IMAGE_TAG=latest
FROM --platform=$TARGETPLATFORM ${IMAGE_NAME}:${IMAGE_TAG} AS hakoniwa-ecu-multiplay-demo

# Inherits HAKO_HOME, TOPPERS_HOME, USERNAME (hako), and PATH from base image.

ARG USERNAME=hako
ENV HAKO_HOME=/home/$USERNAME
ENV WS_DIR=/workspaces/hakoniwa-ecu-multiplay

USER root
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
	ros-foxy-ros2cli \
	ros-foxy-ros2topic \
	ros-foxy-std-msgs \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

USER $USERNAME

ENV HAKO_WS_ROS="$HAKO_HOME/athrill-target-rh850f1x/hakoniwa-ros2pdu/workspace"
ENV HAKO_WS_ECU1="$WS_DIR/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu1"
ENV HAKO_WS_ECU2="$WS_DIR/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu2"
ENV HAKO_WS_CAN="$WS_DIR/a-comstack/can/target/hsbrh850f1k_gcc/sample"

USER $USERNAME