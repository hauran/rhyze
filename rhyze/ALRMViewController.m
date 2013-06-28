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
@synthesize viewPan = _viewPan;
NSString *newAlarmTime;
int panDirection;
UIColor *bgColor;
NSMutableArray *alarmArray;
NSString *alarmCacheFilename;
UIScrollView *scrollView;

int scrollViewTag = 999;

- (IBAction)newAlarmButton:(id)sender {
    NewAlarmModalViewController *newAlarm = [[NewAlarmModalViewController alloc] init];
    
    newAlarm.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:newAlarm animated:YES completion:nil];
}
//
//- (void) saveAlarmClick: (id)sender
//{
//    UIBorderLabel *newAlarmLabel = (UIBorderLabel *)[self.view viewWithTag:newAlarmLabelTag];
//    UIButton *newAlarmBtn = (UIButton *)[self.view viewWithTag:saveNewAlarmBtnTag];
//    
//    NSString *newAlarm = newAlarmLabel.text;
//    
//    [UIView animateWithDuration:0.5 animations:^{newAlarmBtn.alpha = 0.0;}];
//    
//    [UIView transitionWithView:newAlarmLabel duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//        [newAlarmLabel setBackgroundColor:bgColor];
//    } completion:nil];
//    
//    [alarmArray addObject:newAlarm];
//    [alarmArray writeToFile:alarmCacheFilename atomically:YES];
//    
//	NSLog(@"%@", alarmArray);
//}


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
    _currentTime.text = [self currentTime];
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
//    scrollView.backgroundColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];;
    [self.view addSubview:scrollView];
    
    [self updateTime];
    [self loadSavedAlarms];
}


- (void) loadSavedAlarms {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    alarmCacheFilename = [documentsPath stringByAppendingPathComponent:@"geniotAlarm.plist"];
    alarmArray = [[NSMutableArray alloc] initWithContentsOfFile:alarmCacheFilename];
    if (alarmArray == nil) {
        alarmArray = [[NSMutableArray alloc] init];
    }
	NSLog(@"%@", alarmArray);
    for (int i=0; i<[alarmArray count]; i++) {
        [self loadSavedAlarm: [alarmArray objectAtIndex:i]: i];
    }
}

- (void)loadSavedAlarm:(NSString *)time: (int) index{
    CGFloat top = (CGFloat)(50 * index);
    NSLog(@"%f", top);
    UILabel *newAlarmLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, top, 125, 50)];
    [newAlarmLabel setBackgroundColor:bgColor];
    newAlarmLabel.layer.cornerRadius = 10;
    [newAlarmLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:25.0f]];
        
    newAlarmLabel.textColor = [UIColor colorWithRed:150/255.0f green:120/255.0f blue:155/255.0f alpha:1.0f];
    newAlarmLabel.textAlignment = UITextAlignmentRight;
    newAlarmLabel.text = time;
    newAlarmLabel.tag = index;
    
    [scrollView addSubview:newAlarmLabel];
    
//    UISwipeGestureRecognizer *swipeAlarm = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showDeleteButton:)];
//    [swipeAlarm setDirection:UISwipeGestureRecognizerDirectionRight];
    
    UITapGestureRecognizer *editAlarm = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editAlarm:)];
    editAlarm.numberOfTapsRequired = 1;

    [newAlarmLabel setUserInteractionEnabled:YES];
    [newAlarmLabel addGestureRecognizer:editAlarm];
    
    [self resizeScrollView];
}



- (void) resizeScrollView {
    CGFloat scrollViewHeight = 0.0f;
    for (UIView* view in scrollView.subviews)
    {
        scrollViewHeight += view.frame.size.height;
    }
    
//    scrollView.contentSize = CGSizeMake(self.view.frame.size.width * numberOfViews, self.view.frame.size.height);
    
    
    NSLog(@"height:");
    NSLog(@"%f",scrollViewHeight);
    
    
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, scrollViewHeight);
}



- (IBAction)editAlarm:(UIGestureRecognizer *)alarmTapped{
    int tag = alarmTapped.view.tag;
    NSLog(@"%d", tag);
    UILabel *alarm = (UILabel *)[self.view viewWithTag:tag];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)handlePan:(UIGestureRecognizer *)sender{
//    UILabel *newAlarmLabel = (UILabel *)[self.view viewWithTag:newAlarmLabelTag];
//    if ([newAlarmLabel isKindOfClass:[UILabel class]]) {
//        CGPoint translation = [(UIPanGestureRecognizer *) sender translationInView:_viewPan];
//        NSMutableString *dateString = [[NSMutableString alloc] init];
//        
//        NSDate *currDate = [NSDate date];
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
//        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
//        
//        [dateString appendFormat:@"%@ %@",[NSMutableString stringWithString:[dateFormatter stringFromDate:currDate]], newAlarmTime];
//        
//        NSDateFormatter *currentAlarmFormat = [[NSDateFormatter alloc] init];
//        [currentAlarmFormat setDateFormat:@"MMM dd, yyyy hh:mm a"];
//        NSDate *currentAlarm = [currentAlarmFormat dateFromString:dateString];
//        
//        CGFloat velocityY = [(UIPanGestureRecognizer*)sender velocityInView:self.view].y;
////      NSLog([NSString stringWithFormat: @"%.2f", velocityY]);
//    
//        //direction change
//        if(velocityY < 0 && panDirection != 1) {
//            panDirection = 1;
//            [dateString setString:@""];
//            [dateString appendFormat:@"%@ %@",[NSMutableString stringWithString:[dateFormatter stringFromDate:currDate]], newAlarmLabel.text];
//            
//            currentAlarm = [currentAlarmFormat dateFromString:dateString];
//        }
//        else if(velocityY > 0 && panDirection != 0) {
//            panDirection = 0;
//            [dateString setString:@""];
//            [dateString appendFormat:@"%@ %@",[NSMutableString stringWithString:[dateFormatter stringFromDate:currDate]], newAlarmLabel.text];
//            
//            currentAlarm = [currentAlarmFormat dateFromString:dateString];
//        }
//        
//        NSDate *newDate;
//        if(fabs(velocityY) <10){
//            [dateString setString:@""];
//            [dateString appendFormat:@"%@ %@",[NSMutableString stringWithString:[dateFormatter stringFromDate:currDate]], newAlarmLabel.text];
//            currentAlarm = [currentAlarmFormat dateFromString:dateString];
//            newAlarmLabel.text=[self dateToTime:currentAlarm];
//            
//            if(panDirection == 1) {
//                newDate = [currentAlarm dateByAddingTimeInterval:60];
//            }
//            else {
//                newDate = [currentAlarm dateByAddingTimeInterval:-60];
//            }
//
//            newAlarmLabel.text=[self dateToTime:newDate];
//        }
//        else {
//            newDate = [currentAlarm dateByAddingTimeInterval:translation.y/-2 * 60];
//            newAlarmLabel.text=[self dateToTime:newDate];
//        }
//        
//        
//        if(sender.state == UIGestureRecognizerStateEnded)
//        {
//            newAlarmTime = newAlarmLabel.text;
//        }
//    }
}

@end
