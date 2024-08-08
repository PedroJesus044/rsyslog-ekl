# rsyslog-ekl
<h2>Instalación</h2>
<ul>
  <li>
    En un servidor con docker compose bastará correr el siguiente comando para iniciar el entorno EKL para el procesamiento de logs con logstash dentro de la carpeta EKL
    <ul>
<pre>
cd rsyslog-ekl/EKL
docker compose up -d
</pre>
    </ul>
  </li>

  <li>
    Se instala la paquetería rsyslog
    <ul>
<pre>
yum install rsyslog
</pre>
    </ul>
  </li>

  <li>
    Copiar los archivos 70-output.conf y 01-json-template.conf a la ruta correspondiente y reiniciar el servicio rsyslog
    <ul>
<pre>
cp ./*.conf /etc/rsyslog.d/
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
    image: mariadb:11.2.4
    environment:
      - MARIADB_ROOT_PASSWORD=mariadb
    ports:
      - "3306:3306"
    #La sección logging con el driver syslog mandará los logs del contenedor al syslog del sistema previamente configurado.
    #La variable "programname" será el ID del contenedor de Docker
    logging:
      driver: "syslog"
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
</ul>
