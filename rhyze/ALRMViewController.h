//
//  ALRMViewController.h
//  rhyze //  Created by hauran on 6/12/13.
//  Copyright (c) 2013 Geniot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewAlarmModalViewController.h"
#import "UIBorderLabel.h"


@interface ALRMViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *currentTime;
@property (weak, nonatomic) IBOutlet UILabel *currentDate;

@property UIView *deleteDisplayedLabel;

- (void)saveAlarmClick:(NSString *)newAlarmTime;
- (void)dismissAlarm;
@end
