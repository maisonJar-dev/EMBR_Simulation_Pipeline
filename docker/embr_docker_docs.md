Use Docker Compose from a terminal as the authoritative workflow:
  Set `LOCAL_UID` and `LOCAL_GID` in `.env` to the values reported by
  `id -u` and `id -g`. This makes files created in bind-mounted workspaces
  belong to your local user. Both default to `1000`.

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


