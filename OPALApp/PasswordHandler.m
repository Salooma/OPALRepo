//
//  PasswordHandler.m
//  OPALApp
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
