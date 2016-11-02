//
//  BBRBoxScoreViewController.h
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/9/11.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface BBRBoxScoreViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, DBRestClientDelegate>

@property UITableView *playerListTableView;
@property UITableView *playerOnFloorListTableView;
@property UITableView *playerDataTableView;
@property UIView *defenseRecordeView;
@property NSMutableArray *playerOnFloorDataArray;
@property NSMutableArray* playerDataArray;
@property NSMutableArray* OldPlayerDataArray;
@property NSMutableArray* fileNamesInDropbox;
@property NSArray* itemWayKeySet;
@property NSArray* playerNoSet;
@property BOOL isTmpPlistExist;
@property BOOL isRecordMode;
@property BOOL isTimerRunning;
@property BOOL isLoadMetaFinished;
@property BOOL isLoadingRootMeta;
@property BOOL isFolderExistAlready;
@property BOOL isSBLGame;
@property int sessionNo;
@property int gameNo;
@property int playerCount;
@property int playerSelectedIndex;
@property int quarterNo;
@property int showOldRecordNo;
@property int timeCounter;
@property int buttonNo;
@property UIAlertController* nextQuarterAlert;
@property UIAlertController* finishOrNotAlert;
@property UIAlertController* playoffOrNotAlert;
@property NSString* tmpPlistPath;
@property NSString* recordName;
@property NSString* keyForSearch;
@property NSString* gameType;
@property UIButton* undoButton;
@property UIButton* switchModeButton;
@property UIButton* nextQuarterButton;
@property UIButton* lastQuarterButton;
@property UIButton* timeButton;
@property NSTimer* timer;
@property UIView* spinView;
@property UILabel* loadingLabel;
@property UIActivityIndicatorView* spinner;
@property UIBarButtonItem* rightBarButton;
@property (nonatomic, strong) DBRestClient *restClient;

@end
