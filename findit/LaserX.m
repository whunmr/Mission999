//
//  Laser.m
//  findit
//
//  Created by Hongmin Wang on 5/30/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import "LaserX.h"
#import "common.h"
#import "GameScene.h"
#import "HMHero.h"

@interface LaserX()
//@property SKSpriteNode* laser_point;
@property SKSpriteNode* laser_line;
@property BOOL isDisable;
@property CGFloat originalWidth;
@property CGFloat last_length;
@end

@interface LaserLine : SKSpriteNode<SKContactable>
+(LaserLine*)laserLine;
@property CGFloat originalWidth;
@end

@implementation LaserLine
+(LaserLine*)laserLine {
    LaserLine* ll = [[LaserLine alloc] initWithColor:[SKColor greenColor] size:CGSizeMake(30, 8)];
    ll.originalWidth = 30;
    
    ll.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ll.size];
    ll.physicsBody.dynamic = NO;
    ll.physicsBody.categoryBitMask = ground_category;
    ll.physicsBody.collisionBitMask = hero_category;
    ll.name = @"ground";
    ll.position = CGPointMake(0, 6);
    return ll;
}


- (void)contact_body:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
    if ([body.node.name isEqualToString:@"hero"]) {
        HMHero* h = [HMHero hero];
        
        if (([contact.bodyA.node.name isEqualToString:@"hero"] && contact.contactNormal.dy < -0.001)
            ||  ([contact.bodyB.node.name isEqualToString:@"hero"] && contact.contactNormal.dy > 0.001) ) {
            
            [h jump_end_on_ground: self];
        }
        
        return;
    }
    
    if ([body.node conformsToProtocol:@protocol(SKContactable)]) {
        [((SKNode<SKContactable> *)body.node) contact_body:self.physicsBody with:contact];
    } else {
        NSLog(@"X laser line hit %@", body.node.name);
    }
}


-(void)end_contact:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
}


@end



@implementation LaserX
//static SKAction* laser_hit_sound;

+(void)initialize {
    //laser_hit_sound = [SKAction playSoundFileNamed:@"laser_hit.mp3" waitForCompletion:NO];
}

+(LaserX*)laserX: (NSString*)param {
    LaserX* la = [[LaserX alloc] init];
    
    la.originalWidth = 30;
    /*la.laser_line = [[SKSpriteNode alloc] initWithColor:[SKColor greenColor] size:CGSizeMake(la.originalWidth, 2)];
    
    la.laser_line.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:la.laser_line.size];
    la.laser_line.physicsBody.dynamic = NO;
    la.laser_line.physicsBody.categoryBitMask = ground_category;
    la.laser_line.physicsBody.collisionBitMask = hero_category;
    la.laser_line.name = @"laser";
    
    la.laser_line.position = CGPointMake(0, 6);*/
    la.laser_line = [LaserLine laserLine];
    [la addChild:la.laser_line];
    la.name = @"X";
    
    /*la.laser_point = [[SKSpriteNode alloc] initWithImageNamed:@"laser_point.png"];
    la.laser_point.xScale = la.laser_point.yScale = 0.3;
    la.laser_point.position = CGPointMake(la.laser_line.size.width+1, 2);
    la.laser_point.blendMode = SKBlendModeAdd;*/

    SKSpriteNode* emitOutter = [[SKSpriteNode alloc] initWithColor:[SKColor greenColor] size:CGSizeMake(12, 12)];
    emitOutter.position = CGPointMake(0, 1);
    [la addChild:emitOutter];
    
    SKSpriteNode* emit = [[SKSpriteNode alloc] initWithColor:[SKColor whiteColor] size:CGSizeMake(6, 6)];
    emit.position = CGPointMake(3, 0);
    [emitOutter addChild:emit];

    //[la.laser_line addChild:la.laser_point];
    la.zPosition = 1000;
    
    NSArray* ps = [param componentsSeparatedByString:@"/"];
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
    
    //NSLog(@"rotatedWaitTime %f", rotatedWaitTime);
    SKAction* rotateAction = [SKAction repeatActionForever:
                                 [SKAction sequence:@[
                                                      [SKAction EaseInOutRotateByAngle:D_2_R(rotateAngle) duration:rotateTime],
                                                      [SKAction _waitForDuration: rotatedWaitTime ],
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
                                                     [SKAction _waitForDuration:enableTime],
                                                     [SKAction runBlock:^{
                                                                la.isDisable = YES;
                                                                la.laser_line.alpha = 0;
                                                                [la shorten_xlaser_line];
                                                        }],
                                                     [SKAction _waitForDuration:disableTime],
                                                     [SKAction runBlock:^{la.isDisable = NO;
                                                                la.laser_line.alpha = 1;
                                                                CGFloat scaleFactor = la.last_length/la.originalWidth;
                                                                [la.laser_line runAction:[SKAction scaleXTo:scaleFactor duration:0]];
                                                                la.laser_line.position = CGPointMake(la.last_length/2, 1.5);
                                                        }]
                                ]]
                              ];
    
    
//#if 0
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
                                  [SKAction _waitForDuration:initWait]
                                  , [SKAction group:@[rotateAction, moveAction ]]
                              ]]
         ];
    }
//#endif
    
    return la;
}


- (void)shorten_xlaser_line {
    CGFloat length = 1;
    CGFloat scaleFactor = length/self.originalWidth;
    [self.laser_line runAction:[SKAction scaleXTo:scaleFactor duration:0]];
    self.laser_line.position = CGPointMake(length/2, 0);
}

-(void)update:(CFTimeInterval)currentTime {
    if (self.isDisable) {
        return;
    }

    __block BOOL hit = NO;
    
    GameScene* gs = [GameScene sharedInstance];
    
    [gs physicsBodyAlongRay:self.position len:2000 rotation:self.zRotation
            usingBlock:^(SKPhysicsBody *body, CGPoint point, CGVector normal, BOOL *stop) {

                if (body
                    && ! ( body.node.name.length == 0 || [body.node.name isEqualToString:@"hero"] )
                    && body.node.parent != self) {

                    CGPoint pp = [self.parent.scene convertPoint:self.position fromNode:self.parent];
                    
                    //CGPoint p = CGPointMake(pp.x + self.parent.scene.size.width/2, pp.y + self.parent.scene.size.height/2 + 2);
                    //NSLog(@"__ %f %f | %f %f | %f %f", p.x, p.y, point.x, point.y, self.position.x, self.position.y);
                    CGFloat length = fmax (1, DistanceBetweenPoints(pp, point) - 3);
                    
                    //NSLog(@"xx %f", length);
//                    NSLog(@"%f %f", length, self.last_length);
//                    if (fabs(length - self.last_length) < 7) {
//                        *stop = YES;
//                        hit = YES;
//                        return;
//                    }

                    self.last_length = length;
                    
                    CGFloat scaleFactor = length/self.originalWidth;
                    [self.laser_line runAction:[SKAction scaleXTo:scaleFactor duration:0]];
                    self.laser_line.position = CGPointMake(length/2, 1.5);
                    
                    *stop = YES;
                    hit = YES;
                }
    }];
    
    if (!hit) {
        [self shorten_xlaser_line];
        [self runAction:[SKAction resizeToWidth:2000 duration:0]];
        //self.laser_point.alpha = 0;
    }
}


@end
