ARG TARGETPLATFORM=linux/amd64
ARG IMAGE_NAME=ghcr.io/toppers/hakoniwa-ecu-multiplay
ARG IMAGE_TAG=latest
FROM --platform=$TARGETPLATFORM ${IMAGE_NAME}:${IMAGE_TAG} AS hakoniwa-ecu-multiplay-demo

# Inherits HAKO_HOME, TOPPERS_HOME, USERNAME (hako), and PATH from base image.

ARG USERNAME=hako
ENV HAKO_HOME=/home/$USERNAME

# WORKDIR $HAKO_HOME/workspace

# # Build a-comstack CAN sample
# WORKDIR $HAKO_HOME/workspace/a-comstack/can/target/hsbrh850f1k_gcc/sample/
# RUN cp $TOPPERS_HOME/athrill-target-rh850f1x/params/rh850f1k/atk2-sc1/* .  && \
# 	make can  && \
# 	make
# COPY config/proxy_config.json $HAKO_HOME/workspace/a-comstack/can/target/hsbrh850f1k_gcc/sample/
# COPY config/proxy_config_rte_ecu1.json $HAKO_HOME/workspace/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu1/
# COPY config/proxy_config_rte_ecu2.json $HAKO_HOME/workspace/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu2/

# # Build ECU1 sample (HelloAutosarWithCom)
# WORKDIR $HAKO_HOME/workspace/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu1
# RUN bash configure.sh && \
# 	make && \
# 	cp $TOPPERS_HOME/athrill-target-rh850f1x/params/rh850f1k/atk2-sc1/* . && \
# 	sed -i -e "s/root/home\/toppers/g" memory_with_hako.txt

# # Build ECU2 sample (HelloAutosarWithCom)
# WORKDIR $HAKO_HOME/workspace/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu2
# RUN bash configure.sh && \
# 	make && \
# 	cp $TOPPERS_HOME/athrill-target-rh850f1x/params/rh850f1k/atk2-sc1/* . && \
# 	sed -i -e "s/root/home\/toppers/g" memory_with_hako.txt

# WORKDIR $HAKO_HOME/workspace/

# ENV HAKO_WS_ECU1="$HAKO_HOME/workspace/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu1"
# ENV HAKO_WS_ECU2="$HAKO_HOME/workspace/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu2"
# ENV HAKO_WS_CAN="$HAKO_HOME/workspace/a-comstack/can/target/hsbrh850f1k_gcc/sample"

# # Add version label
# ARG IMAGE_TAG
# LABEL hakoniwa.version="${IMAGE_TAG}"
# LABEL maintainer="toppers"
# LABEL description="Hakoniwa ECU Multiplay Demo (atk2-sc1, a-comstack, a-rtegen samples on top of core)"

USER $USERNAME