FROM maven:3-openjdk-17

RUN useradd -m dockeruser
USER dockeruser
WORKDIR /home/dockeruser

# Set MAVEN_CONFIG. Otherwise, some entrypoint script prints some error.
# We also have to manually create that directory.
RUN mkdir -p .m2
# ENV MAVEN_CONFIG=~/.m2

COPY --chown=dockeruser net.haspamelodica.studentcodeseparator studentcodeseparator
RUN cd studentcodeseparator/streammultiplexer && mvn install
RUN cd studentcodeseparator/common && mvn install
