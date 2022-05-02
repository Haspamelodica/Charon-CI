FROM ghcr.io/haspamelodica/studentcodeseparator-for-ci:base
RUN cd studentcodeseparator/exercise && mvn install

# Not strictly neccessary because exercise side has internet connection, but speeds up tests.
# Some of these are (as of writing) newest versions of Surefire and JUnit, some are needed by Surefire.
RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:get -Dartifact=org.apache.maven.plugins:maven-surefire-plugin:3.0.0-M6
RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:get -Dartifact=org.junit.jupiter:junit-jupiter-engine:5.8.2
# Needed by Surefire or JUnit, but aren't caught by the calls above. TODO why is that?
RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:get -Dartifact=org.junit.jupiter:junit-jupiter-engine:5.3.2
RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:get -Dartifact=org.junit.jupiter:junit-jupiter-params:5.3.2
RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:get -Dartifact=org.apache.maven.surefire:surefire-junit-platform:3.0.0-M6
RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:get -Dartifact=org.mockito:mockito-core:2.28.2
RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:get -Dartifact=org.powermock:powermock-reflect:2.0.9
RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:get -Dartifact=junit:junit:4.13.2
RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:get -Dartifact=org.hamcrest:hamcrest-library:1.3
RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:get -Dartifact=org.assertj:assertj-core:3.22.0
RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:get -Dartifact=org.junit:junit-bom:5.8.0:pom
RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:get -Dartifact=org.junit.platform:junit-platform-launcher:1.8.2

# This is where the exercise will be mounted to and the run script will be placed
WORKDIR /data
CMD ./run_in_docker.sh
