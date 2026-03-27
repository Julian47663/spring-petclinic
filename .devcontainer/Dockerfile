FROM mcr.microsoft.com/devcontainers/java:17-bullseye

# Instalar SDKMAN y múltiples versiones de Java
RUN bash -c "curl -s 'https://get.sdkman.io' | bash" \
    && bash -c "source /root/.sdkman/bin/sdkman-init.sh \
    && sdk install java 17.0.8-tem \
    && sdk install java 11.0.20-tem \
    && sdk install maven \
    && sdk install gradle"

# Configurar variables de entorno
ENV SDKMAN_DIR="/usr/local/sdkman"
ENV JAVA_HOME="/usr/local/sdkman/candidates/java/17.0.8-tem"
ENV PATH="${JAVA_HOME}/bin:${SDKMAN_DIR}/candidates/maven/current/bin:${SDKMAN_DIR}/candidates/gradle/current/bin:${PATH}"

# Instalar herramientas adicionales
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    postgresql-client \
    mysql-client \
    mongodb-clients \
    kafkacat \
    curl \
    wget \
    git \
    vim \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Crear usuario vscode si no existe
RUN if ! id -u vscode > /dev/null 2>&1; then \
    groupadd --gid 1000 vscode \
    && useradd --uid 1000 --gid vscode --shell /bin/bash --create-home vscode; \
    fi

# Configurar permisos para Maven y Gradle cache
RUN mkdir -p /root/.m2 /root/.gradle \
    && chown -R vscode:vscode /root/.m2 /root/.gradle

USER vscode

# Pre-descargar dependencias comunes de Maven
RUN mkdir -p /tmp/maven-warmup && cd /tmp/maven-warmup \
    && echo '<project xmlns="http://maven.apache.org/POM/4.0.0"><modelVersion>4.0.0</modelVersion><groupId>warmup</groupId><artifactId>warmup</artifactId><version>1.0</version><dependencies><dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-web</artifactId><version>3.1.5</version></dependency></dependencies></project>' > pom.xml \
    && mvn dependency:resolve || true \
    && cd / && rm -rf /tmp/maven-warmup

WORKDIR /workspace