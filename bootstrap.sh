apt-get update
apt-get install -y zsh
chsh -s $(which zsh) vagrant
apt-get install -y vim git openjdk-7-jdk
export JAVA_HOME="/usr/lib/jvm/java-7-openjdk-amd64/jre"
export JENKINS_HOME="/var/lib/jenkins"
debconf-set-selections <<< 'mysql-server mysql-server/root_password password rootpass'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password rootpass'
apt-get install -y mysql-server
echo "CREATE DATABASE sonar CHARACTER SET utf8 COLLATE utf8_general_ci" | mysql -uroot -prootpass
echo "CREATE USER 'sonar' IDENTIFIED BY 'sonar'" | mysql -uroot -prootpass
echo "GRANT ALL ON sonar.* TO 'sonar'@'%' IDENTIFIED BY 'sonar'" | mysql -uroot -prootpass
echo "GRANT ALL ON sonar.* TO 'sonar'@'localhost' IDENTIFIED BY 'sonar'" | mysql -uroot -prootpass
echo "FLUSH PRIVILEGES" | mysql -uroot -prootpass
apt-get install -y maven
echo "Downloading Jenkins"
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update
apt-get install -y jenkins
sed -i 's/HTTP_PORT=8080/HTTP_PORT=8081/g' /etc/default/jenkins
sed -i 's/JENKINS_ARGS="--webroot=\/var\/cache\/jenkins\/war --httpPort=$HTTP_PORT --ajp13Port=$AJP_PORT"/JENKINS_ARGS="--webroot=\/var\/cache\/jenkins\/war --prefix=$PREFIX --httpPort=$HTTP_PORT --ajp13Port=$AJP_PORT"/g' /etc/default/jenkins
service jenkins stop
service jenkins start
echo "Donwloading SonarQube"
wget -o /dev/null http://dist.sonar.codehaus.org/sonarqube-5.0.zip
unzip sonarqube-5.0.zip
rm sonarqube-5.0.zip
mkdir -p /opt/sonar
mv sonarqube-5.0/* /opt/sonar
rm /opt/sonar/conf/sonar.properties
cp /vagrant/sonar.properties /opt/sonar/conf
cp /vagrant/sonar /etc/init.d/sonar
update-rc.d -f sonar remove
chmod 755 /etc/init.d/sonar
update-rc.d sonar defaults
service sonar start
apt-get install -y tomcat7
service tomcat7 stop
chown tomcat7:tomcat7 /usr/share/tomcat7
echo "Downloading Nexus"
wget -o /dev/null http://central.maven.org/maven2/org/sonatype/nexus/nexus-webapp/2.11.1-01/nexus-webapp-2.11.1-01.war
mv nexus-webapp-2.11.1-01.war /var/lib/tomcat7/webapps/nexus.war
service tomcat7 start
cp -R /vagrant/.zsh /home/vagrant/.zsh
chown -R vagrant:vagrant /home/vagrant/.zsh
cp /vagrant/.zshrc /home/vagrant/.zshrc
chown vagrant:vagrant /home/vagrant/.zshrc
cp -R /vagrant/.vim /home/vagrant/.vim
chown -R vagrant:vagrant /home/vagrant/.vim
cp /vagrant/.vimrc /home/vagrant/.vimrc
chown -R vagrant:vagrant /home/vagrant/.vimrc
mkdir /git
chown vagrant:vagrant /git
