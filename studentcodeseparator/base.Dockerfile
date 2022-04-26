FROM ls1tum/artemis-maven-template:java17-3

RUN useradd -m dockeruser
USER dockeruser
WORKDIR /home/dockeruser

COPY --chown=dockeruser . studentcodeseparator
RUN cd studentcodeseparator/streammultiplexer && mvn install
RUN cd studentcodeseparator/common && mvn install
