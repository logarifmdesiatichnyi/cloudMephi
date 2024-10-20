#!/bin/bash -ex

# Добавление репозитория PostgreSQL
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Импорт ключа для проверки пакетов PostgreSQL
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Обновление списка пакетов и установка PostgreSQL
sudo apt update
sudo apt -y install postgresql

# Переход на пользователя postgres и проверка подключения к базе
sudo -i -u postgres <<EOF
psql -c '\conninfo'
EOF

# Установка и настройка pgAdmin

# Проверка статуса службы PostgreSQL
systemctl status postgresql

# Добавление ключа и репозитория для pgAdmin
wget --quiet -O - https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add -

# Добавление репозитория для pgAdmin4
sudo sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list'

# Обновление списка пакетов и установка pgAdmin4
sudo apt update
sudo apt install -y pgadmin4

# Изменение конфигурации pgAdmin для работы на 0.0.0.0 (доступ с любого IP)
sudo sed -i "s/127.0.0.1/0.0.0.0/" /etc/pgadmin4/config_local.py

# Разрешение порта 80 в firewall
sudo ufw allow 80/tcp

# Перезапуск Apache для применения изменений
sudo systemctl restart apache2
