//
//  BluetoothCallback.h
//  winerappios
//
//  Created by miu on 15/6/1.
//  Copyright (c) 2015年 jyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BluetoothCallback <NSObject>

-(void) isOpenBluetooth;//初始化后判断蓝牙是否打开
-(void) isCloseBluetooth;//蓝牙关闭
-(void) startScanCallback;//开始搜索外设回调
-(void) successScanCallback:(CBPeripheral*) peripheral;//成功搜索外设回调,每次查找成功调用一次
-(void) finishScanCallback:(NSMutableArray*) peripherals;//搜索结束回调
-(void) startConncetCallback:(CBPeripheral*) peripheral;//开始连接设备的回调
-(void) successConnectCallback:(CBPeripheral*) peripheral;//成功连接到指定外设
-(void) disConncetCallback:(CBPeripheral*) peripheral;//连接外设失败
-(void) serviceDiscoverCallback:(CBPeripheral*) peripheral;//发现服务
-(void) targetCharacteristicDiscoveredCallback;//目标character发现
-(void) requestReadOrWriteCallback;//开始读写操作
-(void) responseReadOrWriteCallback;//返回读写操作
-(void) onCharacteristicChange:(Byte[]) param;//监听返回的参数


@end
