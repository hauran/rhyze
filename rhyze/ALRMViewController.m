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

@interface ALRMViewController ()

@end

@implementation ALRMViewController

@synthesize currentTime = _currentTime;
@synthesize currentDate = _currentDate;
@synthesize deleteDisplayedLabel = _deleteDisplayedLabel;

UIColor *bgColor;
NSMutableArray *alarmArray;
NSString *alarmCacheFilename;
UIScrollView *scrollView;
CGRect screenBound;
CGFloat screenWidth;
int alarmIndex = 11;
int scrollViewTag = 999;


- (IBAction)newAlarmButton:(id)sender {
    NewAlarmModalViewController *newAlarm = [[NewAlarmModalViewController alloc] init];
    newAlarm.currentTime = _currentTime.text;
    newAlarm.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:newAlarm animated:YES completion:nil];
}

- (void) saveAlarmClick: (NSString *)newAlarmTime {    
    [self newAlarm:newAlarmTime];
    UIBorderLabel *label = [alarmArray objectAtIndex:[alarmArray count]-1];
    NSLog(@"%@ %d", label, [alarmArray count]-1);
    [self displaySavedAlarm:label index:[alarmArray count]-1];
}

-(void) saveAlarmArray {
    NSError  *error;
    NSData* archiveData = [NSKeyedArchiver archivedDataWithRootObject:alarmArray];
    [archiveData writeToFile:alarmCacheFilename options:NSDataWritingAtomic error:&error];
}

- (NSString *)dateToTime: (NSDate *)date{
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    
    [timeFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [timeFormatter setDateStyle:NSDateFormatterNoStyle];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    return[timeFormatter stringFromDate:date];
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

- (void)viewDidLoad
{
        [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.
        bgColor = [UIColor colorWithRed:40/255.0f green:40/255.0f blue:40/255.0f alpha:1.0f];
        self.view.backgroundColor = bgColor;
    
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height-100)];

        
        screenBound = [[UIScreen mainScreen] bounds];
        screenWidth = screenBound.size.width;
    
        [self updateTime];
        [self loadSavedAlarms];
        
        UITapGestureRecognizer *hideDeleteButton = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDeleteButton:)];
        hideDeleteButton.numberOfTapsRequired = 1;
        [self.view setUserInteractionEnabled:YES];
        [self.view addGestureRecognizer:hideDeleteButton];
        
        UITapGestureRecognizer *hideDeleteButton2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDeleteButton:)];
        hideDeleteButton2.numberOfTapsRequired = 1;
        [scrollView addGestureRecognizer:hideDeleteButton2];
        [self.view addSubview:scrollView];
}

- (void) loadSavedAlarms {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    alarmCacheFilename = [documentsPath stringByAppendingPathComponent:@"geniotAlarm3.plist"];
    
    NSData *archiveData = [NSData dataWithContentsOfFile:alarmCacheFilename];
    alarmArray = (NSMutableArray*)[NSKeyedUnarchiver unarchiveObjectWithData:archiveData];

    if (alarmArray == nil) {
        alarmArray = [[NSMutableArray alloc] init];
    }    
    
    for (int i=0; i<[alarmArray count]; i++) {
        [self displaySavedAlarm:[alarmArray objectAtIndex:i] index:i];
    }
}

-(void) newAlarm:(NSString *)time {
    UIBorderLabel *newAlarmLabel = [[UIBorderLabel alloc] init];
    [newAlarmLabel setBackgroundColor:bgColor];
    
    [newAlarmLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:25.0f]];
    
    newAlarmLabel.textColor = [UIColor colorWithRed:150/255.0f green:120/255.0f blue:155/255.0f alpha:1.0f];
    newAlarmLabel.textAlignment = NSTextAlignmentRight;
    newAlarmLabel.text = time;
    
    UIImage *deleteAlarmImge = [UIImage imageNamed:@"close.png"];
    UIImage *deleteAlarmImageOver = [UIImage imageNamed:@"closeOver.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(aMethod:) forControlEvents:UIControlEventTouchDown];
    [button setBackgroundImage:deleteAlarmImge forState:UIControlStateNormal];
    [button setBackgroundImage:deleteAlarmImageOver forState:UIControlStateHighlighted];
    button.frame = CGRectMake(screenWidth-50, 5, 0, 40.0);
    
    [newAlarmLabel addSubview:button];
    
    NSLog(@"%@",newAlarmLabel);
    [alarmArray addObject:newAlarmLabel];
    [self saveAlarmArray];
}


- (void) displaySavedAlarm:(UIBorderLabel *) alarm index:(int) index{
    CGFloat top = (CGFloat)(50 * index);
    [scrollView addSubview:alarm];
    
    UISwipeGestureRecognizer *showDeleteButton = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showDeleteButton:)];
    [showDeleteButton setDirection:(UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft)];
    
    UITapGestureRecognizer *editAlarm = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editAlarm:)];
    editAlarm.numberOfTapsRequired = 1;
    
    [alarm setUserInteractionEnabled:YES];
    [alarm addGestureRecognizer:editAlarm];
    [alarm addGestureRecognizer:showDeleteButton];
    
    UITapGestureRecognizer *deleteAlarm = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteAlarm:)];
    deleteAlarm.numberOfTapsRequired = 1;

    UIButton *button = [[alarm subviews] objectAtIndex:0];
    [button setUserInteractionEnabled:YES];
    [button addGestureRecognizer:deleteAlarm];
    
    alarm.frame = CGRectMake(0, top, self.view.frame.size.width, 50);
    alarm.rightInset = 170;
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
        [self hideDeleteButton:alarmSwiped];
        UIButton *button = (UIButton *)[alarmSwiped.view.subviews objectAtIndex: 0];
        _deleteDisplayedLabel = alarmSwiped.view;
    
        [UIView
            animateWithDuration:.25
            delay:0.0
            options:UIViewAnimationOptionAllowUserInteraction
            animations:^{
                    button.frame = CGRectMake(screenWidth-50, 5, 40.0, 40.0);
                }
            completion:^(BOOL finished){
                    //              [label removeFromSuperview];
                }
        ];
    }
}

- (IBAction)hideDeleteButton:(UIGestureRecognizer *)view{
    if(_deleteDisplayedLabel != Nil) {
        UIButton *button = (UIButton *)[_deleteDisplayedLabel.subviews objectAtIndex: 0];
        [UIView
            animateWithDuration:.25
            delay:0.0
            options:UIViewAnimationOptionAllowUserInteraction
            animations:^{
                    button.frame = CGRectMake(screenWidth-50, 5, 0, 40.0);
            }
            completion:^(BOOL finished){
                //              [label removeFromSuperview];
            }
        ];
        _deleteDisplayedLabel = Nil;
    }
}

- (IBAction)deleteAlarm:(UIGestureRecognizer *)btn{
    int i;
    for(i=0; i < [alarmArray count]; i++) {
        if([alarmArray objectAtIndex:i] ==  btn.view.superview){
            break;
        }
    }
    
    UILabel *otherLabel;
    for(int j=i+1; j < [alarmArray count]; j++) {
        otherLabel = [alarmArray objectAtIndex:j];
        [UIView
         animateWithDuration:.5
         delay:0.1
         options:UIViewAnimationOptionAllowUserInteraction
         animations:^{
             otherLabel.frame = CGRectMake(0, otherLabel.frame.origin.y - 50, self.view.frame.size.width, 50);
         }
         completion:^(BOOL finished){
             [self resizeScrollView];
         }
         ];
    }
    [btn.view.superview removeFromSuperview];
    [self resizeScrollView];
    [alarmArray removeObjectAtIndex:i];
    [self saveAlarmArray];
    _deleteDisplayedLabel = Nil;
}

@end
