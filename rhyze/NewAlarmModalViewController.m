//
//  NewAlarmModalViewController.m
//  rhyze
//
//  Created by hauran on 6/27/13.
//  Copyright (c) 2013 Geniot. All rights reserved.
//

#import "NewAlarmModalViewController.h"
#import "UIBorderLabel.h"
#import <QuartzCore/QuartzCore.h>

@interface NewAlarmModalViewController ()

@end

UIColor *bgColor;

@implementation NewAlarmModalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    bgColor = [UIColor colorWithRed:30/255.0f green:30/255.0f blue:30/255.0f alpha:1.0f];
    self.view.backgroundColor = bgColor;
    // Do any additional setup after loading the view from its nib.
    
    
    
    UIBorderLabel *newAlarmLabel = [[UIBorderLabel alloc]initWithFrame:CGRectMake(10, 150, 290, 50)];
    UIColor *bgColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    [newAlarmLabel setBackgroundColor:bgColor];
    newAlarmLabel.layer.cornerRadius = 10;
    newAlarmLabel.leftInset = 15;
        
    [newAlarmLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:25.0f]];
    
    newAlarmLabel.textColor = [UIColor colorWithRed:150/255.0f green:120/255.0f blue:155/255.0f alpha:1.0f];
        
    newAlarmLabel.text = @"8:00 pm";
    [[self view] addSubview:newAlarmLabel];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)CloseSaveAlarmModal:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)SaveNewAlarm:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
