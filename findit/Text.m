//
//  Text.m
//  findit
//
//  Created by Hongmin Wang on 6/20/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import "Text.h"

@implementation Text
+(Text*)text:(NSString*) param {
    Text* t = [[Text alloc] init];
    t.anchorPoint = CGPointZero;
    
    SKLabelNode* text = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
    text.fontSize = 10;
    text.text = [param substringFromIndex:[@"T:" length]];
    [text setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    [text setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    
    text.position = CGPointMake(([param length] - 2) * 3.1, 0);
    
    [t addChild:text];
    return t;
}
@end
