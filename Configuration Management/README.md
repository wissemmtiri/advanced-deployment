## INSTALL ANSIBLE
    
    sudo apt update

    sudo apt install ansible

    ansible --version

## CONFIGURE ANSIBLE

1. create a directory **/etc/ansible** (if it dosent exist)

        mkdir /etc/ansible

2. create two files: **ansible.cfg**, **hosts**

        touch ansible.cfg hosts

### HOSTS FILE
this file is your inventory: check the **inventory.ini** file above.

### SSH PRIVATE KEYS
Create a folder for ssh private keys.(**Important**: change the permissions for the keys, use: **_chmod 600 key__**)

### PLAYBOOK
Check the **playbook.yml** file above.

## HOW TO USE 
To run a **single ansible module**, use:
    
    ansible group_name -m ansible_module

To run a **playbook**, use:

    ansible-playbook path_to_playbook