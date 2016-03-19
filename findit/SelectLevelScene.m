//
//  SelectLevelScene.m
//  findit
//
//  Created by Hongmin Wang on 3/1/16.
//  Copyright © 2016 www.whunmr.com. All rights reserved.
//

#import "SelectLevelScene.h"
#import "GameScene.h"

@implementation SelectLevelScene
- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    self.scaleMode = SKSceneScaleModeAspectFill;
    self.backgroundColor = [SKColor blackColor];
    sharedInstance = self;
    return self;
}


static SKAction* play_select_level_sound_action;
static SKAction* play_select_level_sound_action2;

+(void)initialize {
    play_select_level_sound_action = [SKAction playSoundFileNamed:@"select_level.mp3" waitForCompletion:NO];
    play_select_level_sound_action2 = [SKAction playSoundFileNamed:@"victory2.mp3" waitForCompletion:NO];
}

static bool initialized = false;

-(void)didMoveToView:(SKView *)view {
    
    if (!initialized) {
        initialized = true;
        
        int w = view.scene.size.width;
        int h = view.scene.size.height;
        
        const int levelWidth = 30;
        
        const int labelsInALine = w / (levelWidth + levelWidth/2);

        //TODO: calc 61 from level count
        for (int i = 0; i < 61; ++i) {
            SKSpriteNode* level = [[SKSpriteNode alloc] initWithColor:[SKColor colorWithHexString:@"#CCFF00" alpha:1.0]
                                         size:CGSizeMake(levelWidth, levelWidth)];
            
            SKLabelNode* level_label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE"];
            level_label.fontSize = 20;
            level_label.fontColor = [SKColor blackColor];
            level_label.text = [[NSString alloc] initWithFormat:@"%d", i + 1];
            level_label.position = CGPointMake(0, -8);        [level addChild:level_label];
            
            
            int row = i / labelsInALine + 1;
            int column = i % labelsInALine;
            
            level.position = CGPointMake(levelWidth + column * (levelWidth + levelWidth/2), h - row * (levelWidth + levelWidth/2));
            level.name = [NSString stringWithFormat:@"level%d", i + 1];
            level_label.name = [NSString stringWithFormat:@"level%d", i + 1];
            
            [self.scene addChild: level];
        }
        
        self.userInteractionEnabled = YES;
    }
}

static SelectLevelScene *sharedInstance = nil;
+ (SelectLevelScene *)sharedInstance {
    return sharedInstance;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    SKNode *touchedNode = [self nodeAtPoint:touchLocation];
    

    if (touchedNode != self) {
        NSLog(@"touch node : %@", touchedNode.name);
        
        [self runAction:play_select_level_sound_action];
        [self runAction:play_select_level_sound_action2];
        
        [[NSUserDefaults standardUserDefaults] setObject:touchedNode.name forKey:@"saved_level_name"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        if ([GameScene sharedInstance] == nil) {
            GameScene* scene = [[GameScene alloc] initWithSize:self.size];
        }
        
        SKTransition *reveal = [SKTransition doorsOpenVerticalWithDuration:0.5];
        [self.view presentScene:[GameScene sharedInstance] transition:reveal];
    }
}


@end
