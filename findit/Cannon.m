//
//  Cannon.m
//  findit
//
//  Created by Hongmin Wang on 6/7/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import "Cannon.h"
#import "GameScene.h"
#import "Bullet.h"

@interface Cannon()
@property SKSpriteNode* cannon_line;
@property BOOL isDisable;
@property CFTimeInterval last_fire_time;
@end

@implementation Cannon
static SKAction* actionGunShotSound;

+(void)initialize {
    actionGunShotSound = [SKAction playSoundFileNamed:@"gun_fire.mp3" waitForCompletion:NO];
}

+(Cannon*)cannon: (NSString*)param {
    Cannon* la = [[Cannon alloc] init];
    la.cannon_line = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(5, 2)];
    la.cannon_line.anchorPoint = CGPointMake(0, 0);
    [la addChild:la.cannon_line];
    la.name = @"C";
    
    /*la.cannon_point = [[SKSpriteNode alloc] initWithImageNamed:@"laser_point.png"];
    la.cannon_point.xScale = la.cannon_point.yScale = 0.3;
    la.cannon_point.position = CGPointMake(la.cannon_line.size.width+1, 2);
    la.cannon_point.blendMode = SKBlendModeAdd;*/
    
    SKSpriteNode* emitOutter = [[SKSpriteNode alloc] initWithColor:[SKColor colorWithHexString:@"#ffcc33" alpha:1] size:CGSizeMake(12, 12)];
    emitOutter.position = CGPointMake(0, 1);
    [la addChild:emitOutter];
    
    
    SKSpriteNode* emitCenter = [[SKSpriteNode alloc] initWithColor:[SKColor colorWithHexString:@"ff9900" alpha:1] size:CGSizeMake(4, 8)];
    emitCenter.position = CGPointMake(0, 0);
    [emitOutter addChild:emitCenter];
    
    SKSpriteNode* emit = [[SKSpriteNode alloc] initWithColor:[SKColor colorWithHexString:@"ff9900" alpha:1] size:CGSizeMake(30, 4)];
    emit.position = CGPointMake(15, 0);
    [emitOutter addChild:emit];
    
    
    SKSpriteNode* emitHead = [[SKSpriteNode alloc] initWithColor:[SKColor colorWithHexString:@"#D2C5ED" alpha:1] size:CGSizeMake(6, 6)];
    emitHead.position = CGPointMake(30, 0);
    [emitOutter addChild:emitHead];
    
    la.zPosition = 1000;
    la.xScale = la.yScale = 0.8;
    
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
                                                   [SKAction _waitForDuration:enableTime],
                                                   [SKAction runBlock:^{
                                  la.isDisable = YES;
                                  la.cannon_line.alpha = 0;
                                  [la.cannon_line runAction:[SKAction resizeToWidth:0 duration:0]];
                              }],
                                                   [SKAction _waitForDuration:disableTime],
                                                   [SKAction runBlock:^{la.isDisable = NO; la.cannon_line.alpha = 1; }]
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
    
    if (currentTime - self.last_fire_time < 0.6) {
        return;
    }
    
    __block BOOL hit = NO;
    
    GameScene* gs = [GameScene sharedInstance];
    [gs physicsBodyAlongRay:self.position len:2000 rotation:self.zRotation
                 usingBlock:^(SKPhysicsBody *body, CGPoint point, CGVector normal, BOOL *stop) {
                     if ([body.node.name isEqualToString:@"hero"]) {
                         //CGPoint pp = [self.parent.scene convertPoint:self.position fromNode:self.parent];
                         //CGPoint p = CGPointMake(pp.x + self.parent.scene.size.width/2, pp.y + self.parent.scene.size.height/2 + 2);
                         
                         //NSLog(@"__ %f %f | %f %f | %f %f", p.x, p.y, point.x, point.y, self.position.x, self.position.y);
                         //CGFloat length = DistanceBetweenPoints(p, point);
                         
                         //self.cannon_point.alpha = 1;
                         //self.cannon_point.position = CGPointMake(self.cannon_line.size.width+1, 2);
                         //[self.cannon_line runAction:[SKAction resizeToWidth:length-1 duration:0]];
                         
                         //if ([body.node conformsToProtocol:@protocol(Hurtable)]) {
                         //    [(SKNode<Hurtable>*)body.node hurtby:self with:1];
                         //}
                         
                         CGPoint initPos = CGPointMake(self.position.x + 35 * cosf(self.zRotation), self.position.y + 35 * sinf(self.zRotation));
                         Bullet* bullet = [Bullet bullet];
                         bullet.position = initPos;
                         [self.parent addChild:bullet];
                         
                         SKAction* bulletAction = [SKAction sequence:
                                                   @[[SKAction moveTo:CGPointMake(self.position.x + 2000 * cosf(self.zRotation), self.position.y + 2000 * sinf(self.zRotation)) duration:6],
                                                     [SKAction removeFromParent]]];
                         
                         [bullet runAction:[SKAction group:@[bulletAction, actionGunShotSound]]];
                         
//                         [self runAction:
//                           [SKAction sequence:@[
//                            [SKAction _waitForDuration:0.5],
//                            [SKAction runBlock:^{
//                             Bullet* bullet = [Bullet bullet];
//                             bullet.position = initPos;
//                             [self.parent addChild:bullet];
//                             
//                             SKAction* bulletAction = [SKAction sequence:
//                                                       @[[SKAction moveTo:CGPointMake(self.position.x + 2000 * cosf(self.zRotation), self.position.y + 2000 * sinf(self.zRotation)) duration:6],
//                                                         [SKAction removeFromParent]]];
//                             
//                             [bullet runAction:[SKAction group:@[bulletAction, actionGunShotSound]]];
//                           }]]]];
                         
//                         [self runAction:
//                          [SKAction sequence:@[
//                                               [SKAction _waitForDuration:0.5],
//                                               [SKAction runBlock:^{
//                              Bullet* bullet = [Bullet bullet];
//                              bullet.position = initPos;
//                              [self.parent addChild:bullet];
//                              
//                              SKAction* bulletAction = [SKAction sequence:
//                                                        @[[SKAction moveTo:CGPointMake(self.position.x + 2000 * cosf(self.zRotation), self.position.y + 2000 * sinf(self.zRotation)) duration:6],
//                                                          [SKAction removeFromParent]]];
//                              
//                              [bullet runAction:[SKAction group:@[bulletAction, actionGunShotSound]]];
//                          }]]]];
//                         
                         
                         self.last_fire_time = currentTime;
                         hit = YES;
                         *stop = YES;
                     }
                 }];
    
    if (!hit) {
        //[self runAction:[SKAction resizeToWidth:2000 duration:0]];
        //self.cannon_point.alpha = 0;
    }
    
}


@end
