//
//  TriageViewController.h
//  OPALApp
//
//  Created by Alexander Figueroa on 1/23/2014.
//  Copyright (c) 2014 Alexander Figueroa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PasswordHandling.h"

@interface TriageViewController : UIViewController <UITextFieldDelegate>{
    NSTimer *timer;
    IBOutlet UILabel *myCounterLabel;
}

@property (assign) BOOL isCurrentlyOnScreen;
@property (nonatomic, strong) id <PasswordHandling> passwordHandler;

@property (nonatomic, strong) UIColor *navigationBarTintColor;
@property (nonatomic, strong) UIColor *navigationTintColor;
@property (nonatomic, strong) UIColor *navigationTitleColor;
@property (nonatomic, retain) UILabel *myCounterLabel;

-(void)updateCounter:(NSTimer *)theTimer;
-(void)countdownTimer;

@end