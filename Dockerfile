FROM python:3.10-slim-buster

# Устанавливаем системные зависимости
RUN apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
        apt-transport-https \
        build-essential \
        ca-certificates \
        curl \
        git \
        jq \
        less \
        libpcre3 \
        libpcre3-dev \
        openssh-client \
        telnet \
        unzip \
        vim \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем pipx и Poetry через pipx
RUN pip install --no-cache-dir pipx \
    && pipx ensurepath \
    && pipx install poetry

# Добавляем Poetry в PATH
ENV PATH="/root/.local/bin:$PATH"

# Отключаем виртуальное окружение внутри контейнера
RUN poetry config virtualenvs.create false

WORKDIR /app

# Копируем файлы зависимостей и устанавливаем их
COPY pyproject.toml poetry.lock ./
RUN poetry install --no-interaction --no-root

# Копируем исходники
COPY . /app

# Меняем владельца файлов (если необходимо)
RUN chown -R nobody:nogroup /app
USER nobody

ENV DJANGO_SETTINGS_MODULE="task_manager.settings"

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
