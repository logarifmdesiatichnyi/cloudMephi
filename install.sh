#!/bin/bash -ex

# Установка необходимых пакетов и конфигурация для PostgreSQL и pgAdmin

# Добавление репозитория PostgreSQL 15
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Импорт ключа для проверки пакетов PostgreSQL
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Обновление списка пакетов
sudo apt update

# Установка PostgreSQL 15
sudo apt -y install postgresql-15

# Проверка статуса службы PostgreSQL
systemctl status postgresql

# Установка и настройка pgAdmin

# Добавление ключа и репозитория для pgAdmin
wget --quiet -O - https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add -
sudo sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list'

# Обновление списка пакетов и установка pgAdmin4
sudo apt update
sudo apt install -y pgadmin4

# Создание конфигурационного файла, если его нет
if [ ! -f /etc/pgadmin4/config_local.py ]; then
    sudo mkdir -p /etc/pgadmin4
    echo "SERVER_MODE = True" | sudo tee /etc/pgadmin4/config_local.py
    echo "DEFAULT_SERVER = '0.0.0.0'" | sudo tee -a /etc/pgadmin4/config_local.py
fi

# Запуск скрипта настройки pgAdmin
sudo /usr/pgadmin4/bin/setup-web.sh

# Разрешение порта 80 в firewall (при необходимости)
if sudo ufw status | grep -q inactive; then
    echo "UFW is inactive, no firewall rules applied."
else
    sudo ufw allow 80/tcp
fi

# Перезапуск Apache для применения изменений
sudo systemctl restart apache2

# Получение локального IP-адреса
IP_ADDRESS=$(hostname -I | awk '{print $1}')

# Информация о доступе к pgAdmin
echo "pgAdmin 4 установлен и доступен по адресу: http://$IP_ADDRESS/pgadmin4"
