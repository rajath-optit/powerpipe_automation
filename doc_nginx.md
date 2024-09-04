## **Docker Setup for Powerpipe and Steampipe**

### **1. Dockerfile Configuration**

The Dockerfile installs Powerpipe and Steampipe, along with necessary dependencies. Here's the Dockerfile:

```Dockerfile
FROM ubuntu:latest

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl tar && \
    groupadd -g 1001 powerpipe && \
    useradd -u 1001 --create-home --shell /bin/bash --gid powerpipe powerpipe

# Environment variables
ENV USER_NAME=powerpipe
ENV GROUP_NAME=powerpipe
ENV POWERPIPE_TELEMETRY=none

WORKDIR /home/$USER_NAME

# Install Powerpipe
RUN curl -LO https://github.com/turbot/powerpipe/releases/download/v0.3.1/powerpipe.linux.amd64.tar.gz && \
    tar xvzf powerpipe.linux.amd64.tar.gz && \
    mv powerpipe /usr/local/bin/powerpipe && \
    rm -rf powerpipe.linux.amd64.tar.gz

# Install Steampipe
RUN curl -LO https://steampipe.io/install/steampipe.sh && \
    sh steampipe.sh && \
    rm -f steampipe.sh

# Switch to the non-root user
USER powerpipe

# Install AWS plugin for Steampipe as the non-root user
RUN steampipe plugin install aws

# Default command to initialize Powerpipe and Steampipe, then start Powerpipe server
ENTRYPOINT ["/bin/bash", "-c", "mkdir -p /home/powerpipe/mod && cd /home/powerpipe/mod && powerpipe mod init && powerpipe mod install github.com/turbot/steampipe-mod-aws-compliance && steampipe service start && powerpipe server"]
```

### **2. Build Docker Image**
Build the Docker image with the following command:

```bash
docker build -t account1 .
```

### **3. Running Containers for Multiple AWS Accounts**

#### **Account 1 Setup**

1. **Create Docker Network:**
   ```bash
   sudo docker network create aws_account1_network
   ```

2. **Run the Container:**
   ```bash
   sudo docker run -d --name myaccontainer1 \
     --network aws_account1_network \
     -p 9033:9033 \
     -p 9194:9194 \
     -p 9040:9040 \
     -e AWS_ACCESS_KEY_ID=<Your AWS Access Key> \
     -e AWS_SECRET_ACCESS_KEY=<Your AWS Secret Key> \
     -e AWS_REGION=us-east-1 \
     account1
   ```

3. **Access the Container:**
   ```bash
   sudo docker exec -it myaccontainer1 /bin/bash
   ```

4. **Initialize and Start Services:**
   ```bash
   mkdir -p /home/powerpipe/mod
   cd /home/powerpipe/mod
   powerpipe mod init
   powerpipe mod install github.com/turbot/steampipe-mod-aws-compliance
   steampipe query "select * from aws_s3_bucket;"
   nohup steampipe service start --port 9194 > steampipe.log 2>&1 &
   nohup powerpipe server --port 9040 > powerpipe.log 2>&1 &
   ```

#### **Account 2 Setup**

1. **Create Docker Network:**
   ```bash
   sudo docker network create aws_account2_network
   ```

2. **Run the Container:**
   ```bash
   sudo docker run -d --name myaccontainer2 \
     --network aws_account2_network \
     -p 9195:9195 \
     -p 9041:9041 \
     -e AWS_ACCESS_KEY_ID=<Your AWS Access Key> \
     -e AWS_SECRET_ACCESS_KEY=<Your AWS Secret Key> \
     -e AWS_REGION=ap-south-1 \
     account1
   ```

3. **Access the Container:**
   ```bash
   sudo docker exec -it myaccontainer2 /bin/bash
   ```

4. **Initialize and Start Services:**
   ```bash
   mkdir -p /home/powerpipe/mod
   cd /home/powerpipe/mod
   powerpipe mod init
   powerpipe mod install github.com/turbot/steampipe-mod-aws-compliance
   steampipe query "select * from aws_s3_bucket;"
   nohup steampipe service start --port 9195 > steampipe.log 2>&1 &
   nohup powerpipe server --port 9041 > powerpipe.log 2>&1 &
   ```

### **4. Testing from the Hosted Machine**

- **Steampipe**: `http://localhost:<Mapped-Port>`
- **Powerpipe**: `http://localhost:9040` (or the port you assigned)

### **5. Additional Commands**

- **List open files on a specific port:**
  ```bash
  sudo lsof -i :9194
  ```

- **Kill a Process by PID:**
  ```bash
  sudo kill <PID>
  ```

- **Stop and Remove a Docker Container:**
  ```bash
  sudo docker stop myaccontainer1
  docker rm myaccontainer1
  ```

### **6. Regarding 93 Machine Check with Sankeerth**
- **Commands to Run:**
  - To list CPU details: `lscpu`
  - To check memory usage: `free -g`

- **Recommendation**: Suggest upgrading from 8 GB RAM to 16 GB RAM.
