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
@synthesize deleteDisplayedTag = _deleteDisplayedTag;

UIColor *bgColor;
NSMutableArray *alarmArray;
NSString *alarmCacheFilename;
UIScrollView *scrollView;
bool *loaded = FALSE;
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

- (void) saveAlarmClick: (NSString *)newAlarm {
//    [UIView animateWithDuration:0.5 animations:^{newAlarmBtn.alpha = 0.0;}];
//    
//    [UIView transitionWithView:newAlarmLabel duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//        [newAlarmLabel setBackgroundColor:bgColor];
//    } completion:nil];
//
    [alarmArray addObject:newAlarm];
    [alarmArray writeToFile:alarmCacheFilename atomically:YES];
    NSLog(@"%D", [alarmArray count]);
    [self loadSavedAlarm:newAlarm:[alarmArray count]-1];
    
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
    if(!loaded){
        [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.
        bgColor = [UIColor colorWithRed:40/255.0f green:40/255.0f blue:40/255.0f alpha:1.0f];
        self.view.backgroundColor = bgColor;
    
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height-100)];
        //    scrollView.backgroundColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];;
        
        
        screenBound = [[UIScreen mainScreen] bounds];
        screenWidth = screenBound.size.width;
    
        [self updateTime];
        [self loadSavedAlarms];
        loaded = TRUE;
        self.deleteDisplayedTag = -1;
        
        UITapGestureRecognizer *hideDeleteButton = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDeleteButton:)];
        hideDeleteButton.numberOfTapsRequired = 1;
        [self.view setUserInteractionEnabled:YES];
        [self.view addGestureRecognizer:hideDeleteButton];
        
        UITapGestureRecognizer *hideDeleteButton2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDeleteButton:)];
        hideDeleteButton2.numberOfTapsRequired = 1;
        [scrollView addGestureRecognizer:hideDeleteButton2];
        [self.view addSubview:scrollView];
    }
}

-(void) deleteEmptyAlarms{
    NSMutableArray *discardedItems = [NSMutableArray array];
    NSString *item;
    for (item in alarmArray) {
        if([item isEqualToString: @""]){
            [discardedItems addObject:item];
        }
    }
    [alarmArray removeObjectsInArray:discardedItems];
    [alarmArray writeToFile:alarmCacheFilename atomically:YES];
}

- (void) loadSavedAlarms {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    alarmCacheFilename = [documentsPath stringByAppendingPathComponent:@"geniotAlarm.plist"];
    alarmArray = [[NSMutableArray alloc] initWithContentsOfFile:alarmCacheFilename];
    if (alarmArray == nil) {
        alarmArray = [[NSMutableArray alloc] init];
    }
    
    [self deleteEmptyAlarms];
    NSLog(@"%@", alarmArray);
    for (int i=0; i<[alarmArray count]; i++) {
        [self loadSavedAlarm: [alarmArray objectAtIndex:i]: i];
    }
}

- (void)loadSavedAlarm:(NSString *)time: (int) index{
    CGFloat top = (CGFloat)(50 * index);
    NSLog(@"%f", top);
    UIBorderLabel *newAlarmLabel = [[UIBorderLabel alloc]initWithFrame:CGRectMake(0, top, self.view.frame.size.width, 50)];
    [newAlarmLabel setBackgroundColor:bgColor];
//    newAlarmLabel.layer.cornerRadius = 10;
    
    [newAlarmLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:25.0f]];
    newAlarmLabel.rightInset = 170;
    
    newAlarmLabel.textColor = [UIColor colorWithRed:150/255.0f green:120/255.0f blue:155/255.0f alpha:1.0f];
    newAlarmLabel.textAlignment = UITextAlignmentRight;
    newAlarmLabel.text = time;
//    NSLog(@"%d",index);
    newAlarmLabel.tag = index + alarmIndex;
    
    [scrollView addSubview:newAlarmLabel];
    
    UISwipeGestureRecognizer *showDeleteButton = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showDeleteButton:)];
    [showDeleteButton setDirection:(UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft)];

    UITapGestureRecognizer *editAlarm = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editAlarm:)];
    editAlarm.numberOfTapsRequired = 1;

    [newAlarmLabel setUserInteractionEnabled:YES];
    [newAlarmLabel addGestureRecognizer:editAlarm];
    [newAlarmLabel addGestureRecognizer:showDeleteButton];
    
    
    UIImage *deleteAlarmImge = [UIImage imageNamed:@"close.png"];
    UIImage *deleteAlarmImageOver = [UIImage imageNamed:@"closeOver.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(aMethod:) forControlEvents:UIControlEventTouchDown];
    [button setBackgroundImage:deleteAlarmImge forState:UIControlStateNormal];
    [button setBackgroundImage:deleteAlarmImageOver forState:UIControlStateHighlighted];
    UITapGestureRecognizer *deleteAlarm = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteAlarm:)];
				    
    deleteAlarm.numberOfTapsRequired = 1;
    [button setUserInteractionEnabled:YES];
    [button addGestureRecognizer:deleteAlarm];
    button.frame = CGRectMake(screenWidth-50, 5, 0, 40.0);
//    button.hidden = true;
    button.tag = (index + alarmIndex) * 10;

    [newAlarmLabel addSubview:button];

    [self resizeScrollView];
}



- (void) resizeScrollView {
    CGFloat scrollViewHeight = 0.0f;
    for (UIView* view in scrollView.subviews)
    {
        scrollViewHeight += view.frame.size.height;
    }
    
//    scrollView.contentSize = CGSizeMake(self.view.frame.size.width * numberOfViews, self.view.frame.size.height);
    
    
//    NSLog(@"height:");
//    NSLog(@"%f",scrollViewHeight);
    
    
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, scrollViewHeight);
}


- (IBAction)editAlarm:(UIGestureRecognizer *)alarmTapped{
    if(self.deleteDisplayedTag > 0){
        [self hideDeleteButton:alarmTapped];
    }
    else {
        int tag = alarmTapped.view.tag;
        NSLog(@"%d", tag);
        UILabel *alarm = (UILabel *)[self.view viewWithTag:tag];
    }
}

- (IBAction)showDeleteButton:(UIGestureRecognizer *)alarmSwiped{
    int tag = alarmSwiped.view.tag;
    if(tag*10 == self.deleteDisplayedTag){
        [self hideDeleteButton:alarmSwiped];
    }
    else {
        [self hideDeleteButton:alarmSwiped];
        UIButton *button = (UIButton *)[self.view viewWithTag:tag*10];
        self.deleteDisplayedTag = tag*10;
    
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
        //    button.hidden = false;
    }
}

- (IBAction)hideDeleteButton:(UIGestureRecognizer *)view{
    if(self.deleteDisplayedTag>0) {
    UIButton *button = (UIButton *)[self.view viewWithTag:self.deleteDisplayedTag];
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
    self.deleteDisplayedTag  = -1;
    }
}

- (IBAction)deleteAlarm:(UIGestureRecognizer *)btn{
    
    int tag = btn.view.tag/10;
    int cnt = [alarmArray count];
    UILabel *alarm = (UILabel *)[self.view viewWithTag:tag];
   
    UILabel *otherLabel;
    for (int i=tag-alarmIndex+1; i<cnt; i++) {
        otherLabel = (UILabel *)[self.view viewWithTag:i + alarmIndex];
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
    [self resizeScrollView];
    
    [alarm removeFromSuperview];
//    [alarmArray removeObjectAtIndex:tag-alarmIndex];
    [alarmArray replaceObjectAtIndex:tag-alarmIndex withObject:@""];
//    [self deleteEmptyAlarms];
    NSLog(@"delete this, %D", [alarmArray count]);
}

@end
