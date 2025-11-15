# -------- Stage 1: Build WAR using Maven --------
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml ./
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# -------- Stage 2: Deploy to Tomcat --------
FROM tomcat:9-jdk17
WORKDIR /usr/local/tomcat
RUN rm -rf webapps/ROOT
COPY --from=builder /app/target/*.war webapps/ROOT.war
EXPOSE 8085
CMD ["catalina.sh", "run"]
