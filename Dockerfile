# Start from the official Keycloak image
FROM quay.io/keycloak/keycloak:latest as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure database vendor (Postgres is best for Railway)
ENV KC_DB=postgres

# Copy your custom themes and providers (if you have any)
COPY themes/ /opt/keycloak/themes/
COPY providers/ /opt/keycloak/providers/

# Copy configuration file
COPY conf/keycloak.conf /opt/keycloak/conf/keycloak.conf

# Build the optimized Keycloak server
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Copy configuration file
COPY conf/keycloak.conf /opt/keycloak/conf/keycloak.conf

# Copy custom themes and providers
COPY themes/ /opt/keycloak/themes/
COPY providers/ /opt/keycloak/providers/

# Set runtime environment variables for Railway
ENV KC_HTTP_ENABLED=true
ENV KC_HTTP_PORT=${PORT:-8080}
ENV KC_PROXY=reencrypt
ENV KC_PROXY_HEADERS=forwarded
ENV KC_HOSTNAME=${KC_HOSTNAME}
ENV KC_HOSTNAME_STRICT_HTTPS=false
ENV KC_HOSTNAME_STRICT=false
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Health check for Railway
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:${PORT:-8080}/health/ready || exit 1

# Start Keycloak in production mode
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start"]