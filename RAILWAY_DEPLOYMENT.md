# Railway Deployment Guide for Keycloak

## Prerequisites

1. **Railway Account**: Sign up at [railway.app](https://railway.app)
2. **PostgreSQL Database**: Create a PostgreSQL plugin in Railway
3. **Git Repository**: Push your code to GitHub

## Environment Variables to Set in Railway

When deploying to Railway, set these environment variables in the Railway dashboard:

### Database Configuration (Auto-populated from PostgreSQL plugin)
```
DATABASE_URL       # Auto-set by Railway PostgreSQL plugin
DATABASE_USER      # Auto-set by Railway PostgreSQL plugin
DATABASE_PASSWORD  # Auto-set by Railway PostgreSQL plugin
```

### Keycloak Required Variables
```
KC_HOSTNAME=your-keycloak-app.railway.app
KC_DB_URL=jdbc:postgresql://your-db-host:5432/railway
KC_DB_USERNAME=postgres
KC_DB_PASSWORD=<password>
KC_HTTP_PORT=8080
```

### Keycloak Optional Variables
```
KC_LOG_LEVEL=INFO
JAVA_OPTS=-Xms256m -Xmx512m
```

## Deployment Steps

1. **Connect Railway to GitHub**
   - Go to Railway Dashboard
   - Click "New Project" → "Deploy from GitHub repo"
   - Select your Keycloak repository

2. **Add PostgreSQL Plugin**
   - In Railway project, click "Add Services"
   - Select "PostgreSQL"
   - Wait for initialization

3. **Configure Environment**
   - Go to your app's settings
   - Add environment variables (see above)
   - Make sure database is connected

4. **Deploy**
   - Railway will automatically build and deploy on push to main branch
   - Monitor logs in Railway dashboard

5. **Access Keycloak**
   - Once deployment succeeds, visit: `https://your-app-name.railway.app`
   - Admin console: `https://your-app-name.railway.app/admin`

## Troubleshooting 502 Bad Gateway

### Check Logs
- Open Railway dashboard → your app → View Logs
- Look for database connection errors

### Common Issues

1. **Database Connection Error**
   ```
   Error: Connection refused or JDBC URL invalid
   Solution: Verify KC_DB_URL and database credentials
   ```

2. **Port Binding Error**
   ```
   Error: Port already in use
   Solution: Railway sets PORT env var automatically, Dockerfile uses it
   ```

3. **Hostname Redirect Loop**
   ```
   Error: Redirect loop or 302 errors
   Solution: Ensure KC_HOSTNAME matches your Railway app domain
   ```

4. **Health Check Failing**
   ```
   Error: Service unhealthy, restarting
   Solution: Check if /health/ready endpoint is accessible
   ```

## Production Recommendations

1. **Increase Memory**
   - Set `JAVA_OPTS=-Xms512m -Xmx1024m` for production

2. **Configure SMTP** (for emails)
   ```
   KC_SPI_EMAIL_DEFAULT_FROM=noreply@your-domain.com
   KC_SPI_EMAIL_DEFAULT_FROM_DISPLAY_NAME=Keycloak
   KC_SPI_EMAIL_DEFAULT_HOST=smtp.your-provider.com
   KC_SPI_EMAIL_DEFAULT_PORT=587
   ```

3. **Enable Metrics**
   - Already enabled in keycloak.conf
   - Access metrics at: `/metrics`

4. **Backup Database**
   - Use Railway's PostgreSQL backup feature
   - Enable automated backups in database settings

5. **SSL/TLS**
   - Railway automatically provides SSL certificates
   - Keycloak is configured to work behind reverse proxy with SSL termination

## Database Migration

If migrating from H2 to PostgreSQL:

1. Export existing data from H2 database
2. Import into PostgreSQL on Railway
3. Set database configuration in Keycloak

Alternatively, let Keycloak initialize a fresh PostgreSQL database (recommended for new deployments).

## Monitoring

Use Railway's built-in monitoring or add external tools:

- **Metrics endpoint**: `/metrics`
- **Health endpoint**: `/health`
- **Ready endpoint**: `/health/ready`

## Support

- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [Railway Documentation](https://docs.railway.app)
- [Keycloak Server Configuration](https://www.keycloak.org/server/configuration)
