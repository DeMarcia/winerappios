//
//  Status.h
//  winerappios
//
//  Created by miu on 15/6/1.
//  Copyright (c) 2015年 jyz. All rights reserved.
//

#ifndef winerappios_Status_h
#define winerappios_Status_h

@interface Status:NSObject

@end

#define CMD_LIGHT_ON = 0x10;
#define CMD_LIGHT_OFF = 0x11;
#define CMD_SWITCH_ON= 0x20;
#define CMD_SWITCH_OFF= 0x21;
#define CMD_MOTO= 0x30;
#define CMD_TURN_FOWARD= 0x40;
#define CMD_TURN_BACK= 0x41;
#define CMD_TURN_ALL= 0x42;
#define CMD_INIT_MOTO=0xbb;

//向下位机发送验证指令 TODO 这里只是为了标识状态来判断什么时候接受验证数据，并不是真的指令
#define CMD_AUTH=1000;

#define TURN_STATUS_FORWARD = 0;
#define TURN_STATUS_BACK = 1;
#define TURN_STATUS_ALL = 2;


@synchronized int motoNums = 0;
@synchronized int curMoto = 0;
//MOTO类型分为两种 两种TPD不同
#define MOTO_TYPE_ZERO=0;
#define MOTO_TYPE_NORMAL=1;
/**当前MOTO类型 有两种: {@link #MOTO_TYPE_ZERO},{@link #MOTO_TYPE_NORMAL}*/
@synchronized int motoType=-1;
/** TPD数组 对应MOTO类型 {@link #MOTO_TYPE_NORMAL}*/
#define int[] TPDS_NORMAL = {650, 750 , 850 , 1000 , 1950};
#define int[] CMD_TPD_NORMAL = {0x50, 0x51 , 0x52 , 0x53 , 0x54};
/** TPD数组 对应MOTO类型 {@link #MOTO_TYPE_ZERO}*/
#define int[] TPDS_ZERO = {650 , 785 , 950 , 1150 , 1440 , 1570 , 1728 , 1838 , 1920 , 2107 , 2335 , 2618 , 2787 , 2880 , 3600};
#define int[] CMD_TPD_ZERO = {0x50, 0x51 , 0x52 , 0x53 , 0x54, 0x55 , 0x56 , 0x57 , 0x58, 0x59 , 0x5a , 0x5b , 0x5c, 0x5d , 0x5e };
@synchronized int curTpdIndex=0;

@synchronized byte authCode = 0x10;
@synchronized boolean isLightOn = false;
@synchronized boolean isSwitchOn = false;
@synchronized int turnStatus = TURN_STATUS_FORWARD;
@synchronized int curCmd=-1;

#endif
