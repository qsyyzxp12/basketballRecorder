//
//  BBRDefenseViewController.h
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/8/25.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBRLogViewController.h"
#import "BBRMenuViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface BBRDefenseViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DBRestClientDelegate>

@property UITableView *playerListTableView;
@property UITableView *playerOnFloorListTableView;
@property UITableView *playerDataTableView;
@property UIView *defenseRecordeView;
@property NSMutableArray *playerOnFloorDataArray;
@property NSMutableArray* playerDataArray;
@property NSMutableArray* OldPlayerDataArray;
@property NSArray* defenseWayKeySet;
@property NSArray* playerNoSet;
@property BOOL isTmpPlistExist;
@property BOOL isRecordMode;
@property BOOL isTimerRunning;
@property int playerCount;
@property int playerSelectedIndex;
@property int quarterNo;
@property int showOldRecordNo;
@property int timeCounter;
@property int defenseButtonNo;
@property UIAlertController* nextQuarterAlert;
@property UIAlertController* finishOrNotAlert;
@property UIAlertController* playoffOrNotAlert;
@property NSString* tmpPlistPath;
@property NSString* recordName;
@property NSString* keyForSearch;
@property UIButton* undoButton;
@property UIButton* switchModeButton;
@property UIButton* nextQuarterButton;
@property UIButton* lastQuarterButton;
@property UIButton* timeButton;
@property NSTimer* timer;
@property UIBarButtonItem* rightBarButton;
@property (nonatomic, strong) DBRestClient *restClient;

@end