@echo off
REM Quick Start Guide for Keycloak Development & Deployment (Windows)

echo.
echo ================================
echo Keycloak Quick Start Guide
echo ================================
echo.

echo.
echo ^>^>^> 1. LOCAL DEVELOPMENT SETUP
echo.
echo Using docker-compose for local development:
echo.
echo   docker-compose up -d
echo.
echo   Access: http://localhost:8080/admin
echo   Username: admin
echo   Password: admin123
echo.
echo   View logs: docker-compose logs -f keycloak
echo.
echo   Stop: docker-compose down
echo.

echo.
echo ^>^>^> 2. BUILDING DOCKER IMAGE
echo.
echo   docker build -t keycloak-railway:latest .
echo.

echo.
echo ^>^>^> 3. ENVIRONMENT VARIABLES
echo.
echo   Copy .env.example to .env and update values
echo   NEVER commit .env to git
echo.

echo.
echo ^>^>^> 4. DEPLOYMENT TO RAILWAY
echo.
echo   Prerequisites:
echo   - Railway account
echo   - Git repository
echo   - PostgreSQL service on Railway
echo.
echo   See RAILWAY_DEPLOYMENT.md for detailed steps
echo.

echo.
echo ^>^>^> 5. HEALTH CHECKS
echo.
echo   curl http://localhost:8080/health/ready
echo   curl http://localhost:8080/health/live
echo.

echo.
echo ^>^>^> 6. LOGS
echo.
echo   docker-compose logs -f
echo   docker-compose logs keycloak
echo.

echo.
echo ^>^>^> 7. SECURITY
echo.
echo   Read SECURITY.md for best practices
echo.

echo.
echo ================================
echo Ready to deploy! Good luck! ^^_^
echo ================================
echo.
