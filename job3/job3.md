#### 第三次作业

##### 录屏

- Systemd 入门教程：命令篇 
  - [part1 - part4](https://asciinema.org/a/gN7BkLAHFttxrzVHaHI1u5mNV)
  - [part5](https://asciinema.org/a/tnScxPQRY068VIgr6HgN2nX4o)
  - [part6 - part7](https://asciinema.org/a/9Qo5yeICI7ll42DgBMiXAq8Ph)
- Systemd 入门教程：实战篇
  - [part1 - part9](https://asciinema.org/a/A076m9sHUJUHObKaxtp8NlP0e)

##### 自查清单

- 如何添加一个用户并使其具备sudo执行程序的权限？

  ```bash
  sudo adduser new
  sudo usermod -G sudo new
  ```

  ![sudo_user](https://github.com/CUCCS/linux-2019-jackcily/raw/job3/job3/img/sudo_user.PNG)

- 如何将一个用户添加到一个用户组？

  ```bash
  #将new用户添加到root用户组
  sudo usermod -G root new
  #查看new用户所在的组
  id new
  ```

  ![add_group](https://github.com/CUCCS/linux-2019-jackcily/raw/job3/job3/img/add_group.PNG)

- 如何查看当前系统的分区表和文件系统详细信息？

  ```bash
  #使用fdisk查看系统所有硬盘的分区情况
  sudo fdisk -l 
  
  #查看某个分区的文件系统详情
  sudo parted /dev/sda
  print list
  
  /dev/mapper/xhl--vg-root: 79 GiB
  Disk /dev/mapper/xhl--vg-swap_1: 980 MiB
  ```

  

  ![fsdisk](https://github.com/CUCCS/linux-2019-jackcily/raw/job3/job3/img/fsdisk.PNG)

  ![parted](https://github.com/CUCCS/linux-2019-jackcily/raw/job3/job3/img/parted.PNG)

  

- 如何实现开机自动挂载Virtualbox的共享目录分区？

  ```bash
  #首先安装增强功能
  sudo apt-get install virtualbox-guest-utils
  
  #挂载共享文件夹
  在windows10中建立挂载文件夹
  
  #使用systemd实现开机自动挂载
  
   #首先建立自动挂载文件和挂载文件(注意文件名必须和挂载文件目录具有对应关系，把路径里的「/」换成「 -」、配置文件键值对不能出现空格 ）
   sudo vim /lib/systemd/system/mnt-share.automount
   sudo vim /lib/systemd/system/mnt-share.mount
   
   
   #automount加入以下内容
   [Unit]
   Description=Auto mount shared "src" folder
  
   [Automount]
   Where=/mnt/share   #linux中挂载点的绝对路径
   DirectoryMode=0775
  
   [Install]
   WantedBy=multi-user.target
   
   #mount加入以下内容 
   [Unit]
  Description=VirtualBox shared "src" folder
  
  [Mount]
  What=kali    #window10下文件夹名称
  Where=/mnt/share   #linux中挂载点的绝对路径
  Type=vboxsf 
  Options=defaults,noauto,uid=1000,gid=1000
  
  #载入配置文件
  systemctl daemon-reload
   
   #修改完以后 保存退出 重启即可自动挂载
   sudo reboot
  ```

  

- 基于LVM（逻辑分卷管理）的分区如何实现动态扩容和缩减容量？

  当我们在安装系统的时候，由于没有合理分配分区空间，在后续过程中，想重新调整分区。

  如果这些分区在装系统的时候的使用lvm，就可以轻松的进行扩容或缩容。

  ```bash
  #首先查看系统中硬盘的分区情况
  sudo fdisk -l 
  
  #输出结果如下
  Disk /dev/sda: 80 GiB, 85899345920 bytes, 167772160 sectors
  Units: sectors of 1 * 512 = 512 bytes
  Sector size (logical/physical): 512 bytes / 512 bytes
  I/O size (minimum/optimal): 512 bytes / 512 bytes
  Disklabel type: dos
  Disk identifier: 0x820d144a
  
  Device     Boot Start       End   Sectors Size Id Type
  /dev/sda1  *     2048 167770111 167768064  80G 8e Linux LVM
  
  
  Disk /dev/mapper/xhl--vg-root: 79 GiB, 84867547136 bytes, 165756928 sectors
  Units: sectors of 1 * 512 = 512 bytes
  Sector size (logical/physical): 512 bytes / 512 bytes
  I/O size (minimum/optimal): 512 bytes / 512 bytes
  
  
  Disk /dev/mapper/xhl--vg-swap_1: 980 MiB, 1027604480 bytes, 2007040 sectors
  Units: sectors of 1 * 512 = 512 bytes
  Sector size (logical/physical): 512 bytes / 512 bytes
  I/O size (minimum/optimal): 512 bytes / 512 bytes
  
  
  #使用如下两条语句对/dev/mapper/xhl--vg-root进行缩容和扩容
  sudo lvreduce -L -8G /dev/mapper/xhl--vg-root
  sudo lvextend -L +8G /dev/mapper/xhl--vg-root
  
  #执行调整（本虚拟机为ext4文件系统）
  resize2fs /dev/mapper/xhl--vg-root
  ```

- 如何通过systemd设置实现在网络连通时运行一个指定脚本，在网络断开时运行另一个脚本？

  使用`ExecStartPost`和`ExecStopPost`配置`/lib/systemd/system/systemd-networkd.service`

  配置如下内容

  ```bash
  #打开文件
  sudo vim /lib/systemd/system/systemd-networkd.service
  
  #在[service]中增加以下内容
  ExecStartPost=/bin/sh -c "echo started"
  ExecStopPost=/bin/sh -c "echo stoped"
  
  #:x!保存退出 重新载入配置
  systemctl daemon-reload
  
  #重启网络服务
   systemctl restart systemd-networkd
   
   #关闭网络服务
    systemctl stop systemd-networkd
  ```

  执行步骤截图如下

  ![start_script](https://github.com/CUCCS/linux-2019-jackcily/raw/job3/job3/img/start_script.PNG)

  ![stop_script](https://github.com/CUCCS/linux-2019-jackcily/raw/job3/job3/img/stop_script.PNG)

- 如何通过systemd设置实现一个脚本在任何情况下被杀死之后会立即重新启动？实现**杀不死**？

  [service]中的Restart取改为always

  以`/lib/systemd/system`目录下的apache2.service为例测试

  ```bash
  #打开文件
  sudo vim /lib/systemd/system/apache2.service
  
  #修改Restart为always 保存退出
  
  #systemctl status apache2 查看主进程号
  #kill 主进程号
  #apache2服务仍然存在 配置生效
  ```

  

  ![alter_apache](https://github.com/CUCCS/linux-2019-jackcily/raw/job3/job3/img/alter_apache.PNG)

  

  ![kill_apache](https://github.com/CUCCS/linux-2019-jackcily/raw/job3/job3/img/kill_apache.PNG)

##### 参考资料

- [使用systemd挂载文件系统](https://jtree.cc/post/%E4%BD%BF%E7%94%A8systemd%E6%8C%82%E8%BD%BD%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F/)
- [Linux下对lvm逻辑卷分区大小的调整（针对xfs和ext4不同文件系统）](https://blog.csdn.net/h106140873/article/details/83745729)
- [Cause a script to execute after networking has started?](https://unix.stackexchange.com/questions/126009/cause-a-script-to-execute-after-networking-has-started)
- [[systemd系统开机运行rc.local](https://blog.xugaoxiang.com/linux/how-to-enable-rc-local-with-systemd-on-boot.html)](https://blog.xugaoxiang.com/linux/how-to-enable-rc-local-with-systemd-on-boot.html)
- [systemd步骤EXEC产生脚本失败：权限被拒绝](http://www.kbase101.com/question/20276.html)
- [How to write startup script for systemd](https://unix.stackexchange.com/questions/47695/how-to-write-startup-script-for-systemd)