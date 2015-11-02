//
//  NSObject+Status.m
//  winerappios
//
//  Created by miu on 15/6/1.
//  Copyright (c) 2015年 jyz. All rights reserved.
//

#import "NSObject+Status.h"
#import "Constant.h"
#import "NSObject+Utils.h"

@interface Status(){
    BOOL _authed;
}
@end
@implementation Status

//--------------------------------发送的指令码------------------------------------
const int CMD_LIGHT_ON =0x10;//亮灯关指令
const int CMD_LIGHT_OFF = 0x11;//暗灯闭指令
const int CMD_SWITCH_ON= 0x20;//开灯指令
const int CMD_SWITCH_OFF= 0x21;//关灯指令
//const int CMD_MOTO= 0x30;//马达指令
const int CMD_MOTO_ZERO=0x7f;	//初始化特殊马达
const int CMD_MOTO_BEGIN=0x80;
const int CMD_MOTO_END=0x97;
const int CMD_TURN_FOWARD= 0x40;//前转指令
const int CMD_TURN_BACK= 0x41;//后转指令
const int CMD_TURN_ALL= 0x42;//循环
const int CMD_INIT_MOTO=0xbb;//初始化马达指令

//向下位机发送验证指令 TODO 这里只是为了标识状态来判断什么时候接受验证数据，并不是真的指令
const int CMD_AUTH_FLAG=1000;
//向下位机发送变更moto的指令 TODO 这里只是为了标识状态来判断当前的指令是用来改变MOTO的是为了方便后面的状态改变而用的标识，并非真的指令，真的智力见getCurMotoCmd()
const int CMD_MOTO_FLAG=1001;

const int TURN_STATUS_FORWARD = 0;
const int TURN_STATUS_BACK = 1;
const int TURN_STATUS_ALL = 2;

//MOTO类型分为两种 两种TPD不同
const int MOTO_TYPE_ZERO=0;
const int MOTO_TYPE_NORMAL=1;
/** TPD数组 对应MOTO类型 {@link #MOTO_TYPE_NORMAL}*/
int TPDS_NORMAL[] = {650, 750 , 850 , 1000 , 1950};
int CMD_TPD_NORMAL[] = {0x50, 0x51 , 0x52 , 0x53 , 0x54};
/** TPD数组 对应MOTO类型 {@link #MOTO_TYPE_ZERO}*/
int TPDS_ZERO[] = {650 , 785 , 950 , 1150 , 1440 , 1570 , 1728 , 1838 , 1920 , 2107 , 2335 , 2618 , 2787 , 2880 , 3600};
int CMD_TPD_ZERO[] = {0x50, 0x51 , 0x52 , 0x53 , 0x54, 0x55 , 0x56 , 0x57 , 0x58, 0x59 , 0x5a , 0x5b , 0x5c, 0x5d , 0x5e };

Byte authCode;
BOOL isLightOn = false;
BOOL isSwitchOn = false;
int turnStatus = TURN_STATUS_FORWARD;

Boolean logined;//是否登录成功  验证成功+初始化(马达)成功
BOOL authed;//是否验证成功


-(void) changeMoto{
    _curMoto++;
    if(_curMoto>=_motoNums){
        _curMoto=0;
    }
    _curTpdIndex=0;
};

-(int) getCurMotoCmd{
    int index=_curMoto+1;
    int cmd=-1;
    if(index==_motoNums){
        index=0;
    }
    cmd=index+CMD_MOTO_BEGIN;
    return cmd;
};

-(void) changeTpd{
    _curTpdIndex++;
    //tpd_zero的长度 15
    if (_motoType == MOTO_TYPE_ZERO && _curTpdIndex >= 15) {
        _curTpdIndex = 0;
        //tpd_normal的长度
    } else if (_motoType == MOTO_TYPE_NORMAL && _curTpdIndex >= 5) {
        _curTpdIndex = 0;
    }
};
/**
 * 获得当前的tpd指令
 * @return
 */
-(int) getCurTpdCmd{
    int index=_curTpdIndex+1;
    int cmd=-1;
    switch (_motoType) {
        case MOTO_TYPE_ZERO:
            if(index==15){
                index=0;
            }
            cmd=CMD_TPD_ZERO[index];
            break;
        case MOTO_TYPE_NORMAL:
            if(index==5){
                index=0;
            }
            cmd=CMD_TPD_NORMAL[index];
            break;
        default:
            break;
    }
    
    return cmd;
};
/**
 * 判断指令是否是改变转速的指令
 * @return
 */
-(BOOL) isTpdCmd{
    switch (_motoType) {
        case MOTO_TYPE_NORMAL:
            for(int i=0;i<5;i++){
                if(CMD_TPD_NORMAL[i]==_curCmd){
                    return true;
                }
            }
            break;
        case MOTO_TYPE_ZERO:
            for(int i=0;i<15;i++){
                if(CMD_TPD_NORMAL[i]==_curCmd){
                    return true;
                }
            }
            break;
        default:
            break;
    }
    return false;
};

-(int) getTpd{
    if(_motoType==MOTO_TYPE_ZERO){
        return TPDS_ZERO[_curTpdIndex];
    }
    return TPDS_NORMAL[_curTpdIndex];
};

-(BOOL) isAuthed{
    if(!isNeedAuth){
        return true;
    }
    return _authed;
};

-(void) setAuthed:(BOOL) authed{
    _authed = authed;
};

@end
