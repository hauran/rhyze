//
//  Alarm.h
//  rhyze
//
//  Created by hauran on 7/15/13.
//  Copyright (c) 2013 Geniot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIBorderLabel.h"

@interface Alarm : NSObject


@property (weak, nonatomic) NSString *time;
@property (weak, nonatomic) NSMutableArray *daysRepeat;
@property (weak, nonatomic) NSString *soundFile;
@property (nonatomic, assign) BOOL dismissed;
@property (nonatomic, nonatomic) float *alarmId;
@property (weak, nonatomic) NSMutableDictionary *alarmDictionary;

@end