//
//  ALRMViewController.h
//  rhyze //  Created by hauran on 6/12/13.
//  Copyright (c) 2013 Geniot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALRMViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *currentTime;
@property (weak, nonatomic) IBOutlet UILabel *currentDate;
@property (weak, nonatomic) IBOutlet UIView *viewPan;

- (IBAction)handlePan:(UIGestureRecognizer *)sender;
- (void)saveAlarmClick: (id)sender;
@end
