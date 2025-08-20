# Kafka 모니터링 시스템 설치 가이드

이 프로젝트는 Kafka와 함께 Prometheus, Grafana를 사용한 모니터링 시스템을 Docker Compose로 구축하는 예제입니다.

## 시스템 구성

- **Kafka**: 메시징 시스템
- **Zookeeper**: Kafka 클러스터 관리
- **Prometheus**: 메트릭 수집 및 저장
- **Grafana**: 메트릭 시각화 대시보드
- **Kafka Exporter**: Kafka 메트릭 수집기
- **Node Exporter**: 시스템 메트릭 수집기

## 사전 요구사항

### 필수 설치 프로그램
1. **Docker** (버전 20.x 이상)
   - [Docker 공식 사이트](https://www.docker.com/get-started/)에서 다운로드
   - 설치 후 터미널에서 `docker --version`으로 확인

2. **Docker Compose** (버전 2.x 이상)
   - Docker Desktop 설치 시 자동 포함
   - 터미널에서 `docker-compose --version`으로 확인

### 시스템 요구사항
- RAM: 최소 4GB (권장 8GB)
- 디스크 공간: 최소 2GB
- 포트: 2181, 3000, 7071, 9090, 9092, 9100, 9101, 9308 (사용 가능해야 함)

## 설치 방법

### 1. 프로젝트 파일 준비

#### JMX Prometheus 에이전트 다운로드
먼저 Kafka 메트릭 수집을 위한 JMX Prometheus 에이전트를 다운로드해야 합니다:

```bash
# JMX Prometheus 에이전트 다운로드 (최신 버전)
wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.20.0/jmx_prometheus_javaagent-0.20.0.jar -O jmx_prometheus_javaagent.jar

# 다운로드 확인
ls -la jmx_prometheus_javaagent.jar
```

**wget이 설치되지 않은 경우:**
- **macOS**: `brew install wget` 또는 [수동 다운로드](https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.20.0/jmx_prometheus_javaagent-0.20.0.jar)
- **Windows**: [수동 다운로드](https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.20.0/jmx_prometheus_javaagent-0.20.0.jar) 후 파일명을 `jmx_prometheus_javaagent.jar`로 변경
- **Ubuntu/Debian**: `sudo apt-get install wget`

#### 필요한 파일 구조 확인
모든 파일이 준비되면 다음과 같은 구조여야 합니다:
```
kafka-practice/
├── docker-compose.yml
├── prometheus.yml
├── jmx_prometheus_httpserver.yml
├── jmx_prometheus_javaagent.jar    # wget으로 다운로드
└── README.md
```

### 2. 포트 확인
다음 명령어로 필요한 포트가 사용되고 있지 않은지 확인:
```bash
# macOS/Linux
lsof -i :2181,3000,7071,9090,9092,9100,9101,9308

# Windows
netstat -an | findstr "2181 3000 7071 9090 9092 9100 9101 9308"
```

### 3. Docker 서비스 시작
터미널에서 프로젝트 디렉토리로 이동 후 실행:
```bash
# 서비스 시작 (백그라운드에서 실행)
docker-compose up -d

# 로그 확인
docker-compose logs -f
```

### 4. 서비스 상태 확인
```bash
# 모든 컨테이너 상태 확인
docker-compose ps

# 특정 서비스 로그 확인
docker-compose logs kafka
docker-compose logs prometheus
```

## 서비스 접속 정보

서비스 시작 후 웹 브라우저에서 다음 주소로 접속 가능합니다:

### Grafana (데이터 시각화)
- **URL**: http://localhost:3000
- **사용자명**: admin
- **비밀번호**: admin123

### Prometheus (메트릭 수집기)
- **URL**: http://localhost:9090
- 메트릭 쿼리 및 모니터링 가능

### 기타 서비스
- **Kafka**: localhost:9092 (애플리케이션 연결용)
- **Kafka Exporter**: http://localhost:9308/metrics
- **Node Exporter**: http://localhost:9100/metrics

## 기본 사용법

### 1. Kafka 토픽 생성
```bash
# Kafka 컨테이너 접속
docker exec -it kafka bash

# 토픽 생성
kafka-topics --create --topic test-topic --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1

# 토픽 목록 확인
kafka-topics --list --bootstrap-server localhost:9092
```

### 2. 메시지 생산/소비 테스트
```bash
# 프로듀서 실행 (메시지 전송)
kafka-console-producer --topic test-topic --bootstrap-server localhost:9092

# 컨슈머 실행 (메시지 수신) - 새 터미널에서
docker exec -it kafka kafka-console-consumer --topic test-topic --from-beginning --bootstrap-server localhost:9092
```

### 3. Grafana 대시보드 설정
1. http://localhost:3000 접속
2. admin/admin123으로 로그인
3. Configuration > Data Sources 메뉴에서 Prometheus 추가
4. URL에 `http://prometheus:9090` 입력
5. Save & Test 클릭

## 문제 해결

### 컨테이너가 시작되지 않는 경우
```bash
# 모든 서비스 중지
docker-compose down

# 볼륨까지 제거하고 재시작
docker-compose down -v
docker-compose up -d
```

### 포트 충돌 문제
```bash
# 특정 포트를 사용하는 프로세스 찾기
lsof -i :9092  # macOS/Linux
netstat -ano | findstr :9092  # Windows

# 해당 프로세스 종료 후 재시작
```

### 메모리 부족 문제
```bash
# Docker 메모리 사용량 확인
docker stats

# 필요시 Docker Desktop에서 메모리 할당량 증가
```

## 서비스 중지

```bash
# 모든 서비스 중지
docker-compose down

# 데이터 볼륨까지 제거
docker-compose down -v

# Docker 이미지까지 제거
docker-compose down --rmi all
```

## 참고 자료

- [Apache Kafka 공식 문서](https://kafka.apache.org/documentation/)
- [Prometheus 공식 문서](https://prometheus.io/docs/)
- [Grafana 공식 문서](https://grafana.com/docs/)
- [Docker Compose 문서](https://docs.docker.com/compose/)

## 문의사항

설치나 사용 중 문제가 발생하면 다음을 확인해보세요:
1. 모든 사전 요구사항이 설치되어 있는지
2. 필요한 포트가 사용 가능한지
3. Docker 서비스가 정상적으로 실행되고 있는지
4. 시스템 리소스(메모리, 디스크)가 충분한지