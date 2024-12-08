# Базовый этап для добавления репозиториев
FROM ubuntu:jammy-20230605 AS add-apt-repositories

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y wget gnupg \
 && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && echo 'deb http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main' >> /etc/apt/sources.list

# Основной этап с PostgreSQL
FROM ubuntu:jammy-20230605

LABEL maintainer="sameer@damagehead.com"

ENV PG_APP_HOME="/etc/docker-postgresql" \
    PG_VERSION=15 \
    PG_USER=postgres \
    PG_HOME=/var/lib/postgresql \
    PG_RUNDIR=/run/postgresql \
    PG_LOGDIR=/var/log/postgresql \
    PG_CERTDIR=/etc/postgresql/certs \
    PG_BINDIR=/usr/lib/postgresql/${PG_VERSION}/bin \
    PG_DATADIR=${PG_HOME}/${PG_VERSION}/main

# Копирование ключей и репозитория с предыдущего этапа
COPY --from=add-apt-repositories /etc/apt/trusted.gpg /etc/apt/trusted.gpg
COPY --from=add-apt-repositories /etc/apt/sources.list /etc/apt/sources.list

# Установка PostgreSQL и конфигурация окружения
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y acl sudo locales \
      postgresql-${PG_VERSION} postgresql-client-${PG_VERSION} postgresql-contrib-${PG_VERSION} \
 && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
 && locale-gen en_US.UTF-8 \
 && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
 && ln -sf ${PG_DATADIR}/postgresql.conf /etc/postgresql/${PG_VERSION}/main/postgresql.conf \
 && ln -sf ${PG_DATADIR}/pg_hba.conf /etc/postgresql/${PG_VERSION}/main/pg_hba.conf \
 && ln -sf ${PG_DATADIR}/pg_ident.conf /etc/postgresql/${PG_VERSION}/main/pg_ident.conf \
 && rm -rf ${PG_HOME} /var/lib/apt/lists/*

# Копирование конфигурации
COPY runtime/ ${PG_APP_HOME}/

# Открытие порта PostgreSQL
EXPOSE 5433/tcp

WORKDIR ${PG_HOME}

# Запуск PostgreSQL сервера
CMD ["postgres", "-D", "/var/lib/postgresql/15/main"]
