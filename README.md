# Guía de Hardening del Servidor Web con Docker y Apache

## 1. Introducción a Hardening

El *hardening* es el proceso de asegurar un sistema, servidor o aplicación mediante la reducción de sus vulnerabilidades y la implementación de configuraciones de seguridad avanzadas. Esta guía detalla el proceso de creación y configuración de un servidor web seguro utilizando Docker y Apache, aplicando prácticas de seguridad esenciales como la configuración de certificados SSL, la protección contra ataques DoS y la implementación de políticas de seguridad como Content Security Policy (CSP) y HTTP Strict Transport Security (HSTS).

## 2. Creación del Dockerfile Securizado

La creación de una imagen Docker securizada implica la instalación y configuración de Apache con medidas de seguridad adecuadas. Aquí está el `Dockerfile` detallado que hemos utilizado:

[Dockerfile](./Dockerfile)

También dejo un archivo de ejemplo para el servidor web

[TuSitio.conf](./TuSitio.conf)


### **Resumen de la configuración del Dockerfile**:
- **Base de la imagen**: Usamos la imagen base oficial de Ubuntu 20.04 para tener un entorno limpio y controlado.
- **Instalación de Apache y módulos de seguridad**: Instalamos Apache y los módulos `libapache2-mod-security2` y `libapache2-mod-evasive` para proteger el servidor.
- **Configuración de SSL**: Instalamos y configuramos los certificados SSL para asegurar las conexiones.
- **Aplicación de políticas de seguridad**:
  - Configuración de **HSTS (HTTP Strict Transport Security)** y **CSP (Content Security Policy)** para proteger contra ataques de tipo man-in-the-middle y garantizar que solo se carguen recursos seguros.
- **Configuración de un sitio web predeterminado** y habilitación de los puertos HTTP y HTTPS.

### **Pasos para la creación del Dockerfile**:
1. **Instalación de dependencias**: Se instaló Apache y las bibliotecas necesarias, así como los módulos de seguridad.
2. **Configuración de la zona horaria**: Se configuró la zona horaria de forma no interactiva para mantener la coherencia de los registros.
3. **Creación y configuración de archivos de seguridad**:
   - Configuración de HSTS y CSP en el archivo `/etc/apache2/apache2.conf`.
   - Creación de un archivo de configuración del sitio web y definición de `VirtualHost` para HTTPS.
4. **Habilitación de módulos de Apache**:
   - Activación de `ssl`, `headers` y `evasive` para habilitar la protección de SSL y la mitigación de ataques DoS.
5. **Pruebas de funcionalidad**: Verificación de que la imagen de Docker se construye correctamente y se ejecuta sin errores.

## 3. Explicación de Reglas OWASP

La **OWASP Core Rule Set (CRS)** es un conjunto de reglas que se aplican a través del módulo **ModSecurity** de Apache para proteger el servidor contra una variedad de ataques web, como inyecciones de SQL, XSS y ataques de inclusión de archivos. Estas reglas son fundamentales para proporcionar una capa de seguridad adicional y garantizar que las aplicaciones web sean menos vulnerables a ataques.

### **Implementación de OWASP CRS**:
- **Clonación del repositorio de CRS**: Clonamos el repositorio de OWASP CRS y lo configuramos en el contenedor.
- **Configuración de ModSecurity**: Modificamos el archivo de configuración de ModSecurity para incluir las reglas de CRS y activamos la protección.
- **Verificación de la protección**:
  - Se probó que ModSecurity esté activo usando comandos de prueba y asegurándonos de que los ataques simulados fueran detectados y bloqueados.

### **Pruebas realizadas**:
1. **Prueba de inyección SQL**: Se verificó que las peticiones maliciosas fueron bloqueadas por ModSecurity.
2. **Prueba de XSS**: Se intentó cargar scripts maliciosos en el servidor, y ModSecurity los bloqueó.

## 4. Explicación de `mod_evasive`

El módulo **`mod_evasive`** de Apache se usa para proteger el servidor contra ataques de denegación de servicio (DoS) y escaneo de puertos. Este módulo ayuda a prevenir que una máquina realice un número excesivo de solicitudes en un corto período de tiempo, lo que podría hacer que el servidor se sobrecargue y deje de responder.

### **Configuración de `mod_evasive`**:
1. **Instalación y activación del módulo**: Se instaló `libapache2-mod-evasive` y se activó en Apache.
2. **Configuración del módulo**: Se configuró en `/etc/apache2/mods-available/evasive.conf` para establecer umbrales de conexión y políticas de bloqueo.
3. **Parámetros de configuración**:
   - `DOSHashTableSize 2048`: Tamaño de la tabla hash para rastrear conexiones.
   - `DOSPageCount 5`: Número máximo de solicitudes por página antes de bloquear.
   - `DOSSiteCount 100`: Número máximo de solicitudes al sitio antes de bloquear.
   - `DOSBlockingPeriod 10`: Periodo de bloqueo en segundos.
   - `DOSEmailNotify`: Correo electrónico para notificaciones en caso de un bloqueo.
   - `DOSLogDir /var/log/mod_evasive`: Directorio de registros de eventos de `mod_evasive`.

Dejo el archivo configurado tambien.

[evasive.conf](./evasive.conf)

### **Pruebas de `mod_evasive`**:
1. **Prueba de carga con Apache Bench (ab)**:
   - Se realizó una prueba de carga usando `ab` para generar un alto volumen de solicitudes y observar cómo `mod_evasive` bloquea las conexiones que superan el umbral.

   ```bash
   ab -n 100 -c 20 https://tudominio:8443/
