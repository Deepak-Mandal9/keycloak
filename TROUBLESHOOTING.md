# Troubleshooting Guide - Keycloak on Railway

## Common Issues and Solutions

### 1. **502 Bad Gateway Error**

#### Symptoms
- Railway shows error 502
- Can't access the Keycloak application
- App keeps restarting

#### Common Causes & Solutions

**A. Database Connection Failure**
```
Error: Connection refused / JDBC URL invalid
```

**Checks:**
1. Verify PostgreSQL service is running on Railway
2. Check database credentials in environment variables:
   ```
   KC_DB_URL=jdbc:postgresql://host:5432/keycloak
   KC_DB_USERNAME=postgres
   KC_DB_PASSWORD=<password>
   ```
3. Ensure database name matches URL
4. Test connection from Railway CLI:
   ```bash
   railway database connect
   ```

**B. Port Binding Error**
```
Error: Failed to bind port 8080
```

**Solution:**
- Railway automatically injects `$PORT` environment variable
- Verify Dockerfile sets: `ENV KC_HTTP_PORT=${PORT:-8080}`
- Check that Railway has only ONE Keycloak service running

**C. Health Check Failing**
```
Error: Health check endpoint not responding
```

**Solution:**
1. Keycloak takes 40+ seconds to start
2. Verify health check path: `/health/ready`
3. Check logs for startup errors:
   ```bash
   railway logs --follow
   ```

**D. Configuration Error**
```
Error: Invalid configuration / Missing properties
```

**Solution:**
1. Verify `keycloak.conf` is correct
2. Check environment variables are set
3. Run locally first with `docker-compose`:
   ```bash
   docker-compose up
   ```

---

### 2. **Application Crashes After Deployment**

#### Check Logs
```bash
railway logs --follow
```

#### Common Error Messages

**"Cannot connect to database"**
- Database credentials are wrong
- Database doesn't exist
- PostgreSQL service not initialized
- Connection pool is exhausted

**Solution:**
```properties
# Check and update in keycloak.conf or Railway env vars:
KC_DB_URL=jdbc:postgresql://railway-postgres-host:5432/keycloak
KC_DB_POOL_MAX_SIZE=20  # Increase if pool exhausted
```

**"Out of Memory"**
```
java.lang.OutOfMemoryError: Java heap space
```

**Solution:**
```bash
# Increase memory in Railway environment:
JAVA_OPTS=-Xms512m -Xmx1024m
# Or for larger deployments:
JAVA_OPTS=-Xms1024m -Xmx2048m
```

**"Keycloak failed to start"**

**Solution:**
1. Check syntax in `keycloak.conf`
2. Verify all properties are valid
3. Check if database schema exists
4. Check file permissions in Docker container

---

### 3. **Can't Access Admin Console**

#### URL not responding
- Verify exact URL: `https://your-app.railway.app/admin`
- Check Railway domain settings
- Wait 2-3 minutes after deployment

#### Getting 404 errors
```
Error: Resource not found at /admin
```

**Possible causes:**
- Keycloak not fully started yet
- Wrong path
- Admin UI disabled

**Solution:**
```bash
# Check if admin UI is enabled:
curl https://your-app.railway.app/admin

# Or via logs:
railway logs | grep admin
```

#### Login fails with wrong credentials
- Default: `admin` / `admin123` (only works if env vars set)
- If changed, check Railway environment variables:
  ```
  KEYCLOAK_ADMIN=admin
  KEYCLOAK_ADMIN_PASSWORD=your-password
  ```

---

### 4. **Database Issues**

#### "Database already initialized"
This is normal on second deployments. No action needed.

#### "Cannot acquire a connection"
```
Error in pool: Cannot get a connection within 30 seconds
```

**Solution:**
```properties
# Increase pool size in keycloak.conf:
db-pool-max-size=30
db-pool-initial-size=15
```

#### Database migration fails
**Solution:**
1. Check database schema version:
   ```bash
   railway database connect
   SELECT version FROM keycloak_version;
   ```
2. May need manual migration for major version upgrades
3. Backup before upgrading version

---

### 5. **SSL/HTTPS Issues**

#### Mixed content errors
```
Error: Mixed Content - https page loading http resources
```

**Solution:**
```properties
# Ensure these are set in keycloak.conf:
proxy=reencrypt
hostname-strict-https=true
```

#### Redirect loop
```
Error: Redirect loop or too many redirects
```

**Solution:**
1. Verify hostname matches Railway domain:
   ```
   KC_HOSTNAME=your-app.railway.app
   ```
2. Ensure reverse proxy settings are correct:
   ```properties
   proxy=reencrypt
   proxy-headers=forwarded
   ```

---

### 6. **Performance Issues**

#### Slow login / timeout errors

**Check resource usage:**
```bash
railway status
```

**Solutions:**
1. Increase memory allocation
2. Increase database connection pool
3. Enable caching properly:
   ```properties
   cache=ispn
   spi-sticky-session-encoder-infinispan-should-attach-route=false
   ```

#### High CPU usage

**Causes:**
- Too many active sessions
- Inefficient realm settings
- Heavy logging

**Solution:**
```bash
# Reduce log level
KC_LOG_LEVEL=WARN

# Check realm configuration
# Disable unnecessary features
```

---

### 7. **Email/Notifications Not Working**

#### Emails not sending

**Verify configuration:**
```properties
KC_SPI_EMAIL_DEFAULT_FROM=noreply@your-domain.com
KC_SPI_EMAIL_DEFAULT_HOST=smtp.gmail.com
KC_SPI_EMAIL_DEFAULT_PORT=587
KC_SPI_EMAIL_DEFAULT_AUTH=true
```

**Test SMTP:**
```bash
# In Railway shell:
curl telnet://smtp.gmail.com:587
```

**Solutions:**
- Check credentials
- Enable "Less secure app access" for Gmail
- Use app-specific password instead of account password
- Whitelist Railway IP addresses in your mail provider

---

### 8. **Docker Image Build Issues**

#### "Dockerfile: No such file or directory"
- Ensure you're in the correct directory
- Check file path: should be `./Dockerfile`

#### Build fails with "Permission denied"
- Ensure scripts have execute permissions:
  ```bash
  chmod +x bin/kc.sh
  ```

#### Out of disk space during build
- Clean Docker cache:
  ```bash
  docker system prune -a
  ```

---

### 9. **Theme/Provider Issues**

#### Custom theme not loading
**Solution:**
1. Verify theme files in `themes/` directory
2. Check Dockerfile copies themes correctly
3. Rebuild and redeploy:
   ```bash
   git push origin main
   ```

#### Custom provider not loaded
**Solution:**
1. Check `providers/` directory
2. Verify JAR file syntax
3. Check logs for provider loading errors:
   ```bash
   railway logs | grep provider
   ```

---

### 10. **Local Development Issues**

#### docker-compose fails to start

**Port already in use:**
```bash
# Find and kill process using port 8080
lsof -i :8080
kill -9 <PID>
```

**Or change port in docker-compose.yml:**
```yaml
ports:
  - "8081:8080"  # Use 8081 instead
```

#### Cannot connect to Docker daemon
```bash
# Ensure Docker is running
docker --version

# Start Docker daemon if needed (Linux):
sudo systemctl start docker
```

#### PostgreSQL stuck/won't start
```bash
# Reset volume
docker-compose down -v  # Removes all data!
docker-compose up
```

---

### 11. **Debugging Tools**

#### Enable debug logging
```properties
# In keycloak.conf:
log-level=DEBUG
log-console-output=json
```

#### Check Railway logs
```bash
railway logs --follow
railway logs --since 30m
```

#### Access Railway shell
```bash
railway shell
ps aux | grep java
```

#### Test connectivity
```bash
# From Railway shell:
curl http://localhost:8080/health/ready
curl -I http://localhost:8080
```

#### View environment variables
```bash
railway env
```

---

### 12. **When All Else Fails**

1. **Restart the service:**
   ```bash
   railway redeploy
   ```

2. **Check Railway status page:**
   - https://status.railway.app

3. **Review recent deployments:**
   ```bash
   railway deployments
   ```

4. **Clear cache and rebuild:**
   ```bash
   git push --force origin main
   railway down
   railway up
   ```

5. **Collect diagnostic info:**
   ```bash
   # Get comprehensive logs
   railway logs --since 24h > keycloak-logs.txt
   
   # Get environment
   railway env > keycloak-env.txt
   
   # Share with support
   ```

6. **Contact support:**
   - Railway Support: https://railway.app/contact
   - Keycloak Community: https://www.keycloak.org/community
   - Stack Overflow: tag `keycloak`

---

## Prevention Tips

1. **Always test locally first:**
   ```bash
   docker-compose up
   ```

2. **Use environment variables wisely:**
   - Never hardcode secrets
   - Use `.env.example` for documentation

3. **Monitor logs regularly:**
   ```bash
   railway logs --follow
   ```

4. **Set up alerts in Railway:**
   - High memory usage
   - High CPU usage
   - Service restarts

5. **Keep backups:**
   - Enable PostgreSQL backups
   - Document configuration changes

6. **Regular testing:**
   - Test login flows monthly
   - Test password reset
   - Test email notifications
   - Test realm changes
