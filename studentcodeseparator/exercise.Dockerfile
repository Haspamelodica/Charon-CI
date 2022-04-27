FROM studentcodeseparator:base
RUN cd studentcodeseparator/exercise && mvn install

# Not strictly neccessary because exercise side has internet connection, but speeds up tests.
RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:get -Dartifact=org.apache.maven.plugins:maven-surefire-plugin:3.0.0-M6
RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:get -Dartifact=org.junit.jupiter:junit-jupiter-engine:5.8.2

# This is where the exercise will be mounted to and the run script will be placed
WORKDIR /data
CMD ./run_in_docker.sh
