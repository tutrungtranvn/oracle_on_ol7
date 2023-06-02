# Install Oracle with OL7 (Oracle Linux 7) on AWS EC2
## Pre-install
```
yum update
```
Check the status and version of GitHub if it is installed.
```
[oracle@ip-10-0-19-6  ~]# git version
bash: git: command not found
```
As GitHub is not configured, we use YUM to install it with root user and recheck for GitHub version.
```
[oracle@ip-10-0-19-6  ~]# yum -y install git
[oracle@ip-10-0-19-6  ~]# git version
git version 1.7.1
```
In the next step, we need to clone repos from GitHub under the home directory of the root user.
```
[oracle@ip-10-0-19-6  ~]# cd
[oracle@ip-10-0-19-6  ~]# echo $HOME
/root
```
Clone project on Github
```
[oracle@ip-10-0-19-6  ~]#  git clone https://github.com/tutrungtranvn/oracle_on_ol7.git
Cloning into 'docker-oracle-ee-19c'...
remote: Enumerating objects: 12, done.
remote: Counting objects: 100% (12/12), done.
remote: Compressing objects: 100% (11/11), done.
remote: Total 12 (delta 0), reused 0 (delta 0), pack-reused 0
Unpacking objects: 100% (12/12), done.
```
## Install Oracle
Run syntax 
```
chmod u+x $HOME/oracle_on_ol7/install/oracle_19c_install.sh
```
and
```
sh $HOME/oracle_on_ol7/install/oracle_19c_install.sh
```
