# Dev image
FROM maven:3.9.3-eclipse-temurin-17 AS dev

WORKDIR /app

# pom.xml'i önce kopyala ve dependencyleri offline indir
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Kaynak kod mount edileceği için kopyalamıyoruz
# COPY src ./src

# Spring Boot uygulamasını run ile başlat
CMD ["mvn", "spring-boot:run"]



