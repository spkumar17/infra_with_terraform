module "VPC" {
    source = "./Module/VPC"
    region = "us-east-1"

    vpc_cidr_block = "10.0.0.0/16"

    pubsub1a_cidr_block="10.0.1.0/24"

    pubsub1b_cidr_block="10.0.2.0/24"

    project_name="3tierDeployment"

    prisub1a_cidr_block="10.0.3.0/24"
    prisub1b_cidr_block="10.0.4.0/24"
    secsub1a_cidr_block ="10.0.5.0/24"
    secsub1b_cidr_block="10.0.6.0/24"
    #ssm_endpoint_sg_id=module.Resources.ssm_endpoint_sg_id


}

module "Resources" {
    source = "./Module/Resources"
    vpc_id        = module.VPC.vpc_id
}

module "ALB" {
    source = "./Module/ALB"
    publicsubnet1a_id = module.VPC.publicsubnet1a_id
    publicsubnet1b_id = module.VPC.publicsubnet1b_id
    project_name=module.VPC.project_name
    vpc_id        = module.VPC.vpc_id
    alb_sg_id = module.Resources.alb_sg_id

}




module "ASG" {

    source = "./Module/ASG"
    image_id ="ami-0177a0a317ca48b1a"
    instance_type = "t2.micro"
    instance_name = "mainservers"
    max_size="4"
    min_size="2"
    health_check_grace_period="300"
    health_check_type="ELB"
    desired_capacity="2"
    asg_sg_id=module.Resources.asg_sg_id
    privatesubnet1a_id=module.VPC.privatesubnet1a_id
    privatesubnet1b_id=module.VPC.privatesubnet1b_id
    aws_iam_instance_profile=module.Resources.aws_iam_instance_profile_name
    project_name=module.VPC.project_name
    db_instance_endpoint = module.RDS.db_instance_endpoint
    alb_target_group_arn=module.ALB.alb_target_group_arn

}
module "RDS" {
    source = "./Module/RDS"
    allocated_storage="20"
    storage_type = "gp3"
    engine = "mysql"
    instance_class="db.t3.micro"
    engine_version="8.0"
    username="admin"
    password ="Devops#21"
    backup_retention_period = "10"
    backup_window           = "00:00-03:00"
    maintenance_window      = "sun:05:00-sun:06:00"
    securesubnet1a_id=module.VPC.securesubnet1a_id
    securesubnet1b_id=module.VPC.securesubnet1b_id
    rds_sg_id=module.Resources.rds_sg_id
 
}