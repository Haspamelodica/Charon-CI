FROM maven:3-openjdk-17

RUN useradd -m dockeruser
USER dockeruser
WORKDIR /home/dockeruser

COPY --chown=dockeruser net.haspamelodica.studentcodeseparator studentcodeseparator
RUN cd studentcodeseparator/streammultiplexer && mvn install
RUN cd studentcodeseparator/common && mvn install
