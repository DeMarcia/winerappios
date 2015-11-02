//
//  UIViewController+PeripheralsTableView.m
//  winerappios
//
//  Created by miu on 15/5/17.
//  Copyright (c) 2015年 jyz. All rights reserved.
//

#import "PeripheralsTableViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "ViewController.h"

@interface PeripheralsTableViewController() <UITableViewDataSource,UITableViewDelegate>
@property CBCentralManager *cbCentralManager;
@end
@implementation PeripheralsTableViewController

@synthesize str1;

-(void)viewDidLoad{
    [super viewDidLoad];
    if(_perihperalsList!=nil){
        NSLog(@"perihperal:%@",[_perihperalsList objectAtIndex:0]);
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_perihperalsList!=nil){
        return _perihperalsList.count;
    }else{
        return 0;
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cellForRowAtIndex");
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    CBPeripheral *rowPeripheral = [self.perihperalsList objectAtIndex:row];
    NSString *peripheralName = [rowPeripheral name];
    NSString *uuidString = [[rowPeripheral identifier] UUIDString];
    NSString *str = nil;
    if(peripheralName == nil){
        peripheralName = @"UnknowDevice";
    }
    str = [[NSString alloc] initWithFormat:@"%@,%@",peripheralName,uuidString];
    cell.textLabel.text =  str;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CBPeripheral *connectPeripheral = [_perihperalsList objectAtIndex:[indexPath row]];
    NSDictionary *dictionary =[NSDictionary dictionaryWithObject:connectPeripheral forKey:@"selectPeripheral"];
    //开始连接外设
    if(connectPeripheral!=nil){
//        [_cbCentralManager connectPeripheral:connectPeripheral options:nil];
        [self dismissViewControllerAnimated:YES completion:^{[[NSNotificationCenter defaultCenter] postNotificationName:@"connectDevice" object:self userInfo:dictionary];} ];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    _cbCentralManager = [segue.sourceViewController cbCentralManager];
}

@end
