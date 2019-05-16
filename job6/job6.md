

##### 实验环境

本实验使用了两台虚拟机，均安装在virtualbox中，一台为ubuntu18.04 server，称为A, 另一台为ubuntu18.04 desktop，称为B，两台虚拟机的配置如下：

- A的配置
  - 操作系统为ubuntu18.04 server
  - 配置nat上网和host-only网卡(169.254.134.150)
  - 安装ansible/ 2.5.1
- B的配置
  - 操作系统为ubuntu18.04 desktop
  - 安装openssh-server /1:7.6p1-4ubuntu0.3
  - 安装python-minimal/python2.7.15rc1
  - 配置nat上网和host-only网卡(169.254.134.111)



##### 实验过程

- 首先配置虚拟机A到虚拟机B的远程SSH root用户登录

  ```bash
  #在虚拟机A上生成秘钥对
  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
  #在虚拟机B中安装openssh-server
  sudo apt install openssh-server
  #修改虚拟机B配置文件 允许root用户远程登录
  sudo vim /etc/ssh/sshd_config
  将PermitRootLogin 的值改为yes 并保存退出
  #执行ssh脚本将公钥从虚拟机A推送到虚拟机B(为确保配置文件有效 必须保证root用户密码正确 sudo passwd root 修改root用户密码)
   /usr/bin/expect  ssh-root.sh 169.254.134.111 root  123 ~/.ssh/id_rsa.pub
  #此时即可在虚拟机A上SSH root用户登陆到虚拟机B
  ssh root@169.254.134.111
  ```

  


##### proftpd

----

- [x] **配置一个提供匿名访问的FTP服务器，匿名访问者可以访问1个目录且仅拥有该目录及其所有子目录的只读访问权限**

  安装完成proftpd后，修改配置文件proftpd.conf，配置匿名用户对任意文件夹的只读权限。
  
  ![1](https://raw.githubusercontent.com/CUCCS/linux-2019-jackcily/job6/job6/img/1.PNG)
  
  ![2](https://raw.githubusercontent.com/CUCCS/linux-2019-jackcily/job6/job6/img/2.PNG)



- [x] **配置一个支持用户名和密码方式访问的账号，该账号继承匿名访问者所有权限，且拥有对另1个独立目录及其子目录完整读写（包括创建目录、修改文件、删除文件等）权限，（该账号仅可用于FTP服务访问，不能用于系统shell登录）**

  安装完成proftpd后，修改配置文件proftpd.conf

  ```bash
  AuthOrder mod_auth_file.c mod_auth_unix.c
  AuthUserFile /usr/local/etc/proftpd/passwd
  AuthGroupFile /usr/local/etc/proftpd/group
  PersistentPasswd off
  RequireValidShell off
  ```

  使用ftppasswd 创建passwd和group文件

  ```bash
  #创建用户
  spawn ftpasswd --passwd --file=/usr/local/etc/proftpd/passwd --name=${FTP_USER} --uid=1024 --home=/home/${FTP_USER} --shell=/bin/false
  #创建组
  ftpasswd --file=/usr/local/etc/proftpd/group --group --name=virtualusers --gid=1024
  #将用户加入组
  ftpasswd --group --name=virtualusers --gid=1024 --member=${FTP_USER} --file=/usr/local/etc/proftpd/group
  #修改文件夹权限
  if [[ ! -d "$path" ]] ; then
     mkdir  -p $path
     chown -R 1024:1024 $path
     chmod -R 700 $path
  fi
  ```

- [x] **FTP用户不能越权访问指定目录之外的任意其他目录和文件**

  在proftpd.conf配置文件中，添加DefaultRoot ~  限定用户只能访问自己的目录

- [x] **匿名访问权限仅限白名单IP来源用户访问，禁止白名单IP以外的访问**

  修改proftpd.conf文件

  ```bash
  <Limit LOGIN>
         Order allow,deny
         Allow from 169.254.134.150
         Deny from all
  </Limit>
  ```

- [x] 对ftp配置的测试

  对匿名FTP的测试

  ![test_ftp](https://raw.githubusercontent.com/CUCCS/linux-2019-jackcily/job6/job6/img/test_ftp.PNG)
  
  
  
  匿名ftp - 只允许白名单ip访问，其他用户访问会被拒绝。![ftp_white](https://raw.githubusercontent.com/CUCCS/linux-2019-jackcily/job6/job6/img/ftp_white.PNG)
  





##### NFS

---

- [ ] **在1台Linux上配置NFS服务，另1台电脑上配置NFS客户端挂载2个权限不同的共享目录，分别对应只读访问和读写访问权限.**

  - client和server的配置步骤

    ```bash
    #client
    ip:169.254.134.150
    sudo apt install nfs-common
    
    #server
    ip:169.254.134.111
    sudo apt install nfs-kernel-server
    
    #创建一个用于挂载的可读写的文件夹
    mkdir /var/nfs/general -p
    chown nobody:nogroup /var/nfs/general
    #另一个用于挂载的只读文件夹 /home （无需创建）
    
    #配置文件 /etc/exports  指定clients ip和权限
    /var/nfs/general    169.254.134.150(rw,sync,no_subtree_check)
    /home       169.254.134.150(sync,no_root_squash,no_subtree_check)
    
    #在Client上创建相应的挂载文件
    sudo mkdir -p /nfs/general
    sudo mkdir -p /nfs/home
    
    #在Client上挂载文件夹
    sudo mount 169.254.134.111:/var/nfs/general /nfs/general
    sudo mount 169.254.134.111:/home /nfs/home
    
    ```

  - NFS中的文件属主、权限查看

    NFS客户端文件夹的属主、权限信息

    ![nfs_dir](https://raw.githubusercontent.com/CUCCS/linux-2019-jackcily/job6/job6/img/nfs_dir.PNG)

    NFS只读文件夹的属主、权限信息

    ![nfs_read](https://raw.githubusercontent.com/CUCCS/linux-2019-jackcily/job6/job6/img/nfs_read.PNG)

    NFS读写文件夹的属主、权限信息

    ![nfs_write](https://raw.githubusercontent.com/CUCCS/linux-2019-jackcily/job6/job6/img/nfs_write.PNG)

    通过nfs客户端创建的文件属主、权限信息

    ![nfs_mkdir](https://raw.githubusercontent.com/CUCCS/linux-2019-jackcily/job6/job6/img/nfs_mkdir.PNG)

    在NFS服务器端上查看文件属主、权限信息
  
    ![nfs_mkdir_client](https://raw.githubusercontent.com/CUCCS/linux-2019-jackcily/job6/job6/img/nfs_mkdir_client.PNG)
  
    
  
  - 上述共享目录中文件、子目录的属主、权限信息和在NFS服务器端上查看到的信息一样吗？无论是否一致，请给出你查到的资料是如何讲解NFS目录中的属主和属主组信息应该如何正确解读
  
    在/etc/exports配合文件中设置共享文件夹属性时，会涉及到一个参数no_root_squash，如果不设置这个参数，即使在客户端使用sudo创建目录文件，属主和权限信息都继承父文件夹，并不是root:root；相反，如果设置该参数，以sudo创建的目录文件就会是root:root。
  
    

##### Samba

----

修改配置文件smb.conf,guest 设置匿名共享目录，目录demo使用用户名密码可以进行读写。

```bash
[guest]
        # This share allows anonymous (guest) access
        # without authentication!
        path = /srv/samba/guest/
        read only = yes
        guest ok = yes

[demo]
        # This share requires authentication to access
        path = /srv/samba/demo/
        read only = no
        guest ok = no
        force create mode = 0660
        force directory mode = 2770
        force user = demoUser
        force group = demoGroup
```



Server：Linux & Client：Windows

- [x] Linux设置匿名访问共享目录/Linux设置用户名密码方式的共享目录

  ```bash
  #安装
  sudo apt install samba
  #创建用户
  useradd -M -s /sbin/nologin ${SMB_USER}
  sudo passwd smbuser
  
  #在linux中添加同名用户
  smbpasswd -a smbuser
  #使设置的账户生效
  smbpasswd -e smbuser
  #创建用户组并加入
  groupadd smbgroup
  usermod -G smbgroup smbuser
  #创建用于共享的文件夹并修改用户组
  mkdir -p /home/samba/guest/
  mkdir -p /home/samba/demo/
  chgrp -R smbgroup /home/samba/guest/
  chgrp -R smbgroup /home/samba/demo/
  chmod 2775 /home/samba/guest/
  chmod 2770 /home/samba/demo/
  #启动Samba
  smbd
  
  #客户端为win10访问共享文件夹
  \\169.254.134.111\guest
  \\169.254.134.111\demo
  ```



![samba_win10_to_ubuntu](https://raw.githubusercontent.com/CUCCS/linux-2019-jackcily/job6/job6/img/samba_win10_to_ubuntu.PNG)



Server：Windows & Client：Linux

- [ ] Linux访问Windows的匿名共享目录

- [x] 在windows指定目录设置为共享用户名密码方式共享目录[win10局域网共享文件方法](https://blog.csdn.net/u012491783/article/details/73251515)

  ```bash
  #在linux下载安装smbclient
  sudo apt-get install smbclient
  #查看所有共享目录（需要输入windows的用户名和密码 -u指定windows的登陆用户名 然后需要输入密码）
  smbclient -L 169.254.134.111 -U Administer
  #访问共享目录
  smbclient  -U Administer //169.254.134.111/masm
  ```

  Linux访问Windows的用户名密码方式共享目录

  ![samba_ubuntu_log_to_win10](https://raw.githubusercontent.com/CUCCS/linux-2019-jackcily/job6/job6/img/samba_ubuntu_log_to_win10.PNG)

- [x] [下载整个目录](https://indradjy.wordpress.com/2010/04/14/getting-whole-folder-using-smbclient/)

  直接根据教程操作（**当前登陆文件夹默认为文件下载根目录**）

  ```bash
  首先从linux登陆到ubuntu的共享文件夹，需要输入密码
  命令行输入 tarmode
  命令行输入 recurse
  命令行输入 prompt
  命令行输入 mget 指定文件被下载到的目录\
  ```



##### DHCP

---

- [x] 2台虚拟机使用Internal网络模式连接，其中一台虚拟机上配置DHCP服务，另一台服务器作为DHCP客户端，从该DHCP服务器获取网络地址配置

  首先进行DHCP的安装和配置

  ```bash
  #修改server  /etc/network/interfaces配置文件
  auto enp0s9
  iface enp0s9 inet static
  address 192.168.254.25
  netmask 255.255.255.0
  gateway 192.168.254.25
  #server端安装需要使用的软件
  apt install isc-dhcp-server
  #修改server中/etc/default/isc-dhcp-server文件  配置提供DHCP服务的网卡
  INTERFACES="enp0s9"
  #修改server中/etc/dhcp/dhcpd.conf文件  添加如下配置如下
  subnet 10.0.2.0 netmask 255.255.255.0 {
    range dynamic-bootp 10.0.2.65 10.0.2.100;
    option broadcast-address 10.0.2.255;
    option subnet-mask 255.255.255.0;
    default-lease-time 600;
    max-lease-time 7200;
  }
  #server端开启 isc-dhcp-server 服务
  service isc-dhcp-server restart
  ```
  
  在另一台ubuntu服务器中配置开启内部网卡的dhcp服务，配置完成后，查看dhcp的结果。
  
  ```bash
  sudo vim /etc/netplan/01-netcfg.yaml
  #最终配置结果如下
  network:
    version: 2
    renderer: networkd
    ethernets:
      enp0s3:
        dhcp4: yes
  
  network:
          ethernets:
                  enp0s8:
                          addresses: [169.254.134.150/16]
                          dhcp4: no
                          optional: true
                  enp0s9:
                          dhcp4: yes
  #使配置生效
  sudo netplan apply 
  ```
  
  在DHCP client 虚拟机中查看配置结果如下：
  
  ![dhcp_client](https://raw.githubusercontent.com/CUCCS/linux-2019-jackcily/job6/job6/img/dhcp_client.PNG)



##### DNS

---

- server端

  安装bind9 、配置bind9

  ```bash
  #打开 /etc/bind/named.conf.local 添加以下内容
  zone "cuc.edu.cn" {
      type master;
      file "/etc/bind/db.cuc.edu.cn"
  };  
  
  #创建保存域名解析的db文件
  sudo cp /etc/bind/db.local /etc/bind/db.cuc.edu.cn
  
  
  #编辑/etc/bind/db.cuc.edu.cn文件 添加需要解析的域名
  wp.sec.cuc.edu.cn       IN      A       10.0.2.15
  dvwa.sec.cuc.edu.cn     IN      CNAME   wp.sec.cuc.edu.cn.
  test.com                IN      A       10.0.2.65
  
  #重启服务
  service bind9 restart
  ```

  

- 客户端配置使用对应的服务器

  ```bash
  #客户端添加解析服务器
  sudo vim /etc/resolvconf/resolv.conf.d/head
  	search cuc.edu.cn
  	nameserver 192.168.254.25
  
  #更新resolv.conf文件
  sudo apt install resolvconf
  sudo resolvconf -u
  ```



DNS实验要求

- [ ] 基于上述Internal网络模式连接的虚拟机实验环境，在DHCP服务器上配置DNS服务，使得另一台作为DNS客户端的主机可以通过该DNS服务器进行DNS查询

- [ ] 在DNS服务器上添加 `zone "cuc.edu.cn"` 的以下解析记录





##### 参考链接

- https://github.com/CUCCS/linux/blob/master/2017-1/TJY/%E7%BD%91%E7%BB%9C%E8%B5%84%E6%BA%90%E5%85%B1%E4%BA%AB/%E7%BD%91%E7%BB%9C%E8%B5%84%E6%BA%90%E5%85%B1%E4%BA%AB.md
- https://github.com/CUCCS/linux/tree/master/2017-1/snRNA/ex6

- [Configure DHCP Client : Ubuntu](https://www.server-world.info/en/note?os=Ubuntu_18.04&p=dhcp&f=2)
- [How To Configure BIND as a Private Network DNS Server on Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/how-to-configure-bind-as-a-private-network-dns-server-on-ubuntu-18-04)

  

