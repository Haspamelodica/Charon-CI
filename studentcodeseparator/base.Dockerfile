FROM maven:3-openjdk-17

RUN useradd -m dockeruser
USER dockeruser
WORKDIR /home/dockeruser
# Otherwise, some entrypoint script prints some error
ENV MAVEN_CONFIG=~/.m2

COPY --chown=dockeruser net.haspamelodica.studentcodeseparator studentcodeseparator
RUN cd studentcodeseparator/streammultiplexer && mvn install
RUN cd studentcodeseparator/common && mvn install
