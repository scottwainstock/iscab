//
//  GameCenterBridge.h
//  iscab
//
//  Created by Scott Wainstock on 11/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameCenterBridge : NSObject {
}

+ (void)reportScore:(int64_t)score forCategory:(NSString*)category;
+ (void)authenticateLocalPlayer;
+ (BOOL)isGameCenterAPIAvailable;

@end