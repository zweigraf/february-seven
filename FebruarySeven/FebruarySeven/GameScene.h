//
//  GameScene.h
//  FebruarySeven
//

//  Copyright (c) 2015 ZweiGraf. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol GameSceneDelegate <NSObject>

-(void)didEndGameFromScene:(SKScene *)scene withPoints:(int)points;

@end

@interface GameScene : SKScene

@property (weak) id<GameSceneDelegate> gameDelegate;

@end
