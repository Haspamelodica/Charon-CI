FROM studentcodeseparator:base

RUN cd studentcodeseparator/student && mvn install
RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:get -Dartifact=org.codehaus.mojo:exec-maven-plugin:3.0.0
