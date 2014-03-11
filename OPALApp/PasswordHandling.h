//
//  PasswordHandling.h
//  OPALApp
//


#import <Foundation/Foundation.h>
@class TriageViewController;

/**
 @brief The PasswordHandler protocol defines methods for which an object can receive that indicate the actions of the
 password input in order to verify.
 */
@protocol PasswordHandling <NSObject>

@required
- (BOOL)triageViewController:(TriageViewController *)triageViewController verifyPassword:(NSString *)password;

@optional
// This serves, mostly, as an "update stuff after dismissing"
- (void)maxNumberOfFailedAttemptsReached;

@end
