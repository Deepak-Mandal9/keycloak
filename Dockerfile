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

# Build the optimized Keycloak server
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Start Keycloak in production mode
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start"]