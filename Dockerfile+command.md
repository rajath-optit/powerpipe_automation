### **Setting Up AWS Credentials for Multiple Accounts**

To manage multiple AWS accounts, you'll need to configure separate credentials for each account in your AWS CLI configuration. Below are the steps to set up AWS credentials for two accounts (Account 1 and Account 2) and their respective regions.

#### **Step 1: Install AWS CLI**

First, ensure that the AWS CLI is installed on your system. If it's not installed, you can install it using the following commands:

**On Ubuntu/Linux:**

```bash
sudo apt-get update
sudo apt-get install awscli -y
```

**On macOS:**

```bash
brew install awscli
```

#### **Step 2: Configure AWS Credentials for Account 1**

1. **Run AWS Configure:**

   Use the following command to configure the AWS credentials for **Account 1**:

   ```bash
   aws configure --profile account1
   ```

2. **Provide the Required Information:**

   You'll be prompted to enter the following details:

   - **AWS Access Key ID**: Enter the Access Key ID for **Account 1**.
   - **AWS Secret Access Key**: Enter the Secret Access Key for **Account 1**.
   - **Default region name**: Specify the default region (e.g., `us-east-1`).
   - **Default output format**: You can choose `json`, `text`, or `table`. Typically, `json` is used.

   Example:

   ```bash
   AWS Access Key ID [None]: AKIAxxxxxxxxxxxxxxxx
   AWS Secret Access Key [None]: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   Default region name [None]: us-east-1
   Default output format [None]: json
   ```

#### **Step 3: Configure AWS Credentials for Account 2**

1. **Run AWS Configure for Account 2:**

   Repeat the configuration process for **Account 2**:

   ```bash
   aws configure --profile account2
   ```

2. **Provide the Required Information:**

   Enter the credentials and region information for **Account 2**:

   - **AWS Access Key ID**: Enter the Access Key ID for **Account 2**.
   - **AWS Secret Access Key**: Enter the Secret Access Key for **Account 2**.
   - **Default region name**: Specify the default region (e.g., `ap-south-1`).
   - **Default output format**: Choose `json` or your preferred format.

   Example:

   ```bash
   AWS Access Key ID [None]: Axxx
   AWS Secret Access Key [None]: xxxx
   Default region name [None]: ap-south-1
   Default output format [None]: json
   ```

#### **Step 4: Verify Configuration**

To ensure that your credentials are set up correctly, you can list the configured profiles using:

```bash
aws configure list-profiles
```

This command should display `account1` and `account2` as configured profiles.

#### **Step 5: Use AWS Profiles in Docker Commands**

When running your Docker containers, use the `AWS_PROFILE` environment variable to specify which account to use:

- **For AWS Account 1:**

  ```bash
  sudo docker run -d --name powerpipe_account1 \
    -p 9033:9033 \
    -p 9194:9194 \
    -p 9040:9040 \
    -v ~/.aws:/root/.aws \
    -e AWS_PROFILE=account1 \
    my-powerpipe-image
  ```

- **For AWS Account 2:**

  ```bash
  sudo docker run -d --name powerpipe_account2 \
    -p 9034:9034 \
    -p 9195:9195 \
    -p 9041:9041 \
    -v ~/.aws:/root/.aws \
    -e AWS_PROFILE=account2 \
    my-powerpipe-image
  ```

By setting up these profiles, you can easily switch between AWS accounts within your Docker containers, ensuring that each container uses the correct set of credentials and region settings.

### **Documentation: Multi-Account Setup with Powerpipe and Steampipe**

---

#### **Docker Setup for Powerpipe and Steampipe**

**Dockerfile:**

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
```

**Building the Docker Image:**

```bash
sudo docker build -t my-powerpipe-image .
```

**Running Containers for Different AWS Accounts:**

1. **For AWS Account 1:**
    ```bash
    sudo docker run -d --name powerpipe_account1 \
      -p 9033:9033 \
      -p 9194:9194 \
      -p 9040:9040 \
      -v ~/.aws:/root/.aws \
      -e AWS_PROFILE=account1 \
      my-powerpipe-image
    ```

    **Explanation:**
   - **9033:9033**: Port mapping for services running on port 9033 inside the container.
   - **9194:9194**: Port mapping for Steampipe (port 9194).
   - **9040:9040**: Port mapping for Powerpipe (port 9040).
   - **~/.aws:/root/.aws**: Mounts the AWS credentials file with the container.
   - **AWS_PROFILE=account1**: Specifies the AWS profile used inside the container.

2. **For AWS Account 2:**
    ```bash
    sudo docker run -d --name powerpipe_account2 \
      -p 9034:9034 \
      -p 9195:9195 \
      -p 9041:9041 \
      -v ~/.aws:/root/.aws \
      -e AWS_PROFILE=account2 \
      my-powerpipe-image
    ```

    **Explanation:**
   - **9034:9034**: Port mapping for services running on port 9034 inside the container.
   - **9195:9195**: Port mapping for Steampipe (port 9195).
   - **9041:9041**: Port mapping for Powerpipe (port 9041).
   - **~/.aws:/root/.aws**: Mounts the AWS credentials file with the container.
   - **AWS_PROFILE=account2**: Specifies the AWS profile used inside the container.

### **Step-by-Step Workflow for Multiple AWS Accounts Setup**

---

#### **Step 1: Start Services in AWS Account 1 Container**

1. **Access Account 1 container:**
   ```bash
   sudo docker exec -it powerpipe_account1 /bin/bash
   ```

2. **Start Steampipe service:**
   ```bash
   steampipe service start
   ```

3. **Run Powerpipe server on port 9040:**
   ```bash
   powerpipe server --port=9040
   ```

4. **Run Powerpipe server in background using `nohup`:**
   ```bash
   nohup powerpipe server --port=9040 &
   ```

---

#### **Step 2: Start Services in AWS Account 2 Container**

1. **Access Account 2 container:**
   ```bash
   sudo docker exec -it powerpipe_account2 /bin/bash
   ```

2. **Start Steampipe service:**
   ```bash
   steampipe service start
   ```

3. **Run Powerpipe server on port 9041:**
   ```bash
   powerpipe server --port=9041
   ```

4. **Run Powerpipe server in background using `nohup`:**
   ```bash
   nohup powerpipe server --port=9041 &
   ```

---

### **Verification and Troubleshooting**

1. **Check Services via Proxmox Browser:**
   - Attempt to access the Steampipe dashboard in your browser using the assigned ports (e.g., `http://<proxmox_ip>:9040` for Account 1).
   
2. **Encountering Network Issues:**
   - If the dashboard is inaccessible, the issue might be due to incorrect port mapping or network settings.
   
3. **Investigate Inside the Container:**
   - If the dashboard runs correctly inside the container, but not outside, it’s likely a networking issue.

4. **No Browser Inside the Container:**
   - Since containers typically don’t have browsers, direct dashboard access within containers isn’t feasible.

---

### **Automation with Ansible**

#### **Ansible Playbook for Container Setup**

- **Playbook Filename:** `setup_powerpipe_steampipe.yml`
  
```yaml
- name: Setup Powerpipe and Steampipe
  hosts: localhost
  tasks:
    - name: Create and start Docker container
      docker_container:
        name: "{{ container_name }}"
        image: my-powerpipe-image
        state: started
        published_ports:
          - "{{ steampipe_port }}:9194"
          - "{{ powerpipe_port }}:9040"
        volumes:
          - "~/.aws:/root/.aws"
        env:
          AWS_PROFILE: "{{ aws_profile }}"
    - name: Start Steampipe service
      shell: steampipe service start
      args:
        chdir: /home/powerpipe

    - name: Start Powerpipe server
      shell: powerpipe server --port="{{ powerpipe_port }}"
      args:
        chdir: /home/powerpipe
```

**Run Playbook for Account 1:**

```bash
ansible-playbook setup_powerpipe_steampipe.yml --extra-vars "steampipe_port=9194 powerpipe_port=9040 container_name=powerpipe_account1 aws_profile=account1"
```

**Run Playbook for Account 2:**

```bash
ansible-playbook setup_powerpipe_steampipe.yml --extra-vars "steampipe_port=9195 powerpipe_port=9041 container_name=powerpipe_account2 aws_profile=account2"
```

**Benefits:**
- **Automated Setup:** The entire setup process can be automated, reducing the need for manual intervention.
- **Consistent Deployment:** Ensures consistency across multiple accounts.

---

### **Next Steps**

1. **Create Additional Containers:**
   - Continue creating containers for more AWS accounts by assigning different ports.

   ```bash
   sudo docker run -d --name powerpipe_account3 \
     -p 9035:9035 \
     -p 9196:9196 \
     -p 9042:9042 \
     -v ~/.aws:/root/.aws \
     -e AWS_PROFILE=account3 \
     my-powerpipe-image
   ```

2. **Automate with Ansible:**
   - Use the provided Ansible playbooks to automate container setups, ensuring all accounts are deployed efficiently.

By using this structured approach, multiple AWS accounts are managed effectively on the same machine, with clear port configurations and automation through Ansible.
