#!/bin/bash

set -e

echo "🚀 Iniciando configuración post-creación..."

# Detectar el gestor de paquetes y archivo de construcción
if [ -f "pom.xml" ]; then
    echo "📦 Detectado proyecto Maven"
    echo "Descargando dependencias..."
    mvn dependency:resolve dependency:resolve-plugins || true
    echo "✅ Dependencias Maven descargadas"
elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
    echo "📦 Detectado proyecto Gradle"
    echo "Descargando dependencias..."
    if [ -f "gradlew" ]; then
        chmod +x gradlew
        ./gradlew build --no-daemon || true
    else
        gradle build --no-daemon || true
    fi
    echo "✅ Dependencias Gradle descargadas"
else
    echo "⚠️  No se detectó pom.xml ni build.gradle"
fi

# Verificar conectividad con bases de datos
echo "🔍 Verificando servicios..."

for i in {1..30}; do
    if pg_isready -h db-postgres -p 5432 -U devuser > /dev/null 2>&1; then
        echo "✅ PostgreSQL está listo"
        break
    fi
    echo "⏳ Esperando PostgreSQL... ($i/30)"
    sleep 2
done

for i in {1..30}; do
    if mysqladmin ping -h db-mysql -u devuser -pdevpass --silent > /dev/null 2>&1; then
        echo "✅ MySQL está listo"
        break
    fi
    echo "⏳ Esperando MySQL... ($i/30)"
    sleep 2
done

for i in {1..30}; do
    if mongosh --host db-mongodb --username devuser --password devpass --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
        echo "✅ MongoDB está listo"
        break
    fi
    echo "⏳ Esperando MongoDB... ($i/30)"
    sleep 2
done

echo "🎉 Configuración completada!"
echo ""
echo "📝 Comandos útiles:"
echo "  - Maven: mvn spring-boot:run"
echo "  - Gradle: ./gradlew bootRun"
echo "  - PostgreSQL: psql -h db-postgres -U devuser -d devdb"
echo "  - MySQL: mysql -h db-mysql -u devuser -pdevpass devdb"
echo "  - MongoDB: mongosh mongodb://devuser:devpass@db-mongodb:27017/devdb"
echo ""