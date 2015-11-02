//
//  ViewController.m
//  winerappios
//
//  Created by miu on 15/5/16.
//  Copyright (c) 2015年 jyz. All rights reserved.
//
#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "PeripheralsTableViewController.h"
#import "Constant.h"
#import "BluetoothCallback.h"
#import "NSObject+BluetoothManager.h"
#import "ResString.h"
#import "NSObject+Status.h"
#import "NSObject+Utils.h"


/**主界面控制器
 */
@interface ViewController ()<BluetoothCallback,UIAlertViewDelegate>

@property BluetoothManager *bluetoothManager;
@property NSMutableArray* peripherals;
@property UIAlertView *mAlertView;//页面一进入，加载框，等查找到蓝牙关闭
@property (weak, nonatomic) IBOutlet UIButton *powerBtn;
@property (weak, nonatomic) IBOutlet UIButton *switchBtn;
@property (weak, nonatomic) IBOutlet UIButton *motoBtn;
@property (weak, nonatomic) IBOutlet UIButton *turnBtn;
@property (weak, nonatomic) IBOutlet UIButton *tpdBtn;

@property (weak, nonatomic) IBOutlet UIImageView *imgTurnForward;//正向旋转图片
@property (weak, nonatomic) IBOutlet UIImageView *imgTurnBack;//反向旋转图片
@property (weak, nonatomic) IBOutlet UIImageView *imgLightSwitch;//灯开关
@property (weak, nonatomic) IBOutlet UIImageView *imgLightStatus;//灯电量
@property (weak, nonatomic) IBOutlet UIImageView *imgCurMoto;
@property (weak, nonatomic) IBOutlet UIImageView *imgCurTPD;


@property Status* mStatus;
@property UIAlertView* errorDialog;//错误弹出框

@end

@implementation ViewController

-(IBAction)btnAction:(id)sender{
    if(![_mStatus isLogined]){
        [self handleError:notConnectedWhenSendCmd];
        return;
    }
    UIButton *btn = (UIButton*)sender;
    int cmd = -1;
    switch ([btn tag]) {
        case 1:
            cmd = [_mStatus isLightOn] ? CMD_LIGHT_OFF: CMD_LIGHT_ON;
            NSLog(@"powerBtn");
            break;
        case 2:
            cmd = [_mStatus isSwitchOn] ? CMD_SWITCH_OFF: CMD_SWITCH_ON;
            NSLog(@"switchBtn");
            break;
        case 3:
            NSLog(@"motoBtn");
            if(_mStatus.motoNums<=1){
                return;
            }
            cmd = [_mStatus getCurMotoCmd];
            [self sendCmdWithInt:cmd withCurCmd:CMD_MOTO_FLAG];
            return;	//TODO 注意这里已经发完指令 直接返回
            break;
        case 4:
            if (_mStatus.turnStatus==TURN_STATUS_FORWARD) {
                cmd = CMD_TURN_BACK;
            }else if(_mStatus.turnStatus==TURN_STATUS_BACK){
                cmd = CMD_TURN_ALL;
            }else if(_mStatus.turnStatus==TURN_STATUS_ALL){
                cmd = CMD_TURN_FOWARD;
            }
            NSLog(@"turnBtn");
            break;
        case 5:
            cmd = [_mStatus getCurTpdCmd];
            NSLog(@"tpdBtn");
            break;
        default:
            break;
    }
    [self sendCmd:cmd];
}

- (IBAction)exitAction:(id)sender {
    exit(0);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString* iphoneName = [UIDevice currentDevice].model;
    NSString* iphoneVersion = [UIDevice currentDevice].localizedModel;
    
    NSLog(@"设备版本号:%@%@",iphoneName,iphoneVersion);
    
    [self updateStatusView];
    //界面加载完成搜索蓝牙设备
    _bluetoothManager = [BluetoothManager getInstance];
    [_bluetoothManager operator:self UUID:UUID_CH_WRITE];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(toDoConnectDevice:) name:@"connectDevice" object:nil];
}

-(void)toDoConnectDevice:(NSNotification*)sender{
    NSDictionary *data = [sender userInfo];
    CBPeripheral *perpheral = [data objectForKey:@"selectPeripheral"];
    if(perpheral!=nil&&(perpheral.state != CBPeripheralStateConnected)){
        [_bluetoothManager connectPeripheral:perpheral];
    }
}

//跳转界面传值
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"getPeripheralsID"]) //"goView2"是SEGUE连线的标识
    {
        id theSegue = segue.destinationViewController;
        [theSegue setValue:_peripherals forKey:@"perihperalsList"];
    }
}

//弹出加载框
-(void)showProgressDialog:(NSString *)showMsg{
    [self dismissProgressDialog];
    _mAlertView = [[UIAlertView alloc] initWithTitle:nil message:showMsg delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    aiv.center = CGPointMake(_mAlertView.bounds.size.width / 2.0f, _mAlertView.bounds.size.height - 40.0f);
    [aiv startAnimating];
    [_mAlertView addSubview:aiv];
    [_mAlertView show];
}

//关闭加载框
-(void)dismissProgressDialog{
    if(_mAlertView!=nil){
        [_mAlertView dismissWithClickedButtonIndex:0 animated:YES];
        _mAlertView = nil;
    }
}


//-------------------------------发送指令的函数---------------------
/** 发送指令 */
-(void) sendCmdWithByte:(Byte)cmd withCurCmd:(int)curCmd {
    [_mStatus setCurCmd:curCmd];
    Byte b[] = {cmd};
    NSString* str = [Utils byte2HexStr:b[0]];
    [[BluetoothManager getInstance] writeCharacteristic:b];
    NSLog(@"发送指令%02x,%@",cmd,str);
}
/** 发送指令 */
-(void) sendCmdWithInt:(int)cmd withCurCmd:(int)curCmd{
    [_mStatus setCurCmd:curCmd];
    Byte cmdbyte=(Byte)cmd;
    Byte b[] = {cmdbyte};
     NSString* str = [Utils byte2HexStr:b[0]];
    [[BluetoothManager getInstance] writeCharacteristic:b];
    NSLog(@"发送指令%d,%@",cmd,str);
}
/** 发送指令 */
-(void) sendCmd:(int)cmd {
    [_mStatus setCurCmd:cmd];
    Byte cmdbyte=(Byte)cmd;
    Byte b[] = {cmdbyte};
     NSString* str = [Utils byte2HexStr:b[0]];
    [[BluetoothManager getInstance] writeCharacteristic:b];
    NSLog(@"发送指令%d,%@",cmd,str);
}
/** 发送指令 */
-(void) sendData:(Byte[])data {
    [Utils byteArrayToHex:data];
    [[BluetoothManager getInstance] writeCharacteristic:data];
}
//-----------------------------更新界面-----------------------------------------
-(void) updateStatusView{
    if(_mStatus == nil){
        _mStatus = [Status alloc];
    }
    if ([_mStatus isLogined]) {
        [self startImageTurnBackAnim];
        [self startImageTurnForwardAnim];
        
        if ([_mStatus isLightOn]){
            [self startLightOnAnim];
        } else {
            [_imgLightStatus stopAnimating];
            [_imgLightStatus setImage:[UIImage imageNamed:@"ico-light-00.png"]];
        }
        if ([_mStatus isSwitchOn]) {
            [self startSwitchOnAnim];
        } else {
            [_imgLightSwitch stopAnimating];
            [_imgLightSwitch setImage:[UIImage imageNamed:@"ico-r-00.png"]];
             
        }
        
    } else {
        [_imgTurnBack stopAnimating];
        [_imgTurnForward stopAnimating];
        [_imgLightStatus stopAnimating];
        [_imgLightSwitch stopAnimating];
        [_imgTurnBack stopAnimating];
        
        [_imgTurnForward setImage:[UIImage imageNamed:@"r01.png"]];
        [_imgTurnBack setImage:[UIImage imageNamed:@"l01.png"]];
        if ([_mStatus isLightOn]) {
            [_imgLightStatus setImage:[UIImage imageNamed:@"ico-light-05.png"]];
        } else {
            [_imgLightStatus setImage:[UIImage imageNamed:@"ico-light-00.png"]];
        }
        if ([_mStatus isSwitchOn]) {
            [_imgLightSwitch setImage:[UIImage imageNamed:@"ico-r-01.png"]];
        } else {
            [_imgLightSwitch setImage:[UIImage imageNamed:@"ico-r-00.png"]];
        }
    }
    if(_mStatus.turnStatus==TURN_STATUS_ALL){
        _imgTurnForward.hidden = NO;
        _imgTurnBack.hidden = NO;
    }else if(_mStatus.turnStatus == TURN_STATUS_BACK){
        _imgTurnForward.hidden = YES;
        _imgTurnBack.hidden = NO;
    }else if(_mStatus.turnStatus == TURN_STATUS_FORWARD){
        _imgTurnForward.hidden = NO;
        _imgTurnBack.hidden = YES;
    }
    
    CGRect mainRect = [UIScreen mainScreen].applicationFrame;
    
    UIImage *newImgMoto = [self drawImage:_mStatus.curMoto+1 Type:0];
    UIImage *newImgTPD =[self drawImage:[_mStatus getTpd] Type:1];
    CGRect rect=_imgCurMoto.frame;
    CGRect rect2=_imgCurTPD.frame;
    float mScale = rect.size.height/newImgMoto.size.height;
    _imgCurMoto.frame = CGRectMake(rect.origin.x,mainRect.size.height*2/5,newImgMoto.size.width*mScale, rect.size.height);
    _imgCurTPD.frame = CGRectMake(rect2.origin.x,mainRect.size.height*2/5+rect.size.height*1.3,newImgTPD.size.width*mScale, rect2.size.height);
    [_imgCurMoto setImage:newImgMoto];
    [_imgCurTPD setImage:newImgTPD];
//    imgCurMoto.setImageBitmap(drawNumImg(status.getCurMoto()+1));
//    imgCurTpd.setImageBitmap(drawNumImg(status.getTpd()));
}

-(void) startImageTurnBackAnim{
    [_imgTurnBack stopAnimating];
    NSMutableArray *arrayM = [NSMutableArray array];
    for (int i=1; i<25; i++) {
        [arrayM addObject:[UIImage imageNamed:[NSString stringWithFormat:@"l%02d.png",i]]];
    }
    //设置动画数组
    [_imgTurnBack setAnimationImages:arrayM];
    //设置动画播放次数
    [_imgTurnBack setAnimationRepeatCount:-1];
    [_imgTurnBack setAnimationDuration:6];
    //开始动画
    [_imgTurnBack startAnimating];
}

-(void) startImageTurnForwardAnim{
    [_imgTurnForward stopAnimating];
    NSMutableArray *arrayM = [NSMutableArray array];
    for (int i=1; i<25; i++) {
        [arrayM addObject:[UIImage imageNamed:[NSString stringWithFormat:@"r%02d.png",i]]];
    }
    //设置动画数组
    [_imgTurnForward setAnimationImages:arrayM];
    //设置动画播放次数
    [_imgTurnForward setAnimationRepeatCount:-1];
    [_imgTurnForward setAnimationDuration:6];
    //开始动画
    [_imgTurnForward startAnimating];
}

-(void) startLightOnAnim{
    [_imgLightStatus stopAnimating];
    NSMutableArray *arrayM = [NSMutableArray array];
    for (int i=0; i<6; i++) {
        [arrayM addObject:[UIImage imageNamed:[NSString stringWithFormat:@"ico-light-%02d.png",i]]];
    }
    //设置动画数组
    [_imgLightStatus setAnimationImages:arrayM];
    //设置动画播放次数
    [_imgLightStatus setAnimationRepeatCount:-1];
    [_imgLightStatus setAnimationDuration:6*0.5];
    //开始动画
    [_imgLightStatus startAnimating];
}

-(void) startSwitchOnAnim{
    [_imgLightSwitch stopAnimating];
    NSMutableArray *arrayM = [NSMutableArray array];
    for (int i=0; i<3; i++) {
        [arrayM addObject:[UIImage imageNamed:[NSString stringWithFormat:@"ico-r-%02d.png",i]]];
    }
    //设置动画数组
    [_imgLightSwitch setAnimationImages:arrayM];
    //设置动画播放次数
    [_imgLightSwitch setAnimationRepeatCount:-1];
    [_imgLightSwitch setAnimationDuration:3*0.5];
    //开始动画
    [_imgLightSwitch startAnimating];
}
             
-(UIImage*) drawImage:(int)num Type:(int)MorTpd{
    NSMutableArray *nums = [NSMutableArray arrayWithCapacity:10];
    int tempNum = num;
    while (tempNum!=0) {
        [nums addObject:[NSNumber numberWithInt:tempNum%10]];
        tempNum = tempNum/10;
    }
    UIImage *uiImageNum0 = [UIImage imageNamed:@"number0.png"];
    UIImage *uiImageM = [UIImage imageNamed:@"m.png"];
    UIImage *uiImageTpd = [UIImage imageNamed:@"tpd.png"];
    int spacing = uiImageNum0.size.width/20;
    CGFloat width;
    CGFloat height;
    if(MorTpd == 0){
        if(nums.count==0){
            width = uiImageNum0.size.width+uiImageM.size.width+spacing;
        }else{
        width = (uiImageNum0.size.width+spacing)*nums.count+uiImageM.size.width;
            
        }
        height = uiImageNum0.size.height;
    }else if(MorTpd == 1){
        if(nums.count==0){
            width = uiImageNum0.size.width+uiImageM.size.width+spacing;
        }else{
        width = (uiImageNum0.size.width+spacing)*nums.count+uiImageTpd.size.width;
       
        }
         height = uiImageNum0.size.height;
    }
    CGSize offScreenSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(offScreenSize);
    int tempWidth=0;
    if(nums.count==0){
        [uiImageNum0 drawInRect:CGRectMake(0,0,uiImageNum0.size.width,uiImageNum0.size.height)];
        tempWidth = uiImageNum0.size.width + tempWidth+spacing;
    }else{
    for(int i=nums.count-1;i>=0;i--){
        NSNumber *number = [nums objectAtIndex:i];
        int itemNUM = [number intValue];
        NSString *imageName =[NSString stringWithFormat:@"number%d.png",itemNUM];
        UIImage *numberImage = [UIImage imageNamed:imageName];
        [numberImage drawInRect:CGRectMake(tempWidth,0,numberImage.size.width,numberImage.size.height)];
        tempWidth = numberImage.size.width + tempWidth+spacing;
        NSLog(@"width%d,%d",tempWidth,itemNUM);
    }
    }
    if(MorTpd == 0){
        [uiImageM drawInRect:CGRectMake(tempWidth,height-uiImageM.size.height,uiImageM.size.width,uiImageM.size.height)];
    }else if(MorTpd == 1){
        [uiImageTpd drawInRect:CGRectMake(tempWidth,height-uiImageTpd.size.height,uiImageTpd.size.width,uiImageTpd.size.height)];
    }
    UIImage *newImage =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
 }

//------------------------------以下为蓝牙连接的回调-------------------------------
-(void)isOpenBluetooth{
    if(_bluetoothManager!=nil){
        [_bluetoothManager scanPeripherals];
    }
}

-(void)isCloseBluetooth{
//iphone检测蓝牙会自动提示用户打开蓝牙设备
//    [self dismissProgressDialog];
//    UIAlertView *cbSwitchOnAlertView = [[UIAlertView alloc] initWithTitle:nil message:notBluetoothAvailable delegate:self cancelButtonTitle:@"exit" otherButtonTitles:nil, nil];
//    [cbSwitchOnAlertView show];
}

-(void)startScanCallback{
    [self showProgressDialog:tip_find_device];//开始搜索外设的加载框
}

-(void)successScanCallback:(CBPeripheral *)peripheral{
    
}

-(void)finishScanCallback:peripherals{
    [self dismissProgressDialog];
    _peripherals = peripherals;
    //跳转显示蓝牙设备
    [self performSegueWithIdentifier:@"getPeripheralsID" sender:self];
}

-(void)startConncetCallback:(CBPeripheral *)peripheralstart{
     [self showProgressDialog:tip_connect_device];
}

-(void)successConnectCallback:(CBPeripheral *)peripheral{
    [self dismissProgressDialog];
}

-(void)disConncetCallback:(CBPeripheral *)peripheral{
    [self handleError:connectionFailed];

}

-(void)serviceDiscoverCallback:(CBPeripheral *)peripheral{

}

-(void)requestReadOrWriteCallback{

}

-(void)responseReadOrWriteCallback{

}

-(void)targetCharacteristicDiscoveredCallback{
    _mStatus = [Status alloc];
    [self showProgressDialog:beginVerify];
    // 开始验证连接
    float ran = arc4random()%100;
    float ranFloat = ran/100;
    Byte randNo = (Byte)(ranFloat*0xfe);
    if(D){
        NSString* str = [Utils byte2HexStr:randNo];
        NSLog(@"%@",[@"rand 0x" stringByAppendingString:str]);
    }
    _mStatus.authCode = randNo;
    //验证
    //				sendData(new byte[]{(byte) 0xcc,Utils.encode(randNo)});
    //TODO 注意 此处改为分两次发送 每次一字节
    [self sendCmdWithInt:0xcc withCurCmd:CMD_AUTH_FLAG];
    //TODO 改为不加密了
    [self sendCmdWithInt:[Utils encode:randNo] withCurCmd:CMD_AUTH_FLAG];
    [self updateStatusView];
}

-(void)onCharacteristicChange:(Byte *)param{
    unsigned long len = strlen((char*)param);
    if(![_mStatus isAuthed]&&_mStatus.curCmd==CMD_AUTH_FLAG){
        if(len ==1&&param[0]==_mStatus.authCode){
            [self showProgressDialog:beginInit];
            //验证成功
            [_mStatus setAuthed:TRUE];
            //请求初始化马达
            [self sendCmd:CMD_INIT_MOTO];
        }else{
            //error
            [self handleError:verifyFailed];
        }
        return;
    }
    if(_mStatus.isAuthed && !_mStatus.isLogined && _mStatus.curCmd==CMD_INIT_MOTO&&len==1 ){
        _mStatus.isLogined = true;
        //TODO 初始化指令已经修改为0x7f开始
        int motoData = [Utils byteArrayToInt:param];
        if(motoData==CMD_MOTO_ZERO){
            _mStatus.motoNums = 1;
            _mStatus.motoType = MOTO_TYPE_ZERO;
        }else if(motoData>=CMD_MOTO_BEGIN&&motoData<CMD_MOTO_END){
            _mStatus.motoNums =motoData-CMD_MOTO_BEGIN+1;
            _mStatus.motoType = MOTO_TYPE_NORMAL;
        }else{
            _mStatus.isLogined = false;
        }
        //马达初始化成功代表登录成功
        if(_mStatus.isLogined){
            [self dismissProgressDialog];
            [self showToast:matchedConnected];
    
        }else{
            [self handleError:initFailed];
        }
        return;
    }
    //指令反馈
    if(_mStatus.isLogined && len == 1&&param[0] == (Byte)0xaa){
        if(_mStatus.curCmd == CMD_LIGHT_ON){
            _mStatus.isLightOn = true;
        }else if(_mStatus.curCmd == CMD_LIGHT_OFF){
            _mStatus.isLightOn = false;
        }else if(_mStatus.curCmd == CMD_MOTO_FLAG){
            [_mStatus changeMoto];
        }else if(_mStatus.curCmd == CMD_SWITCH_OFF){
            _mStatus.isSwitchOn = false;
        }else if(_mStatus.curCmd == CMD_SWITCH_ON){
            _mStatus.isSwitchOn = true;
        }else if(_mStatus.curCmd == CMD_TURN_ALL){
            _mStatus.turnStatus = TURN_STATUS_ALL;
        }else if(_mStatus.curCmd == CMD_TURN_BACK){
            _mStatus.turnStatus = TURN_STATUS_BACK;
        }else if(_mStatus.curCmd == CMD_TURN_FOWARD){
            _mStatus.turnStatus = TURN_STATUS_FORWARD;
        }else{
            if(_mStatus.isTpdCmd){
                [_mStatus changeTpd];
            }
        }
        [self updateStatusView];
        return;
    }

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if([alertView isEqual:self.errorDialog]){
        switch (buttonIndex) {
            case 0:
                [self dismissProgressDialog];
                break;
            case 1:
                [self dismissProgressDialog];
                [[BluetoothManager getInstance] scanPeripherals];
                break;
                
            default:
                break;
        }
    }
}

-(void) handleError:(NSString*) error{
    [self dismissProgressDialog];
    [[BluetoothManager getInstance] cleanup];
    [self updateStatusView];
    NSString *msg = [error stringByAppendingString:tip_error_append];
    if (self.errorDialog!=nil) {
        [self.errorDialog setMessage:msg];
    } else {
        self.errorDialog = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:btn_cancel otherButtonTitles:btn_retry, nil];
        [self.errorDialog show];
    }

}

-(void) showToast:(NSString*) msg{
    CGRect mainCGRect =[UIScreen mainScreen].applicationFrame;
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(mainCGRect.size.width*1/6,mainCGRect.size.height*4/5,mainCGRect.size.width*2/3,40)];
    hintLabel.layer.cornerRadius = 15;
    hintLabel.layer.masksToBounds =YES;
    hintLabel.textAlignment = NSTextAlignmentCenter;
    hintLabel.backgroundColor = [UIColor darkGrayColor];
    hintLabel.alpha = 0.0;
    hintLabel.textColor  = [UIColor whiteColor];
    hintLabel.text = msg;
    [self.view addSubview:hintLabel];
    //animateWithDuration可以控制label显示持续时间
    [UIView animateWithDuration:0.5 animations:^{
        hintLabel.alpha = 1.0;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:1 animations:^{
            hintLabel.alpha = 0.9;
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.5 animations:^{
                hintLabel.alpha = 0;
            } completion:^(BOOL finished){
                
                [hintLabel removeFromSuperview];
            }];
        }];
    }];
}

    

@end
