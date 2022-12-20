FROM openjdk:8-jdk-alpine
RUN mvn clean install
COPY target/validator-0.0.1.jar backend-validator-0.0.1.jar
ENTRYPOINT ["java","-jar","/backend-validator-0.0.1.jar"]