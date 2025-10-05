# 🌾 Tarladan – Dijital Tarım Pazarı Platformu

## 🚀 Proje Hakkında

**Tarladan**, çiftçileri, alıcıları, depocuları ve nakliyecileri tek bir dijital platformda buluşturarak **tarımda dijital dönüşümü** hedefleyen bir web ve mobil uygulamadır.  
Bu proje, **aracıları ortadan kaldırarak** çiftçinin kazancını artırmayı, **lojistik ve depolama süreçlerini dijitalleştirerek** verimliliği yükseltmeyi ve **tüketiciye daha uygun fiyatlı ürün** ulaştırmayı amaçlar.

---

## 🎯 Projenin Amacı

Günümüzde çiftçiler, ürünlerini pazara ulaştırmak için birçok aracıya ihtiyaç duyar. Bu durum hem çiftçinin kazancını azaltır hem de tüketiciye daha yüksek fiyat olarak yansır.  
**Tarladan**, bu süreci tamamen dijitalleştirerek üreticiden tüketiciye doğrudan erişim sağlayan bir **uçtan uca tarımsal ticaret ekosistemi** oluşturur.

**Hedeflerimiz:**
- Aracı sayısını azaltarak üreticinin gelirini artırmak,  
- Tarımda dijitalleşmeyi yaygınlaştırmak,  
- Depo ve nakliye süreçlerini optimize ederek verimliliği artırmak,  
- Türkiye tarımında sürdürülebilir bir dijital ekosistem oluşturmak.  

---

## 👥 Kullanıcı Tipleri

Platformda dört temel kullanıcı tipi bulunmaktadır:

| Rol | Açıklama |
|-----|-----------|
| 👨‍🌾 **Farmer (Çiftçi)** | Ürün ilanı oluşturur, depoya gönderim talebi oluşturur. |
| 🧑‍💼 **Buyer (Alıcı)** | Ürünleri inceleyip sipariş verir, nakliyeci seçimi yapar. |
| 🚛 **Trucker (Nakliyeci)** | Tırını sisteme kaydeder, ilan oluşturur, taşıma teklifleri alır. |
| 🏢 **Depot Owner (Depocu)** | Depo ilanı oluşturur, gelen depolama isteklerini onaylar. |

---

## 🧩 Proje Özellikleri (Features)

| Kategori | Özellik | Açıklama |
|-----------|----------|----------|
| 🧾 **Kullanıcı Yönetimi** | JWT Authentication | Access & Refresh Token yapısı (Spring Security + Redis). |
| 🧑‍🌾 **Ürün Yönetimi** | Ürün ilanı oluşturma, düzenleme, silme | Çiftçilerin ürünlerini pazara sunmasını sağlar. |
| 🏪 **Depo Yönetimi** | Depo kayıt & onay sistemi | Çiftçilerin depolama izni istemesini sağlar. |
| 🚛 **Nakliye Yönetimi** | Tır kayıt ve ilan sistemi | Nakliyeciler kendi tırlarını ve müsaitlik durumlarını paylaşır. |
| 📦 **Sipariş Sistemi** | Ürün alım & sevkiyat işlemleri | Alıcı, çiftçi ve tırcı arasında koordinasyon sağlar. |
| 🔔 **Bildirim Sistemi** | Gerçek zamanlı istek bildirimleri | Depo ve nakliye onay süreçlerini yönetir. |
| 💾 **Caching** | Redis Entegrasyonu | Refresh token ve sık kullanılan sorgular cache’lenir. |
| 🐳 **Dockerize Yapı** | Docker Compose | Backend + PostgreSQL aynı anda ayağa kalkar. |
| ⚙️ **Error & Success Response** | Generic Response Yapısı | Frontend tarafına tutarlı veri dönüşleri sağlanır. |
| 🧠 **Monitoring & Logging** | Prometheus, Grafana (planlı) | Sistem sağlığı ve hatalar izlenir. |

---

## 🏗️ Mimari Yapı

Proje **Spring Boot Monolithic Architecture (MVC)** prensibine göre yapılandırılmıştır.  
Backend, Controller–Service–Repository katmanlarından oluşur. Her katman modüler, sürdürülebilir ve genişletilebilir bir yapı sunar.  
Ayrıca proje, JWT tabanlı kimlik doğrulama, Redis caching, generic response yapıları (Success & Error Responses) ve Docker Compose üzerinden containerize edilmiştir.

---

## 🌍 Sosyal ve Ekonomik Etki

- 👨‍🌾 **Çiftçilerin gelirini artırır**, aracıları azaltarak ürünün doğrudan tüketiciye ulaşmasını sağlar.  
- 🛒 **Tüketiciye daha uygun fiyatlı ürün** ulaştırılmasına katkı sağlar.  
- 🚛 **Depo ve nakliyat süreçlerini dijitalleştirerek** operasyonel verimliliği artırır.  
- 🌾 **Türkiye tarımında ilk uçtan uca dijital çözüm** olma potansiyeline sahiptir.  
- ♻️ **Sürdürülebilir tarım ve dijital dönüşüm vizyonunu** destekler.  

---

## 🧠 Geliştiriciler (Contributors)

| 👤 İsim | 🔗 GitHub |
|:--|:--|
| 🎨 **Ali Koray Ürün**  | [@korayUrun](https://github.com/korayUrun) |
| 🧑‍💻 **Mazlum Emre Girgin** | [@mazlumemregirgin](https://github.com/mazlumemregirgin) |
| 💡 **Şehriban Yaren Öztekin** | [@yarennoztekinn](https://github.com/yarennoztekinn) |

---





