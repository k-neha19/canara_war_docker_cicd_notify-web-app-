# Dockerizing a Maven webapp

This project implements a complete CI/CD pipeline for deploying a Java web application using GitHub, Jenkins, Maven, Docker, Tomcat, and AWS EC2. The pipeline supports Dev and Prod environments through Jenkins parameters, enabling automated builds, containerization, and environment-specific deployments. Dev uses Docker Compose for testing, while Prod pulls the latest Docker image, removes old containers, and runs a fresh instance. Cleanup automation is included to remove old containers and images. Designed & Developed by Sak_Shetty under MIT License.

## Prerequisites
- Docker installed
- Maven (for local builds) or use multi-stage Docker build
- JDK version matching your app (example uses JDK 11)
---

### ⚙️ Jenkins Parameters
| Param | Description |
|------|------------|
| ENVIRONMENT | dev / prod |
| ACTION | build / deploy |
| RECIPIENT_EMAIL | Email to receive alerts |
---

### 📨 Notification Environment Variables (Jenkins Credentials)
| Key | Description |
|----|-------------|
| GMAIL_USER | Gmail sender ID |
| GMAIL_APP_PASS | Gmail App Password |
---

### 🛠 Run Notification Script Manually (test)
```bash
GMAIL_USER="your@gmail.com" \
GMAIL_APP_PASS="xxxx" \
./jenkins_notify.sh SUCCESS sample-job 10 user@example.com
```
## Add Jenkins credential for DockerHub:
## Add Jenkins credential for Gmail:
- **Kind**: Username with password
- **Username**: your Gmail address
- **Password**: Gmail App Password
- **ID**: GMAIL_GMAILAUTH
---
## Project Photos
<img width="1883" height="910" alt="image" src="https://github.com/user-attachments/assets/f75261ce-188c-46b2-aacd-750dded38a83" />

<img width="1887" height="923" alt="image" src="https://github.com/user-attachments/assets/0dbad5da-201d-4359-bb84-ff91f673c4ef" />

<img width="1857" height="303" alt="image" src="https://github.com/user-attachments/assets/9d05a48d-8ee8-450e-950a-694e7780c2a5" />
