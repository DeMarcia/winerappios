    //
    //  ResString.h
    //  winerappios
    //
    //  Created by miu on 15/6/2.
    //  Copyright (c) 2015年 jyz. All rights reserved.
    //相关的字符串

    #ifndef winerappios_ResString_h
    #define winerappios_ResString_h


    NSString* const btn_ok = @"OK";
    NSString* const btn_retry = @"Retry";
    NSString* const btn_exit = @"Exit";
    NSString* const btn_cancel = @"Cancel";

    //bluetooth
    /**错误弹框提示追加信息*/
    NSString* const tip_error_append = @"\nPlease retry connect an device.";
    /**进度提示：搜索设备*/
    NSString* const tip_find_device =@"Searching devices...";
    /**进度提示：连接设备*/
    NSString* const tip_connect_device = @"Connecting the device...";
    /**错误提示：您的设备上没有发现蓝牙模块*/
    NSString* const notBluetoothAvailable = @"Didnot found bluetooth service on your device!";
    /**错误提示：附近没有搜索到蓝牙设备*/
    NSString* const notDiscoveryDevices = @"Didnot found bluetooth devices nearby!";
    /**错误提示：连接失败*/
    NSString* const connectionFailed = @"Connect failed!";
    /**错误提示：查找服务失败*/
    NSString* const discoverServiceFailed=  @"Discover services failed!";
    /**错误提示：配对失败*/
    NSString* const matchFailed = @"Match failed!";
    /**错误提示：未知错误*/
    NSString* const unknowException = @"Unknow exception:";
    /**错误提示：连接错误*/
    NSString* const connectException = @"Connection broken!Maybe the server is busy or shutdown.";
    /**提示：连接成功配对成功*/
    NSString* const matchedConnected = @"Connect and verify success!";
    /**提示：您中途取消了搜索设备的操作*/
    NSString* const cancelSearchDevice = @"You canceled to search a device!";
    /**提示：您中途取消了选择设备的操作*/
    NSString* const cancelChooseDevice=  @"You canceled to choose a device!";
    /**提示：您中途取消了连接设备的操作*/
    NSString* const cancelConnectDevice = @"You canceled to connect the device!";
    /**提示：您中途取消了验证设备的操作*/
    NSString* const cancelVerifyDevice = @"You canceled to verify the device!";
    /**提示：您中途取消操作*/
    NSString* const cancelOperation = @"You canceled the operation!";
    /**进度提示：正在验证设备*/
    NSString* const beginVerify = @"Verifing the device now...";
    /**进度提示：正在初始化*/
    NSString* const beginInit = @"Initialize now...";
    /**错误提示：验证设备失败*/
    NSString* const verifyFailed = @"Verify the device faild...";
    /**错误提示：验证设备失败*/
    NSString* const initFailed = @"Initialize faild...";
    /**错误提示：没有连接到任何蓝牙设备 (发送指令时发现无设备的错误提示)*/
    NSString* const notConnectedWhenSendCmd = @"Not any bluetooth device connected!";


    #endif
