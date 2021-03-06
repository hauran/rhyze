//
//  ALRMViewController.m
//  rhyze
//
//  Created by hauran on 6/12/13.
//  Copyright (c) 2013 Geniot. All rights reserved.
//

#import "ALRMViewController.h"
#import "UIBorderLabel.h"
#import "NewAlarmModalViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+FontAwesome.m"
#import "Alarm.h"
@interface ALRMViewController ()

@end

@implementation ALRMViewController

@synthesize currentTime = _currentTime;
@synthesize currentDate = _currentDate;
@synthesize deleteDisplayedLabel = _deleteDisplayedLabel;

UIColor *bgColor;
UIColor *textColor;
//NSMutableArray *alarmArray;
NSMutableDictionary *alarmClassDictionary;
NSMutableDictionary *alarmDictionary;
UIScrollView *scrollView;
CGRect screenBound;
CGFloat screenWidth;
int alarmIndex = 11;
int scrollViewTag = 999;


- (IBAction)showNewAlarmModal:(UIGestureRecognizer *)newAlarmTapped{
    NewAlarmModalViewController *newAlarm = [[NewAlarmModalViewController alloc] init];
    newAlarm.currentTime = _currentTime.text;
    newAlarm.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:newAlarm animated:YES completion:nil];
    
//    [self alarmGoingOffModal];
}


-(void) dismissAlarm {
}


- (void) saveAlarmClick: (NSString *)newAlarmTime {    
    Alarm *alarm  = [self newAlarm:newAlarmTime];
    [self displaySavedAlarm:alarm.time index:[[alarmDictionary allKeys] count]-1];
}


-(Alarm *) newAlarm:(NSString *)time {
    Alarm *newAlarm = [[Alarm alloc] init];
    NSMutableDictionary  *newAlarmDictionary= [[NSMutableDictionary alloc] init];
    
    [newAlarmDictionary setObject:time forKey:@"time"];
    [newAlarmDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"skip"];
    [newAlarmDictionary setObject:@"ring.aiff" forKey:@"soundFile"];
    [alarmDictionary setObject:newAlarmDictionary forKey:time];
    
    newAlarm = [self createAlarmClassFromDictionary:newAlarmDictionary];
//    newAlarm.time = time;
//    newAlarm.alarmDictionary = newAlarmDictionary;
//    newAlarm.dismissed = false;
//    newAlarm.soundFile = @"ring.mp3";
//    newAlarm.alarmId = (float *)rand();
    
    [alarmClassDictionary setObject:[self createAlarmClassFromDictionary:newAlarmDictionary] forKey:time];
    
    [self saveAlarms];
    
    NSDate *date = [self timeStringToDate:time];
    UILocalNotification*notification = [[UILocalNotification alloc] init];
    
    notification.fireDate = date;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = @"Alarm is ringing.";
    notification.alertAction = @"Snooze";
    notification.userInfo = newAlarmDictionary;
    notification.repeatInterval = 0;
    
    //    Settings *settings = [Settings sharedSettings];
    notification.soundName = newAlarm.soundFile;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    return newAlarm;
}


-(void) saveAlarms {
    NSLog(@"%@", alarmDictionary);
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:alarmDictionary forKey:@"geniotAlarm"];
    [prefs synchronize];
}

- (NSString *)dateToTime: (NSDate *)date{
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    
    [timeFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [timeFormatter setDateStyle:NSDateFormatterNoStyle];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [[timeFormatter stringFromDate:date] lowercaseString];
}


- (NSDate *)timeStringToDate: (NSString *)time{
    NSMutableString *dateString = [[NSMutableString alloc] init];
    
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    [dateString appendFormat:@"%@ %@",[NSMutableString stringWithString:[dateFormatter stringFromDate:currDate]], time];
    
    NSDateFormatter *currentAlarmFormat = [[NSDateFormatter alloc] init];
    [currentAlarmFormat setDateFormat:@"MMM dd, yyyy hh:mm a"];
    return [currentAlarmFormat dateFromString:dateString];
}


- (NSString *)currentTime {
    NSDate *currDate = [NSDate date];
    return [self dateToTime:currDate];
}

-(void)updateTime {
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    [dayFormatter setDateFormat:@"EEE"];
    
    NSMutableString *dateString = [[NSMutableString alloc] init];
    [dateString appendString:[dayFormatter stringFromDate:[NSDate date]]];
    [dateString appendString:@", "];
    [dateString appendString:[NSMutableString stringWithString:[dateFormatter stringFromDate:currDate]]];
    
    _currentTime.text = (NSString *)[self currentTime];
    _currentDate.text = dateString;
    
    [self performSelector:@selector(updateTime) withObject:self afterDelay:1.0];
}





- (void) loadSavedAlarms {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *alarmPreferenceDictionary = [[NSMutableDictionary alloc] init];
//    
//
//    [prefs setObject:arrayOfDictionaries forKey:@"geniotAlarm"];
//    [prefs synchronize];
    
    NSArray *alarmPreferences = [prefs objectForKey:@"geniotAlarm"];
    
    if (alarmPreferences == nil || [alarmPreferences count] == 0) {
        alarmPreferenceDictionary = [[NSMutableDictionary alloc] init];
        alarmDictionary = [[NSMutableDictionary alloc] init];
    }
    else {
        alarmPreferenceDictionary = [alarmPreferences copy];
        alarmDictionary = [alarmPreferences mutableCopy];
    }
    
    int i = 0;
    for(id time in alarmPreferenceDictionary) {
        [self displaySavedAlarm:time index:i++];
        [self createAlarmClassFromDictionary: [alarmPreferenceDictionary objectForKey:time]];
    }
}


-(Alarm *) createAlarmClassFromDictionary:(NSMutableDictionary *)alarmDictionary{
    Alarm *alarm = [[Alarm alloc] init];
    alarm.dismissed = false;
    alarm.time = [alarmDictionary valueForKey:@"time"];
    alarm.soundFile = [alarmDictionary valueForKey:@"soundFile"];
    alarm.alarmId = (float *)rand();
    alarm.alarmDictionary = alarmDictionary;
    [alarmClassDictionary setObject:alarm forKey:alarm.time];
    return alarm;
}

-(UIBorderLabel *) createAlarmLabel:(NSString *)time {
    UIBorderLabel *newAlarmLabel = [[UIBorderLabel alloc] init];
    [newAlarmLabel setBackgroundColor:bgColor];
    
    [newAlarmLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:25.0f]];

    newAlarmLabel.textColor = textColor;
    newAlarmLabel.textAlignment = NSTextAlignmentRight;
    newAlarmLabel.text = [time lowercaseString];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:25.f];
    [button setTitleColor:textColor forState:UIControlStateNormal];
    [button setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"icon-remove-sign"] forState: UIControlStateNormal];
    [button addTarget:self action:@selector(aMethod:) forControlEvents:UIControlEventTouchDown];
    button.frame = CGRectMake(screenWidth - 40, 10, 0, 30.0);
    
    [newAlarmLabel addSubview:button];
    return newAlarmLabel;
}



- (void) displaySavedAlarm:(NSString *)time index:(int) index{
    CGFloat top = (CGFloat)(50 * index);
    UIBorderLabel *alarmLabel = [self createAlarmLabel:time];
    
    UISwipeGestureRecognizer *showDeleteButton = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showDeleteButton:)];
    [showDeleteButton setDirection:(UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft)];
    
    UITapGestureRecognizer *editAlarm = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editAlarm:)];
    editAlarm.numberOfTapsRequired = 1;
    
    [alarmLabel setUserInteractionEnabled:YES];
    [alarmLabel addGestureRecognizer:editAlarm];
    [alarmLabel addGestureRecognizer:showDeleteButton];
    
    UITapGestureRecognizer *deleteAlarm = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteAlarm:)];
    deleteAlarm.numberOfTapsRequired = 1;

    UIButton *button = [[alarmLabel subviews] objectAtIndex:0];
    [button setUserInteractionEnabled:YES];
    [button addGestureRecognizer:deleteAlarm];
    
    alarmLabel.frame = CGRectMake(10, top, self.view.frame.size.width, 50);
    alarmLabel.rightInset = 170;
    [scrollView addSubview:alarmLabel];
    
    [self resizeScrollView];
}


- (void) resizeScrollView {
    CGFloat scrollViewHeight = 0.0f;
    for (UIView* view in scrollView.subviews)
    {
        
        if([view isKindOfClass: [UIBorderLabel class]]){
            scrollViewHeight += view.frame.size.height;
        }
    }
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, scrollViewHeight);
}


- (IBAction)editAlarm:(UIGestureRecognizer *)alarmTapped{
    if(_deleteDisplayedLabel != Nil){
        [self hideDeleteButton:alarmTapped];
    }
    else {
        NSLog(@"%@", alarmTapped.view);
    }
}

- (IBAction)showDeleteButton:(UIGestureRecognizer *)alarmSwiped{
    if(_deleteDisplayedLabel != Nil && (alarmSwiped.view == _deleteDisplayedLabel)){
        [self hideDeleteButton:alarmSwiped];
    }
    else {
        UIColor *labelBG  = [UIColor colorWithRed:30/255.0f green:30/255.0f blue:30/255.0f alpha:1.0f];
        
        [self hideDeleteButton:alarmSwiped];
        UIButton *button = (UIButton *)[alarmSwiped.view.subviews objectAtIndex: 0];
        _deleteDisplayedLabel = alarmSwiped.view;
        
        alarmSwiped.view.backgroundColor = labelBG;
    
        [UIView
            animateWithDuration:.25
            delay:0.0
            options:UIViewAnimationOptionAllowUserInteraction
            animations:^{
//                    button.frame = CGRectMake(screenWidth-55, 10, 30.0, 30.0);
                    button.frame = CGRectMake(screenWidth - 40, 10, 30.0, 30.0);
                }
            completion:^(BOOL finished){
                    //              [label removeFromSuperview];
                }
        ];
    }
}

- (IBAction)hideDeleteButton:(UIGestureRecognizer *)alarmSwiped{
    if(_deleteDisplayedLabel != Nil) {
        UIButton *button = (UIButton *)[_deleteDisplayedLabel.subviews objectAtIndex: 0];
        
        _deleteDisplayedLabel.backgroundColor = bgColor;
        
        [UIView
            animateWithDuration:.25
            delay:0.0
            options:UIViewAnimationOptionAllowUserInteraction
            animations:^{
                button.frame = CGRectMake(screenWidth - 40, 10, 0, 30.0);
            }
            completion:^(BOOL finished){
                //              [label removeFromSuperview];
            }
        ];
        _deleteDisplayedLabel = Nil;
    }
}

- (IBAction)deleteAlarm:(UIGestureRecognizer *)btn{
    int i = 0;
    UIBorderLabel *label = (UIBorderLabel *)btn.view.superview;
    for(id time in alarmDictionary) {
        //[self displaySavedAlarm:time index:i++];
        if([(NSString *)time isEqualToString:label.text]){
            break;
        }
    }
    
    
    UILabel *otherLabel;
    for(int j=i+1; j < [scrollView.subviews count]; j++) {
        otherLabel = [scrollView.subviews objectAtIndex:j];
        if([otherLabel isKindOfClass:[UIBorderLabel class]]) {
            [UIView
             animateWithDuration:.5
             delay:0.1
             options:UIViewAnimationOptionAllowUserInteraction
             animations:^{
                 otherLabel.frame = CGRectMake(10, otherLabel.frame.origin.y - 50, self.view.frame.size.width, 50);
             }
             completion:^(BOOL finished){
                [self resizeScrollView];
             }
         ];
        }
    }
    [btn.view.superview removeFromSuperview];
    [self resizeScrollView];
    [alarmClassDictionary removeObjectForKey:label.text];
    [alarmDictionary removeObjectForKey:label.text];
    [self saveAlarms];
    _deleteDisplayedLabel = Nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    bgColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    self.view.backgroundColor = bgColor;
    textColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height-100)];
    screenBound = [[UIScreen mainScreen] bounds];
    screenWidth = screenBound.size.width;
    
    alarmClassDictionary = [[NSMutableDictionary alloc] init];
    
    [self loadSavedAlarms];
    
    UITapGestureRecognizer *hideDeleteButton = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDeleteButton:)];
    hideDeleteButton.numberOfTapsRequired = 1;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:hideDeleteButton];
    
    UITapGestureRecognizer *hideDeleteButton2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDeleteButton:)];
    hideDeleteButton2.numberOfTapsRequired = 1;
    [scrollView addGestureRecognizer:hideDeleteButton2];
    [self.view addSubview:scrollView];
        
    _currentTime.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:40.f];
    _currentTime.textColor = textColor;
    
    _currentDate.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:19.f];
    _currentDate.textColor = textColor;
    
    
    UIButton *newAlarmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    newAlarmButton.backgroundColor = [UIColor clearColor];
    newAlarmButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:25.f];
    [newAlarmButton setTitleColor:textColor forState:UIControlStateNormal];
    [newAlarmButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"icon-plus-sign"] forState: UIControlStateNormal];
    newAlarmButton.frame = CGRectMake(screenWidth-35, 10, 40.0, 40.0);
    
    UITapGestureRecognizer *newAlarmModal = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNewAlarmModal:)];
    newAlarmModal.numberOfTapsRequired = 1;
    [newAlarmButton setUserInteractionEnabled:YES];
    [newAlarmButton addGestureRecognizer:newAlarmModal];
    [self.view addSubview:newAlarmButton];
    
    [self updateTime];
    
}

@end
