//
//  PasswordHandler.m
//  OPALApp
//
//  Created by Salma Hindy on 2/12/2014.
//  Copyright (c) 2014 Alexander Figueroa. All rights reserved.
//

#import "PasswordHandler.h"

@implementation PasswordHandler

#pragma mark - PasswordHandling Protocol Methods
- (BOOL)triageViewController:(TriageViewController *)triageViewController verifyPassword:(NSString *)password
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return [password isEqualToString:@"1234"];
}

- (void)maxNumberOfFailedAttemptsReached
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}


@end
