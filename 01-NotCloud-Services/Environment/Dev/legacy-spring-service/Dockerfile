FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/legacy-spring-service.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
