//
//  NewAlarmModalViewController.m
//  rhyze
//
//  Created by hauran on 6/27/13.
//  Copyright (c) 2013 Geniot. All rights reserved.
//

#import "NewAlarmModalViewController.h"
#import "UIBorderLabel.h"
#import "ALRMViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+FontAwesome.m"

@interface NewAlarmModalViewController ()

@end


@implementation NewAlarmModalViewController {

    
    CAGradientLayer* _gradientLayer;
	CGPoint _originalCenter;
	BOOL _deleteOnDragRelease;
    
	CALayer *_itemCompleteLayer;
	BOOL _markCompleteOnDragRelease;
	UILabel *_tickLabel;
	UILabel *_crossLabel;
}

UIColor *bgColor_modal;
UIColor *bgColor_black;
UIColor *textColor;
int panDirection;
NSString *newAlarmTime;
UIBorderLabel *newAlarmLabel;
CGRect screenBound;
CGFloat screenWidth;
CGFloat screenHeight;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSString *)dateToTime: (NSDate *)date{
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    
    [timeFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [timeFormatter setDateStyle:NSDateFormatterNoStyle];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];

    return [[timeFormatter stringFromDate:date] lowercaseString];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    textColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    bgColor_modal = [UIColor colorWithRed:30/255.0f green:30/255.0f blue:30/255.0f alpha:1.0f];
    screenBound = [[UIScreen mainScreen] bounds];
    screenWidth = screenBound.size.width;
    screenHeight = screenBound.size.height;
    
    self.view.backgroundColor = bgColor_modal;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setBackgroundColor:bgColor_modal];
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:30.0f]];
    titleLabel.textColor = textColor;
    titleLabel.text = @"Create New Alarm";
    titleLabel.frame = CGRectMake(10, 10, screenWidth-10, 50);
    [[self view] addSubview:titleLabel];
    
    
    newAlarmLabel = [[UIBorderLabel alloc]initWithFrame:CGRectMake(10, 150, screenWidth - 20, 60)];
    bgColor_black = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    [newAlarmLabel setBackgroundColor:bgColor_black];
//    newAlarmLabel.layer.cornerRadius = 10;
    newAlarmLabel.leftInset = 15;
        
    [newAlarmLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:25.0f]];
    
    newAlarmLabel.textColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
        
    newAlarmLabel.text = self.currentTime;
    newAlarmTime = newAlarmLabel.text;
    
    UIGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [newAlarmLabel setUserInteractionEnabled:YES];
    [newAlarmLabel addGestureRecognizer:recognizer];
    
    [[self view] addSubview:newAlarmLabel];
    
    
    UIButton *newAlarmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    newAlarmButton.backgroundColor = [UIColor clearColor];
    newAlarmButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:25.f];
    [newAlarmButton setTitleColor:textColor forState:UIControlStateNormal];
    [newAlarmButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"icon-remove-sign"] forState: UIControlStateNormal];
    newAlarmButton.frame = CGRectMake(screenWidth-35, 10, 40.0, 40.0);
    
    UITapGestureRecognizer *closeAlarmModal = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeModal:)];
    closeAlarmModal.numberOfTapsRequired = 1;
    [newAlarmButton setUserInteractionEnabled:YES];
    [newAlarmButton addGestureRecognizer:closeAlarmModal];
    
    [self.view addSubview:newAlarmButton];
    
    
    
    UIButton *saveAlarmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveAlarmButton.backgroundColor = bgColor_black;
//    saveAlarmButton.layer.cornerRadius = 10;
    saveAlarmButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:30.f];
    [saveAlarmButton setTitleColor:textColor forState:UIControlStateNormal];
    
    NSString *btnText = [NSString stringWithFormat:@"%@%@", [NSString fontAwesomeIconStringForIconIdentifier:@"icon-bell"], @"  Save"];

    [saveAlarmButton setTitle: btnText forState: UIControlStateNormal];
    saveAlarmButton.frame = CGRectMake(10, screenHeight - 90, screenWidth - 20, 60.0);
    
    UITapGestureRecognizer *SaveNewAlarm = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SaveNewAlarm:)];
    SaveNewAlarm.numberOfTapsRequired = 1;
    [saveAlarmButton setUserInteractionEnabled:YES];
    [saveAlarmButton addGestureRecognizer:SaveNewAlarm];
    
    [self.view addSubview:saveAlarmButton];
    
}



-(void)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:newAlarmLabel];
    
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

//    CGFloat velocityY = [(UIPanGestureRecognizer*)recognizer velocityInView:self.view].y;
//    NSLog([NSString stringWithFormat: @"%.2f", velocityY]);
    
    //direction change
//    if(velocityY < 0 && panDirection != 1) {
//        panDirection = 1;
//        [dateString setString:@""];
//        [dateString appendFormat:@"%@ %@",[NSMutableString stringWithString:[dateFormatter stringFromDate:currDate]], newAlarmLabel.text];
//
//        currentAlarm = [currentAlarmFormat dateFromString:dateString];
//    }
//    else if(velocityY > 0 && panDirection != 0) {
//        panDirection = 0;
//        [dateString setString:@""];
//        [dateString appendFormat:@"%@ %@",[NSMutableString stringWithString:[dateFormatter stringFromDate:currDate]], newAlarmLabel.text];
//        
//        currentAlarm = [currentAlarmFormat dateFromString:dateString];
//    }
    
    NSDate *newDate;
//    if(fabs(velocityY) <10){
////        [dateString setString:@""];
//        [dateString appendFormat:@"%@ %@",[NSMutableString stringWithString:[dateFormatter stringFromDate:currDate]], newAlarmLabel.text];
//        currentAlarm = [currentAlarmFormat dateFromString:dateString];
//        newAlarmLabel.text=[self dateToTime:currentAlarm];
//        
//        if(panDirection == 1) {
//            newDate = [currentAlarm dateByAddingTimeInterval:60];
//        }
//        else {
//            newDate = [currentAlarm dateByAddingTimeInterval:-60];
//        }
//        
//        NSLog([self dateToTime:newDate]);
//        
//        newAlarmLabel.text=[self dateToTime:newDate];
//    }
//    else {
        newDate = [currentAlarm dateByAddingTimeInterval:translation.y/-2 * 60];
        newAlarmLabel.text=[self dateToTime:newDate];
//    }
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        newAlarmTime = newAlarmLabel.text;
    }
}





//        // translate the center
//        CGPoint translation = [recognizer translationInView:newAlarmLabel];
//        newAlarmLabel.center = CGPointMake(_originalCenter.x + translation.x, _originalCenter.y);
//        
//        // determine whether the item has been dragged far enough to initiate a delete / complete
//        _markCompleteOnDragRelease = newAlarmLabel.frame.origin.x > newAlarmLabel.frame.size.width / 2;
//        _deleteOnDragRelease = newAlarmLabel.frame.origin.x < -newAlarmLabel.frame.size.width / 2;
//		// Context cues
//		// fade the contextual cues
//		float cueAlpha = fabsf(newAlarmLabel.frame.origin.x) / (newAlarmLabel.frame.size.width / 2);
//		_tickLabel.alpha = cueAlpha;
//		_crossLabel.alpha = cueAlpha;
//        
//		// indicate when the item have been pulled far enough to invoke the given action
//		_tickLabel.textColor = _markCompleteOnDragRelease ?
//        [UIColor greenColor] : [UIColor whiteColor];
//		_crossLabel.textColor = _deleteOnDragRelease ?
//        [UIColor redColor] : [UIColor whiteColor];
//    }
//
//    if (recognizer.state == UIGestureRecognizerStateEnded) {
//        // the frame this cell would have had before being dragged
//        CGRect originalFrame = CGRectMake(0, self.frame.origin.y,
//                                          self.bounds.size.width, self.bounds.size.height);
//        if (!_deleteOnDragRelease) {
//            // if the item is not being deleted, snap back to the original location
//            [UIView animateWithDuration:0.2
//                             animations:^{
//                                 self.frame = originalFrame;
//                             }
//             ];
//        }
//		if (_deleteOnDragRelease) {
//			// notify the delegate that this item should be deleted
//			[self.delegate toDoItemDeleted:self.todoItem];
//		}
//        if (_markCompleteOnDragRelease) {
//            // mark the item as complete and update the UI state
//            self.todoItem.completed = YES;
//            _itemCompleteLayer.hidden = NO;
//            _label.strikethrough = YES;
//        }
//    }
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeModal:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)SaveNewAlarm:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [(ALRMViewController *)self.presentingViewController saveAlarmClick:newAlarmTime];
}
@end
