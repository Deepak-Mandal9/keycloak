# Keycloak Security Best Practices for Railway

## Pre-Deployment Security Checklist

### 1. **Environment Variables & Secrets**
- [ ] Never commit `.env` files with real credentials
- [ ] Use `.env.example` for documentation
- [ ] Set `KEYCLOAK_ADMIN_PASSWORD` to a strong, unique password
- [ ] Rotate database password after initial setup
- [ ] Use Railway's secure environment variables UI

```bash
# DO NOT do this in code:
KEYCLOAK_ADMIN_PASSWORD=admin123

# Instead, use strong passwords:
KEYCLOAK_ADMIN_PASSWORD=$(openssl rand -base64 32)
KC_DB_PASSWORD=$(openssl rand -base64 32)
```

### 2. **Database Security**
- [ ] Enable PostgreSQL SSL connections if Railway supports it
- [ ] Use strong, unique database passwords (minimum 16 characters)
- [ ] Restrict database access to Keycloak service only
- [ ] Enable PostgreSQL logging for audit trails
- [ ] Regular automated backups enabled in Railway

```properties
# keycloak.conf - Connection pool settings
db-pool-initial-size=10
db-pool-max-size=20
db-pool-min-size=5
```

### 3. **HTTPS & TLS Configuration**
- [ ] Railway provides automatic SSL certificates
- [ ] Force HTTPS redirects
- [ ] Set HSTS (HTTP Strict Transport Security) headers
- [ ] Disable old TLS versions (use TLS 1.2+)

```properties
# keycloak.conf
hostname-strict-https=true
spi-theme-default=keycloak
```

### 4. **Admin Console Security**
- [ ] Change default admin credentials immediately
- [ ] Disable admin console in production if not needed: `KC_ADMIN_UI_ENABLED=false`
- [ ] Restrict admin console access by IP (if using Railway's network policies)
- [ ] Use strong, unique passwords for all admin accounts
- [ ] Enable 2FA for admin accounts

```bash
# Disable admin UI in production
KC_ADMIN_UI_ENABLED=false
```

### 5. **CORS & Origin Validation**
- [ ] Configure CORS settings for your client applications
- [ ] Set explicit allowed origins (never use *)
- [ ] Whitelist specific client URLs

```properties
# keycloak.conf
spi-cors-allowed-methods=GET,POST,PUT,DELETE,OPTIONS,HEAD
spi-cors-exposed-response-headers=WWW-Authenticate
```

### 6. **Session & Cookie Security**
- [ ] Enable secure session cookies (HTTPS only)
- [ ] Set appropriate session timeouts
- [ ] Use SameSite=Lax or SameSite=Strict for cookies

```properties
# keycloak.conf - Session timeout (in minutes)
spi-theme-welcome-page-enabled=false
```

### 7. **Logging & Auditing**
- [ ] Enable security event logging
- [ ] Monitor failed login attempts
- [ ] Enable audit logs for admin actions
- [ ] Send logs to a centralized logging service if possible

```properties
# keycloak.conf
log=console
log-level=INFO
spi-events-listener-jboss-logging-success-level=warn
spi-events-listener-jboss-logging-error-level=warn
```

### 8. **Rate Limiting & DDoS Protection**
- [ ] Enable rate limiting for authentication endpoints
- [ ] Set up Railway's DDoS protection
- [ ] Configure login failure tolerance

```properties
# keycloak.conf - Brute force detection
spi-login-protocol-openid-connect-legacy-logout-redirect-uri=true
```

### 9. **Database Connection Security**
```properties
# keycloak.conf
# Use SSL for database connections
db-url=jdbc:postgresql://host:5432/keycloak?ssl=true&sslmode=require
```

### 10. **API Security**
- [ ] Enable API token expiration (default: 5 minutes)
- [ ] Rotate service account keys regularly
- [ ] Use OAuth 2.0 for all API access
- [ ] Implement request signing for sensitive operations

### 11. **Infrastructure Security**
- [ ] Use Railway's private networking if available
- [ ] Enable Web Application Firewall (WAF) rules
- [ ] Monitor for suspicious activity
- [ ] Enable Railway's security scanning

### 12. **Dependency Management**
- [ ] Keep Keycloak version updated
- [ ] Monitor security advisories
- [ ] Update custom themes and providers regularly
- [ ] Use container image scanning

## Post-Deployment Security Tasks

### Monitoring
1. Set up alerts for failed login attempts
2. Monitor admin account activity
3. Check logs regularly for suspicious patterns
4. Review security events in Keycloak admin console

### Regular Maintenance
1. Review and update security settings quarterly
2. Audit user accounts and roles
3. Test backup and disaster recovery procedures
4. Update security policies as needed

### Incident Response
1. Have an incident response plan documented
2. Know how to disable compromised accounts
3. Maintain audit logs for at least 90 days
4. Have contact information for Railway support

## Security Headers Configuration

Add these headers in Keycloak realm settings:

```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), microphone=(), camera=()
```

## References
- [Keycloak Security Guidelines](https://www.keycloak.org/docs/latest/server_admin/index.html#_security)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Railway Security](https://docs.railway.app/security)
- [PostgreSQL Security](https://www.postgresql.org/docs/current/sql-syntax.html)
