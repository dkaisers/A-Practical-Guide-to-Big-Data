# update apt-get and install dependencies
add-apt-repository ppa:openjdk-r/ppa -y
apt-get update
apt-get -y install openjdk-8-jdk pdsh python-pip python-dev libfreetype6-dev libpng12-dev subversion unzip
apt-get -y build-dep python-matplotlib
update-alternatives --config java

# install GEOS
cd /tmp
wget --progress=bar:force http://download.osgeo.org/geos/geos-3.4.2.tar.bz2
bunzip2 geos-3.4.2.tar.bz2
tar -xvf geos-3.4.2.tar

cd geos-3.4.2

./configure && make && make install && ldconfig
cd

# install PROJ4

cd /tmp
svn co http://svn.osgeo.org/metacrs/proj/branches/4.8/proj/

cd /tmp/proj/nad
wget --progress=bar:force http://download.osgeo.org/proj/proj-datumgrid-1.5.zip

unzip -o -q proj-datumgrid-1.5.zip

cd /tmp/proj/

./configure && make &&  make install && ldconfig
cd

# install python dependencies
easy_install numpy==1.8.2
easy_install matplotlib==2.1.0
easy_install pyproj==1.9.5.1

# install basemap
cd /tmp
wget --progress=bar:force https://github.com/matplotlib/basemap/archive/v1.1.0.tar.gz
tar -xzvf v1.1.0.tar.gz
cd basemap-1.1.0
python setup.py install
cd

# fix python vulnerability warning
chmod g-wx,o-wx /home/vagrant/.python-eggs

# set up env variables
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
export HADOOP_HOME=/home/vagrant/hadoop/

export PATH=$PATH:$HADOOP_HOME/bin

# ssh to localhost setup
sudo -u vagrant ssh-keygen -t rsa -P '' -f /home/vagrant/.ssh/id_rsa
sudo -u vagrant cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
ssh-keyscan -H localhost,127.0.0.1 >> /home/vagrant/.ssh/known_hosts
ssh-keyscan -H localhost >> /home/vagrant/.ssh/known_hosts
ssh-keyscan -H 127.0.0.1 >> /home/vagrant/.ssh/known_hosts

# disable ipv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
cat /proc/sys/net/ipv6/conf/all/disable_ipv6

# install zeppelin
wget --progress=bar:force http://www-us.apache.org/dist/zeppelin/zeppelin-0.7.3/zeppelin-0.7.3-bin-all.tgz
tar -xzvf zeppelin-0.7.3-bin-all.tgz
rm zeppelin-0.7.3-bin-all.tgz
mv zeppelin-0.7.3-bin-all /home/vagrant/zeppelin

cp -f /home/vagrant/config/zeppelin/zeppelin-env.sh /home/vagrant/zeppelin/conf/zeppelin-env.sh

# install hadoop
wget --progress=bar:force http://www-us.apache.org/dist/hadoop/common/hadoop-2.7.4/hadoop-2.7.4.tar.gz
tar -xzvf hadoop-2.7.4.tar.gz
rm hadoop-2.7.4.tar.gz
mv hadoop-2.7.4 /home/vagrant/hadoop

cp -f /home/vagrant/config/hadoop/hadoop-env.sh /home/vagrant/hadoop/etc/hadoop/hadoop-env.sh
cp -f /home/vagrant/config/hadoop/core-site.xml /home/vagrant/hadoop/etc/hadoop/core-site.xml
cp -f /home/vagrant/config/hadoop/hdfs-site.xml /home/vagrant/hadoop/etc/hadoop/hdfs-site.xml

sudo -u vagrant /home/vagrant/hadoop/bin/hdfs namenode -format

# create hdfs folders
mkdir -p /home/vagrant/hdfs/hdfs
mkdir -p /home/vagrant/hdfs/tmp

# set folder rights
chown -R vagrant:vagrant /home/vagrant/

# start services
sudo -u vagrant /home/vagrant/zeppelin/bin/zeppelin-daemon.sh start
sudo -u vagrant /home/vagrant/hadoop/sbin/start-dfs.sh
sudo -u vagrant /home/vagrant/hadoop/sbin/start-yarn.sh

# create hdfs user folder
sudo -u vagrant /home/vagrant/hadoop/bin/hdfs dfs -mkdir /user
sudo -u vagrant /home/vagrant/hadoop/bin/hdfs dfs -mkdir /user/vagrant
