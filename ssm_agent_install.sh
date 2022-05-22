#!/bin/bash
sudo mkdir /tmp/ssm
cd /tmp/ssm
echo "Downloading the SSM agent..."
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
echo "Enabling SSM agent..."
sudo systemctl enable amazon-ssm-agent
rm amazon-ssm-agent.deb
echo "SSM agent installed successfully!"