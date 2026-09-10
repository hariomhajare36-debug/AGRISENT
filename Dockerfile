# ==============================================================================
# Multi-Stage Dockerfile for AgriRent India Fullstack Platform
# Stage 1: Build React 18 + Vite Frontend
# Stage 2: Build Spring Boot 3 Backend with embedded static frontend
# Stage 3: Lightweight Production JRE 17 Runtime
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. FRONTEND BUILD STAGE
# ------------------------------------------------------------------------------
FROM node:20-alpine AS frontend-builder
WORKDIR /app/frontend

COPY frontend/package*.json ./
RUN npm ci || npm install

COPY frontend/ ./
RUN npm run build

# ------------------------------------------------------------------------------
# 2. BACKEND BUILD STAGE
# ------------------------------------------------------------------------------
FROM maven:3.9.6-eclipse-temurin-17 AS backend-builder
WORKDIR /app/backend

# Pre-fetch dependencies
COPY backend/pom.xml ./
RUN mvn dependency:go-offline -B || true

# Copy backend source code
COPY backend/src ./src

# Embed compiled frontend dist into Spring Boot static resources
COPY --from=frontend-builder /app/frontend/dist ./src/main/resources/static/

# Package the Spring Boot JAR
RUN mvn clean package -DskipTests

# ------------------------------------------------------------------------------
# 3. PRODUCTION RUNTIME STAGE
# ------------------------------------------------------------------------------
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Run as non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Copy compiled JAR
COPY --from=backend-builder --chown=appuser:appgroup /app/backend/target/agrirent-backend-*.jar app.jar

# Dynamic port binding (Render assigns $PORT dynamically)
ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["sh", "-c", "exec java -Dserver.port=${PORT:-8080} -jar app.jar"]
