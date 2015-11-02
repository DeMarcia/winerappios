//
//  NSObject+Utils.m
//  winerappios
//
//  Created by miu on 15/6/23.
//  Copyright (c) 2015年 jyz. All rights reserved.
//

#import "NSObject+Utils.h"

@implementation Utils

+(NSString*) byte2HexStr:(Byte) random{
    NSString *str = [NSString stringWithFormat:@"%02X",random];
    return str;
};

+(NSString*) byteArrayToHex:(Byte*)a{
    NSString *hexStr=@"";
    for(int i=0;i<sizeof(a);i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%02x",a[i]&0xff]; ///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
};

+(int) byteArrayToInt:(Byte*)a{
   return a[0] & 0xFF;
};

+(int) getArrayLength:(int*)a{
    int len=0;
    for(int i=0;i<a;i++){
        len++;
    }
    return len;
}

+(Byte) encode:(Byte) random{
    // 高低位取反
    Byte temp = (Byte) ((random << 4) & 0xf0);
    random &= 0xf0;
    random = (Byte) ((random >> 4) & 0x0f);
    random |= temp;
    // 和0x5a Xor
    random ^= 0x5a;
    return random;
}

+(Byte) decode:(Byte) num{
    // 和0x5a Xor
    num ^= 0x5a;
    // 高低位取反
    Byte temp = (Byte) ((num << 4) & 0xf0);
    num &= 0xf0;
    num = (Byte) ((num >> 4) & 0x0f);
    num |= temp;
    return num;
}



@end
