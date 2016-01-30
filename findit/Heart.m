//
//  Heart.m
//  findit
//
//  Created by Hongmin Wang on 5/11/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import "Heart.h"
#import "HMHero.h"

@implementation Heart

static SKAction* disapearAction;
+(void)initialize {
    disapearAction = [SKAction group:@[
                                     [SKAction sequence:@[[SKAction _waitForDuration:8], [SKAction removeFromParent]]]
                                     ,[SKAction EaseInOutMoveByX:0 y:600 duration:12]
                                     ]];
}

+ (Heart*)new_heart:(CGPoint)position {
    Heart* bp = [[Heart alloc] initWithImageNamed:[NSString stringWithFormat:@"heart%d.png", arc4random_uniform(3)]];
    bp.alpha = 1;
    bp.position = position;
    bp.name = @"heart";
    
    bp.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(bp.size.width+20, bp.size.height+20)];
    bp.physicsBody.dynamic = YES;
    bp.physicsBody.affectedByGravity = NO;
    bp.physicsBody.categoryBitMask = heart_category;
    bp.physicsBody.collisionBitMask = heart_category;
    bp.physicsBody.contactTestBitMask = hero_category;
    bp.physicsBody.fieldBitMask = 0;
    bp.physicsBody.allowsRotation = NO;
    
    bp.xScale = bp.yScale = 0.15;
    
    
    [bp runAction:[SKAction repeatActionForever:[SKAction sequence:@[
                                                                     [SKAction scaleBy:1.2 duration:0.5]
                                                                     , [SKAction scaleBy:0.833333 duration:0.5]
                                                                     ]]]];
    
    
    [bp runAction: [SKAction sequence:@[[SKAction moveTo:position duration:0]
                                           ,[SKAction fadeAlphaTo:1 duration:0]
                                        ]]];
    
    return bp;
}

+ (Heart*)new_disapearable_heart:(CGPoint)position {
    Heart* heart = [Heart new_heart:position];
    //TODO: h display in 10s  and render with blend factor
    [heart runAction: disapearAction ];

    return heart;
}


- (void)contact_body:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
    if ([body.node.name isEqualToString:@"hero"]) {
        [[HMHero hero] hurtby:self with:-1];        //TODO: 20 to contact force.
        [self removeFromParent];
    }
}

-(void)end_contact:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
}

@end
