# 🧪 Laboratuvar: Merkezi ELK Stack ile Mikroservis Hata Ayıklama & Log Analizi

Bu laboratuvar dokümanı, **Instana Robot Shop** mikroservislerinde kasıtlı olarak oluşturulan arızaları **Kibana & Elasticsearch** kullanarak tespit etmeyi ve kök neden analizi (Root Cause Analysis - RCA) yapmayı öğretir.

---

## 🎯 Laboratuvar Hedefleri
1. Kibana üzerinde `k8s-logs-*` Index Pattern oluşturmak.
2. Pod ve konteyner loglarını Kubernetes etiketleriyle (namespace, pod, container) filtrelemek.
3. KQL (Kibana Query Language) kullanarak kritik hataları ve HTTP 500 yanıtlarını yakalamak.
4. Çöken veritabanı (MongoDB) ile ona bağlı servisler arasındaki hata zincirini izlemek.

---

## 🚀 1. Adım: Kibana Arayüzüne Bağlanma

Eğer EKS kümesi üzerindeki Kibana'ya yerel tarayıcınızdan erişmek isterseniz:
```bash
kubectl port-forward svc/kibana 5601:5601 -n logging
```
Tarayıcınızda açın: `http://localhost:5601`

---

## 🔍 2. Adım: Index Pattern Tanımlama

1. Sol menüden **Management -> Stack Management** seçeneğine tıklayın.
2. **Kibana -> Index Patterns** sekmesine gelin.
3. **Create index pattern** butonuna tıklayın.
4. **Name:** `k8s-logs-*` yazın (Elasticsearch'teki indeksler listelenecektir).
5. **Timestamp field:** `@timestamp` seçin.
6. **Create index pattern** butonuna basarak tamamlayın.

---

## 💥 3. Adım: Hata Senaryolarını Tetikleme

Aşağıdaki komutla 3 farklı mikroserviste arıza üretin:
```bash
./scripts/simulate-log-incidents.sh all
```

---

## 🕵️ 4. Adım: Senaryo Bazlı Hata İncelemeleri

### Senaryo A: Ürün Kataloğu Servisi (Catalogue) Yanıt Vermiyor
* **Semptom:** Web arayüzünde ürünler yüklenmiyor.
* **KQL Sorgusu:**
  ```text
  kubernetes.container_name: "catalogue" AND log: "*Error*"
  ```
* **Kök Neden:** Loglarda `MongoServerSelectionError: connect ECONNREFUSED 10.x.x.x:27017` görülür. MongoDB podunun kapalı olduğu tespit edilir.

### Senaryo B: Ödeme Servisi (Payment) Hataları
* **Semptom:** Müşteriler siparişi tamamlayamıyor.
* **KQL Sorgusu:**
  ```text
  kubernetes.container_name: "payment" AND (log: "*500*" OR log: "*INVALID*")
  ```
* **Kök Neden:** Gönderilen ödeme isteğinde negatif tutar ve geçersiz para birimi olduğu Python Flask loglarında açıkça listelenir.

### Senaryo C: Genel Sistem Sağlık Taraması
* **Semptom:** Sistemde genel olarak hangi servisler hata logu üretiyor?
* **KQL Sorgusu:**
  ```text
  kubernetes.namespace_name: "robot-shop" AND NOT kubernetes.container_name: "load-gen" AND (log: "*Exception*" OR log: "*ERROR*" OR log: "*fatal*")
  ```

---

## 🏆 Tebrikler!
Merkezi loglama mimarisi sayesinde sunuculara tek tek SSH yapmadan tüm dağıtık mikroservislerin durumunu tek bir ekrandan analiz ettiniz!
