This script automates the setup and running of a Docker container for AWS-based tools, Powerpipe and Steampipe, using provided AWS credentials and custom port settings. Here's a breakdown of what each part does:

### Parameters
The script accepts parameters for AWS credentials, region, and Docker configuration:
- `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`: Credentials for authenticating AWS API requests.
- `AWS_REGION`: The AWS region, with a default of `us-east-1`.
- `STEAMPIPE_PORT` and `POWERPIPE_PORT`: Custom ports for Steampipe and Powerpipe services (default: 9194 and 9040, respectively).
- `IMAGE_NAME`: Name of the Docker image (default: `pp-sp-img`).
- `DOCKER_NETWORK`: Docker network for container communication (default: `aws_default_network`).
- `CONTAINER_NAME_BASE`: Base name for Docker container (default: `default_container`).

### Function Descriptions

1. **check_aws_credentials()**
   - Verifies if the AWS credentials provided are valid using the AWS CLI (`aws sts get-caller-identity`). 
   - If the credentials are invalid, the script exits with an error.

2. **check_port_availability()**
   - Checks if the specified Steampipe and Powerpipe ports are available using `netstat`.
   - If any port is in use, the script exits with an error.

3. **create_docker_network()**
   - Checks if the specified Docker network exists. If not, it creates one using `docker network create`.
   - Ensures the container can communicate with other containers on the same network.

4. **run_docker_container()**
   - Loops through a naming scheme (`CONTAINER_NAME_BASE` with suffix `_1`, `_2`, `_3`) to find an available container name.
   - Runs the Docker container with the selected name, using the specified network and ports. 
   - Passes AWS credentials and region as environment variables into the container.

5. **initialize_and_install_modules()**
   - Inside the running container, this function sets up Powerpipe and installs the AWS compliance module from GitHub.
   - Runs a Steampipe query to verify the setup (`steampipe query "select * from aws_s3_bucket;"`).

6. **start_services()**
   - Starts the Steampipe and Powerpipe services inside the container in the background, using the specified ports.
   - Logs output to files (`steampipe.log` and `powerpipe.log`).

### Main Execution
The script runs in sequence:
1. Validates AWS credentials.
2. Ensures ports are available.
3. Creates the Docker network (if needed).
4. Starts the Docker container.
5. Initializes and installs Powerpipe modules.
6. Starts the services (Steampipe and Powerpipe) in the container.

This is a self-contained automation script to simplify running a Powerpipe/Steampipe environment for managing AWS resources inside Docker.

Here is the updated script with detailed comments explaining each section:

```bash
#!/bin/bash
 
# Parameters
AWS_ACCESS_KEY_ID="$1"                      # AWS Access Key ID provided as the first argument
AWS_SECRET_ACCESS_KEY="$2"                  # AWS Secret Access Key provided as the second argument
AWS_REGION="${3:-us-east-1}"                # AWS region with a default of 'us-east-1' if not specified
STEAMPIPE_PORT="${4:-9194}"                 # Steampipe service port, defaulting to 9194
POWERPIPE_PORT="${5:-9040}"                 # Powerpipe service port, defaulting to 9040
IMAGE_NAME="${6:-pp-sp-img}"                # Docker image name, defaulting to 'pp-sp-img'
DOCKER_NETWORK="${7:-aws_default_network}"  # Docker network name, defaulting to 'aws_default_network'
CONTAINER_NAME_BASE="${8:-default_container}" # Base name for the Docker container, defaulting to 'default_container'

# Function: Check AWS Credentials
check_aws_credentials() {
    echo "Checking AWS Credentials..."
    # Using AWS CLI to check if credentials are valid by getting the caller identity
    aws sts get-caller-identity --region "$AWS_REGION" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Invalid AWS Credentials"
        exit 1 # Exit if AWS credentials are invalid
    fi
    echo "AWS Credentials are valid."
}
 
# Function: Check Port Availability
check_port_availability() {
    echo "Checking Port Availability..."
    
    # Function to check if a port is available
    is_port_available() {
        local port=$1
        netstat -tuln | grep -q ":$port " >/dev/null 2>&1
        return $? # Returns 0 if port is in use, non-zero if available
    }
 
    # Check if the Steampipe port is available
    is_port_available "$STEAMPIPE_PORT"
    if [ $? -eq 0 ]; then
        echo "Port $STEAMPIPE_PORT is already in use."
        exit 1 # Exit if Steampipe port is already in use
    fi
 
    # Check if the Powerpipe port is available
    is_port_available "$POWERPIPE_PORT"
    if [ $? -eq 0 ]; then
        echo "Port $POWERPIPE_PORT is already in use."
        exit 1 # Exit if Powerpipe port is already in use
    fi
 
    echo "Both Steampipe Port ($STEAMPIPE_PORT) and Powerpipe Port ($POWERPIPE_PORT) are available."
}
 
# Function: Create Docker Network
create_docker_network() {
    echo "Checking Docker Network..."
    # Check if the Docker network exists using docker network ls
    network_exists=$(sudo docker network ls --filter name="$DOCKER_NETWORK" --format '{{.Name}}')
    if [ -z "$network_exists" ]; then
        # Create the Docker network if it doesn't exist
        sudo docker network create "$DOCKER_NETWORK"
        echo "Created Docker network: $DOCKER_NETWORK"
    else
        echo "Docker network already exists: $DOCKER_NETWORK"
    fi
}
 
# Function: Run Docker Container
run_docker_container() {
    echo "Running Docker Container..."
    
    # Loop through candidate container names (e.g., default_container_1, default_container_2, etc.)
    for i in 1 2 3; do
        candidate_name="${CONTAINER_NAME_BASE}_$i"
        # Check if the container with the candidate name already exists
        container_exists=$(sudo docker ps -a --filter name="$candidate_name" --format '{{.Names}}')
 
        if [ -z "$container_exists" ]; then
            container_name="$candidate_name"
            break # Select the first available container name
        fi
    done
 
    if [ -z "$container_name" ]; then
        # Exit if all three candidate container names are already in use
        echo "All containers (${CONTAINER_NAME_BASE}_1, ${CONTAINER_NAME_BASE}_2, ${CONTAINER_NAME_BASE}_3) are already in use."
        exit 1
    fi
 
    echo "Selected container name: $container_name"
 
    # Run the Docker container with the selected name and configured environment/ports
    sudo docker run -d --name "$container_name" \
        --network "$DOCKER_NETWORK" \
        -p "$STEAMPIPE_PORT":"$STEAMPIPE_PORT" \
        -p "$POWERPIPE_PORT":"$POWERPIPE_PORT" \
        -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
        -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
        -e AWS_REGION="$AWS_REGION" \
        "$IMAGE_NAME"
}
 
# Function: Initialize and Install Modules
initialize_and_install_modules() {
    echo "Initializing and Installing Modules..."
    
    # Execute commands inside the running Docker container to set up Powerpipe and Steampipe modules
    sudo docker exec -it "$container_name" /bin/bash -c '
        mkdir -p /home/powerpipe/mod && cd /home/powerpipe/mod &&
        powerpipe mod init && # Initialize Powerpipe module
        powerpipe mod install github.com/turbot/steampipe-mod-aws-compliance && # Install AWS compliance module
        steampipe query "select * from aws_s3_bucket;" # Query example to validate setup
    '
}
 
# Function: Start Services
start_services() {
    echo "Starting Steampipe and Powerpipe Services..."
    
    # Start Steampipe and Powerpipe services in the background using nohup
    sudo docker exec -d "$container_name" /bin/bash -c '
        nohup steampipe service start --port '"$STEAMPIPE_PORT"' > /home/powerpipe/steampipe.log 2>&1 & # Start Steampipe
        nohup powerpipe server --port '"$POWERPIPE_PORT"' > /home/powerpipe/powerpipe.log 2>&1 &  # Start Powerpipe
    '
}
 
# Main Script Execution
# 1. Check AWS credentials
check_aws_credentials

# 2. Check if the specified ports are available
check_port_availability

# 3. Ensure the Docker network exists
create_docker_network

# 4. Run the Docker container with the specified settings
run_docker_container

# 5. Initialize Powerpipe and install necessary modules
initialize_and_install_modules

# 6. Start the Steampipe and Powerpipe services in the container
start_services
```

### Script Overview with Comments
- **Parameters**: Inputs for AWS credentials, Docker settings, and service ports are taken via command-line arguments with defaults for some values.
- **AWS Credential Check**: The script validates the provided AWS credentials using the AWS CLI.
- **Port Availability Check**: Ensures that the specified ports are not already in use.
- **Docker Network Setup**: If the specified Docker network does not exist, it creates a new one.
- **Container Execution**: The script attempts to find an available container name (up to three possibilities) and runs the container using specified environment variables and ports.
- **Module Initialization**: Inside the container, the script installs Powerpipe and AWS Steampipe compliance modules, and runs a sample query to validate the setup.
- **Service Start**: Finally, it starts both Steampipe and Powerpipe services inside the container and logs their outputs.

This script can be run as:
```bash
./your-script.sh <AWS_ACCESS_KEY_ID> <AWS_SECRET_ACCESS_KEY> <AWS_REGION> <STEAMPIPE_PORT> <POWERPIPE_PORT> <IMAGE_NAME> <DOCKER_NETWORK> <CONTAINER_NAME_BASE>
```

The line `./pipeline.sh <AWS_ACCESS_KEY_ID> <AWS_SECRET_ACCESS_KEY> <AWS_REGION> <STEAMPIPE_PORT> <POWERPIPE_PORT> <IMAGE_NAME> <DOCKER_NETWORK> <CONTAINER_NAME>` indicates that the script is executed by passing specific arguments directly to the `pipeline.sh` script.

This would correspond to the parameters used in the script we just discussed. Here's how each argument maps to the script:

### Arguments:
1. **AWS_ACCESS_KEY_ID**: Your AWS Access Key ID (used for authenticating with AWS).
2. **AWS_SECRET_ACCESS_KEY**: Your AWS Secret Access Key (used for authentication).
3. **AWS_REGION**: The AWS region for your resources (e.g., `us-east-1`, `ap-south-1`).
4. **STEAMPIPE_PORT**: The port you want Steampipe to run on (default is 9194).
5. **POWERPIPE_PORT**: The port for Powerpipe to run on (default is 9040).
6. **IMAGE_NAME**: The name of the Docker image to use (default is `pp-sp-img`).
7. **DOCKER_NETWORK**: The name of the Docker network (default is `aws_default_network`).
8. **CONTAINER_NAME**: The base name for the container that will be created.

### Example Usage:

Suppose you want to run `pipeline.sh` with the following values:
- AWS Access Key ID: `AKIEXAMPLEKEY`
- AWS Secret Access Key: `EXAMPLESECRET`
- AWS Region: `us-west-2`
- Steampipe port: `9194`
- Powerpipe port: `9040`
- Docker image: `pp-sp-img`
- Docker network: `aws_network1`
- Container base name: `mycontainer`

The command would look like this:

```bash
./pipeline.sh AKIEXAMPLEKEY EXAMPLESECRET us-west-2 9194 9040 pp-sp-img aws_network1 mycontainer
```

This command will:
1. Check the AWS credentials for the specified region (`us-west-2`).
2. Ensure that ports 9194 (for Steampipe) and 9040 (for Powerpipe) are available.
3. Verify or create the Docker network (`aws_network1`).
4. Run the Docker container using the `pp-sp-img` Docker image, connecting it to the network and configuring it to run on the specified ports.
5. Start Steampipe and Powerpipe services inside the container.

The final parameter `<CONTAINER_NAME>` is used to name the Docker container (e.g., `mycontainer_1`, `mycontainer_2`, etc.). If the container with this base name already exists, the script will append a number to make it unique.


