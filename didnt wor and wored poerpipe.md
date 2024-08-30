didnt wor and wored poerpipe

To manage and switch between your AWS accounts on a Linux machine, you can store your AWS credentials in a file (like ~/.aws/credentials), and then create a Python script that allows you to switch between the accounts. 

  

Step 1: Store Your AWS Credentials 

First, make sure your AWS credentials are stored in ~/.aws/credentials like this: 

  

[acc1] 

aws_access_key_id = YOUR_ACCESS_KEY_ID_1 

aws_secret_access_key = YOUR_SECRET_ACCESS_KEY_1 

  

[acc2] 

aws_access_key_id = YOUR_ACCESS_KEY_ID_2 

aws_secret_access_key = YOUR_SECRET_ACCESS_KEY_2 

Update Your Configuration File 

Create a configuration file, for example, aws_config.ini: 

  

[aws_account1] 

region = us-east-1 

  

[aws_account2] 

region = ap-south-1 

  
 

Usage: 

Place the aws_config.ini file in the same directory as your script. 

Run the script using python3 switch_aws_account.py. 

Select the desired account, and the script will handle setting the region automatically. 

  

How It Works: 

Configuration File: The script reads the aws_config.ini file to get the region associated with each account. 

Automatic Region Setting: Once you select an account, the script automatically sets the appropriate region. 

  

switch_aws_account.py 

  

import os 

import subprocess 

import configparser 

  

# Define the AWS profile names 

profiles = { 

    '1': 'aws_account1', 

    '2': 'aws_account2' 

} 

  

# Load regions from the config file 

config = configparser.ConfigParser() 

config.read('aws_config.ini') 

  

def switch_account(): 

    print("Available AWS accounts:") 

    for key, value in profiles.items(): 

        print(f"{key}: {value}") 

  

    choice = input("Select the AWS account to activate (1 or 2): ").strip() 

  

    if choice in profiles: 

        selected_profile = profiles[choice] 

        os.environ['AWS_PROFILE'] = selected_profile 

         

        # Set region based on config file 

        region = config[selected_profile]['region'] 

        os.environ['AWS_DEFAULT_REGION'] = region 

         

        print(f"\033[92mAWS account {selected_profile} is now active.\033[0m") 

        print(f"\033[92mAWS region {region} is now set.\033[0m") 

    else: 

        print("\033[91mInvalid selection. Please choose 1 or 2.\033[0m") 

  

def run_command(): 

    while True: 

        command = input("\033[94mEnter a command (or 'exit' to quit): \033[0m").strip() 

  

        if command.lower() == 'exit': 

            break 

  

        result = subprocess.run(command, shell=True) 

        if result.returncode != 0: 

            print(f"\033[91mCommand failed with return code {result.returncode}.\033[0m") 

        else: 

            print(f"\033[92mCommand executed successfully.\033[0m") 

  

if __name__ == "__main__": 

    switch_account() 

    run_command() 

  

  

Example Scenarios: 

If You Selected aws_account1: 

  

After exiting the script, if you run a report generating tool or any AWS CLI command, it will use aws_account1 with the region us-east-1. 

If You Selected aws_account2: 

  

After exiting the script, any commands or tools will use aws_account2 with the region ap-south-1. 

 

 
 
 
if two simultaiousely added... does not work 
 

Docker approch and step that was followed 
 
This document outlines the installation of PowerPipe and Steampipe, as well as the creation and execution of Docker containers for these tools. 

  

--- 

  

# **Setting Up PowerPipe and Steampipe with Docker** 

  

## **1. Installing PowerPipe on Linux** 

  

### **Step 1: Install PowerPipe** 

Open your Linux shell and run the following command to install PowerPipe: 

  

```bash 

sudo /bin/sh -c "$(curl -fsSL https://powerpipe.io/install/powerpipe.sh)" 

``` 

  

### **Step 2: Install Steampipe** 

Next, install Steampipe by running: 

  

```bash 

sudo /bin/sh -c "$(curl -fsSL https://steampipe.io/install/steampipe.sh)" 

``` 

  

### **Step 3: Verify Installation** 

Check the installed version of Steampipe: 

  

```bash 

steampipe -v 

``` 

  

You should see an output like: 

  

```bash 

steampipe version 0.23.5 

``` 

  

### **Step 4: Install the AWS Plugin** 

To install the AWS plugin for Steampipe: 

  

```bash 

steampipe plugin install aws 

``` 

  

### **Step 5: Set Up PowerPipe Mod** 

Create a directory for dashboards and initialize the PowerPipe mod: 

  

```bash 

mkdir dashboards 

cd dashboards 

powerpipe mod init 

powerpipe mod install github.com/turbot/steampipe-mod-aws-compliance 

``` 

  

### **Step 6: Start Services** 

1. **Start Steampipe as a Data Source:** 

   ```bash 

   steampipe service start 

   ``` 

2. **Start the Dashboard Server:** 

   ```bash 

   powerpipe server 

   ``` 

  

### **Step 7: Access Dashboards** 

Once the server is running, browse and view your dashboards at: 

  

``` 

http://localhost:9033 

``` 

  

--- 

  

## **2. Setting Up Docker for PowerPipe and Steampipe** 

  

### **Step 1: Create Dockerfile** 

  

Create a `Dockerfile` in your working directory with the following content: 

  

```Dockerfile 

FROM ubuntu:latest 

  

# Install required packages including curl and tar 

RUN apt-get update && \ 

    apt-get install -y curl tar && \ 

    groupadd -g 1001 powerpipe && \ 

    useradd -u 1001 --create-home --shell /bin/bash --gid powerpipe powerpipe 

  

# Set environment variables 

ENV USER_NAME=powerpipe 

ENV GROUP_NAME=powerpipe 

ENV POWERPIPE_TELEMETRY=none 

  

WORKDIR /home/$USER_NAME/mod 

  

# Download and install PowerPipe 

RUN curl -LO https://github.com/turbot/powerpipe/releases/download/v0.3.1/powerpipe.linux.amd64.tar.gz \ 

  && tar xvzf powerpipe.linux.amd64.tar.gz \ 

  && mv powerpipe /usr/local/bin/powerpipe \ 

  && rm -rf powerpipe.linux.amd64.tar.gz 

  

# Copy mod.pp file to the container and set permissions 

COPY mod.pp /home/${USER_NAME}/mod/mod.pp 

RUN chown -R ${USER_NAME}:${GROUP_NAME} /home/${USER_NAME}/mod 

  

# Run as unprivileged user 

USER $USER_NAME 

ENV USER=$USER_NAME 

RUN powerpipe mod install /home/${USER_NAME}/mod/mod.pp 

  

# Copy and set up entrypoint 

COPY entrypoint.sh /entrypoint.sh 

ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ] 

``` 

  

### **Step 2: Create Entrypoint Script** 

  

Create an `entrypoint.sh` file with the following content: 

  

```bash 

#!/usr/bin/env bash 

set -Eeo pipefail 

# copy bundled files to writeable location 

SRC_DIR="$HOME/.powerpipe" 

RUN_DIR="$HOME/run/.powerpipe" 

POWERPIPE_INSTALL_DIR="${RUN_DIR}" 

mkdir -p "${HOME}/run" 

cp -a "${SRC_DIR}" "${RUN_DIR}" 

exec "$@" 

``` 

  

### **Step 3: Build the Docker Image** 

  

Build the Docker image using the following command: 

  

```bash 

docker build -t my-powerpipe-image . 

``` 

  

### **Step 4: Run the Docker Container** 

  

Run the Docker container: 

  

```bash 

docker run --name my-powerpipe-container -d my-powerpipe-image 

``` 

  

### **Step 5: Running Steampipe in Docker** 

  

To pull and run Steampipe as a Docker container: 

  

```bash 

docker pull turbot/steampipe 

  

docker run --name my-steampipe-container \ 

  -e AWS_ACCESS_KEY_ID=your-access-key-id \ 

  -e AWS_SECRET_ACCESS_KEY=your-secret-access-key \ 

  -p 9194:9194 \ 

  -d turbot/steampipe 

``` 

  

### **Step 6: Accessing the Dockerized Services** 

  

- **Steampipe**: Access Steampipe by connecting to the mapped port (e.g., `http://localhost:9194`). 

- **PowerPipe**: You can access the PowerPipe dashboard server at `http://localhost:9033`. 

 Outcome 
 

Power Pipe and Steampipe with workspace:(Multi account on single server) 

================================================================== 

 
 
Approachable solution: 

Solution 1 : 
 
Setting Up and Using Multipass 

  

Multipass is a lightweight VM manager that simplifies the creation and management of Ubuntu virtual machines (VMs). This guide will walk you through the installation process, launching VMs, and accessing them via SSH. 

  

Installation 

  

Multipass can be installed on various operating systems. Below are the installation instructions for Linux, macOS, and Windows. 

  

Linux Installation 

For Linux, Multipass can be installed using Snap: 

```bash 

sudo snap install multipass 

``` 

> Note: Ensure Snap is installed on your Linux distribution. If not, you can install it using your distribution’s package manager. 

  

macOS Installation 

On macOS, Multipass can be installed via Homebrew: 

```bash 

brew install --cask multipass 

``` 

> Note: If Homebrew is not installed, follow the instructions on [Homebrew’s official website](https://brew.sh) to install it. 

  

Windows Installation 

For Windows, download and install Multipass from the official [Multipass website](https://multipass.run/download/windows). 

  

Getting Started with Multipass 

  

Once installed, you can start using Multipass to create and manage Ubuntu VMs. 

  

1. Launching a VM 

  

To create and start a new Ubuntu VM, use the following command: 

```bash 

multipass launch --name my-vm 

``` 

This command will: 

- Download the latest Ubuntu cloud image. 

- Create a VM named `my-vm`. 

- Start the VM. 

  

2. Listing All VMs 

  

To see all running and stopped VMs, use: 

```bash 

multipass list 

``` 

This will display a list of all instances, along with their names, states, and IP addresses. 

  

3. Accessing a VM via Shell 

  

To log into your VM and access its shell, run: 

```bash 

multipass shell my-vm 

``` 

This command will open a terminal session inside the VM, allowing you to interact with it as if you were directly logged into a physical machine. 

  

4. Stopping a VM 

  

If you want to stop a running VM, use: 

```bash 

multipass stop my-vm 

``` 

This will stop the `my-vm` instance, freeing up system resources. 

  

5. Deleting a VM 

  

To delete a VM (after stopping it), run: 

```bash 

multipass delete my-vm 

``` 

To permanently remove all deleted instances and reclaim disk space: 

```bash 

multipass purge 

``` 

> Warning: The `purge` command will permanently delete the data from the deleted VMs. 

  

Accessing Multipass VM via SSH 

  

By default, Multipass provides SSH access to the VM without requiring any additional configuration. 

  

1. Finding the VM's IP Address 

  

First, you need to find the IP address of your VM: 

```bash 

multipass list 

``` 

The IP address will be displayed in the output. 

  

2. Connecting via SSH 

  

Use the following command to connect to the VM via SSH: 

```bash 

ssh ubuntu@<VM_IP_ADDRESS> 

``` 

For example, if the VM’s IP address is `192.168.64.3`: 

```bash 

ssh ubuntu@192.168.64.3 

``` 

> Note: The default username for Multipass VMs is `ubuntu`. 

  

3. Copying SSH Keys 

  

For passwordless SSH access, copy your SSH public key to the VM: 

```bash 

ssh-copy-id ubuntu@<VM_IP_ADDRESS> 

``` 

This will add your SSH public key to the `~/.ssh/authorized_keys` file on the VM, allowing you to log in without a password. 

  

Additional Multipass Commands 

  

Mounting a Local Directory 

You can mount a local directory inside the VM: 

```bash 

multipass mount /path/to/local/dir my-vm:/path/in/vm 

``` 

  

Unmounting a Directory 

To unmount a directory from the VM: 

```bash 

multipass unmount my-vm 

``` 

  

--- 

  

Example Workflow 

  

Here’s a quick example workflow for setting up and managing a VM: 

  

1. Launch a VM: 

   ```bash 

   multipass launch --name dev-vm 

   ``` 

2. Access the VM via shell: 

   ```bash 

   multipass shell dev-vm 

   ``` 

3. Stop the VM: 

   ```bash 

   multipass stop dev-vm 

   ``` 

4. Delete the VM: 

   ```bash 

   multipass delete dev-vm 

   multipass purge 

   ``` 

  

This guide should help you get started with Multipass, whether you’re setting up a quick development environment or managing multiple Ubuntu VMs. 
 
 
approched solution while experimenting 
 

Approach1 

Steps to configure Multiple AWs  account by using  Workspace 

First  Login to  abc su abc It will ask password  Please provide correct password to continue. 

Create folder  with any name  

Cd to newly created folder  

PowerPipe: and Steampipe 

====================== 

Execute this command sudo /bin/sh -c "$(curl -fsSL https://powerpipe.io/install/powerpipe.sh)" 

powerpipe –v 

sudo /bin/sh -c "$(curl -fsSL https://steampipe.io/install/steampipe.sh)" 

steampipe plugin install aws 

mkdir learn_powerpipe 

Cd learn_powerpipe 

powerpipe mod init 

powerpipe mod install github.com/turbot/steampipe-mod-aws-insights 

cd ~/.steampipe/config 
steampipe plugin install aws 

nano ~/.steampipe/config/workspaces.spc  

export AWS_PROFILE=account1 

steampipe service start --dashboard --dashboard-port 9194 

git clone https://github.com/turbot/steampipe-mod-aws-insights.git 

cd steampipe-mod-aws-insights 

steampipe service start --dashboard --dashboard-port 9194 

powerpipe server ( It will start with default server , Use the default port (e.g., 9033) for the first dashboard. )  

Powerpipe start with with different port ( Example: powerpipe server --port 9033) 

Note: 

Separate Directories offer better isolation, easier management, and clearer separation between different account configurations. 

Single Directory might be simpler initially but can become cumbersome and error-prone as the number of accounts or configurations increases. 

 

Approach2: 

 

So, we need to use Seperate Directories, please find below structure 

/. steampipe/config$ tree account1 account2 

account1 

├── dashboard.sp 

├── mod.sp 

└── queries.sp 

account2 

├── dashboard.sp 

├── mod.sp 

└── queries.sp 

Once you created the above structure and update the file content also once it is done    you need to create any dir  as below example  

 

 

/.steampipe/config/account1$ ls 

dashboard.sp   

mod.sp  

 Queries.sp 

 

 

-LT-218:~/.steampipe/config/account1$ cat dashboard.sp 

dashboard "account1_dashboard" { 

  title = "Account1 Dashboard" 

  

  chart { 

    type = "donut" 

    width = 4 

    title = "EC2 Instances by Region" 

    sql = "SELECT region, COUNT() FROM aws_ec2_instance GROUP BY region" 

  } 

  

  chart { 

    type = "donut" 

    width = 4 

    title = "EC2 Instances by Instance Type" 

    sql = "SELECT instance_type, COUNT() FROM aws_ec2_instance GROUP BY instance_type" 

  } 

  

  chart { 

    type = "donut" 

    width = 4 

    title = "EC2 Instances by State" 

    sql = "SELECT instance_state, COUNT() FROM aws_ec2_instance GROUP BY instance_state" 

  } 

} 

-LT-218:~/.steampipe/config/account1$ cat mod.sp 

mod "aws" { 

  version = "0.144.0" 

} 

-LT-218:~/.steampipe/config/account1$ cat queries.sp 

query "account1_queries" { 

  title = "Account1 Queries" 

   Add your queries here 

} 

-LT-218:~/.steampipe/config/account2$ 

 

 

 

 

/.steampipe/config/account2$ cat dashboard.sp 

dashboard "account2_dashboard" { 

  title = "Account2 Dashboard" 

  

  chart { 

    type = "donut" 

    width = 4 

    title = "EC2 Instances by Region" 

    sql = "SELECT region, COUNT() FROM aws_ec2_instance GROUP BY region" 

  } 

  

  chart { 

    type = "donut" 

    width = 4 

    title = "EC2 Instances by Instance Type" 

    sql = "SELECT instance_type, COUNT() FROM aws_ec2_instance GROUP BY instance_type" 

  } 

  

  chart { 

    type = "donut" 

    width = 4 

    title = "EC2 Instances by State" 

    sql = "SELECT instance_state, COUNT() FROM aws_ec2_instance GROUP BY instance_state" 

  } 

} 

-LT-218:~/.steampipe/config/account2$ cat mod.sp 

mod "aws" { 

  version = "0.144.0" 

} 

-LT-218:~/.steampipe/config/account2$ cat queries.sp 

query "account2_queries" { 

  title = "Account2 Queries" 

   Add your queries here 

} 

 

In this path /home/user have created  AwsAccount1 Folder 

cd AwsAccount1 

 

As above  steps  same  

Execute this command sudo /bin/sh -c "$(curl -fsSL https://powerpipe.io/install/powerpipe.sh)" 

powerpipe –v 

sudo /bin/sh -c "$(curl -fsSL https://steampipe.io/install/steampipe.sh)" 

steampipe plugin install aws 

mkdir learn_powerpipe 

Cd learn_powerpipe 

powerpipe mod init 

powerpipe mod install github.com/turbot/steampipe-mod-aws-insights 

 Then update  

 

export AWS_PROFILE=account1 

export STEAMPIPE_CONFIG_PATH=~/.steampipe/config/account1 

steampipe service start --dashboard --dashboard-port 9194 

powerpipe server --port 9033 
or 
for backgroud run  
[nohup powerpipe server --port 9053 > powerpipe.log 2>&1 &] 

 
-To stop background run 
pgrep powerpipe 
kill [49980] 

Same Process create another folder Example AwsAccount2 repeat all the steps same as above  

 While starting steampipe service we need to specify  the  dashboard by default it will check in this folder /.steampipe 

 

export AWS_PROFILE=account2 

export STEAMPIPE_CONFIG_PATH=~/.steampipe/config/account2 

steampipe service start --dashboard --dashboard-port 9195 

powerpipe server --port 9034 

 
Approach3: 

 

Aggregators 
 
To manage multiple accounts with a single user using Steampipe and PowerPipe, you can leverage Steampipe's `steampipe` CLI and PowerPipe’s API capabilities effectively. Here’s a guide to using an aggregator approach with Steampipe and PowerPipe: 

  

 Steampipe Configuration 

  

1. Install Steampipe: 

   Ensure you have Steampipe installed. You can download it from the [Steampipe website](https://steampipe.io/downloads). 

  

2. Configure Steampipe: 

   You need to configure your `steampipe` CLI with the necessary plugins for the accounts you wish to manage. 

  

   For example, to configure AWS accounts, you might use: 

   ```bash 

   steampipe plugin install aws 

   ``` 

  

   Then, set up your AWS configuration in `~/.steampipe/config/aws.spc`: 

   ```hcl 

   connection "aws" { 

     plugin = "aws" 

     profile = "default" 

     region  = "us-west-2" 

   } 

   ``` 

  

   You can add multiple profiles or use environment variables to manage different accounts: 

   ```bash 

   export AWS_PROFILE=account1 

   steampipe query 'SELECT  FROM aws_iam_role' 

   ``` 

  

3. Use Aggregator Queries: 

   Steampipe allows you to run queries across different configurations. For example, you can query all your accounts using SQL-like syntax: 

   ```sql 

   SELECT  FROM aws_s3_bucket WHERE region = 'us-west-2' 

   ``` 

  

 PowerPipe Configuration 

  

1. Install PowerPipe: 

   Ensure you have PowerPipe installed and configured. You can follow the instructions on the [PowerPipe GitHub page](https://github.com/torbot/powerpipe). 

  

2. API Integration: 

   Use PowerPipe’s API to aggregate data across different accounts. You’ll need to configure API tokens or other authentication mechanisms as needed. 

  

3. Using the API: 

   To interact with PowerPipe, use API endpoints to fetch data from multiple accounts. For example: 

   ```bash 

   curl -X GET "https://api.powerpipe.io/v1/accounts" -H "Authorization: Bearer YOUR_API_TOKEN" 

   ``` 

  

   This will allow you to retrieve and manage data from various accounts through a single API endpoint. 

  

4. Example Integration: 

   You can write scripts or use tools to interact with both Steampipe and PowerPipe, aggregating data as needed. For example, use Python scripts to interact with the APIs: 

   ```python 

   import requests 

  

    Fetch data from PowerPipe 

   response = requests.get("https://api.powerpipe.io/v1/accounts", headers={"Authorization": "Bearer YOUR_API_TOKEN"}) 

   data = response.json() 

  

    Use Steampipe for additional querying 

   import subprocess 

   result = subprocess.run(['steampipe', 'query', 'SELECT  FROM aws_iam_role'], capture_output=True) 

   print(result.stdout.decode()) 

   ``` 

  

By following these steps, you can effectively use Steampipe and PowerPipe to aggregate and manage data across multiple accounts with a single user setup. This approach allows for flexible querying and integration, enabling you to handle various accounts efficiently. 
 
Approach 4: 

 
user 
To switch between multiple AWS accounts in parallel, you can use the following methods depending on your workflow: 

  

 1. AWS CLI Profiles 

   - Set Up Multiple Profiles: 

     If you haven't already set up multiple profiles, you can do so by configuring them with the AWS CLI: 

  

     ```bash 

     aws configure --profile profile1 

     aws configure --profile profile2 

     ``` 

  

     Replace `profile1` and `profile2` with meaningful names for your AWS accounts. 

  

   - Switching Between Profiles: 

     To switch between AWS accounts in the CLI, you can use the `--profile` flag: 

  

     ```bash 

     aws s3 ls --profile profile1 

     aws s3 ls --profile profile2 

     ``` 

  

   - Setting a Default Profile Temporarily: 

     You can also set a default profile for a single terminal session: 

  

     ```bash 

     export AWS_PROFILE=profile1 

     aws s3 ls   This will use profile1 

      

     export AWS_PROFILE=profile2 

     aws s3 ls   This will use profile2 

     ``` 

  

 2. Assume Role (For Cross-Account Access) 

   - If you need to switch roles between accounts, you can assume a role in the second account: 

  

     ```bash 

     aws sts assume-role --role-arn arn:aws:iam::<second-account-id>:role/<role-name> --role-session-name session1 --profile profile1 

     ``` 

  

     This command will return temporary security credentials which you can use to interact with the second account. 

  

 3. Using AWS IAM Identity Center (formerly AWS SSO) 

   - If you're using AWS IAM Identity Center, you can switch between AWS accounts through the AWS Console or AWS CLI using SSO. 

  

   - Log In to a Different Account via CLI: 

     ```bash 

     aws sso login --profile profile1 

     aws sso login --profile profile2 

     ``` 

  

     You can then run AWS CLI commands with the appropriate profile. 

  

 4. AWS Management Console (Browser) 

   - Use multiple browsers or browser profiles to log in to different AWS accounts simultaneously. 

  

   - You can also use the AWS Console’s role-switching feature to switch between accounts easily if roles are set up correctly. 

  

 5. Use AWS Vault (for secure access) 

   - AWS Vault is a tool that securely stores and accesses AWS credentials. You can create and use multiple profiles securely: 

  

     ```bash 

     aws-vault exec profile1 -- aws s3 ls 

     aws-vault exec profile2 -- aws s3 ls 

     ``` 

  

This approach allows you to manage multiple AWS accounts easily and switch between them as needed. 

To switch to the second AWS account from the first account, assuming you have set up multiple profiles, you can temporarily change the active profile in your current terminal session. 

  

Here’s how you can do it: 

  

 1. Switch Using the AWS CLI Profile 

   If you want to run a command with the second account, specify the profile directly with the `--profile` option: 

  

   ```bash 

   aws s3 ls --profile profile2 

   ``` 

  

   This command will list S3 buckets in the second account. 

  

 2. Change the Active Profile Temporarily 

   If you want to switch the active profile for the entire terminal session: 

  

   ```bash 

   export AWS_PROFILE=profile2 

   ``` 

  

   Now, any AWS CLI command you run in this session will use the second account: 

  

   ```bash 

   aws s3 ls 

   ``` 

  

 3. Verify the Active Account 

   To confirm that the correct profile (and thus the correct AWS account) is active, you can check the current caller identity: 

  

   ```bash 

   aws sts get-caller-identity 

   ``` 

  

   This will return the account ID, user, or role ARN, which should correspond to the second account. 

  

By exporting the `AWS_PROFILE` environment variable or using the `--profile` flag, you effectively switch to the second AWS account. 

  

Here's a detailed step-by-step guide on how to set up and configure AWS profiles for two users on the same Linux VM, specifically on Ubuntu. Each command necessary to complete the setup is provided. 

  

 Step 1: Create Two Users on the Same Linux VM 

  

First, create two separate users on your Ubuntu VM. This can be done using the `adduser` command. 

  

1. Create user1: 

    ```bash 

    sudo adduser user1 

    ``` 

   Follow the prompts to set a password and other details for `user1`. 

  

2. Create user2: 

    ```bash 

    sudo adduser user2 

    ``` 

   Similarly, follow the prompts to set up `user2`. 

  

 Step 2: Configure AWS Profiles for Each User 

  

Each user will have their own home directory, so AWS CLI configurations will be independent. 

  

 For user1: 

  

1. Switch to `user1`: 

    ```bash 

    su - user1 

    ``` 

  

2. Install AWS CLI (if not already installed): 

    ```bash 

    sudo apt update 

    sudo apt install awscli -y 

    ``` 

  

3. Configure AWS CLI for `user1`: 

    ```bash 

    aws configure --profile account1 

    ``` 

   You'll be prompted to enter: 

   - AWS Access Key ID 

   - AWS Secret Access Key 

   - Default region name (e.g., `us-west-2`) 

   - Default output format (e.g., `json`) 

  

   This creates the AWS credentials and config files in `/home/user1/.aws/credentials` and `/home/user1/.aws/config`. 

  

4. Export the Profile for `user1`: 

    ```bash 

    export AWS_PROFILE=account1 

    ``` 

  

 For user2: 

  

1. Switch to `user2`: 

    ```bash 

    su - user2 

    ``` 

  

2. Install AWS CLI (if not already installed): 

    ```bash 

    sudo apt update 

    sudo apt install awscli -y 

    ``` 

  

3. Configure AWS CLI for `user2`: 

    ```bash 

    aws configure --profile account2 

    ``` 

   You'll be prompted to enter: 

   - AWS Access Key ID 

   - AWS Secret Access Key 

   - Default region name (e.g., `us-west-2`) 

   - Default output format (e.g., `json`) 

  

   This creates the AWS credentials and config files in `/home/user2/.aws/credentials` and `/home/user2/.aws/config`. 

  

4. Export the Profile for `user2`: 

    ```bash 

    export AWS_PROFILE=account2 

    ``` 

  

 Step 3: Using the Profiles 

  

Now each user can use their specific AWS profile to interact with AWS services. 

  

- For `user1`: 

    ```bash 

    aws s3 ls --profile account1 

    ``` 

  

- For `user2`: 

    ```bash 

    aws s3 ls --profile account2 

    ``` 

  

 Step 4: Maintaining Separate Environments 

  

The environment variables are independent for each user. If `user1` exports `AWS_PROFILE=account1`, it will only affect `user1`'s session. 

  

- Set the AWS profile for `user1`: 

    ```bash 

    export AWS_PROFILE=account1 

    ``` 

  

- Set the AWS profile for `user2`: 

    ```bash 

    export AWS_PROFILE=account2 

    ``` 

  

 Step 5: Switching Between Users 

  

You can switch between the users using the `su` command. 

  

- Switch to `user1`: 

    ```bash 

    su - user1 

    ``` 

  

- Switch to `user2`: 

    ```bash 

    su - user2 

    ``` 

  

 Step 6: Persistent Configuration 

  

To automatically set the AWS profile when each user logs in, add the export command to their `.bashrc` file. 

  

 For `user1`: 

  

1. Add the export command to `.bashrc`: 

    ```bash 

    echo 'export AWS_PROFILE=account1' >> ~/.bashrc 

    ``` 

  

2. Reload `.bashrc`: 

    ```bash 

    source ~/.bashrc 

    ``` 

  

 For `user2`: 

  

1. Add the export command to `.bashrc`: 

    ```bash 

    echo 'export AWS_PROFILE=account2' >> ~/.bashrc 

    ``` 

  

2. Reload `.bashrc`: 

    ```bash 

    source ~/.bashrc 

    ``` 

  

 Summary of Commands 

  

Here’s a summary of all the commands you’ll need: 

  

```bash 

 Create users 

sudo adduser user1 

sudo adduser user2 

  

 Switch to user1 

su - user1 

  

 Install AWS CLI (if needed) 

sudo apt update 

sudo apt install awscli -y 

  

 Configure AWS for user1 

aws configure --profile account1 

export AWS_PROFILE=account1 

echo 'export AWS_PROFILE=account1' >> ~/.bashrc 

source ~/.bashrc 

  

 Switch to user2 

su - user2 

  

 Install AWS CLI (if needed) 

sudo apt update 

sudo apt install awscli -y 

  

 Configure AWS for user2 

aws configure --profile account2 

export AWS_PROFILE=account2 

echo 'export AWS_PROFILE=account2' >> ~/.bashrc 

source ~/.bashrc 

``` 

  

Each user is now set up to manage their AWS accounts independently. 
 
 
outcome of experiment. 

The challenges we've encountered with PowerPipe's multi-account setup, particularly the issues caused by port configuration changes that have consistently led to account overlapping. This problem arises when using PowerPipe with multiple accounts from the same cloud provider. Despite following all the recommended steps in the documentation, experimenting thoroughly, and seeking suggestions from the PowerPipe team on Slack, we've observed that the current solution does not reliably support a two-account configuration, even after adjusting the port settings. 

 image 

Key Findings: 

One critical finding is that while a single machine can handle one AWS, one GCP, and one Azure account simultaneously, it cannot effectively manage two accounts from the same provider (e.g., two AWS accounts). When attempting this, we encountered overlapping issues where the generated report only reflects data from one of the accounts, rather than both. 

  

Separate Dashboards: During our experiments, we found a way to create separate dashboards for each module, which helped avoid overlapping reports. We did this by creating two users, installing the modules separately for each, and running the powerpipe server command with a different port for each user. This allowed us to generate reports for each module separately without any overlap. 

  

Best practice/recommandation 

Given these consistent issues, we can suggest that it may be more effective to maintain separate instances of PowerPipe for each account. This approach could provide more stability and reduce the risk of cross-account configuration conflicts, ensuring that each instance operates independently without the problems we've experienced with the current multi-account setup. 

  

This recommendation is based on our extensive testing and experimentation, and we believe it will lead to a more reliable and manageable solution for all teams using PowerPipe. 

Finally, we should present a detailed report of our findings to substantiate our recommendation and provide a clear path forward. 

 
