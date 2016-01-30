//
//  GameScene.h
//  findit
//

//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "common.h"

@interface GameScene : SKScene<SKPhysicsContactDelegate, GameApp>
- (id)initWithSize:(CGSize)size;
+ (id)sharedInstance;
- (SKNode*)world;
- (void)physicsBodyAlongRay:(CGPoint)start_point_in_world len:(CGFloat)len rotation:(CGFloat)rotation
                usingBlock:(void (^)(SKPhysicsBody *body, CGPoint point, CGVector normal, BOOL *stop))block;
- (void)reload_level_from_file:(NSString*)level_file_name;
@end
