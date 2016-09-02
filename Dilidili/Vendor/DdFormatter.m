//
//  DdFormatter.m
//  Dilidili
//
//  Created by iMac on 16/8/29.
//  Copyright © 2016年 BoxingWoo. All rights reserved.
//

#import "DdFormatter.h"

@implementation DdFormatter

+ (NSString *)stringForCount:(NSUInteger)count
{
    float result = count / 10000.0;
    if (result < 1) {
        return [NSString stringWithFormat:@"%lu", count];
    }else {
        return [NSString stringWithFormat:@"%.1f万", result];
    }
}

@end
