//
//  NSObject+BluetoothManager.h
//  winerappios
//
//  Created by miu on 15/6/1.
//  Copyright (c) 2015年 jyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BluetoothCallback.h"

@interface BluetoothManager:NSObject



+(instancetype)getInstance;//单例模式

-(void) operator:(id<BluetoothCallback>) mBluetoothCallback UUID:(NSString*) UUID;//操作，需要带个回调
- (void) scanPeripherals;//查找蓝牙设备
-(void) connectPeripheral:(CBPeripheral*) peripheral;//连接指定外设
-(void)writeCharacteristic:(Byte[]) data;//发送character
- (void)cleanup;

@end
