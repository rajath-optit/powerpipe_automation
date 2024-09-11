# service
ec2

aws_ec2_ami
aws_ec2_ami_shared
aws_ec2_application_load_balancer
aws_ec2_application_load_balancer_metric_request_count
aws_ec2_application_load_balancer_metric_request_count_daily
aws_ec2_autoscaling_group
aws_ec2_capacity_reservation
aws_ec2_classic_load_balancer
aws_ec2_client_vpn_endpoint
aws_ec2_gateway_load_balancer
aws_ec2_instance
aws_ec2_instance_availability
aws_ec2_instance_metric_cpu_utilization
aws_ec2_instance_metric_cpu_utilization_daily
aws_ec2_instance_metric_cpu_utilization_hourly
aws_ec2_instance_type
aws_ec2_key_pair
aws_ec2_launch_configuration
aws_ec2_launch_template
aws_ec2_launch_template_version
aws_ec2_load_balancer_listener
aws_ec2_load_balancer_listener_rule
aws_ec2_managed_prefix_list
aws_ec2_managed_prefix_list_entry
aws_ec2_network_interface
aws_ec2_network_load_balancer
aws_ec2_network_load_balancer_metric_net_flow_count
aws_ec2_network_load_balancer_metric_net_flow_count_daily
aws_ec2_regional_settings
aws_ec2_reserved_instance
aws_ec2_spot_price
aws_ec2_ssl_policy
aws_ec2_target_group
aws_ec2_transit_gateway
aws_ec2_transit_gateway_route
aws_ec2_transit_gateway_route_table
aws_ec2_transit_gateway_vpc_attachment

s3
aws_s3_access_point
aws_s3_account_settings
aws_s3_bucket
aws_s3_bucket_intelligent_tiering_configuration
aws_s3_multi_region_access_point
aws_s3_object
aws_s3_object_version

cloudwatch
aws_cloudwatch_alarm
aws_cloudwatch_log_event
aws_cloudwatch_log_group
aws_cloudwatch_log_metric_filter
aws_cloudwatch_log_resource_policy
aws_cloudwatch_log_stream
aws_cloudwatch_log_subscription_filter
aws_cloudwatch_metric
aws_cloudwatch_metric_data_point
aws_cloudwatch_metric_statistic_data_point

cloud triel
aws_cloudtrail_channel
aws_cloudtrail_event_data_store
aws_cloudtrail_import
aws_cloudtrail_lookup_event
aws_cloudtrail_query
aws_cloudtrail_trail
aws_cloudtrail_trail_event


# step
steampipe check list
steampipe mod install github.com/turbot/steampipe-mod-aws-compliance
 
ls #you should look for mod.sp
git clone https://github.com/turbot/steampipe-mod-aws-compliance
cd steampipe-mod-aws-compliance
 
 
steampipe query --var=instance_state="running"
steampipe check all --output=brief
 
powerpipe benchmark run aws_compliance.benchmark.soc_2
 
steampipe check benchmark.cis_v130 --tag cis_level=1 --dry-run
  steampipe check all --where "severity in ('critical', 'high') and tags ->> 'pci' = 'true'" #can use tag given in document so get detailed report
  steampipe check all --where "severity in ('critical', 'high') 
  steampipe check all --where "severity in ('critical', 'high')" --output=html #to get output in html formate
steampipe check all --where "severity in ('critical', 'high')" --export=html #to download output in html formate
 
 
steampipe check all --where "severity in ('critical', 'high','midium')" #this command only work if there's


![5b07723e-d70d-4575-983e-7282c7b17611](https://github.com/user-attachments/assets/1b55aa57-833e-4085-8c93-d4e74113878b)

![cf83ed1f-56ee-4940-93ae-9eaabde35ba8](https://github.com/user-attachments/assets/070c0d99-84df-475c-9c9f-08213a78b466)


![74fa0884-2ce9-4658-93ae-c08fe3d77849](https://github.com/user-attachments/assets/b48a8d38-87aa-47c0-91c3-b9372de079aa)

