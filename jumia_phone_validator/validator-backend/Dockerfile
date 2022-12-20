# FROM openjdk:8-jdk-alpine
# COPY target/validator-0.0.1.jar backend-validator-0.0.1.jar
# ENTRYPOINT ["java","-jar","/backend-validator-0.0.1.jar"]

FROM maven:3.6.0-jdk-11-slim AS build
WORKDIR /validator-backend
COPY ./jumia_phone_validator/validator-backend /validator-backend/
RUN pwd && ls
RUN mvn clean install
RUN pwd && ls


# stage 2
FROM openjdk:8-jdk-alpine
WORKDIR /app
COPY --from=build /validator-backend/target/validator-0.0.1.jar  /app/validator-0.0.1.jar
ENTRYPOINT ["java","-jar","/validator-0.0.1.jar"]