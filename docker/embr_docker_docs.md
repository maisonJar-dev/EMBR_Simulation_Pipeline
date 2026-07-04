Use Docker Compose from a terminal as the authoritative workflow:
  ```bash
  docker compose build control-systems-dev
  docker compose up -d --force-recreate control-systems-dev
  docker compose exec control-systems-dev bash
  ```
Build only after Dockerfile/dependency changes. Normal startup requires
only:
```bash
docker compose up -d control-systems-dev
```



