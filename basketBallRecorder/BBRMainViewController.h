//
//  BBRMainViewController.h
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/2/22.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBRLogViewController.h"
#import "BBRMenuViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface BBRMainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DBRestClientDelegate>
@property UITableView *playerListTableView;
@property UITableView *playerOnFloorListTableView;
@property UITableView *playerDataTableView;
@property NSMutableArray *playerOnFloorToPPPIndexMap;
@property NSMutableArray* playerDataArray;
@property NSMutableArray* OldPlayerDataArray;
@property NSArray* attackWaySet;
@property NSArray* attackWayKeySet;
@property NSArray* playerNoSet;
@property BOOL isShowZoneGrade;
@property BOOL isTmpPlistExist;
@property BOOL isRecordMode;
@property BOOL isTimerRunning;
@property int playerCount;
@property int playerSelectedIndex;
@property int zoneNo;
@property int quarterNo;
@property int showOldRecordNo;
@property int timeCounter;
@property UIAlertController* madeOrNotAlert;
@property UIAlertController* attackWayAlert;
@property UIAlertController* resultAlert;
@property UIAlertController* bonusAlertFor2Chance;
@property UIAlertController* bonusAlertFor3Chance;
@property UIAlertController* andOneAlert;
@property UIAlertController* nextQuarterAlert;
@property UIAlertController* playoffOrNotAlert;
@property UIAlertController* finishOrNotAlert;
@property UIImageView* backgroundImageView;
@property NSString* tmpPlistPath;
@property NSString* recordName;
@property NSString* keyForSearch;
@property UIButton* undoButton;
@property UIButton* switchModeButton;
@property UIButton* nextQuarterButton;
@property UIButton* lastQuarterButton;
@property UIButton* timeButton;
@property NSTimer* timer;
@property (nonatomic, strong) DBRestClient *restClient;
@end
