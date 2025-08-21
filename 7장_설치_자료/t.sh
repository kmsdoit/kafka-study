#!/bin/bash

# 초당 처리율 데이터를 위한 연속 메시지 생성
for i in {1..20}; do echo "Message batch 1 - $i $(date)" | docker run --rm -i --network 7___default confluentinc/cp-kafka:7.4.0 kafka-console-producer --topic test-topic --bootstrap-server kafka:29092; sleep 0.1; done

# 병렬로 빠른 메시지 생성 (lag 생성용)
for i in {1..30}; do echo "Fast message batch - $i $(date)" | docker run --rm -i --network 7___default confluentinc/cp-kafka:7.4.0 kafka-console-producer --topic test-topic --bootstrap-server kafka:29092 & done; wait
