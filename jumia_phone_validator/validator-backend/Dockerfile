FROM openjdk:8-jdk-alpine
WORKDIR /app
COPY ./jumia_phone_validator/validator-backend /app/
RUN pwd && ls
COPY /validator-backend/target/validator-0.0.1.jar /app/backend-validator-0.0.1.jar
# ENTRYPOINT ["java","-jar","/backend-validator-0.0.1.jar"]