apt update && sudo apt install -y python3-pip git curl ufw

sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw --force enable

# Install Ansible

sudo apt update && sudo apt install ansible -y
