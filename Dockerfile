# Usar una imagen base oficial de Ubuntu
FROM ubuntu:20.04

# Evitar la interacción para la configuración de la zona horaria
    ENV DEBIAN_FRONTEND=noninteractive

# Establecer la zona horaria y evitar la interacción durante la instalación
    RUN apt-get update && \
        apt-get install -y tzdata && \
        ln -fs /usr/share/zoneinfo/Europe/Madrid /etc/localtime && \
        dpkg-reconfigure --frontend noninteractive tzdata

# Instalar Apache2
    RUN apt-get install -y apache2 libapache2-mod-security2 libapache2-mod-evasive git apache2-utils && \
        rm -rf /var/lib/apt/lists/*

# Deshabilitar el módulo autoindex
    RUN sed -i '/autoindex_module/d' /etc/apache2/apache2.conf

# Configurar HSTS y CSP
    RUN echo "Header always set Strict-Transport-Security \"max-age=63072000; includeSubDomains\"" >> /etc/apache2/apache2.conf && \
        echo "Header set Content-Security-Policy \"default-src 'self'; img-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline';\"" >> /etc/apache2/apache2.conf

# Crear un directorio para el sitio web y establecer un archivo index básico
    RUN mkdir -p /var/www/html
    COPY jgonalb/* /var/www/html
    RUN mkdir -p /etc/letsencrypt/live/path
# Copiar certificados
    COPY certificados/* /etc/letsencrypt/live/path
    COPY TuSitio.conf /etc/apache2/sites-available/
    COPY security2.conf /etc/apache2/mods-available/
# Copiar evasive.conf
    COPY evasive.conf /etc/apache2/sites-available/

# Clonar repositorio de OWASP CRS
    RUN git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /tmp/owasp-modsecurity-crs && \
        mv /tmp/owasp-modsecurity-crs/crs-setup.conf.example /etc/modsecurity/crs-setup.conf && \
        mv /tmp/owasp-modsecurity-crs/rules /etc/modsecurity/

# Habilitar el módulo headers para usar las cabeceras de seguridad
    RUN a2enmod headers

# Si creas un archivo de configuración propio descomenta la linea para que se desactive el por defecto
    #    RUN a2dissite 000-default.conf
# Comenta la siguiente linea si no has hecho cambios en el default
    RUN a2ensite TuSitio.conf
    RUN a2enmod ssl
    RUN service apache2 restart

# Exponer los puertos HTTP y HTTPS
    EXPOSE 80 443

# Comando para iniciar Apache
    CMD ["apachectl", "-D", "FOREGROUND"]