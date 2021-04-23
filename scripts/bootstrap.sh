sudo yum update -y && sudo yum install -y epel-release
# mirrors fix after epel installed
sudo yum clean all && sudo yum clean metadata

sudo yum install -y \
git vim zsh htop \
ansible python3 python3-pip 

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
 
