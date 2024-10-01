//
//  PRMediaFilesProcessingManager.h
//  PRIME
//
//  Created by armens on 4/9/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRMediaFilesProcessingManager : UIViewController

-(instancetype)initWithPresenter:(UIViewController*)presenter;
-(void)handleCameraAction;
-(void)handlePhotoVideoAction;
-(void)handleDocumentAction;
-(void)handleLocationAction;
-(void)handleContactsAction;

@end
