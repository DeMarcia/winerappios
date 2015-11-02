//
//  NSObject+Utils.h
//  winerappios
//
//  Created by miu on 15/6/23.
//  Copyright (c) 2015年 jyz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils:NSObject

+(NSString*) byte2HexStr:(Byte) random;

+(NSString*) byteArrayToHex:(Byte[])a;

+(int) byteArrayToInt:(Byte[])a;

+(int) getArrayLength:(int*)a;

+(Byte) encode:(Byte) random;

+(Byte) decode:(Byte) num;

@end
