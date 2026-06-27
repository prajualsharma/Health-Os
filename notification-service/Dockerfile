# syntax=docker/dockerfile:1

# --- Build stage: compile the Spring Boot fat jar from source ---
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /workspace

COPY pom.xml .
RUN mvn -q -B dependency:go-offline

COPY src ./src
RUN mvn -q -B clean package -DskipTests

# --- Runtime stage: small JRE image ---
FROM eclipse-temurin:21-jre
WORKDIR /app

COPY --from=build /workspace/target/*.jar app.jar

ENV JAVA_OPTS="-XX:MaxRAMPercentage=70 -XX:InitialRAMPercentage=40"
EXPOSE 8082

ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar /app/app.jar"]
