# rsyslog-ekl
<h2>Instalación</h2>
<ul>
  <li>
    En un servidor con docker compose bastará correr el siguiente comando para iniciar el entorno EKL para el procesamiento de logs con logstash dentro de la carpeta EKL
    <ul>
<pre>
docker compose up -d
</pre>
    </ul>
  </li>

  <li>
    Se instala la paquetería rsyslog y el módulo omhttp. Ejemplo para RHEL 8
    <ul>
<pre>
cd /etc/yum.repos.d/
wget https://download.opensuse.org/repositories/home:rgerhards/CentOS_8/home:rgerhards.repo
yum install rsyslog rsyslog-omhttp
</pre>
    </ul>
  </li>

  <li>
    Copiar el archivo elastic.rsyslog.conf a /etc/rsyslog.d/ remplazando el server, puerto y https según nuestro logstash
    <ul>
<pre>
cp ./elastic.rsyslog.conf /etc/rsyslog.d/
systemctl restart rsyslog
</pre>
    </ul>
  </li>
</ul>
Ahora solo debemos mandar los logs de nuestros servicios a syslog de manera normal en cada paquetería instalada.

<h2>Configuración de syslog en los servicios</h2>
<ul>
  <li>
    <h3>Docker</h3>
    <ul>Se requiere que los servicios en docker compose queden de la siguiente manera
<pre>
services:
  mariadb-log-test:
    container_name: db01
    image: mariadb:11.2.4
    environment:
      - MARIADB_ROOT_PASSWORD=mariadb
    ports:
      - "3306:3306"
    #La sección logging con el driver syslog mandará los logs del contenedor al syslog del sistema previamente configurado.
    #La variable "programname" será el ID del contenedor de Docker
    logging:
      driver: syslog
      options:
        tag: docker-db01
</pre>
    </ul> 
  </li>

  <li>
    <h3>httpd</h3>
    <ul>Agregar la siguiente línea al archivo de configuración de apache /etc/httpd/conf/httpd.conf
<pre>
CustomLog "| /bin/sh -c '/usr/bin/tee -a /var/log/httpd/access_log | /usr/bin/logger -thttpd_access_log'" combined
</pre>
    </ul> 
  </li>

  <li>
    <h3>mariadb</h3>
    <ul>Se debe editar el servicio desde systemd con el siguiente comando y pegar el siguiente texto a continuación
<pre>
[Service]

StandardOutput=syslog
StandardError=syslog
SyslogFacility=daemon
SysLogLevel=err
</pre>
    </ul> 
  </li>

  <li>
    <h3>Ansible</h3>
    <ul>Copiar el archivo remote.rsyslog.conf a /etc/rsyslog.d/
        Las variables de entorno de ansible deben quedar de la siguiente manera
<pre>
- ANSIBLE_HOST_KEY_CHECKING=False
- TZ=America/Mexico_City
- ANSIBLE_STDOUT_CALLBACK=syslog_json
- SYSLOG_FACILITY=user
- SYSLOG_PORT=514
- SYSLOG_SERVER=<your_rsyslog_server_host>
</pre>
        Finalmente reiniciar el servicio de rsyslog
<pre>
systemctl restart rsyslog
</pre>
</ul>
    </ul> 
  </li>
</ul>
