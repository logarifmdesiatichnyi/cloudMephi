#!/bin/bash -ex

# Переменные
packages=('git' 'gcc' 'tar' 'gzip' 'libreadline-dev' 'make' 'zlib1g' 'zlib1g-dev' 'flex' 'bison' 'perl' 'python3' 'tcl' 'gettext' 'odbc-postgresql' 'libreadline-dev')
rfolder='/postgres'
dfolder='/postgres/data'
gitloc='git://git.postgresql.org/git/postgresql.git'
sysuser='postgres'
helloscript='/home/leewalker/scripts/hello.sql'
logfile='psqlinstall-log'

# Установка пакетов
sudo apt-get update -y >> $logfile
sudo apt-get install ${packages[@]} -y >> $logfile

# Создание директорий
sudo mkdir -p $dfolder >> $logfile

# Создание системного пользователя
sudo adduser --system $sysuser >> $logfile

# Скачивание PostgreSQL
git clone $gitloc >> $logfile

# Установка PostgreSQL
~/postgresql/configure --prefix=$rfolder --datarootdir=$dfolder >> $logfile
make >> $logfile
sudo make install >> $logfile

# Настройка прав
sudo chown postgres $dfolder >> $logfile

# Инициализация базы данных
sudo -u postgres $rfolder/bin/initdb -D $dfolder/db >> $logfile

# Запуск PostgreSQL
sudo -u postgres $rfolder/bin/pg_ctl -D $dfolder/db -l $dfolder/logfilePSQL start >> $logfile

# Добавление PostgreSQL в автозагрузку
sudo sed -i '$isudo -u postgres /postgres/bin/pg_ctl -D /postgres/data/db -l /postgres/data/logfilePSQL start' /etc/rc.local >> $logfile

# Добавление переменных окружения
cat << EOL | sudo tee -a /etc/profile

LD_LIBRARY_PATH=/postgres/lib
export LD_LIBRARY_PATH
PATH=/postgres/bin:$PATH
export PATH
EOL

# Установка pgAdmin
systemctl status postgresql
sudo wget https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add packages_pgadmin_org.pub
echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > sudo tee /etc/apt/sources.list.d/pgadmin4.list
sudo apt update
sudo apt install -y pgadmin4
sudo sed -i "s/127.0.0.1/0.0.0.0/" /etc/pgadmin4/config_local.py
sudo ufw allow 80/tcp
sudo systemctl restart apache2

# Запуск hello.sql
sleep 5
$rfolder/bin/psql -U postgres -f $helloscript

# Запрос к базе данных
/postgres/bin/psql -c 'select * from hello;' -U psqluser hello_postgres;

