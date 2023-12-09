FROM openjdk:11
WORKDIR /app
COPY MyApp.jar /app
CMD ["java", "-jar", "MyApp.jar"]