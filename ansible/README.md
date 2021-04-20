Project is designed for 2 or more *linux server groups* (and almost independent of the distribution) with a master node and a group of controlled hosts on which we deploy the following infrastructure:

- on **ctrl_host** is installed *jenkins* (with all the plugins we need), *ansible* (to upgrade the infrastructure on the project directly from the master-node);

- on **workers** group (future jenkins agents) is installed *docker*, *java* and *nginx*. 


### *Structure*

Structurally, the project is divided into separate instructions for each node group. Each group has its own variables and performs the roles assigned to it. There is also an ansible module *authorized_key* in the **_main.yml** file structure to see which RSA-keys have been set for each group, thus taking care of security.

### **node_users**.
---

The key object that holds the core of the project logic is the variable ***node_users*** (individual for each node).


it is used to create users and configure them in ansible-roles *create_users_and_groups*, it contains information for ansible-roles **ctrl_host** and *ssh_create* (create individual ssh-keypairs for the user) and *ssh_manipulate* (download to the project folder and copy user credentials **ansible** -> **jenkins**), allowing the jenkins user to run playback directly on the wizard by the user, to configure the group infrastructure **workers**.
