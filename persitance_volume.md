 1. Create Docker Networks

You need to create Docker networks for each group of containers to communicate with each other. Ensure that you create networks with unique names for each logical group:

```bash
sudo docker network create foradian-network
sudo docker network create capitalmind-network
sudo docker network create rao-network
```

 2. Run Docker Containers

Here are the corrected `docker run` commands:

- Foradian Container:

  ```bash
  sudo docker run -d --name foradian-pp-sp-container-1 \
    --network foradian-network \
    -p 9001:9001 \
    -p 9101:9101 \
    -e AWS_ACCESS_KEY_ID= \
    -e AWS_SECRET_ACCESS_KEY= \
    -e AWS_REGION=ap-south-1 \
    -v /opt/powerpipedata/capitalmind:/opt/powerpipedata/capitalmind \
    pp-sp-img
  ```

- Capitalmind Container:

  ```bash
  sudo docker run -d --name capitalmind-pp-sp-container-2 \
    --network capitalmind-network \
    -p 9011:9011 \
    -p 9111:9111 \
    -e AWS_ACCESS_KEY_ID=6 \
    -e AWS_SECRET_ACCESS_KEY= \
    -e AWS_REGION=ap-south-1 \
    -v /opt/powerpipedata/capitalmind:/opt/powerpipedata/capitalmind \
    pp-sp-img
  ```

- Rao Container:

  ```bash
  sudo docker run -d --name rao-pp-sp-container-3 \
    --network rao-network \
    -p 9021:9021 \
    -p 9121:9121 \
    -e AWS_ACCESS_KEY_ID=AK \
    -e AWS_SECRET_ACCESS_KEY=Dsyvw \
    -e AWS_REGION=us-east-1 \
    -v /opt/powerpipedata/capitalmind:/opt/powerpipedata/capitalmind \
    pp-sp-img
  ```

 3. Verify Running Containers

Use the following command to check that your containers are running:

```bash
docker ps
```

 4. Execute Commands Inside Containers

To execute commands inside the containers, use `docker exec`:

- Foradian Container:

  ```bash
  sudo docker exec -it foradian-pp-sp-container-1 /bin/bash
  ```

- Capitalmind Container:

  ```bash
  sudo docker exec -it capitalmind-pp-sp-container-2 /bin/bash
  ```

- Rao Container:

  ```bash
  sudo docker exec -it rao-pp-sp-container-3 /bin/bash
  ```

 5. Setup and Run Services

Inside each container, execute the following commands to set up and start the services:

```bash
powerpipe --version
steampipe --version
mkdir -p /home/powerpipe/mod
cd /home/powerpipe/mod
powerpipe mod init
powerpipe mod install github.com/turbot/steampipe-mod-aws-compliance
steampipe query "select  from aws_s3_bucket;"
```

Then start the services using `nohup`:

- Foradian Service:

  ```bash
  nohup steampipe service start --port 9001 > steampipe.log 2>&1 &
  nohup powerpipe server --port 9101 > powerpipe.log 2>&1 &
  ```

- Capitalmind Service:

  ```bash
  nohup steampipe service start --port 9011 > steampipe.log 2>&1 &
  nohup powerpipe server --port 9111 > powerpipe.log 2>&1 &
  ```

- Rao Service:

  ```bash
  nohup steampipe service start --port 9021 > steampipe.log 2>&1 &
  nohup powerpipe server --port 9121 > powerpipe.log 2>&1 &
  ```

 6. Testing from Hosted Machine

To test the services from the host machine, use the following URLs:

- Foradian Steampipe: `http://localhost:9001`
- Foradian Powerpipe: `http://localhost:9101`

- Capitalmind Steampipe: `http://localhost:9011`
- Capitalmind Powerpipe: `http://localhost:9111`

- Rao Steampipe: `http://localhost:9021`
- Rao Powerpipe: `http://localhost:9121`

Ensure you use the correct port numbers as assigned to each service.

 Summary

The key points include:
- Correctly specifying Docker network names and container configurations.
- Properly formatting and using environment variables.
- Ensuring ports are correctly mapped and used for testing.

To ensure that your log files (with `.log` extension) persist on the host machine even if the Docker container is stopped or deleted, you need to mount a volume that maps a directory on the host to the container's directory where the log files are stored. This way, any log files written inside the container will be saved directly on the host machine, and the data will persist across container restarts.

### Steps:
1. **Create a Host Directory for Logs**:
   Create a directory on the host machine where you want to store the log files. For example:
   ```bash
   sudo mkdir -p /opt/powerpipedata/capitalmind/logs
   sudo chmod 777 /opt/powerpipedata/capitalmind/logs
   ```

2. **Modify the Docker Run Command**:
   Update your Docker run command to mount the `/opt/powerpipedata/capitalmind/logs` directory from the host machine to the container's directory where the log files will be stored.

   Here's the updated Docker run command:
   ```bash
   sudo docker run -d --name rao-pp-sp-container-3 \
     --network rao-network \
     -p 9021:9021 \
     -p 9121:9121 \
     -e AWS_ACCESS_KEY_ID=I \
     -e AWS_SECRET_ACCESS_KEY= \
     -e AWS_REGION=us-east-1 \
     -v /opt/powerpipedata/capitalmind/logs:/opt/powerpipedata/capitalmind/logs \
     pp-sp-img
   ```

3. **Verify Data Persistence**:
   After starting the container, any `.log` files created in `/opt/powerpipedata/capitalmind/logs` inside the container will be stored on the host at `/opt/powerpipedata/capitalmind/logs`.

   To test, inside the container:
   ```bash
   powerpipe@container$ echo "Log data" > /opt/powerpipedata/capitalmind/logs/testlog.log
   powerpipe@container$ cat /opt/powerpipedata/capitalmind/logs/testlog.log
   ```

   Then, check on the host:
   ```bash
   cat /opt/powerpipedata/capitalmind/logs/testlog.log
   ```

4. **Handle Container Deletion**:
   Since the volume is mounted, even if you stop or delete the container, the log files stored in `/opt/powerpipedata/capitalmind/logs` on the host machine will persist. You can restart the container and continue accessing the logs.

This setup ensures that all files ending with `.log` inside the container are saved in the specified host directory.
