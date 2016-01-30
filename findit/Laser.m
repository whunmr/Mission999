//
//  Laser.m
//  findit
//
//  Created by Hongmin Wang on 5/30/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import "Laser.h"
#import "common.h"
#import "GameScene.h"

@interface Laser()
@property SKSpriteNode* laser_point;
@property SKSpriteNode* laser_line;
@property BOOL isDisable;
@end

@implementation Laser
//static SKAction* laser_hit_sound;

+(void)initialize {
    //laser_hit_sound = [SKAction playSoundFileNamed:@"laser_hit.mp3" waitForCompletion:NO];
}

+(Laser*)laser: (NSString*)param {
    Laser* la = [[Laser alloc] init];
    la.laser_line = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(1, 2)];
    la.laser_line.anchorPoint = CGPointMake(0, 0);
    [la addChild:la.laser_line];
    la.name = @"L";
    
//    la.laser_point = [[SKSpriteNode alloc] initWithImageNamed:@"laser_point.png"];
//    la.laser_point.xScale = la.laser_point.yScale = 0.3;
//    la.laser_point.position = CGPointMake(la.laser_line.size.width+1, 2);
//    la.laser_point.blendMode = SKBlendModeAdd;

    SKSpriteNode* emitOutter = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(12, 12)];
    emitOutter.position = CGPointMake(0, 1);
    [la addChild:emitOutter];
    
    SKSpriteNode* emit = [[SKSpriteNode alloc] initWithColor:[SKColor yellowColor] size:CGSizeMake(6, 6)];
    emit.position = CGPointMake(3, 0);
    [emitOutter addChild:emit];

    //[la.laser_line addChild:la.laser_point];
    la.zPosition = 1000;
    
    NSArray* ps = [param componentsSeparatedByString:@"/"];
    
    if ([[ps objectAtIndex:0] isEqualToString:@"L0"]) {
        la.isDisable = true;
    }
    
    CGFloat initAngle = ValueOfIndexInTextArray(ps, 1);
    CGFloat rotateAngle = ValueOfIndexInTextArray(ps, 2);
    CGFloat rotateTime = ValueOfIndexInTextArray(ps, 3);
    CGFloat rotatedWaitTime = ValueOfIndexInTextArray(ps, 4);
    CGFloat enableTime = ValueOfIndexInTextArray(ps, 5);
    CGFloat disableTime = ValueOfIndexInTextArray(ps, 6);
    
    CGFloat initWait = ValueOfIndexInTextArray(ps, 7);
    CGFloat xmove = ValueOfIndexInTextArray(ps, 8);
    CGFloat ymove = ValueOfIndexInTextArray(ps, 9);
    CGFloat moveTime = ValueOfIndexInTextArray(ps, 10);
    CGFloat movedWaitTime = ValueOfIndexInTextArray(ps, 11);
    

    la.zRotation = D_2_R(initAngle);

    SKAction* rotateAction = [SKAction repeatActionForever:
                                 [SKAction sequence:@[
                                                      [SKAction EaseInOutRotateByAngle:D_2_R(rotateAngle) duration:rotateTime],
                                                      [SKAction _waitForDuration:rotatedWaitTime],
                                                      [SKAction EaseInOutRotateByAngle:D_2_R(-rotateAngle) duration:rotateTime]
        ]]];
    
    
    SKAction* moveAction = [SKAction repeatActionForever:
                                [SKAction sequence:@[
                                                     [SKAction EaseInOutMoveByX:xmove y:ymove duration:moveTime],
                                                     [SKAction _waitForDuration:movedWaitTime],
                                                     [SKAction EaseInOutMoveByX:-xmove y:-ymove duration:moveTime]
                                ]]
                            ];
    
    SKAction* enableAction = [SKAction repeatActionForever:
                                [SKAction sequence:@[
                                                     [SKAction waitForDuration:enableTime],
                                                     [SKAction runBlock:^{
                                                                la.isDisable = YES;
                                                                la.laser_line.alpha = 0;
                                                                [la.laser_line runAction:[SKAction resizeToWidth:0 duration:0]];
                                                        }],
                                                     [SKAction _waitForDuration:disableTime],
                                                     [SKAction runBlock:^{la.isDisable = NO; la.laser_line.alpha = 1; }]
                                ]]
                              ];
    

    if (enableTime > 0 && disableTime > 0) {
        [la runAction:
            [SKAction sequence:@[
                    [SKAction _waitForDuration:initWait],
                    [SKAction group:@[rotateAction, moveAction, enableAction]]
           ]]
       ];
    } else {
        [la runAction:
         [SKAction sequence:@[
                              [SKAction _waitForDuration:initWait],
                              [SKAction group:@[rotateAction, moveAction]]
                              ]]
         ];
    }
    
    return la;
}


-(void)update:(CFTimeInterval)currentTime {
    if (self.isDisable) {
        return;
    }
    
    
    __block BOOL hit = NO;
    
    GameScene* gs = [GameScene sharedInstance];
    
    [gs physicsBodyAlongRay:self.position len:2000 rotation:self.zRotation
            usingBlock:^(SKPhysicsBody *body, CGPoint point, CGVector normal, BOOL *stop) {
                if (body && ![body.node.name isEqualToString:@"DH"]) {
                    CGPoint pp = [self.parent.scene convertPoint:self.position fromNode:self.parent];
                    //CGPoint p = CGPointMake(pp.x + self.parent.scene.size.width/2, pp.y + self.parent.scene.size.height/2 + 2);
                    //NSLog(@"__ %f %f | %f %f | %f %f", p.x, p.y, point.x, point.y, self.position.x, self.position.y);
                    CGFloat length = DistanceBetweenPoints(pp, point);
                    
                    self.laser_point.alpha = 1;
                    //self.laser_point.position = CGPointMake(self.laser_line.size.width+1, 2);
                    [self.laser_line runAction:[SKAction resizeToWidth:length-1 duration:0]];
                    if ([body.node conformsToProtocol:@protocol(Hurtable)]) {
                        [(SKNode<Hurtable>*)body.node hurtby:self with:1];
                        //[self runAction: laser_hit_sound];
                    }
                    
                    *stop = YES;
                    hit = YES;
                    
                    //NSLog(@"hit");
                }
    }];
    
    if (!hit) {
        //NSLog(@"not hit");
        [self.laser_line runAction:[SKAction resizeToWidth:5 duration:0]];
        //[self runAction:[SKAction resizeToWidth:1 duration:0]];
        //self.laser_point.alpha = 0;
    }
    
}


@end
