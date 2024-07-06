# Etapa 1: Construir la aplicación con Maven Wrapper
FROM openjdk:17-jdk-slim AS build

# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar el archivo de Maven Wrapper y el script para descargar dependencias
COPY .mvn/ .mvn/
COPY mvnw .

# Dar permisos de ejecución al script de Maven Wrapper
RUN chmod +x mvnw

# Copiar el archivo pom.xml para resolver dependencias
COPY pom.xml .

# Ejecutar Maven Wrapper para descargar dependencias offline
RUN ./mvnw dependency:go-offline

# Copiar todo el código fuente del proyecto
COPY src ./src

# Compilar la aplicación utilizando Maven Wrapper
RUN ./mvnw clean package -DskipTests

# Para ver el contenido de la carpeta
RUN echo "Contenido de /app/target/:" && ls -la /app/target

# Etapa 2: Crear la imagen para ejecutar la aplicación
FROM openjdk:17-jdk-slim

# Establecer el directorio de trabajo para la imagen final
WORKDIR /app

# Copiar el JAR construido en la etapa anterior al contenedor final
COPY --from=build /app/target/products-service-example-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080

# Definir el comando para ejecutar la aplicación
ENTRYPOINT ["java", "-jar", "app.jar"]
