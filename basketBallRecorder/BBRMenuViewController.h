//
//  BBRMenuViewController.h
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/2/29.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>


@interface BBRMenuViewController : UIViewController <DBRestClientDelegate>
@property (weak, nonatomic) IBOutlet UIButton *addNewCompetitionButton;
@property (weak, nonatomic) IBOutlet UIButton *lastCompetitionButton;
@property (weak, nonatomic) IBOutlet UIButton *lastStatusButton;
@property (weak, nonatomic) IBOutlet UIButton *lastTwoCompetitionButton;
@property (weak, nonatomic) IBOutlet UIButton *lastTwoStatusButton;
@property (weak, nonatomic) IBOutlet UIButton *lastThreeCompetitionButton;
@property (weak, nonatomic) IBOutlet UIButton *lastThreeStatusButton;
@property (weak, nonatomic) IBOutlet UIButton *lastFourCompetitionButton;
@property (weak, nonatomic) IBOutlet UIButton *lastFourStatusButton;
@property (weak, nonatomic) IBOutlet UIButton *lastFiveCompetitionButton;
@property (weak, nonatomic) IBOutlet UIButton *lastFiveStatusButton;

@property UIView* spinView;
@property UILabel* loadingLabel;
@property UIActivityIndicatorView* spinner;

@property NSArray* statusButtonArray;
@property NSArray* buttonArray;

@property NSMutableArray* fileNamesInDropbox;
@property BOOL isLoadMetaFinished;

@property UIAlertController* dirtyStatusAlert;
@property BOOL isTmpPlistExist;
@property int buttonClickedNo;
@property int showOldRecordNo;

@property (nonatomic, strong) DBRestClient *restClient;
@end
