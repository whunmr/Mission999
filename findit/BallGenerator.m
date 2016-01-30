//
//  BallGenerator.m
//  findit
//
//  Created by Hongmin Wang on 6/14/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import "BallGenerator.h"
#import "common.h"
#import "Ball.h"

@implementation BallGenerator

+(BallGenerator*)ballGenerator:(NSString*)param  atPos:(CGPoint)pos  parent:(SKNode*)parent{
    NSArray* ps = [param componentsSeparatedByString:@"/"];
    
    CGFloat xforce = ValueOfIndexInTextArrayWithDefaultValue(ps, 1, 100);
    CGFloat yforce = ValueOfIndexInTextArrayWithDefaultValue(ps, 2, -100);
    CGFloat waitDuration = ValueOfIndexInTextArrayWithDefaultValue(ps, 3, 3);
    CGFloat ballLifeDuration = ValueOfIndexInTextArrayWithDefaultValue(ps, 4, 5);
    
    BallGenerator* bg = [[BallGenerator alloc] initWithImageNamed:@"ball_generator.png"];
    bg.zPosition = 1;
    bg.xScale = bg.yScale = 0.15;
    
    [bg runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:D_2_R(360) duration:8]]];
    bg.position = pos;

    [bg runAction:
        [SKAction repeatActionForever:
           [SKAction sequence:@[
               [SKAction _waitForDuration:waitDuration],
               [SKAction runBlock:^{
               Ball* b = [Ball ball: ballLifeDuration];
                    b.position = pos;
                    [parent addChild:b];
                    [b.physicsBody applyImpulse:CGVectorMake(xforce, yforce)];
               }]
           ]]
        ]
     ];
    return bg;
}

@end
