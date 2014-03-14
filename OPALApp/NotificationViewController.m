//
//  NotificationViewController.m
//  OPALApp
//


#import "NotificationViewController.h"
#import "BaseTheme.h"
#import "ThemeFactory.h"


@interface NotificationViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *tweetsArray;
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

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
//    UILabel *label1 = [[UILabel alloc] init];
//    label1.text = @"Keep up to date with the latest hospital notifications here.";
//    label1.frame = CGRectMake(self.view.center.x-130.0f, self.view.center.y-230.0f, 300.0f, 100.0f);
//    label1.textColor = [UIColor darkTextColor];
//    label1.font = [UIFont fontWithName:@"Futura" size:15];
//    label1.numberOfLines = 0;
//    
//    //[self.view addSubview:label1];
//    
////    // Initialize table data
////    tableData = [NSArray arrayWithObjects:@"Now accepting Volunteer Applications! Click here for more information.",
////                 @"@OslerHealth Join us at our #KissMyApp Awards Ceremony on March 25th from 2-3pm.",
////                 @"The Rose Elevator is currently out of order. We apologize for the inconvenience. Please ask our volunteers should you require any assistance.",
////                 @"Free cookies in Hospital Lobby! Happy Easter from the William Osler Brampton Civic family!",
////                 @"Hospital Wait Time: 10 hours.",nil];
//    
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //1
    
        UILabel *label1 = [[UILabel alloc] init];
        label1.text = @"Keep up to date with the latest hospital notifications here.";
        label1.frame = CGRectMake(self.view.center.x-150.0f, self.view.center.y-230.0f, 300.0f, 100.0f);
        label1.textColor = [UIColor darkTextColor];
        label1.font = [UIFont fontWithName:@"Futura" size:20];
        label1.numberOfLines = 0;
        label1.textAlignment = UITextAlignmentCenter;
        //label1.layer.borderColor=[UIColor grayColor].CGColor;
    
    [self.view addSubview:label1];
    
    self.tableView.dataSource = self;
    //2
    self.tweetsArray = [[NSArray alloc] initWithObjects:
                        @"Now accepting Volunteer Applications! Click here for more information.",
                        @"Join us at our #KissMyApp Awards Ceremony on March 25th from 2-3pm.",
                        @"The Rose Elevator is currently out of order. We apologize for the inconvenience. Please ask our volunteers should you require any assistance. ",
                        @"Current Hospital Wait Time: 6 hours.",
                        @"Free cookies in Hospital Lobby from 10-11AM! Happy Easter from the William Osler Brampton Civic family!",
                        @"Current Hospital Wait Time: 10 hours.",
                        @"Our CEO blogged! Take a look at his perspective on #mhealth and what Osler is doing to make the most of it.",
                        nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//3
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tweetsArray count];
}

//4
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //5
    static NSString *cellIdentifier = @"SettingsCell";
    //6
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    //5.1 you do not need this if you have set SettingsCell as identifier in the storyboard (else you can remove the comments on this code)
    if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
       }
    
    NSString *tweet = [self.tweetsArray objectAtIndex:indexPath.row];
    //7
    [cell.textLabel setText:tweet];
    [cell.detailTextLabel setText:@"via Twitter"];
    return cell;
}



@end
