//
//  BBRMenuViewController.h
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/2/29.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

enum XlsxType{PPP, SHOT_CHART};
enum LoadMetaType {PPP_AND_SHOT_CHART, FILE_NAMES, FOLDER_EXIST};

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
@property BOOL isGradeXlsxFileExistInDropbox;
@property BOOL isShotChartXlsxFileExistInDropbox;
@property BOOL isLoadMetaFinished;
@property BOOL isDownloadPPPXlsxFileFinished;
@property BOOL isDownloadShotChartXlsxFileFinished;
@property BOOL isUploadingOffenseXlsx;
@property BOOL isFolderExistAlready;
@property NSString* folderName;
@property enum LoadMetaType loadMetaType;

@property UIAlertController* dirtyStatusAlert;
@property BOOL isTmpPlistExist;
@property int buttonClickedNo;
@property int showOldRecordNo;
@property int uploadFilesCount;

@property (nonatomic, strong) DBRestClient *restClient;
@end
