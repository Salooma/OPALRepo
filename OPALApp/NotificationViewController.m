//
//  NotificationViewController.m
//  OPALApp
//


#import "NotificationViewController.h"
#import "BaseTheme.h"
#import "ThemeFactory.h"


@interface NotificationViewController ()
//@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (strong, nonatomic) NSArray *tweetsArray;
@end

@implementation NotificationViewController

- (void)awakeFromNib
{
    // This method is called when the storyboard file is loaded into memory
    [super awakeFromNib];
    
    // Call the applyTheme on initialization of view
    [self applyTheme];
}

- (void)applyTheme
{
    // Ask factory to build <Theme> compliant object to use as our themeSetter
    id <Theme> themeSetter = [[ThemeFactory sharedThemeFactory] buildThemeForSettingsKey];
    
    // Apply the themeSetters methods to apply to the view controller
    [themeSetter themeViewBackground:self.view];
    [themeSetter themeNavigationBar:self.navigationController.navigationBar];
    [themeSetter themeTabBar:self.tabBarController.tabBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.text = @"Keep up to date with the latest hospital notifications here.";
    label1.frame = CGRectMake(self.view.center.x-130.0f, self.view.center.y-230.0f, 300.0f, 100.0f);
    label1.textColor = [UIColor darkTextColor];
    label1.font = [UIFont fontWithName:@"Futura" size:15];
    label1.numberOfLines = 0;
    
    [self.view addSubview:label1];
}

@end
