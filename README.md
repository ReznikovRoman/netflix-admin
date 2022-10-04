# Netflix Admin
_Netflix_ admin management panel.

## Services
- Netflix Admin:
  - Online-cinema management panel. Admins can manage films, genres, actors/directors/writers/...
  - https://github.com/ReznikovRoman/netflix-admin
- Netflix ETL:
  - ETL pipeline for synchronizing data between "Netflix Admin" database and Elasticsearch
  - https://github.com/ReznikovRoman/netflix-etl
- Netflix Movies API:
  - Movies API
  - https://github.com/ReznikovRoman/netflix-movies-api
    - Python client: https://github.com/ReznikovRoman/netflix-movies-client
- Netflix Auth API:
  - Authorization service - users and roles management
  - https://github.com/ReznikovRoman/netflix-auth-api
- Netflix UGC:
  - Service for working with user generated content (comments, likes, film reviews, etc.)
  - https://github.com/ReznikovRoman/netflix-ugc
- Netflix Notifications:
  - Notifications service (email, mobile, push)
  - https://github.com/ReznikovRoman/netflix-notifications
- Netflix Voice Assistant:
  - Online-cinema voice assistant
  - https://github.com/ReznikovRoman/netflix-voice-assistant

## Configuration
Docker containers:
1. server
2. db

docker-compose files:
 1. `docker-compose.yml` - for local development.

To run docker containers, you need to create a `.env` file in the root directory.

**`.env` example:**

```
ENV=.env

# Django
DJANGO_SETTINGS_MODULE=netflix.settings
DJANGO_CONFIGURATION=Local
DJANGO_ADMIN=django-cadmin
DJANGO_SECRET_KEY=change-me
ALLOWED_HOSTS=localhost,127.0.0.1

# Project
NA_PROJECT_BASE_URL=http://localhost:8000

# Media
NA_MEDIA_URL=/media/
NA_STATIC_URL=/staticfiles/

# Postgres
NA_DB_HOST=db
NA_DB_PORT=5432
NA_DB_NAME=
NA_DB_USER=
NA_DB_PASSWORD=

# Scripts
NA_DB_POSTGRES_BATCH_SIZE=500
```

To run project locally, you need to create local Django settings `tb_content/settings/local.py`:

```python
import mimetypes
import socket

from .base import Base
from .values import from_environ


class Local(Base):
    DEBUG = True
    ALLOWED_HOSTS = ['*']
    CSRF_TRUSTED_ORIGINS = [
        'http://127.0.0.1:8000',
        'http://localhost:8000',
    ]

    STATIC_URL = "staticfiles/"

    LOG_SQL = from_environ(name='PROJECT_LOG_SQL', type=bool, default=False)

    # debug toolbar
    hostname, _, ips = socket.gethostbyname_ex(socket.gethostname())
    INTERNAL_IPS = [ip[: ip.rfind(".")] + ".1" for ip in ips] + ["127.0.0.1", "10.0.2.2"]
    DEBUG_TOOLBAR_CONFIG = {
        "SHOW_TOOLBAR_CALLBACK": lambda show_toolbar: True,
    }
    mimetypes.add_type('application/javascript', '.js', True)

    DEV_INSTALLED_APPS = [
        "debug_toolbar",
    ]
    DEV_MIDDLEWARE = [
        "debug_toolbar.middleware.DebugToolbarMiddleware",
    ]

    Base.INSTALLED_APPS.extend(DEV_INSTALLED_APPS)
    Base.MIDDLEWARE.extend(DEV_MIDDLEWARE)
```

### Start project:

Locally:
```shell
docker-compose build
docker-compose up
```

**To fill DB with test data**
```shell
docker-compose run --rm server bash -c "cd /app/scripts/load_db && python load_data.py"
```

On startup migrations are applied and static files are collected.

## Development
In this project we use [`django-configurations`](https://django-configurations.readthedocs.io/en/latest/),
therefore for running management commands instead of using `./manage.py` / `python -m django` / `django-admin`
you have to use `django-cadmin`.

**Example: Creating a superuser**
```shell
django-cadmin createsuperuser
```

Sync environment with `requirements.txt` / `requirements.dev.txt` (will install/update missing packages, remove redundant ones):
```shell
make sync-requirements
```

Compile requirements.\*.txt files (have to re-compile after changes in requirements.\*.in):
```shell
make compile-requirements
```

Use `requirements.local.in` for local dependencies; always specify _constraints files_ (-c ...)

Example:
```shell
# requirements.local.txt

-c requirements.txt

ipython
```

### Code style:
Before pushing a commit run all linters:

```shell
make lint
```

## Documentation
OpenAPI 3 documentation:
- `${PROJECT_BASE_URL}/api/v1/schema` - YAML or JSON, selection via content negotiation with the `Accept` header
- `${PROJECT_BASE_URL}/api/v1/schema/redoc` - ReDoc
- `${PROJECT_BASE_URL}/api/v1/schema/swagger` - Swagger
