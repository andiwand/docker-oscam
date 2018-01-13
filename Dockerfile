FROM ubuntu:16.04

ARG SVN="http://www.streamboard.tv/svn/oscam/trunk"
ARG REVISION="HEAD"
ARG SOURCE_PATH="/usr/src/oscam-svn"
ARG CONFIG_PATH="/config"
ARG BINARY_PATH="/usr/bin/oscam"
ARG CONFIG_ENABLE="all"
ARG CONFIG_DISABLE="CARDREADER_DB2COM CARDREADER_INTERNAL CARDREADER_STINGER CARDREADER_STAPI CARDREADER_STAPI5 IPV6SUPPORT LCDSUPPORT LEDSUPPORT READ_SDT_CHARSETS"

RUN apt-get update
RUN apt-get install -y \
        build-essential \
        subversion
RUN apt-get install -y \
        libssl-dev

RUN CPU_CORES="$( grep -c processor /proc/cpuinfo )" || CPU_CORES="1"

RUN svn checkout "${SVN}" "${SOURCE_PATH}"
RUN cd "${SOURCE_PATH}" \
    && svn update \
    && svn update -r "${REVISION}" \
    && ./config.sh \
        --enable ${CONFIG_ENABLE} \
        --disable ${CONFIG_DISABLE} \
    && make -j "${CPU_CORES}" \
        CONF_DIR="${CONFIG_PATH}"   \
        OSCAM_BIN=${BINARY_PATH}
RUN rm -rf "${SOURCE_PATH}"

RUN apt-get remove -y \
        build-essential \
        subversion      \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf "/var/lib/apt/lists/*"

VOLUME "${CONFIG_PATH}"

CMD "${BINARY_PATH}" -c "${CONFIG_PATH}"

