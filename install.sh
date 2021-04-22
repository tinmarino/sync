#############################################
#                                           #
#          Packages Installation            #
#                                           #
#############################################
sudo apt update
sudo apt install -y build-essential  # 50 Mb
sudo apt install -y radio airspy mono-complete libportaudio2 librtlsdr0 librtlsdr-dev gqrx-sdr rtl-sdr cubicsdr python-dev python-pip xterm  # 200Mb
sudo pip install pyephem
 
#############################################
#                                           #
#          gnu radio Installation           #
#                                           #
#############################################
sudo apt update
sudo add-apt-repository -y ppa:gnuradio/gnuradio-releases-3.7
sudo apt install -y cmake git g++ libboost-all-dev python-dev python-mako \
python-numpy python-wxgtk3.0 python-sphinx python-cheetah swig libzmq3-dev \
libfftw3-dev libgsl-dev libcppunit-dev doxygen libcomedi-dev libqt4-opengl-dev \
python-qt4 libqwt-dev libsdl1.2-dev libusb-1.0-0-dev python-gtk2 python-lxml \
pkg-config python-sip-dev  # 500Mb
sudo apt install -y gnuradio  # 100Mb
 
#############################################
#                                           #
#          Create Working Directory         #
#                                           #
#############################################
mkdir /home/$USER/RadioTelescope/
cd /home/$USER/RadioTelescope/
 
#############################################
#                                           #
#             Install gr-nfs                #
#  Gnu Radio - National Science Fundation   #
#############################################
cd /home/$USER/RadioTelescope/
git clone https://github.com/glangsto/gr-nsf.git
cd gr-nsf
sudo cp /home/$USER/RadioTelescope/gr-nsf/grc/* /usr/share/gnuradio/grc/blocks/
 
#############################################
#                                           #
#          Configure gr-nsf                 #
#                                           #
#############################################
sudo gedit /etc/gnuradio/conf.d/grc.conf
----Edit the following variables: ----
local_blocks_path = /home/alma/RadioTelescope/gr-nsf/grc
xterm_executable = /usr/bin/lxterm
  
# Add plugin to PYTHONPATH
# after the change of the .profile file log out and then log in the session (or just run: "source ~/.profile" for current shell)
echo '# python configuration for glangsto gr-nsf grc modules
export PYTHONPATH=/home/alma/RadioTelescope/gr-nsf/python:$PYTHONPATH' > /home/alma/.profile
 
 
#############################################
#                                           #
#          Download spyserver               #
#                                           #
#############################################
cd /home/$USER/RadioTelescope/
mkdir spyserver-linux-x64
cd spyserver-linux-x64
wget -O spyserver-linux.tgz https://airspy.com/?ddownload=4262
tar xvf spyserver-linux.tgz
 
#############################################
#                                           #
#          Configure spy as service         #
#                                           #
#############################################
cat /etc/systemd/system/spyserver.service  # No such file or directory
sudo cat << EOF | sudo tee /etc/systemd/system/spyserver.service > /dev/null # Copy until next EOF
[Unit]
Description=SPY Server
After=network.target
StartLimitIntervalSec=0
 
[Service]
Type=simple
Restart=always
RestartSec=1
User=alma
WorkingDirectory=/home/alma/RadioTelescope/spyserver-linux-x64
ExecStart=/home/alma/RadioTelescope/spyserver-linux-x64/spyserver spyserver.config
 
[Install]
WantedBy=multi-user.target
EOF
cat /etc/systemd/system/spyserver.service  # Happy now ?
 
sudo systemctl enable spyserver
sudo systemctl start spyserver
sudo systemctl status spyserver
 
#############################################
#                                           #
#  Install, compile and configure sdsharp   #
#                                           #
#############################################
cd /home/$USER/RadioTelescope/
git clone https://github.com/cgommel/sdrsharp
cd /home/$USER/RadioTelescope/sdrsharp/
xbuild /p:TargetFrameworkVersion="v4.5" /p:Configuration=Release
cd /home/$USER/RadioTelescope/sdrsharp/Release
ln -s /usr/lib/x86_64-linux-gnu/libportaudio.so.2 libportaudio.so
ln -s /usr/lib/x86_64-linux-gnu/librtlsdr.so.0 librtlsdr.dll
 
 
#############################################
#                                           #
#           How to run sdsharp?             #
#                                           #
#############################################
cd /home/$USER/RadioTelescope/sdrsharp/Release
mono SDRSharp.exe
 
#############################################
#                                           #
#    How to run ALMA_processing example?    #
#                                           #
#############################################
cd /home/$USER/RadioTelescope/gr-nsf/examples
# export PYTHONPATH=../python:$PYTHONPATH  # This should be done with ~/.profile
gnuradio-config-info --version
gnuradio-config-info --prefix
gnuradio-config-info --enabled-components
gnuradio-companion vectordemo.grc
