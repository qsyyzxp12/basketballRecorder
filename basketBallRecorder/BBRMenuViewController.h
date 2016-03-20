//
//  BBRMenuViewController.h
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/2/29.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KEY_FOR_LAST_RECORD_QUARTER @"LastRecordQuarter"
#define KEY_FOR_PLAYER_NO_SET @"PlayerNoSet"
#define KEY_FOR_GRADE @"Grade"
#define KEY_FOR_NAME @"Name"

@interface BBRMenuViewController : UIViewController 
@property (weak, nonatomic) IBOutlet UIButton *addNewCompetitionButton;
@property (weak, nonatomic) IBOutlet UIButton *lastCompetitionButton;
@property (weak, nonatomic) IBOutlet UIButton *lastTwoCompetitionButton;
@property (weak, nonatomic) IBOutlet UIButton *lastThreeCompetitionButton;
@property (weak, nonatomic) IBOutlet UIButton *lastFourCompetitionButton;
@property (weak, nonatomic) IBOutlet UIButton *lastFiveCompetitionButton;
@property NSArray* buttonArray;

@property UIAlertController* dirtyStatusAlert;
@property BOOL isTmpPlistExist;
@property int buttonClickedNo;
@end
