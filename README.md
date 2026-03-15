# cloud-1

Internet
   |
   | 80 / 443
   v
Reverse Proxy (TLS)
   |
   |--------------------|
   |                    |
WordPress          phpMyAdmin
   |
MySQL Database

# Install required packages for Ansible and Docker

apt update
sudo apt install -y python3-pip git curl ufw

# Set up UFW firewall

sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable

# Install Docker + Docker Compose

covered in ansible

# Install Docker Compose

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

covered in ansible

# Install Nginx

covered in ansible

# Configure Firewall for Nginx

_________________________________
sudo ufw app info 'Nginx Full'
_________________________________

sudo ufw allow 'Nginx Full'
sudo ufw delete allow 8080
sudo ufw delete allow 8081
__________________________________________

delete → removes a firewall rule
allow 8080 → removes the rule that allowed
traffic to port 8080
__________________________________________

# Create Reverse Proxy Config

covered in ansible

server {
    listen 80;
    server_name areifoun.com;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

server {
    listen 80;
    server_name pma.areifoun.com;

    location / {
        proxy_pass http://127.0.0.1:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

# Enable Site and Test Nginx

covered in ansible

sudo ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

nginx -t → test config syntax.
systemctl reload nginx → apply changes.

# Enable HTTPS with Let’s Encrypt

(i think those needs real domain)
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d example.com -d pma.example.com

# Verify Security

Only ports 22, 80, 443 open:

sudo ufw status

# Install Ansible (on your LOCAL machine)

Your laptop is the Ansible controller.

    sudo apt update
    sudo apt install ansible -y

Check:

    ansible --version

# Project Structure

cloud-1/
│
├── ansible/
│   ├── inventory
│   ├── playbook.yml
│   └── roles/
│        ├── docker/
│        │    └── main.yml
│        ├── nginx/
│        │    └── main.yml
│        └── deploy/
│             └── main.yml
└── docker/
     └── docker-compose.yml

# Inventory File

[server]
your_server_ip ansible_user=ubuntu (if local add : ansible_connection=local)

# playbook.yml

- hosts: server
  become: yes

  roles:
    - docker
    - nginx
    - deploy

Explanation:

    hosts: server
    Run tasks on machines listed in inventory.

    become: yes
    Run commands with sudo.

    roles
    Execute roles in order.

# Docker Role

- name: Install required packages
  apt:
    name:
      - docker.io
      - docker-compose
    state: present
    update_cache: yes

- name: Start docker service
  service:
    name: docker
    state: started
    enabled: yes

Explanation:

    Task 1 installs:

        docker
        docker-compose

    Task 2 ensures Docker:

        starts automatically on boot

# Nginx Role

- name: Install nginx
  apt:
    name: nginx
    state: present
    update_cache: yes

- name: Start nginx
  service:
    name: nginx
    state: started
    enabled: yes

# Deploy Role

- name: Copy docker-compose file
  copy:
    src: ../../docker/docker-compose.yml
    dest: /home/ubuntu/docker-compose.yml

- name: Start containers
  command: docker-compose up -d
  args:
    chdir: /home/ubuntu

Explanation:

    Task 1:

    copy docker-compose.yml to server

    Task 2:

    run containers automatically

# Run the Full Deployment

From the ansible directory:

    (local test) ansible-playbook -i inventory playbook.yml -e "ansible_become_pass=hero"

    (vagrant test) ansible -i inventory server1 -m ping

What happens automatically:

connect to server
install docker
install nginx
copy docker-compose
run containers

Your WordPress site is deployed.


______________________________________

# vagrant test

(on your local machine not vagrant machine)

  sudo nano /etc/hosts

  192.168.56.10 areifoun.com
  192.168.56.10 pma.areifoun.com

______________________________________





