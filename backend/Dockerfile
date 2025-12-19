# ----------------------------
# 1. AŞAMA: BUILD (Derleme)
# ----------------------------
FROM maven:3.9.3-eclipse-temurin-17 AS build
WORKDIR /app

# Önce sadece pom.xml'i kopyala ve kütüphaneleri indir (Cache mantığı)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# ŞİMDİ KRİTİK NOKTA: Kaynak kodları içeri kopyalıyoruz!
COPY src ./src

# Projeyi derle ve .jar dosyasını oluştur (Testleri calistir)
RUN mvn clean package

# ----------------------------
# 2. AŞAMA: RUNTIME (Çalıştırma)
# ----------------------------
FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app

# İlk aşamada üretilen .jar dosyasını buraya al
COPY --from=build /app/target/*.jar app.jar

# Fotoğraf yükleme klasörlerini oluştur
RUN mkdir -p /app/uploads/productPhotos /app/uploads/truckPhotos

# Uygulamayı başlat (mvn run yerine java -jar kullanıyoruz, çok daha hızlıdır)
ENTRYPOINT ["java", "-jar", "app.jar"]