//
//  NSObject+BluetoothManager.m
//  winerappios
//
//  Created by miu on 15/6/1.
//  Copyright (c) 2015年 jyz. All rights reserved.
//

#import "NSObject+BluetoothManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BluetoothCallback.h"

static const int SCAN_PERIOD = 3;

@interface BluetoothManager()<CBCentralManagerDelegate,CBPeripheralDelegate>
@property CBCentralManager *cbCentralManager;
@property id<BluetoothCallback> callback;
@property NSMutableArray * peripherals;//查找出所有的设备
@property NSMutableArray* services;//所有的services
@property CBPeripheral * curPeripheral;//当前连接的设备

@property NSString* UUID;
@property BOOL isConnect;
@property BOOL isEnableReq;
@end

@implementation BluetoothManager

+(instancetype) getInstance
{
    static BluetoothManager* _instance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    
    return _instance ;
}

////为了控制单例保持一个对象
//+(instancetype)allocWithZone:(struct _NSZone *)zone{
//    return [BluetoothManager getInstance];
//}
//
//-(id) copyWithZone:(struct _NSZone *)zone
//{
//    return [BluetoothManager getInstance] ;
//}

-(void) operator:(id<BluetoothCallback>) mBluetoothCallback UUID:(NSString*) UUID{
    //初始化蓝牙管理中心
    _cbCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    NSLog(@"初始化蓝牙管理中心");
    _callback = mBluetoothCallback;
    _UUID = UUID;
}

/**查找设备并保存在集合中用于界面显示和选择*/
- (void) scanPeripherals{
    [self.cbCentralManager scanForPeripheralsWithServices:nil options:nil];
    if(_callback!=nil){
        [_callback startScanCallback];
    }
    NSLog(@"开始搜索");
    //5秒后结束搜索
    [NSTimer scheduledTimerWithTimeInterval:SCAN_PERIOD target:(self) selector:@selector(scanFinish) userInfo:nil repeats:NO];
}

//连接指定设备
-(void) connectPeripheral:(CBPeripheral*) peripheral{
    _isConnect = NO;
    if(_cbCentralManager!=nil){
        [_cbCentralManager connectPeripheral:peripheral options:nil];
        if(_callback!=nil){
            [_callback startConncetCallback:peripheral];
        }
    }
}

-(void) scanFinish{
    if(_callback!=nil){
        [_callback finishScanCallback:_peripherals];
        if(_cbCentralManager!=nil){
            [_cbCentralManager stopScan];
        }
        NSLog(@"搜索结束");
    }
}

-(BOOL)isConnectPeripheral{
    if(_cbCentralManager!=nil&&_curPeripheral!=nil&&_curPeripheral.state==CBPeripheralStateConnected){
        return YES;
    }else{
        
        return NO;
    }
}

//发送数据的函数
-(void)writeCharacteristic:(Byte[]) data{
    if([self isConnectPeripheral]){
        _isEnableReq = NO;
        NSMutableArray *characteristics = [self getCharacteristic];
        NSData* sendData = [[NSData alloc] initWithBytes:data length:1];
        for(CBCharacteristic *characteristic in characteristics){
            [_curPeripheral writeValue:sendData forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
        }
    }else{
        if(_callback!=nil){
            [_callback disConncetCallback:_curPeripheral];
        }
    }
        
}

-(NSMutableArray*)getCharacteristic{
    NSMutableArray* characteristics = [NSMutableArray arrayWithCapacity:6];
    if(_services!=nil){
        for(CBService *service in _services){
            for (CBCharacteristic *characteristic in service.characteristics) {
                
                if ([[characteristic.UUID UUIDString]isEqual:_UUID]) {
                    [characteristics addObject:characteristic];
                }
            }
        }
    }
    return characteristics;
}


//-----------------------------------以下为委托函数-----------------------------------------------

//用于检测蓝牙状态的方法
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    //蓝牙未打开｀
    if(central.state!=CBCentralManagerStatePoweredOn){
        NSLog(@"蓝牙未打开");
        if(_callback!=nil){
            [_callback isCloseBluetooth];
        }
    }else{
        NSLog(@"蓝牙已打开");
        if(_callback!=nil){
            [_callback isOpenBluetooth];
        }
    }
}

//查找的蓝牙设备
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    if(_peripherals==nil){
        _peripherals = [NSMutableArray arrayWithCapacity:6];
    }
    if(_callback!=nil){
        [_callback successScanCallback:peripheral];
    }
    [_peripherals addObject:peripheral];
    NSLog(@"peripheral name:%@,rssi:%@",peripheral.name,RSSI);
    
}

//连接到外设
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"连接到外设%@",peripheral);
    _curPeripheral = peripheral;
    _isConnect = YES;
    if(_callback!=nil){
        [_callback successConnectCallback:peripheral];
        if(_cbCentralManager!=nil&&peripheral!=nil){
            if(_isConnect){
                peripheral.delegate = self;
                [peripheral discoverServices:nil];
                if(_services==nil){
                    _services = [NSMutableArray arrayWithCapacity:6];
                }
            }
        }
    }
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"连接外设失败");
    _isConnect = NO;
    if(_callback!=nil){
        [_callback disConncetCallback:peripheral];
    }
}

-(void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals{
    
}

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        return;
    }
    if(_callback!=nil){
        [_callback serviceDiscoverCallback:peripheral];
        for (CBService *service in peripheral.services) {
            NSLog(@"找到服务，%@",service);
            [peripheral discoverCharacteristics:nil forService:service];
        }

    }
}

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    if(service!=nil){
        
        [_services addObject:service];
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog([@"ALL CHARACTER UUID" stringByAppendingString:[characteristic.UUID UUIDString]]);
        if ([[characteristic.UUID UUIDString] isEqual:_UUID]) {
            NSLog(@"查找出character，%@",characteristic);
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            [_callback targetCharacteristicDiscoveredCallback];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", error.localizedDescription);
        return;
    }
    Byte *byte = (Byte *)[characteristic.value bytes];
    if(byte!=nil){
    NSLog(@"UPDATE_VALUE:%02x",byte[0]);
    }else{
        NSLog(@"UPDATE_VALUE:nil");
    }
    if(byte[0]==0xff){
        return;
    }
    [_callback onCharacteristicChange:byte];
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Exit if it's not the transfer characteristic
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:_UUID]]) {
        return;
    }
    Byte *byte = (Byte *)[characteristic.value bytes];
    if(byte!=nil){
    NSLog(@"UPDATE_NOTIFY:%02x",byte[0]);
    }else{
        NSLog(@"UPDATE_NOTIFY:nil");
    }
}


- (void)cleanup
{
    if (!(self.curPeripheral.state == CBPeripheralStateConnected) ) {
        return;
    }
    if (self.curPeripheral.services != nil) {
        for (CBService *service in self.curPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                            // It is notifying, so unsubscribe
                            [self.curPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                }
            }
        }
    }
    [self.cbCentralManager cancelPeripheralConnection:self.curPeripheral];
    _peripherals = nil;
    _services = nil;
    _curPeripheral = nil;
    _isConnect = NO;
    _isEnableReq = NO;
}



@end
