//
//  ALRMViewController.m
//  rhyze
//
//  Created by hauran on 6/12/13.
//  Copyright (c) 2013 Geniot. All rights reserved.
//

#import "ALRMViewController.h"
#import "UIBorderLabel.h"
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

- (IBAction)newAlarmButton:(id)sender {
    UIBorderLabel *newAlarmLabel = (UIBorderLabel *)[self.view viewWithTag:1];
    
    
    if (![newAlarmLabel isKindOfClass:[UIBorderLabel class]]) {
        newAlarmLabel = [[UIBorderLabel alloc]initWithFrame:CGRectMake(10, 150, 290, 50)];
        UIColor *bgColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
        [newAlarmLabel setBackgroundColor:bgColor];
        newAlarmLabel.layer.cornerRadius = 10;
        newAlarmLabel.leftInset = 15;
        
        
//    [newAlarmLabel setFont:[UIFont systemFontOfSize:30]];
//   [newAlarmLabel setFont:[UIFont fontNamesForFamilyName: @"Helvetica Neue Light"]];
        [newAlarmLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:25.0f]];

        newAlarmLabel.textColor = [UIColor colorWithRed:150/255.0f green:120/255.0f blue:155/255.0f alpha:1.0f];

        newAlarmLabel.text = [self currentTime];
        newAlarmLabel.tag = 1;
        newAlarmTime = newAlarmLabel.text;
        
        [[self view] addSubview:newAlarmLabel];
        
        UIImage *saveAlarmImage = [UIImage imageNamed:@"save.png"];
        UIImage *saveAlarmImageOver = [UIImage imageNamed:@"saveOver.png"];
        
        UIButton *saveAlarm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [saveAlarm addTarget:self action:@selector(saveAlarmClick:) forControlEvents:UIControlEventTouchDown];
        [saveAlarm setBackgroundImage:saveAlarmImage forState:UIControlStateNormal];
        [saveAlarm setBackgroundImage:saveAlarmImageOver forState:UIControlStateHighlighted];
        saveAlarm.tag = 2;

        saveAlarm.frame = CGRectMake(253.0, 155.0, 40.0, 40.0);
        [[self view] addSubview:saveAlarm];
    }
}

- (void) saveAlarmClick: (id)sender
{
    UIBorderLabel *newAlarmLabel = (UIBorderLabel *)[self.view viewWithTag:1];
    UIButton *newAlarmBtn = (UIButton *)[self.view viewWithTag:2];
    
    NSString *newAlarm = newAlarmLabel.text;
 
    [UIView animateWithDuration:0.5 animations:^{newAlarmBtn.alpha = 0.0;}];
    
    [UIView transitionWithView:newAlarmLabel duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [newAlarmLabel setBackgroundColor:bgColor];
    } completion:nil];
    
    [alarmArray addObject:newAlarm];
    [alarmArray writeToFile:alarmCacheFilename atomically:YES];
    
	NSLog(@"%@", alarmArray);
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
    _currentTime.text = [self currentTime];
    _currentDate.text = dateString;
    [self performSelector:@selector(updateTime) withObject:self afterDelay:1.0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    bgColor = [UIColor colorWithRed:34/255.0f green:8/255.0f blue:39/255.0f alpha:1.0f];
    self.view.backgroundColor = bgColor;
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
        [self loadSavedAlarm: [alarmArray objectAtIndex:i]: &i];
    }
}

- (void)loadSavedAlarm:(NSString *)time: (NSInteger *) index{
    UIBorderLabel *newAlarmLabel = [[UIBorderLabel alloc]initWithFrame:CGRectMake(10, 150, 290, 50)];
    [newAlarmLabel setBackgroundColor:bgColor];
    newAlarmLabel.layer.cornerRadius = 10;
    newAlarmLabel.leftInset = 15;
    [newAlarmLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:25.0f]];
        
    newAlarmLabel.textColor = [UIColor colorWithRed:150/255.0f green:120/255.0f blue:155/255.0f alpha:1.0f];
        
    newAlarmLabel.text = time;
    newAlarmLabel.tag = [NSString stringWithFormat:@"%d", (int)index];
    [[self view] addSubview:newAlarmLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handlePan:(UIGestureRecognizer *)sender{
    UILabel *newAlarmLabel = (UILabel *)[self.view viewWithTag:1];
    if ([newAlarmLabel isKindOfClass:[UILabel class]]) {
        CGPoint translation = [(UIPanGestureRecognizer *) sender translationInView:_viewPan];
        NSMutableString *dateString = [[NSMutableString alloc] init];
        
        NSDate *currDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        
        [dateString appendFormat:@"%@ %@",[NSMutableString stringWithString:[dateFormatter stringFromDate:currDate]], newAlarmTime];
        
        NSDateFormatter *currentAlarmFormat = [[NSDateFormatter alloc] init];
        [currentAlarmFormat setDateFormat:@"MMM dd, yyyy hh:mm a"];
        NSDate *currentAlarm = [currentAlarmFormat dateFromString:dateString];
        
        CGFloat velocityY = [(UIPanGestureRecognizer*)sender velocityInView:self.view].y;
//      NSLog([NSString stringWithFormat: @"%.2f", velocityY]);
    
        //direction change
        if(velocityY < 0 && panDirection != 1) {
            panDirection = 1;
            [dateString setString:@""];
            [dateString appendFormat:@"%@ %@",[NSMutableString stringWithString:[dateFormatter stringFromDate:currDate]], newAlarmLabel.text];
            
            currentAlarm = [currentAlarmFormat dateFromString:dateString];
        }
        else if(velocityY > 0 && panDirection != 0) {
            panDirection = 0;
            [dateString setString:@""];
            [dateString appendFormat:@"%@ %@",[NSMutableString stringWithString:[dateFormatter stringFromDate:currDate]], newAlarmLabel.text];
            
            currentAlarm = [currentAlarmFormat dateFromString:dateString];
        }
        
        NSDate *newDate;
        if(fabs(velocityY) <10){
            [dateString setString:@""];
            [dateString appendFormat:@"%@ %@",[NSMutableString stringWithString:[dateFormatter stringFromDate:currDate]], newAlarmLabel.text];
            currentAlarm = [currentAlarmFormat dateFromString:dateString];
            newAlarmLabel.text=[self dateToTime:currentAlarm];
            
            if(panDirection == 1) {
                newDate = [currentAlarm dateByAddingTimeInterval:60];
            }
            else {
                newDate = [currentAlarm dateByAddingTimeInterval:-60];
            }

            newAlarmLabel.text=[self dateToTime:newDate];
        }
        else {
            newDate = [currentAlarm dateByAddingTimeInterval:translation.y/-2 * 60];
            newAlarmLabel.text=[self dateToTime:newDate];
        }
        
        
        if(sender.state == UIGestureRecognizerStateEnded)
        {
            newAlarmTime = newAlarmLabel.text;
        }
    }
}

@end
