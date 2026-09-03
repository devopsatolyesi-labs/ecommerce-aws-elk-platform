# Instana Robot Shop — AWS Cloud Platform (EKS & ECS) with Centralized ELK Logging

Bu proje, çok katmanlı mikroservis mimarisine ve çeşitli veritabanlarına (MongoDB, MySQL, Redis, RabbitMQ) sahip **Robot Shop** e-ticaret platformunu temel alır. Proje; **Terraform** ile otomatik olarak AWS üzerinde VPC, **Amazon EKS** (Kubernetes) ve **Amazon ECS** (Fargate) altyapısını kurar; tüm pod ve konteyner loglarını **Fluent Bit** ile toplayarak **Merkezi ELK Stack (Elasticsearch & Kibana)** üzerinde indeksler ve analiz eder.

---

## 📚 Dokümantasyon & Hızlı Bağlantılar

* 📖 **[Master Kurulum ve Operasyon Kılavuzu (A'dan Z'ye)](docs/FULL_SETUP_AND_OPERATIONS_GUIDE.md)**: AWS Sandbox gereksinimleri, Terraform modülleri, S3 backend, GitHub Actions, Helm ve ELK kurulumu.
* 🧪 **[Merkezi Log Analizi & Kök Neden Laboratuvarı](docs/LOG_ANALYSIS_LAB.md)**: Kibana KQL sorguları, MongoDB/Payment arıza simülasyonları ve hata ayıklama pratiği.

---

## 🏛️ Sistem Mimarisi

```mermaid
flowchart TD
    subgraph IAC [Altyapı Kod Olarak - Terraform]
        TF[Terraform CLI] -->|Tek Komutla Provision| AWS[AWS Bulut Hesabı]
    end

    subgraph AWS_VPC [AWS Multi-AZ VPC (10.0.0.0/16)]
        IGW[Internet Gateway]
        NAT[NAT Gateway]
        
        subgraph PUBLIC_SUBNETS [Genel Alt Ağlar]
            ALB[Application Load Balancer]
        end

        subgraph PRIVATE_SUBNETS [Özel Alt Ağlar]
            EKS_NODES[Amazon EKS Managed Node Group\nKubernetes v1.31 / t3.medium]
            ECS_TASKS[Amazon ECS Fargate Tasks]
        end
    end

    subgraph APP_LAYER [Robot Shop Mikroservisleri]
        WEB[web: Nginx / AngularJS]
        USER[user: NodeJS & MongoDB]
        CATALOG[catalogue: NodeJS & MongoDB]
        CART[cart: NodeJS & Redis]
        PAYMENT[payment: Python]
        SHIPPING[shipping: Java & MySQL]
        DISPATCH[dispatch: Golang & RabbitMQ]
    end

    subgraph LOGGING_LAYER [Merkezi Loglama & Gözlemlenebilirlik (ELK)]
        FB[Fluent Bit DaemonSet\n/var/log/containers/*.log]
        ES[(Elasticsearch 7.17\nLog İndeksleme & Arama)]
        KIBANA[Kibana 7.17 Web UI\nLog Analizi & Dashboardlar]
    end

    AWS --> AWS_VPC
    EKS_NODES --> APP_LAYER
    APP_LAYER -->|Stdout / Stderr Logs| FB
    FB -->|Parsed JSON HTTP Post| ES
    ES --> KIBANA
    ADMIN[SRE / DevOps Mühendisi] -->|Port 5601| KIBANA
```

---

## 🌟 Neden AWS EKS/ECS ve Merkezi ELK Stack?

Modern dağıtık mikroservis mimarilerinde hata ayıklama (troubleshooting) yaparken onlarca pod'un içine tek tek `kubectl logs` ile girmek imkansızdır.
* **Merkezi Log Havuzu:** Tüm servislerin (MongoDB sorgu hataları, MySQL bağlantı kopmaları, Nginx HTTP 500'leri) tek bir merkezde toplanması gerekir.
* **JSON Log Zenginleştirme:** Fluent Bit, Docker logunu Kubernetes API'den aldığı namespace, pod_name, container_name ve node_name etiketleriyle zenginleştirir.
* **Sıfırdan Altyapı Kurma Zahmeti Yok:** Hazır Terraform modülleri sayesinde öğrenci veya mühendis saatlerce konsolda VPC, Subnet, IAM ve EKS ayarlarıyla uğraşmaz; tek komutla üretim standartlarında küme ayağa kalkar.

---

## 🚀 Hızlı Başlangıç & Adım Adım Kurulum

### 1. Ön Koşullar
* AWS CLI (`aws configure` yapılmış, geçerli IAM yetkisi olan)
* Terraform (v1.5+)
* `kubectl` (v1.28+)

### 2. AWS Altyapısını Tek Komutla Kurma (Terraform)
Hiçbir manuel konsol işlemine gerek kalmadan VPC, EKS ve ECS altyapısını başlatın:

```bash
chmod +x scripts/*.sh
./scripts/deploy-aws-infra.sh
```

Bu betik otomatik olarak:
1. `terraform init` ve `terraform apply -auto-approve` çalıştırır.
2. VPC, NAT Gateway, Internet Gateway ve EKS kümesini kurar.
3. Yerel `kubectl` konfigürasyonunuzu yeni kurulan EKS kümesine bağlar.

### 3. Merkezi ELK Loglama Yığınını Dağıtma
Elasticsearch, Kibana ve Fluent Bit DaemonSet'ini ayağa kaldırın:

```bash
./scripts/deploy-elk.sh
```

Loglama namespace'indeki podların hazır olduğunu doğrulayın:
```bash
kubectl get pods -n logging
```

### 4. Robot Shop Mikroservislerini Dağıtma
Tüm e-ticaret mikroservislerini ve ilişkili veritabanlarını başlatın:

```bash
./scripts/deploy-robot-shop.sh
```

Dağıtımı izleyin:
```bash
kubectl get pods -n robot-shop -w
```

### 5. Otomatik Doğrulama ve Sağlık Testi
Sistemin tüm bileşenlerini test edin:

```bash
./scripts/validate.sh
```

---

## 🔍 Kibana Üzerinde Log Analizi ve Hata Ayıklama

Kibana arayüzüne erişmek için:
```bash
kubectl port-forward svc/kibana -n logging 5601:5601
```
Tarayıcınızda `http://localhost:5601` adresine gidin.

### Temel Log Arama Örnekleri (KQL - Kibana Query Language):
* **HTTP 500 ve Hata Alan Servisler:**
  ```text
  log_processed.status >= 500 or log_processed.level: "error"
  ```
* **Ödeme (Payment) Servisi Logları:**
  ```text
  kubernetes.container_name: "payment"
  ```
* **Veritabanı Bağlantı Hataları:**
  ```text
  log_processed.message: *connection* and log_processed.level: "error"
  ```

---

## 🛑 Maliyet Yönetimi: Altyapıyı Güvenle Silme

Laboratuvar çalışması bittiğinde AWS faturası oluşmaması için tüm bulut kaynaklarını tek komutla temizleyin:

```bash
./scripts/destroy-aws-infra.sh
```

Bu betik `terraform destroy` komutunu çalıştırarak VPC, EKS, NAT Gateway ve ilgili tüm ücretli AWS varlıklarını tamamen siler.

---

## 🔧 Dizin Yapısı

```text
.
├── terraform/
│   ├── main.tf                 # Terraform ana konfigürasyon ve provider
│   ├── vpc.tf                  # Multi-AZ VPC, Subnet ve NAT Gateway
│   ├── eks.tf                  # Amazon EKS v1.31 & Managed Node Group
│   ├── ecs.tf                  # Amazon ECS Fargate Task tanımları
│   ├── variables.tf            # Parametreler (bölge, node tipi, boyut)
│   ├── outputs.tf              # Kubeconfig ve endpoint çıktıları
│   └── terraform.tfvars.example# Örnek değişkenler
├── elk-stack/
│   ├── 01-elasticsearch.yaml   # Elasticsearch 7.17 StatefulSet & Service
│   ├── 02-kibana.yaml          # Kibana 7.17 Web UI Deployment
│   └── 03-fluent-bit.yaml      # Pod log toplayıcı DaemonSet & Parser
├── K8s/descriptors/            # Robot Shop Kubernetes manifestoları
├── scripts/
│   ├── deploy-aws-infra.sh     # Tek tıkla AWS altyapı kurulumu
│   ├── destroy-aws-infra.sh    # Tek tıkla AWS kaynak silimi
│   ├── deploy-elk.sh           # ELK Stack kurulum betiği
│   ├── deploy-robot-shop.sh    # Robot Shop dağıtım betiği
│   └── validate.sh             # Otomatik doğrulama testi
└── README.md                   # Üretim seviyesi operasyon kılavuzu
```

---

## 📞 Destek ve Katkı
Bu proje DevOps Atölyesi Eğitim Programı kapsamında hazırlanmıştır. Sorularınız için eğitim kanalından veya eğitmeninizle iletişime geçebilirsiniz.
