# rsyslog-ekl
#En un servidor solo bastará correr el siguiente comando para iniciar el entorno EKL para el procesamiento de logs con logstash dentro de la carpeta EKL
docker compose up -d

#Se instala la paquetería rsyslog
yum install rsyslog

#Copiar los archivos 70-output.conf 01-json-template.conf a la ruta correspondiente
cp ./*.conf /etc/rsyslog.d/

#Ahora solo basta con mandar los logs de todo a syslog de manera normal en cada paquetería instalada.

#Para mandar logs desde Docker los servicios dentro de docker-compose.yaml deberán verse de la siguiente manera
services:
  mariadb-log-test:
    image: mariadb:11.2.4
    environment:
      - MARIADB_ROOT_PASSWORD=mariadb
    ports:
      - "3306:3306"
    #La sessión logging con el driver syslog mandará los logs del contenedor.
    #El programname será el ID del contenedor de Docker
    logging:
      driver: "syslog"
        #syslog-address: "udp://1.2.3.4:1111"

#Para mandar access_logs desde httpd se debe agregar la siguiente línea al archivo de configuración de apache /etc/httpd/conf/httpd.conf
#Los error_logs se mandan a logstash de manera predeterminada vía systemd
CustomLog "| /bin/sh -c '/usr/bin/tee -a /var/log/httpd/access_log | /usr/bin/logger -thttpd_access_log'" combined

#Para mandar logs desde mariadb bastará con editar el servicio desde systemd con el siguiente comando. Esto abrirá una ventana con vim o nano, seguidamente se deberá pegar el contenido de mariadb-service.conf
#Nota: Debemos asegurarnos que la variable log_error en /etc/my.conf.d/service.conf no está definida
sudo systemctl edit mariadb.service