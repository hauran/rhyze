//
//  AlarmGoingOffViewController.m
//  rhyze
//
//  Created by hauran on 7/15/13.
//  Copyright (c) 2013 Geniot. All rights reserved.
//

#import "AlarmGoingOffViewController.h"
#import "UIBorderLabel.h"
#import "ALRMViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+FontAwesome.m"
#import <AVFoundation/AVFoundation.h>

@interface AlarmGoingOffViewController ()

@end

UIColor *btnColor;
UIColor *textColor_black;
CGRect screenBound;
CGFloat screenWidth;
CGFloat screenHeight;
AVAudioPlayer *audioPlayer;

@implementation AlarmGoingOffViewController

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
    // Do any additional setup after loading the view from its nib.
    
    btnColor = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:1.0f];
    textColor_black = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    screenBound = [[UIScreen mainScreen] bounds];
    screenWidth = screenBound.size.width;
    screenHeight = screenBound.size.height;
    
    UIButton *saveAlarmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveAlarmButton.backgroundColor = btnColor;
    //    saveAlarmButton.layer.cornerRadius = 10;
    saveAlarmButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:30.f];
    [saveAlarmButton setTitleColor:textColor_black forState:UIControlStateNormal];
    
    NSString *btnText = [NSString stringWithFormat:@"%@%@", [NSString fontAwesomeIconStringForIconIdentifier:@"icon-smile"], @"  I'm Up!"];
    
    [saveAlarmButton setTitle: btnText forState: UIControlStateNormal];
    saveAlarmButton.frame = CGRectMake(10, screenHeight - 80, screenWidth - 20, 50.0);
    
    UITapGestureRecognizer *SaveNewAlarm = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DismissAlarm:)];
    SaveNewAlarm.numberOfTapsRequired = 1;
    [saveAlarmButton setUserInteractionEnabled:YES];
    [saveAlarmButton addGestureRecognizer:SaveNewAlarm];
    
    [self.view addSubview:saveAlarmButton];
    
    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ring" ofType:@"mp3"];
//    // Convert the file path to a URL.
//    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
//    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
//    audioPlayer.numberOfLoops = 5;
//    [audioPlayer play];
}


- (IBAction)DismissAlarm:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [(ALRMViewController *)self.presentingViewController dismissAlarm];
    [self audioFadeOut];
}

-(void) audioFadeOut {
    if (self.audioPlayer.volume > 0.0) {
        self.audioPlayer.volume = audioPlayer.volume - 0.1;
        [self performSelector:@selector(audioFadeOut) withObject:nil afterDelay:0.2];
    }
    else {
        [self.audioPlayer stop];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
