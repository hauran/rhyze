//
//  NewAlarmModalViewController.h
//  rhyze
//
//  Created by hauran on 6/27/13.
//  Copyright (c) 2013 Geniot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewAlarmModalViewController : UIViewController
- (IBAction)CloseSaveAlarmModal:(UIButton *)sender;
- (IBAction)SaveNewAlarm:(UIButton *)sender;

@property(nonatomic, weak) NSString *currentTime;


@end
