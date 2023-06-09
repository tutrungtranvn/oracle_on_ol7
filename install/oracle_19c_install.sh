#!/bin/bash

set -e
export INSTALL=$HOME/oracle_on_ol7/install
echo `hostname -I|awk '{print $1}'` `hostname -s` `hostname` >> /etc/hosts

echo "Installing Dependencies"
yum install -y wget unzip binutils.x86_64 compat-libcap1.x86_64 gcc.x86_64 gcc-c++.x86_64 glibc.i686 glibc.x86_64 \
glibc-devel.i686 glibc-devel.x86_64 ksh compat-libstdc++-33 libaio.i686 libaio.x86_64 libaio-devel.i686 libaio-devel.x86_64 \
libgcc.i686 libgcc.x86_64 libstdc++.i686 libstdc++.x86_64 libstdc++-devel.i686 libstdc++-devel.x86_64 libXi.i686 libXi.x86_64 \
libXtst.i686 libXtst.x86_64 make.x86_64 sysstat.x86_64 oracle-database-preinstall-19c && yum clean all

rm -rf /var/cache/yum

echo "Configure users!"
groupadd -g 54321 oinstall
groupadd -g 54322 dba
groupadd -g 54323 oper
useradd -u 54321 -g oinstall -G dba,oper oracle

echo "Creating Directory"
rm -rf /u01
mkdir -p /u01 && mkdir -p /u01/app/oracle/product/19.0.0/dbhome_1 && chown -R oracle:oinstall /u01 && chmod -R 775 /u01
touch /etc/oratab
cat /dev/null > /etc/oratab
chmod 777 /etc/oratab
chmod 755 $INSTALL/post_install.sh

echo "Setting ENV"
echo oracle:oracle | chpasswd
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export ORACLE_SID=ORCL19 >> /home/oracle/.bash_profile
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1 >> /home/oracle/.bash_profile
export PATH=$ORACLE_HOME/bin:$PATH >> /home/oracle/.bash_profile

su oracle -c "source ~/.bash_profile"
#Download oracle database zip
echo "Downloading oracle database zip"
wget -q --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1QinowHmGgiOCdj-OO20qaTQGHfYN2u6M' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1QinowHmGgiOCdj-OO20qaTQGHfYN2u6M" -O oracle_database.zip && rm -rf /tmp/cookies.txt

echo "Extracting oracle database zip"
mv oracle_database.zip /home/oracle
chmod 777 /home/oracle/oracle_database.zip
su  oracle -c 'unzip -q /home/oracle/oracle_database.zip -d /u01/app/oracle/product/19.0.0/dbhome_1/'
rm -f /home/oracle/oracle_database.zip

echo "setting up Response files"
cp $INSTALL/oracle-19c-ee.rsp $ORACLE_HOME/oracle-19c-ee.rsp
cp $INSTALL/dbca_19c.rsp $ORACLE_HOME/dbca_19c.rsp
cp $INSTALL/netca.rsp $ORACLE_HOME/netca.rsp
cp $INSTALL/initprod_primary.ora $ORACLE_HOME/initprod_primary.ora
cp $INSTALL/initprod_standby.ora $ORACLE_HOME/initprod_standby.ora
chmod 777 $ORACLE_HOME/oracle-19c-ee.rsp
chmod 777 $ORACLE_HOME/dbca_19c.rsp
chmod 777 $ORACLE_HOME/netca.rsp
chmod 777 $ORACLE_HOME/initprod_primary.ora
chmod 777 $ORACLE_HOME/initprod_standby.ora

echo "Installing Oracle Binaries"

su oracle -c "$ORACLE_HOME/runInstaller -force -skipPrereqs -silent -responseFile $ORACLE_HOME/oracle-19c-ee.rsp -waitForCompletion"

echo "Done"


#Connect to Oracle
su - oracle <<EOF
id
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
sqlplus -v
EOF

echo "Default 19c database install with PDB"

su oracle -c "/u01/app/oracle/product/19.0.0/dbhome_1/bin/dbca -silent -createDatabase -responseFile $ORACLE_HOME/dbca_19c.rsp"

echo "Starting default listener"
ps -ef | grep tnslsnr| grep -v grep| awk '{print $2}'|xargs -i kill -9 {}
su oracle -c "$ORACLE_HOME/bin/netca -silent -responseFile $ORACLE_HOME/netca.rsp"


echo "Configuring the TNS"
sh $HOME/oracle_on_ol7/install/tns.sh
chown oracle:oinstall $ORACLE_HOME/network/admin/tnsnames.ora

echo "Testing Database"
su - oracle <<EOF
export ORACLE_SID=ORCL19
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
sqlplus / as sysdba
alter system register;
select name,open_mode from v\$database;
show pdbs;
EOF


echo "Cleaning up"
rm -rf /home/oracle/database /tmp/*
echo "Configure environment for Oracle user"


echo "DataBase Installed!!!"


