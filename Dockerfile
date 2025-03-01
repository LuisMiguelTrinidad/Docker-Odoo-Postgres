FROM python:3.10-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    dirmngr \
    fonts-liberation \
    gnupg \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    node-less \
    npm \
    postgresql-client \
    python3-num2words \
    python3-pdfminer \
    python3-phonenumbers \
    python3-pip \
    python3-pyldap \
    python3-qrcode \
    python3-renderpm \
    python3-setuptools \
    python3-slugify \
    python3-vobject \
    python3-watchdog \
    python3-xlrd \
    python3-xlwt \
    unzip \
    xfonts-75dpi \
    xfonts-base \
    libsass-dev \
    libldap2-dev \
    libpq-dev \
    build-essential \
    python3-dev \
    # SASL dependencies needed for python-ldap
    libsasl2-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Pre-install Cython con una versión específica
RUN pip install --no-cache-dir Cython==3.0.0

# Install wkhtmltopdf
RUN curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.bullseye_amd64.deb \
    && apt-get update && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Create Odoo user first
RUN useradd -ms /bin/bash odoo

# Set working directory
WORKDIR /opt/odoo

# Download and extract Odoo
ARG ODOO_VERSION
RUN wget https://github.com/odoo/odoo/archive/refs/heads/${ODOO_VERSION}.zip \
    && unzip ${ODOO_VERSION}.zip \
    && rm ${ODOO_VERSION}.zip \
    && mv odoo-${ODOO_VERSION} odoo

# Set working directory to Odoo
WORKDIR /opt/odoo/odoo

# Copy extended requirements to the Docker image
COPY external-requirements.txt .

# Instalar primero external-requirements para sobrescribir versiones problemáticas
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r external-requirements.txt && \
    # Filtrar gevent del archivo requirements.txt de Odoo
    grep -v "gevent" requirements.txt > requirements.filtered.txt && \
    mv requirements.filtered.txt requirements.txt && \
    # Instalar el resto de dependencias
    pip install --no-cache-dir -r requirements.txt

# Create directories and set permissions (only once)
RUN mkdir -p /var/lib/odoo /opt/odoo/custom-addons \
    && chown -R odoo:odoo /var/lib/odoo /opt/odoo \
    && chmod -R 775 /var/lib/odoo /opt/odoo/custom-addons

# Add permission fix script
COPY fix-permissions.sh /usr/local/bin/fix-permissions.sh
RUN chmod +x /usr/local/bin/fix-permissions.sh

# Runtime configuration
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose Odoo port
EXPOSE 8069

# Usar un script para cambiar al usuario odoo después de arreglar los permisos
ENTRYPOINT ["/entrypoint.sh"]
CMD ["python3", "odoo-bin"]