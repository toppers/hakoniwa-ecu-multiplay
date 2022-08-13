# hakoniwa-ecu-multiplay

複数の車載ECUを箱庭（仮想シミュレーション）環境で動作させるための環境です。
以下では、2つのECU間でCAN通信を行う
## ATK2 Sample1のビルド方法

```
cd ~/workspace/atk2-sc1/
mkdir OBJ ;cd OBJ
../configure -T hsbrh850f1k_gcc
cp /root/athrill-target-rh850f1x/params/rh850f1k/atk2-sc1/* .
make

```

## athrillを使ったATK2の実行方法
```
# athrill2 -c1 -i -d device_config.txt -m memory.txt atk2-sc1
core id num=1
ROM : START=0x0 SIZE=1024
RAM : START=0xfede8000 SIZE=512
ELF SET CACHE RIGION:addr=0x0 size=62 [KB]
Elf loading was succeeded:0x0 - 0xf89b : 62.155 KB
Elf loading was succeeded:0xf89c - 0x1205c : 0.220 KB
ELF SYMBOL SECTION LOADED:index=16
ELF SYMBOL SECTION LOADED:sym_num=597
ELF STRING TABLE SECTION LOADED:index=17
DEBUG_FUNC_FT_LOG_SIZE=1024
[DBG>
HIT break:0x0
[NEXT> pc=0x0 prc_support.S 256
c      <======  INPUT `c` 
[CPU>
TOPPERS/ATK2-SC1 Release 1.4.2 for HSBRH850F1K (Jul 17 2022, 09:27:45)

Input Command:
```

## A-COMSTACKを使ったCAN通信の例 : ビルド方法
```
cd a-comstack/can/target/hsbrh850f1k_gcc/sample/
cp /root/athrill-target-rh850f1x/params/rh850f1k/atk2-sc1/* .
make can
make
```

## A-COMSTACKを使ったCAN通信の例 : 実行方法
### ターミナル１(ROS Master)
```
# mnt/master/ros-master.bash 
... logging to /root/.ros/log/a9400e2e-05b3-11ed-bf83-000d3ac8da62/roslaunch-codespaces-4a7fa1-8259.log
Checking log directory for disk usage. This may take a while.
Press Ctrl-C to interrupt
Done checking log file disk usage. Usage is <1GB.

started roslaunch server http://codespaces-4a7fa1:41219/
ros_comm version 1.14.13


SUMMARY
========

PARAMETERS
 * /rosdistro: melodic
 * /rosversion: 1.14.13

NODES

auto-starting new master
process[master]: started with pid [8307]
ROS_MASTER_URI=http://codespaces-4a7fa1:11311/

setting /run_id to a9400e2e-05b3-11ed-bf83-000d3ac8da62
process[rosout-1]: started with pid [8326]
started core service [/rosout]
```

### ターミナル２ (ROS TOPIC)
- Step1 running rostopic
```
source /opt/ros/melodic/setup.bash
rostopic echo /channel0/CAN_IDE0_RTR0_DLC8_0x001
WARNING: topic [/channel0/CAN_IDE0_RTR0_DLC8_0x001] does not appear to be published yet
```

- Step2 CAN logging after run can application
```
WARNING: topic [/channel0/CAN_IDE0_RTR0_DLC8_0x001] does not appear to be published yet
data: "\x01\x02\x03\x04\x05\x06\a\b"
---
data: "\x02\x03\x04\x05\x06\a\b\t"
---
data: "\x03\x04\x05\x06\a\b\t\n"
---
data: "\x04\x05\x06\a\b\t\n\v"
---
data: "\x05\x06\a\b\t\n\v\f"
---
data: "\x06\a\b\t\n\v\f\r"
---
data: "\a\b\t\n\v\f\r\x0E"
---
data: "\b\t\n\v\f\r\x0E\x0F"
---
data: "\t\n\v\f\r\x0E\x0F\x10"
```

### ターミナル３ (CAN Application using TOPPERS Automotive Stacks)
- Step1 Run athrill
```
cd a-comstack/can/target/hsbrh850f1k_gcc/sample/
athrill2 -c1 -i -d device_config_with_can.txt -m memory.txt atk2-sc1.exe
core id num=1
ROM : START=0x0 SIZE=1024
RAM : START=0xfede8000 SIZE=512
ELF SET CACHE RIGION:addr=0x0 size=57 [KB]
Elf loading was succeeded:0x0 - 0xe680 : 57.640 KB
Elf loading was succeeded:0xe680 - 0x128c4 : 0.160 KB
ELF SYMBOL SECTION LOADED:index=16
ELF SYMBOL SECTION LOADED:sym_num=602
ELF STRING TABLE SECTION LOADED:index=17
DEBUG_FUNC_MROS_TOPIC_PUB_0 = channel0/CAN_IDE0_RTR0_DLC8_0x001
DEBUG_FUNC_MROS_TOPIC_SUB_0 = channel0/CAN_IDE0_RTR0_DLC8_0x123
DEBUG_FUNC_MROS_TOPIC_SUB_1 = channel0/CAN_IDE0_RTR0_DLC8_0x122
DEBUG_FUNC_MROS_TOPIC_SUB_2 = channel0/CAN_IDE0_RTR0_DLC8_0x003
DEBUG_FUNC_MROS_TOPIC_SUB_3 = channel0/CAN_IDE0_RTR0_DLC8_0x004
DEBUG_FUNC_FT_LOG_SIZE=1024
mros_master_ipaddr=0.0.0.0
mros_slave_port_no=11411
mros_uri_slave=http://127.0.0.1:11411
mros_publisher_port_no=11511
[DBG>**********mROS main task start**********

HIT break:0x0
[NEXT> pc=0x0 prc_support.S 256
**********mROS Main task finish**********
DEBUG_FUNC_MROS_NODE_NAME = athrill_test_node
**********mROS pub task start**********
**********mROS pub task start**********
**********mROS pub task start**********
**********mROS pub task start**********
WARNING: topic [/channel0/CAN_IDE0_RTR0_DLC8_0x123] does not appear to be published yet
WARNING: topic [/channel0/CAN_IDE0_RTR0_DLC8_0x122] does not appear to be published yet
WARNING: topic [/channel0/CAN_IDE0_RTR0_DLC8_0x003] does not appear to be published yet
WARNING: topic [/channel0/CAN_IDE0_RTR0_DLC8_0x004] does not appear to be published yet
```
- Step2 Continue Athrill simulation and run CAN application
```
c
[CPU>
TOPPERS/ATK2-SC1 Release 1.4.2 for HSBRH850F1K (Jul 23 2022, 01:41:36)

== finished StartupHook ==
== Can_Init ==
== CanIf_ControllerModeIndication(0, 2) ==
[FCN0] Can_Write(3) CAN-ID:0x1
DATA[0]:0x0
DATA[1]:0x1
DATA[2]:0x2
DATA[3]:0x3
DATA[4]:0x4
DATA[5]:0x5
DATA[6]:0x6
DATA[7]:0x7

== finished SendTask ==
== CanIf_TxConfirmation(3) ==
```

## A-RTEGENの HelloWorldWithCOMを使った例
- ECU1（送信側）のビルド
```
cd ~/workspace/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu1
bash configure.sh
make
cp /root/athrill-target-rh850f1x/params/rh850f1k/atk2-sc1/* .
```
- device_config_with_can.txtを修正
```
DEBUG_FUNC_MROS_TOPIC_PUB_0 channel0/CAN_IDE0_RTR0_DLC4_0x002
```
- athrillの実行
```
athrill2 -c1 -i -d device_config_with_can.txt -m memory.txt atk2-sc1
```