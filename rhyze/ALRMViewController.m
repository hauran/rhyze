//
//  ALRMViewController.m
//  rhyze
//
//  Created by hauran on 6/12/13.
//  Copyright (c) 2013 Geniot. All rights reserved.
//

#import "ALRMViewController.h"

@interface ALRMViewController ()

@end

@implementation ALRMViewController

@synthesize currentTime = _currentTime;
@synthesize currentDate = _currentDate;

- (IBAction)newAlarmButton:(id)sender {
    NSLog(@"NEW");
    
    UILabel *newAlarmLabel = [[UILabel alloc]initWithFrame:CGRectMake(45, 150, 229, 50)];
    [newAlarmLabel setBackgroundColor:[UIColor clearColor]];
//    [newAlarmLabel setFont:[UIFont systemFontOfSize:30]];
//   [newAlarmLabel setFont:[UIFont fontNamesForFamilyName: @"Helvetica Neue Light"]];
    [newAlarmLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:25.0f]];

    newAlarmLabel.textColor = [UIColor colorWithRed:150/255.0f green:120/255.0f blue:155/255.0f alpha:1.0f];

    newAlarmLabel.text = [self currentTime];
    [[self view] addSubview:newAlarmLabel];
}

- (NSString *)currentTime {
    NSDate *currDate = [NSDate date];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    
    [timeFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [timeFormatter setDateStyle:NSDateFormatterNoStyle];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    return[timeFormatter stringFromDate:currDate];
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
    
//    [_currentTime setText:[self currentTime]];
    _currentTime.text = [self currentTime];
    _currentDate.text = dateString;
    [self performSelector:@selector(updateTime) withObject:self afterDelay:1.0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self updateTime];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
