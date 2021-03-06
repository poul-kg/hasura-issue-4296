#!/bin/bash
docker-compose down && \
  docker volume rm hasura-issue_test_data && \
  docker-compose up -d --build && \
  sleep 5 && \
  hasura migrate apply --admin-secret 12345 --endpoint http://localhost:8080 && \
  echo "Done!!!"
