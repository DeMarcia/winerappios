//
//  NSObject+Status.h
//  winerappios
//
//  Created by miu on 15/6/1.
//  Copyright (c) 2015年 jyz. All rights reserved.
//描述灯光指令状态的类

#import <Foundation/Foundation.h>

@interface Status:NSObject{
}

@property int curCmd;
@property Byte authCode;
@property BOOL isLightOn;
@property int motoNums;
@property int curMoto;
@property BOOL isSwitchOn;
@property int turnStatus;
@property int curTpdIndex;
@property BOOL isLogined;
@property int motoType;

extern const int CMD_LIGHT_ON;//亮灯指令
extern const int CMD_LIGHT_OFF;//暗灯指令
extern const int CMD_SWITCH_ON;//开灯指令
extern const int CMD_SWITCH_OFF;//关灯指令
extern const int CMD_MOTO_ZERO;	//初始化特殊马达
extern const int CMD_MOTO_BEGIN;
extern const int CMD_MOTO_END;
//extern const int CMD_MOTO;//请求马达指令
extern const int CMD_TURN_FOWARD;//正传指令
extern const int CMD_TURN_BACK;//反转指令
extern const int CMD_TURN_ALL;//循环
extern const int CMD_INIT_MOTO;//初始化马达指令

//向下位机发送验证指令 TODO 这里只是为了标识状态来判断什么时候接受验证数据，并不是真的指令
extern const int CMD_AUTH_FLAG;//登录验证指令
//向下位机发送变更moto的指令 TODO 这里只是为了标识状态来判断当前的指令是用来改变MOTO的是为了方便后面的状态改变而用的标识，并非真的指令，真的智力见getCurMotoCmd()
extern const int CMD_MOTO_FLAG;

extern const int TURN_STATUS_FORWARD;
extern const int TURN_STATUS_BACK;
extern const int TURN_STATUS_ALL;

//马达类型分为两种，两种tpd不同
extern const int MOTO_TYPE_ZERO;
extern const int MOTO_TYPE_NORMAL;

//MOTO类型分为两种 两种TPD不同
extern const int MOTO_TYPE_ZERO;
extern const int MOTO_TYPE_NORMAL;

-(void) changeMoto;
-(int) getCurMotoCmd;

-(void) changeTpd;
/**
 * 获得当前的tpd指令
 * @return
 */
-(int) getCurTpdCmd;
/**
 * 判断指令是否是改变转速的指令
 * @return
 */
-(BOOL) isTpdCmd;

-(int) getTpd;

-(BOOL) isAuthed;

-(void) setAuthed:(BOOL) authed;

@end