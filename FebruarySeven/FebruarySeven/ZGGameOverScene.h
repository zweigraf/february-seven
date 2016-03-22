//
//  ZGGameOverScene.h
//  FebruarySeven
//
//  Created by Luis Reisewitz on 08.02.15.
//  Copyright (c) 2015 ZweiGraf. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol ZGGameOverSceneDelegate <NSObject>

-(void)didStartGameFromScene:(SKScene *)scene;

@end

@interface ZGGameOverScene : SKScene

@property (assign) int points;
@property (weak) id<ZGGameOverSceneDelegate> gameDelegate;

@end
