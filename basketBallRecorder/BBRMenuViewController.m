//
//  BBRMenuViewController.m
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/2/29.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import "BBRMenuViewController.h"
#import "BBROffenseViewController.h"
#import "BBRDefenseViewController.h"
#import "BRAOfficeDocumentPackage.h"
#import "BBRBoxScoreViewController.h"
#import "BBRMacro.h"
#import <DropboxSDK/DropboxSDK.h>

@interface BBRMenuViewController ()

@end

@implementation BBRMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self constructAlertController];
    
    [self.navigationItem setHidesBackButton:YES];
    
    [self.addNewCompetitionButton setFrame:CGRectMake(CGRectGetMidX(self.view.frame)-76, self.view.frame.size.height*0.12, 152, 30)];
    
    self.spinView = [[UIView alloc] initWithFrame:self.view.frame];
    self.spinView.backgroundColor = [UIColor grayColor];
    self.spinView.alpha = 0.8;
    
    self.loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.spinView.frame)-50, CGRectGetMidY(self.spinView.frame)-15, 100, 30)];
    self.loadingLabel.backgroundColor = [UIColor whiteColor];
    self.loadingLabel.textAlignment = NSTextAlignmentCenter;
    self.loadingLabel.text = @"Loading";
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.frame = CGRectMake(CGRectGetMinX(self.loadingLabel.frame), CGRectGetMaxY(self.loadingLabel.frame), 100, 30);
    self.spinner.backgroundColor = [UIColor whiteColor];
    [self.spinner startAnimating];
    
    self.buttonClickedNo = 0;
    
    self.buttonArray = [NSArray arrayWithObjects:self.lastCompetitionButton, self.lastTwoCompetitionButton, self.lastThreeCompetitionButton, self.lastFourCompetitionButton, self.lastFiveCompetitionButton, nil];
    self.statusButtonArray = [NSArray arrayWithObjects:self.lastStatusButton, self.lastTwoStatusButton, self.lastThreeStatusButton, self.lastFourStatusButton, self.lastFiveStatusButton, nil];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.rightBarButtonItem.title = @"重新整理";
    self.navigationItem.rightBarButtonItem.target = self;
    self.navigationItem.rightBarButtonItem.action = @selector(viewWillAppear:);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.leftBarButtonItem.title = @"資料庫切換";
    self.navigationItem.leftBarButtonItem.target = self;
    self.navigationItem.leftBarButtonItem.action = @selector(leftBarButtonClicked);
    
    for(int i=0; i<5; i++)
    {
        if(!i)
            [(self.buttonArray[i]) setFrame:CGRectMake(0, CGRectGetMaxY(self.addNewCompetitionButton.frame)+30, self.view.frame.size.width*0.6, 30)];
        else
            [(self.buttonArray[i]) setFrame:CGRectMake(0, CGRectGetMaxY(self.buttonArray[i-1].frame)+12, self.view.frame.size.width*0.6, 30)];
        
        [(self.statusButtonArray[i]) setFrame:CGRectMake(CGRectGetMaxX(self.buttonArray[i].frame), CGRectGetMinY(self.buttonArray[i].frame), self.view.frame.size.width*0.4, 30)];
        
        self.buttonArray[i].hidden = YES;
        self.statusButtonArray[i].hidden = YES;
    }
    
    self.isTmpPlistExist = NO;
    
    NSFileManager* fm = [[NSFileManager alloc] init];
    NSString* tmpPlistPath = [NSString stringWithFormat:@"%@/Documents/tmp.plist", NSHomeDirectory()];
    
    if([fm fileExistsAtPath:tmpPlistPath])
    {
        self.isTmpPlistExist = YES;
        [self presentViewController:self.dirtyStatusAlert animated:YES completion:nil];
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [self.view addSubview:self.spinView];
    [self.view addSubview:self.spinner];
    self.loadingLabel.text = @"Loading";
    [self.view addSubview:self.loadingLabel];
    
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    
    self.isLoadMetaFinished = NO;
    self.loadMetaType = PPP_AND_SHOT_CHART;
    [self.restClient loadMetadata:@"/"];
    
    [self updateButtons];
}

-(void) updateButtons
{
    NSFileManager* fm = [[NSFileManager alloc] init];
    NSString* src = [[NSBundle mainBundle] pathForResource:@"record" ofType:@"plist"];
    NSString* recordPlistPath = [NSString stringWithFormat:@"%@/Documents/record.plist", NSHomeDirectory()];
    if(![fm fileExistsAtPath:recordPlistPath])
    {
        [fm copyItemAtPath:src toPath:recordPlistPath error:nil];
        for(UIButton* button in self.buttonArray)
            button.hidden = YES;
        for(UIButton* button in self.statusButtonArray)
            button.hidden = YES;
    }
    else
    {
        //        [fm removeItemAtPath:recordPlistPath error:nil];
        NSArray* recordPlistContent = [NSArray arrayWithContentsOfFile:recordPlistPath];
        int buttonIndex = 0;
        for (int i=((int)[recordPlistContent count]-1); i >= 0; i--)
        {
            NSString* gameName;
            if([[[recordPlistContent objectAtIndex:i] objectForKey:KEY_FOR_DATA_TYPE] isEqualToString:OFFENSE_TYPE_DATA])
                gameName = [NSString stringWithFormat:@"%@_進攻", [[recordPlistContent objectAtIndex:i] objectForKey:KEY_FOR_NAME]];
            else
                gameName = [[recordPlistContent objectAtIndex:i] objectForKey:KEY_FOR_NAME];
            [self.buttonArray[buttonIndex] setTitle:gameName forState:UIControlStateNormal];
            self.buttonArray[buttonIndex].hidden = NO;
            self.statusButtonArray[buttonIndex].hidden = NO;
            [self.statusButtonArray[buttonIndex] setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [self.statusButtonArray[buttonIndex] setTitle:@"上傳" forState:UIControlStateNormal];
            self.statusButtonArray[buttonIndex].userInteractionEnabled = YES;
            buttonIndex++;
        }
        for(int i=(int)[recordPlistContent count]; i<5; i++)
        {
            self.buttonArray[i].hidden = YES;
            self.statusButtonArray[i].hidden = YES;
        }
    }
    [self.spinView removeFromSuperview];
    [self.loadingLabel removeFromSuperview];
    [self.spinner removeFromSuperview];
}

-(void) constructAlertController
{
    self.dirtyStatusAlert = [UIAlertController alertControllerWithTitle:@"注意" message:@"上次的紀錄尚未完成，是否要繼續記錄？" preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"要" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            NSString* tmpPlistPath = [NSString stringWithFormat:@"%@/Documents/tmp.plist", NSHomeDirectory()];
            NSMutableDictionary* tmpPlistDic = [NSMutableDictionary dictionaryWithContentsOfFile:tmpPlistPath];
            if([[tmpPlistDic objectForKey:KEY_FOR_DATA_TYPE] isEqualToString:OFFENSE_TYPE_DATA])
                [self performSegueWithIdentifier:SEGUE_ID_FOR_OFFENSE sender:nil];
            else if([[tmpPlistDic objectForKey:KEY_FOR_DATA_TYPE] isEqualToString:DEFENSE_TYPE_DATA])
                [self performSegueWithIdentifier:SEGUE_ID_FOR_DEFENSE sender:nil];
            else if([[tmpPlistDic objectForKey:KEY_FOR_DATA_TYPE] isEqualToString:BOX_RECORD_TYPE_DATA])
                [self performSegueWithIdentifier:SEGUE_ID_FOR_BOX_SCORE sender:nil];
        }];
    UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"不要" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action)
        {
            NSFileManager* fm = [[NSFileManager alloc] init];
            NSString* tmpPlistPath = [NSString stringWithFormat:@"%@/Documents/tmp.plist", NSHomeDirectory()];
            [fm removeItemAtPath:tmpPlistPath error:nil];
        }];
    
    [self.dirtyStatusAlert addAction:yesAction];
    [self.dirtyStatusAlert addAction:noAction];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SEGUE_ID_FOR_OFFENSE])
    {
        BBROffenseViewController* mainViewCntler = [segue destinationViewController];
        mainViewCntler.isTmpPlistExist = self.isTmpPlistExist;
        mainViewCntler.showOldRecordNo = self.showOldRecordNo + 1;
      //  NSLog(@"%d", mainViewCntler.showOldRecordNo);
    }
    else if([segue.identifier isEqualToString:SEGUE_ID_FOR_DEFENSE])
    {
        BBRDefenseViewController* defenseViewCntler = [segue destinationViewController];
        defenseViewCntler.isTmpPlistExist = self.isTmpPlistExist;
        defenseViewCntler.showOldRecordNo = self.showOldRecordNo + 1;
    }
    else if([segue.identifier isEqualToString:SEGUE_ID_FOR_BOX_SCORE])
    {
        BBRBoxScoreViewController* defenseViewCntler = [segue destinationViewController];
        defenseViewCntler.isTmpPlistExist = self.isTmpPlistExist;
        defenseViewCntler.showOldRecordNo = self.showOldRecordNo + 1;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)leftBarButtonClicked
{
    if ([[DBSession sharedSession] isLinked])
        [[DBSession sharedSession] unlinkAll];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)recordButtonClicked:(UIButton*)sender
{
    self.buttonClickedNo = (int)sender.tag;
    NSString* recordPlistPath = [NSString stringWithFormat:@"%@/Documents/record.plist", NSHomeDirectory()];
    NSArray* recordPlistArray = [NSArray arrayWithContentsOfFile:recordPlistPath];
    self.showOldRecordNo = (int)[recordPlistArray count] - self.buttonClickedNo;
    NSDictionary* dataDic = [recordPlistArray objectAtIndex:self.showOldRecordNo];
    if([[dataDic objectForKey:KEY_FOR_DATA_TYPE] isEqualToString:OFFENSE_TYPE_DATA])
        [self performSegueWithIdentifier:SEGUE_ID_FOR_OFFENSE sender:nil];
    else if([[dataDic objectForKey:KEY_FOR_DATA_TYPE] isEqualToString:DEFENSE_TYPE_DATA])
        [self performSegueWithIdentifier:SEGUE_ID_FOR_DEFENSE sender:nil];
    else if([[dataDic objectForKey:KEY_FOR_DATA_TYPE]isEqualToString:BOX_RECORD_TYPE_DATA])
        [self performSegueWithIdentifier:SEGUE_ID_FOR_BOX_SCORE sender:nil];
}



- (IBAction)uploadButtonClicked:(UIButton*)sender
{
    [self.view addSubview:self.spinView];
    self.loadingLabel.text = @"Uploading";
    [self.view addSubview:self.loadingLabel];
    [self.view addSubview:self.spinner];
    NSString* recordPlistPath = [NSString stringWithFormat:@"%@/Documents/record.plist", NSHomeDirectory()];
    NSArray* recordPlistArray = [NSArray arrayWithContentsOfFile:recordPlistPath];
    
    int menuCount = (int)[recordPlistArray count];
    NSDictionary* dataDic = [recordPlistArray objectAtIndex:menuCount-(6-sender.tag)];
    
    while(!self.isLoadMetaFinished);
    self.isFolderExistAlready = NO;
    self.isLoadMetaFinished = NO;
    self.loadMetaType = FOLDER_EXIST;
    self.folderName = [dataDic objectForKey:KEY_FOR_DATE];
    [self.restClient loadMetadata:@"/"];
    NSThread *newThread = [[NSThread alloc] initWithTarget:self selector:@selector(xlsxFileGenerateAndUpload:) object:dataDic];

    [newThread start];
}

-(void)loadFolderMetaData
{
    NSString* path = [NSString stringWithFormat:@"/%@", self.folderName];
    [self.restClient loadMetadata:path];
}

- (void)downloadXlsxFile: (NSArray<NSString*>*) param
{
    NSString* pathInDropbox = [NSString stringWithFormat:@"/%@/%@", param[0], param[1]];
    NSString* sheetPath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), param[1]];
    [self.restClient loadFile:pathInDropbox intoPath:sheetPath];
}
- (void)deleteXlsxFile: (NSString*)path
{
    [self.restClient deletePath:path];
}

#pragma mark - Xlsx Files Operation

-(void) xlsxFileGenerateAndUpload:(NSDictionary*) dataDic
{
    while(!self.isLoadMetaFinished);
    if(self.isFolderExistAlready)
    {
        self.isLoadMetaFinished = NO;
        self.loadMetaType = FILE_NAMES;
        [self performSelectorOnMainThread:@selector(loadFolderMetaData) withObject:nil waitUntilDone:NO];
    }
    if([[dataDic objectForKey:KEY_FOR_DATA_TYPE] isEqualToString:OFFENSE_TYPE_DATA])
    {
        self.isUploadingOffenseXlsx = YES;
        
        while(!self.isLoadMetaFinished);
        [self performSelectorInBackground:@selector(generateTimeLineXlsx:) withObject:dataDic];
        [self performSelectorInBackground:@selector(generateGradeXlsx:) withObject:dataDic];
        [self performSelectorInBackground:@selector(generateShotChartXlsxAndUpload:) withObject:dataDic];
        [self performSelectorInBackground:@selector(generateZoneGradeXlsxAndUpload:) withObject:dataDic];
        self.isFstPlusMinusGenerateAndUploadFinished = NO;
        [self generatePlusMinusXlsxAndUpload:dataDic];
        self.isFstPlusMinusGenerateAndUploadFinished = YES;
        [self generateSecPlusMinusXlsxAndUpload:dataDic];
    }
    else if([[dataDic objectForKey:KEY_FOR_DATA_TYPE] isEqualToString:DEFENSE_TYPE_DATA])
    {
        self.isUploadingOffenseXlsx = NO;
        [self generateDefenseXlsx:dataDic];
    }
    else if([[dataDic objectForKey:KEY_FOR_DATA_TYPE] isEqualToString:BOX_RECORD_TYPE_DATA])
    {
        self.isUploadingOffenseXlsx = NO;
        [self generateBoxScoreXlsxAndUpload:dataDic];
    }
}

-(void) uploadXlsxFile:(NSArray*) parameters
{
    if([parameters[0] isEqualToString:[NSString stringWithFormat:@"%@.xlsx", NAME_OF_THE_FINAL_XLSX_FILE]] )
    {
        if(self.isGradeXlsxFileExistInDropbox)
            [self.restClient deletePath:[NSString stringWithFormat:@"/%@.xlsx", NAME_OF_THE_FINAL_XLSX_FILE]];
        else
            [self.restClient uploadFile:[parameters objectAtIndex:0] toPath:@"/" withParentRev:nil fromPath:[parameters objectAtIndex:1]];
    }
    else if([parameters[0] isEqualToString:[NSString stringWithFormat:@"%@.xlsx", NAME_OF_THE_SHOT_CHART_XLSX_FILE]])
    {
        if(self.isShotChartXlsxFileExistInDropbox)
            [self.restClient deletePath:[NSString stringWithFormat:@"/%@.xlsx", NAME_OF_THE_SHOT_CHART_XLSX_FILE]];
        else
            [self.restClient uploadFile:[parameters objectAtIndex:0] toPath:@"/" withParentRev:nil fromPath:[parameters objectAtIndex:1]];
    }
    else
        [self.restClient uploadFile:[parameters objectAtIndex:0] toPath:@"/" withParentRev:nil fromPath:[parameters objectAtIndex:1]];
}

- (void)generatePlusMinusXlsxAndUpload:(NSDictionary*)dataDic
{
    NSArray* plusMinusArray = [dataDic objectForKey:KEY_FOR_PLUS_MINUS];
    NSString* gameDate = [dataDic objectForKey:KEY_FOR_DATE];
    NSString* recordName = [NSString stringWithFormat:@"%@_%@.xlsx", [dataDic objectForKey:KEY_FOR_NAME], NAME_OF_THE_PLUS_MINUS_XLSX_FILE];
    NSArray* playerNoSet = [dataDic objectForKey:KEY_FOR_PLAYER_NO_SET];
    
    self.isPlusMinusXlsxFileExistInDropbox = NO;
    NSString* xlsxFilePath;

    if([self.fileNamesInDropbox containsObject:recordName])
    {
        self.isPlusMinusXlsxFileExistInDropbox = YES;
        self.isDownloadPlusMinusXlsxFileFinished = NO;
        NSArray* param = [NSArray arrayWithObjects:gameDate, recordName, nil];
        [self performSelectorOnMainThread:@selector(downloadXlsxFile:) withObject:param waitUntilDone:NO];
        while (!self.isDownloadPlusMinusXlsxFileFinished);
        self.isDeletePlusMinusXlsxFileFinished = NO;
        [self performSelectorOnMainThread:@selector(deleteXlsxFile:) withObject:[NSString stringWithFormat:@"/%@/%@", gameDate, recordName] waitUntilDone:NO];
        xlsxFilePath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), recordName];
    }
    else
        xlsxFilePath = [[NSBundle mainBundle] pathForResource:NAME_OF_THE_PLUS_MINUS_XLSX_FILE ofType:@"xlsx"];
    
    BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:xlsxFilePath];
    BRAWorksheet *worksheet = spreadsheet.workbook.worksheets[0];
    char outIndex = '\0';
    char interIndex = 'A';
    int rowIndex = 2;
    NSString* cellRef;
    
  //  NSLog(@"%@", plusMinusArray);
    
    for(NSMutableDictionary* eventDic in plusMinusArray)
    {
        char outI = outIndex;
        char interI = interIndex;
        cellRef = [NSString stringWithFormat:@"%c%c%d", outI, interI, rowIndex];
        NSArray* playerNoArray = [eventDic objectForKey:KEY_FOR_PLAYER_ON_FLOOR];

        for(NSString* playerNo in playerNoArray)
        {
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:playerNo];
            cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:rowIndex];
        }
        NSNumber* startTime = [eventDic objectForKey:KEY_FOR_START_TIME];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:startTime.integerValue];
        cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:rowIndex];
        
        NSNumber* endTime = [eventDic objectForKey:KEY_FOR_END_TIME];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:endTime.integerValue];
        cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:rowIndex];
        
        NSNumber* pts = [eventDic objectForKey:KEY_FOR_PTS];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:pts.integerValue];
        rowIndex++;
    }
    
    interIndex = 'P';
    rowIndex = 2;
    for(NSString* playerNo in playerNoSet)
    {
        cellRef = [NSString stringWithFormat:@"%c%c%d", outIndex, interIndex, rowIndex];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:playerNo];
        rowIndex++;
    }
    
    if(self.isPlusMinusXlsxFileExistInDropbox)
        [self analyzePlusMinusXlsxFile:worksheet];
    
    //Save the xlsx to the app space in the device
    NSString *localPath = [NSString stringWithFormat:@"%@/Documents/%@.xlsx", NSHomeDirectory(), NAME_OF_THE_PLUS_MINUS_XLSX_FILE];
    NSFileManager* fm = [[NSFileManager alloc] init];
    
    if([fm fileExistsAtPath:localPath])
        [fm removeItemAtPath:localPath error:nil];
    
    [spreadsheet saveAs:localPath];
    
  //  NSString* filename = [self addXlsxVersionNumber:1 type:NAME_OF_THE_PLUS_MINUS_XLSX_FILE recordName:recordName];
    
    NSString* dropBoxpath = [NSString stringWithFormat:@"%@/%@", self.folderName, recordName];
    NSArray* agus = [[NSArray alloc] initWithObjects:dropBoxpath, localPath, nil];
    if(self.isPlusMinusXlsxFileExistInDropbox)
        while(!self.isDeletePlusMinusXlsxFileFinished);
    [self performSelectorOnMainThread:@selector(uploadXlsxFile:) withObject:agus waitUntilDone:0];
}

- (void)generateSecPlusMinusXlsxAndUpload:(NSDictionary*)dataDic
{
    NSString* gameDate = [dataDic objectForKey:KEY_FOR_DATE];
    NSString* myTeamName = [dataDic objectForKey:KEY_FOR_MY_TEAM_NAME];
    NSString* opponentName = [dataDic objectForKey:KEY_FOR_OPPONENT_NAME];
    NSNumber* isSBLGame = [dataDic objectForKey:KEY_FOR_IS_SBL_GAME];
    NSArray* timeLineRecordArray = [dataDic objectForKey:KEY_FOR_TIMELINE];
    NSString* recordName;
    if(!isSBLGame.intValue)
        recordName = [NSString stringWithFormat:@"%@_vs_%@-%@_%@.xlsx", opponentName, myTeamName, gameDate, NAME_OF_THE_PLUS_MINUS_XLSX_FILE];
    else
    {
        NSString* gameSeason = [dataDic objectForKey:KEY_FOR_GAME_SEASON];
        NSString* gameNo = [dataDic objectForKey:KEY_FOR_GAME_NO];
        recordName = [NSString stringWithFormat:@"%@%@-%@_vs_%@-%@_%@.xlsx", gameSeason, gameNo, opponentName , myTeamName, gameDate, NAME_OF_THE_PLUS_MINUS_XLSX_FILE];
    }
    
    self.isSecPlusMinusXlsxFileExistInDropbox = NO;
    NSString* xlsxFilePath;
    if([self.fileNamesInDropbox containsObject:recordName])
    {
        self.isSecPlusMinusXlsxFileExistInDropbox = YES;
        self.isDownloadSecPlusMinusXlsxFileFinished = NO;
        NSArray* param = [NSArray arrayWithObjects:gameDate, recordName, nil];
        [self performSelectorOnMainThread:@selector(downloadXlsxFile:) withObject:param waitUntilDone:NO];
        while (!self.isDownloadSecPlusMinusXlsxFileFinished);
        self.isDeleteSecPlusMinusXlsxFileFinished = NO;
        [self performSelectorOnMainThread:@selector(deleteXlsxFile:) withObject:[NSString stringWithFormat:@"/%@/%@", gameDate, recordName] waitUntilDone:NO];
        xlsxFilePath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), recordName];
    }
    else
        xlsxFilePath = [[NSBundle mainBundle] pathForResource:NAME_OF_THE_PLUS_MINUS_XLSX_FILE ofType:@"xlsx"];
    
    BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:xlsxFilePath];
    BRAWorksheet *worksheet = spreadsheet.workbook.worksheets[0];
    
    int rowIndex = 2;
    NSString* cellRef;
    for(int quarterNo = 0; quarterNo < timeLineRecordArray.count; quarterNo++)
    {
        NSDictionary* quarterTimeLineDic = [timeLineRecordArray objectAtIndex:quarterNo];
        NSArray* timeLineArray = [quarterTimeLineDic objectForKey:KEY_FOR_TIME_LINE_DATA];
        for(NSDictionary* eventDic in timeLineArray)
        {
            NSString* type = [eventDic objectForKey:KEY_FOR_TYPE];
            if(![type isEqualToString:SIGNAL_FOR_NORMAL] && ![type isEqualToString:SIGNAL_FOR_BONUS])
                continue;
            NSInteger pts = [[eventDic objectForKey:KEY_FOR_PTS] integerValue];
            if(!pts)
                continue;
            NSString* time = [eventDic objectForKey:KEY_FOR_TIME];
            NSArray* timeArr = [time componentsSeparatedByString:@":"];
            int timeInSec = [timeArr[0] intValue]*60 + [timeArr[1] intValue];
            if(quarterNo < 4)
                timeInSec += quarterNo*600;
            else
                timeInSec += 600*4 + (quarterNo-4)*300;
            cellRef = [NSString stringWithFormat:@"M%d", rowIndex];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:timeInSec];
            
            cellRef = [NSString stringWithFormat:@"N%d", rowIndex];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:pts];
            
            rowIndex++;
        }
    }
    
    if(self.isSecPlusMinusXlsxFileExistInDropbox)
        [self analyzePlusMinusXlsxFile:worksheet];
    
    //Save the xlsx to the app space in the device
    NSString *localPath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), recordName];
    NSFileManager* fm = [[NSFileManager alloc] init];
    
    if([fm fileExistsAtPath:localPath])
        [fm removeItemAtPath:localPath error:nil];
    
    [spreadsheet saveAs:localPath];
    
    NSString* dropboxPath = [NSString stringWithFormat:@"%@/%@", self.folderName, recordName];
    NSArray* agus = [[NSArray alloc] initWithObjects:dropboxPath, localPath, nil];
    if(self.isSecPlusMinusXlsxFileExistInDropbox)
        while(!self.isDeleteSecPlusMinusXlsxFileFinished);
    [self performSelectorOnMainThread:@selector(uploadXlsxFile:) withObject:agus waitUntilDone:0];
}

- (void)generateShotChartXlsxAndUpload:(NSDictionary*)dataDic
{
    NSArray* playerDataArray = [dataDic objectForKey:KEY_FOR_GRADE];
    NSArray* playerNoSet = [dataDic objectForKey:KEY_FOR_PLAYER_NO_SET];
    NSString* myTeamName = [dataDic objectForKey:KEY_FOR_MY_TEAM_NAME];
    NSString* opponentName = [dataDic objectForKey:KEY_FOR_OPPONENT_NAME];
    NSString* gameDate = [dataDic objectForKey:KEY_FOR_DATE];
    NSString* xlsxFilePath;
    if(self.isShotChartXlsxFileExistInDropbox && [myTeamName isEqualToString:NAME_OF_NTU_MALE_BASKETBALL])
    {
        while (!self.isDownloadShotChartXlsxFileFinished);
        xlsxFilePath = [NSString stringWithFormat:@"%@/Documents/%@.xlsx", NSHomeDirectory(), NAME_OF_THE_SHOT_CHART_XLSX_FILE];
    }
    else
        xlsxFilePath = [[NSBundle mainBundle] pathForResource:NAME_OF_THE_SHOT_CHART_XLSX_FILE ofType:@"xlsx"];
    
    BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:xlsxFilePath];
    for(int i=0; i<=playerNoSet.count; i++)
    {
        char outIndex = '\0';
        char interIndex = 'A';
        int rowIndex = 0;
        
        BRAWorksheet *worksheet = [self lookForWorkSheetWithPlayerIndex:i spreadSheet:spreadsheet playerNoArray:playerNoSet type:SHOT_CHART];
        
        NSString* cellRef;
        NSString *cellContent;
        do
        {
            rowIndex = rowIndex + 2;
            cellRef = [NSString stringWithFormat:@"%c%c%d", outIndex, interIndex, rowIndex];
            cellContent = [[worksheet cellForCellReference:cellRef] stringValue];
        }while(cellContent && ![cellContent isEqualToString:@""]);
        
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:gameDate];
        
        cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:rowIndex];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:opponentName];
        
        NSArray* totalGradeArray = [playerDataArray objectAtIndex:0];
        NSDictionary* playerGradeDic = [totalGradeArray objectAtIndex:i];
        
        for(int j=0; j<11; j++)
        {
            NSString* key = [NSString stringWithFormat:@"zone%d", j+1];
            NSDictionary* zoneGradeDic = [playerGradeDic objectForKey:key];
            
            cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:rowIndex];
            int madeCount = [[zoneGradeDic objectForKey:KEY_FOR_MADE_COUNT] intValue];
            int attemptCount = [[zoneGradeDic objectForKey:KEY_FOR_ATTEMPT_COUNT] intValue];
            NSString* madeAndAttempt = [NSString stringWithFormat:@"%d/%d", madeCount, attemptCount];
            
            NSString* ratio = @"0%";
            if(attemptCount)
                ratio = [NSString stringWithFormat:@"%.0f%c", ((float)madeCount/attemptCount)*100, '%'];
            
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:ratio];
            
            cellRef = [NSString stringWithFormat:@"%c%c%d", outIndex, interIndex, rowIndex+1];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:madeAndAttempt];
        }
    }
    
    //Save the xlsx to the app space in the device
    NSString *localPath = [NSString stringWithFormat:@"%@/Documents/%@.xlsx", NSHomeDirectory(), NAME_OF_THE_SHOT_CHART_XLSX_FILE];
    NSFileManager* fm = [[NSFileManager alloc] init];
    
    if([fm fileExistsAtPath:localPath])
        [fm removeItemAtPath:localPath error:nil];
    
    [spreadsheet saveAs:localPath];
    
    NSString* recordName = [dataDic objectForKey:KEY_FOR_NAME];
    NSString* dropboxPath;
    if(![myTeamName isEqualToString:NAME_OF_NTU_MALE_BASKETBALL])
    {
        NSString* fileName = [self addXlsxVersionNumber:1 type:NAME_OF_THE_SHOT_CHART_XLSX_FILE recordName:recordName];
        dropboxPath = [NSString stringWithFormat:@"%@/%@",self.folderName, fileName];
    }
    else
        dropboxPath = [NSString stringWithFormat:@"%@.xlsx", NAME_OF_THE_SHOT_CHART_XLSX_FILE];
    
    NSArray* agus = [[NSArray alloc] initWithObjects:dropboxPath, localPath, nil];
    [self performSelectorOnMainThread:@selector(uploadXlsxFile:) withObject:agus waitUntilDone:0];
}

-(void) generateZoneGradeXlsxAndUpload:(NSDictionary*) dataDic
{
    
    NSArray* playerDataArray = [dataDic objectForKey:KEY_FOR_GRADE];
    NSArray* playerNoSet = [dataDic objectForKey:KEY_FOR_PLAYER_NO_SET];
    NSString* recordName = [dataDic objectForKey:KEY_FOR_NAME];
    NSString* orgDocumentPath = [[NSBundle mainBundle] pathForResource:NAME_OF_THE_ZONE_GRADE_XLSX_FILE ofType:@"xlsx"];
    BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:orgDocumentPath];
    
    for(int i=0; i<playerNoSet.count+1; i++)
    {
        BRAWorksheet* worksheet;
        if(i != playerNoSet.count)
            worksheet = [spreadsheet.workbook createWorksheetNamed:playerNoSet[i] byCopyingWorksheet:spreadsheet.workbook.worksheets[0]];
        else
            worksheet = spreadsheet.workbook.worksheets[0];
        
        NSArray* totalGradeArray = [playerDataArray objectAtIndex:0];
        NSDictionary* playerGradeDic = [totalGradeArray objectAtIndex:i];
        NSArray* ratioCellRefArray = [NSArray arrayWithObjects:@"C3", @"E3", @"G6", @"I3", @"K3", @"D20", @"E11", @"G17", @"I11", @"J20", @"G23", nil];
        NSArray* madeAttemptCellRefArray = [NSArray arrayWithObjects:@"C4", @"E4", @"G7", @"I4", @"K4", @"D21", @"E12", @"G18", @"I12", @"J21", @"G24", nil];
        for(int j=0; j<11; j++)
        {
            NSString* key = [NSString stringWithFormat:@"zone%d", j+1];
            NSDictionary* zoneDic = [playerGradeDic objectForKey:key];
            int madeCount = [[zoneDic objectForKey:KEY_FOR_MADE_COUNT] intValue];
            int attemptCount = [[zoneDic objectForKey:KEY_FOR_ATTEMPT_COUNT] intValue];
            NSString* madeAndAttempt = [NSString stringWithFormat:@"%d/%d", madeCount, attemptCount];
            NSString* ratio = @"0%";
            if(attemptCount)
                ratio = [NSString stringWithFormat:@"%.0f%c", ((float)madeCount/attemptCount)*100, '%'];
            
            [[worksheet cellForCellReference:ratioCellRefArray[j] shouldCreate:YES] setStringValue:ratio];
            [[worksheet cellForCellReference:madeAttemptCellRefArray[j] shouldCreate:YES] setStringValue:madeAndAttempt];
        }
    }
    
    //Save the xlsx to the app space in the device
    NSString *localPath = [NSString stringWithFormat:@"%@/Documents/%@.xlsx", NSHomeDirectory(), NAME_OF_THE_ZONE_GRADE_XLSX_FILE];
    NSFileManager* fm = [[NSFileManager alloc] init];
    
    if([fm fileExistsAtPath:localPath])
        [fm removeItemAtPath:localPath error:nil];
    
    [spreadsheet saveAs:localPath];
    
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY_MM_dd"];
    NSString* filename = [self addXlsxVersionNumber:1 type:@"投籃分佈圖" recordName:recordName];
    
    NSString* dropBoxpath = [NSString stringWithFormat:@"%@/%@",self.folderName, filename];
    NSArray* agus = [[NSArray alloc] initWithObjects:dropBoxpath, localPath, nil];
    [self performSelectorOnMainThread:@selector(uploadXlsxFile:) withObject:agus waitUntilDone:0];
}


-(void) generateDefenseXlsx:(NSDictionary*) dataDic
{
    //Generate the xlsx file
    NSString *documentPath = [[NSBundle mainBundle] pathForResource:@"spreadsheet_for_defense" ofType:@"xlsx"];
    NSArray* playerDataArray = [dataDic objectForKey:KEY_FOR_GRADE];
    NSArray* playerNoSet = [dataDic objectForKey:KEY_FOR_PLAYER_NO_SET];
    NSString* recordName = [dataDic objectForKey:KEY_FOR_NAME];
    
    NSArray* defenseWayKeySet = [[NSArray alloc] initWithObjects:@"Tip", @"CloseOut", @"StopBall", @"BLK", @"STL", @"8/24", @"DoubleTeam", @"LooseBall", @"OR", @"DR", @"ORTip", @"AST", @"TO", @"WIDEOPEN", @"NOBLOCKOUT", @"DEFASS", @"BlownBy", nil];
    
    BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:documentPath];
    for(int i=0; i<playerDataArray.count; i++)
    {
        BRAWorksheet *worksheet;
        if(i == [spreadsheet.workbook.worksheets count])
        {
            NSString* worksheetName;
            switch (i)
            {
                case 1: worksheetName = @"第一節"; break;
                case 2: worksheetName = @"第二節"; break;
                case 3: worksheetName = @"第三節"; break;
                case 4: worksheetName = @"第四節"; break;
                case 5: worksheetName = @"延長賽第一節"; break;
                case 6: worksheetName = @"延長賽第二節"; break;
                case 7: worksheetName = @"延長賽第三節"; break;
                case 8: worksheetName = @"延長賽第四節"; break;
                case 9: worksheetName = @"延長賽第五節"; break;
                case 10: worksheetName = @"延長賽第六節"; break;
            }
            worksheet = [spreadsheet.workbook createWorksheetNamed:worksheetName byCopyingWorksheet:spreadsheet.workbook.worksheets[0]];
        }
        else
            worksheet = spreadsheet.workbook.worksheets[i];
        
        NSString* cellRef;
        NSArray* totalGradeArray = [playerDataArray objectAtIndex:i];
        for(int i=0; i<playerNoSet.count+1; i++)
        {
            char outIndex = '\0';
            char interIndex = 'A';
            cellRef = [NSString stringWithFormat:@"%c%c%d", outIndex, interIndex++, i+3];
            if(i < playerNoSet.count)
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:playerNoSet[i]];
            else
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:@"全隊"];
            
            NSDictionary* playerDataDic = [totalGradeArray objectAtIndex:i];
            NSDictionary* deflectionDic = [playerDataDic objectForKey:KEY_FOR_DEFLECTION];
            NSDictionary* goodDic = [playerDataDic objectForKey:KEY_FOR_GOOD];
            NSDictionary* badDic = [playerDataDic objectForKey:KEY_FOR_BAD];
            NSArray* dicArray = [NSArray arrayWithObjects:deflectionDic, goodDic, badDic, nil];
            int top = 0;
            for(int k=0; k<3; k++)
            {
                for(int l=0; l<[dicArray[k] count]-1; l++)
                {
                    NSString* gradeStr = [dicArray[k] objectForKey:defenseWayKeySet[top++]];
                    if(interIndex == 91) // (int)'Z' == 90
                    {
                        if(outIndex != '\0')
                            outIndex++;
                        else
                            outIndex = 'A';
                        interIndex = 65;
                    }
                    cellRef = [NSString stringWithFormat:@"%c%c%d", outIndex, interIndex++, i+3];
                    [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:gradeStr];
                }
            }
            
            int deflectionTotal = [[deflectionDic objectForKey:KEY_FOR_TOTAL_COUNT] intValue];
            int goodTotal = deflectionTotal + [[goodDic objectForKey:KEY_FOR_TOTAL_COUNT] intValue];
            int total = goodTotal - [[badDic objectForKey:KEY_FOR_TOTAL_COUNT] intValue];
            
            NSString* str = [NSString stringWithFormat:@"%d", total];
            cellRef = [NSString stringWithFormat:@"S%d", i+3];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:str];
            
            str = [NSString stringWithFormat:@"%d", deflectionTotal];
            cellRef = [NSString stringWithFormat:@"T%d", i+3];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:str];
        }
        
    }
    
    //Save the xlsx to the app space in the device
    NSString *sheetPath = [NSString stringWithFormat:@"%@/Documents/spreadsheet.xlsx", NSHomeDirectory()];
    NSFileManager* fm = [[NSFileManager alloc] init];
    
    if([fm fileExistsAtPath:sheetPath])
        [fm removeItemAtPath:sheetPath error:nil];
    
    [spreadsheet saveAs:sheetPath];
    
    //Dropbox
    if (![[DBSession sharedSession] isLinked])
        [[DBSession sharedSession] linkFromController:self];
    
    while(!self.isLoadMetaFinished);
    NSString* filename = [self addXlsxFileVersionNumber:1 recordName:recordName];
    NSString* dropBoxpath = [NSString stringWithFormat:@"%@/%@", self.folderName, filename];
    
    NSArray* agus = [[NSArray alloc] initWithObjects: dropBoxpath, sheetPath, nil];
    [self performSelectorOnMainThread:@selector(uploadXlsxFile:) withObject:agus waitUntilDone:0];
    //  [self.restClient uploadFile:filename toPath:@"/" withParentRev:nil fromPath:sheetPath];
}

-(void) generateBoxScoreXlsxAndUpload:(NSDictionary*)dataDic
{
    //Generate the xlsx file
    NSArray* playerDataArray = [dataDic objectForKey:KEY_FOR_GRADE];
    NSArray* playerNoSet = [dataDic objectForKey:KEY_FOR_PLAYER_NO_SET];
    NSString* recordName = [dataDic objectForKey:KEY_FOR_NAME];
    NSArray* itemWayKeySet = [[NSArray alloc] initWithObjects:KEY_FOR_2_PTS, KEY_FOR_3_PTS, KEY_FOR_FREE_THROW, KEY_FOR_OFF_REB, KEY_FOR_DEF_REB, KEY_FOR_ASSIST, KEY_FOR_STEAL, KEY_FOR_BLOCK, KEY_FOR_TURNOVER, KEY_FOR_FOUL, KEY_FOR_TOTAL_TIME_ON_FLOOR, nil];
    
    NSString *documentPath = [[NSBundle mainBundle] pathForResource:@"spreadsheet_for_boxScore" ofType:@"xlsx"];
    BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:documentPath];
    BRAWorksheet *worksheet = spreadsheet.workbook.worksheets[0];
    
    NSString* cellRef;
    NSArray* totalGradeArray = [playerDataArray objectAtIndex:0];
    char outIndex = '\0';
    char interIndex = 'A';
    for(int i=0; i<playerNoSet.count+1; i++)
    {
        char outI = outIndex;
        char interI = interIndex;
        cellRef = [NSString stringWithFormat:@"%c%c%d", outI, interI, i+2];
        if(i < playerNoSet.count)
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:playerNoSet[i]];
        else
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:@"全隊"];
        
        NSDictionary* playerDataDic = [totalGradeArray objectAtIndex:i];
        
        cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:i+2];
        if(i != playerNoSet.count)
        {
            int time = [[playerDataDic objectForKey:KEY_FOR_TIME_ON_FLOOR] intValue];
            int min = time/60;
            int sec = time%60;
            NSString* timeStr = [NSString stringWithFormat:@"%02d:%02d", min, sec];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:timeStr];
        }
        else
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:@"-"];
        
        
        for(int j=0; j<3; j++)
        {
            NSDictionary* madeOrAttemptDic = [playerDataDic objectForKey:itemWayKeySet[j]];
            NSInteger madeCount = [[madeOrAttemptDic objectForKey:KEY_FOR_MADE_COUNT] integerValue];
            cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:i+2];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:madeCount];
            
            NSInteger attemptCount =[[madeOrAttemptDic objectForKey:KEY_FOR_ATTEMPT_COUNT] integerValue];
            cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:i+2];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:attemptCount];
            
            if(i == playerNoSet.count)
            {
                cellRef = [NSString stringWithFormat:@"%c%c%d", outI, interI, i+3];
                NSString* ratioStr;
                if(attemptCount)
                {
                    float ratio = (float)madeCount/attemptCount;
                    ratioStr = [NSString stringWithFormat:@"%.0f%c", ratio*100, '%'];
                }
                else
                    ratioStr = @"0%";
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:ratioStr];
            }
        }
        NSInteger orCount = [[playerDataDic objectForKey:itemWayKeySet[3]] integerValue];
        cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:i+2];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:orCount];
        
        NSInteger drCount = [[playerDataDic objectForKey:itemWayKeySet[4]] integerValue];
        cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:i+2];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:drCount];
        
        NSInteger trCount = orCount + drCount;
        cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:i+2];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:trCount];
        
        for(int j=5; j<itemWayKeySet.count-1; j++)
        {
            NSInteger count = [[playerDataDic objectForKey:itemWayKeySet[j]] integerValue];
            cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:i+2];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:count];
        }
        
        NSInteger totalPts = [[playerDataDic objectForKey:KEY_FOR_TOTAL_SCORE_GET] integerValue];
        cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:i+2];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:totalPts];
        
    }
    
    outIndex = '\0';
    interIndex = 'R';
    for(int i=1; i<playerDataArray.count; i++)
    {
        cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:1];
        NSString* title;
        if(i < 5)
            title = [NSString stringWithFormat:@"%dth", i];
        else
            title = [NSString stringWithFormat:@"OT%d", i-4];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:title];
        
        cellRef = [NSString stringWithFormat:@"%c%c2", outIndex, interIndex];
        NSArray* totalGradeArray = [playerDataArray objectAtIndex:i];
        NSDictionary* dic = [totalGradeArray objectAtIndex:playerNoSet.count];
        NSInteger pts = [[dic objectForKey:KEY_FOR_TOTAL_SCORE_GET] integerValue];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:pts];
    }
    
    
    //Save the xlsx to the app space in the device
    NSString *sheetPath = [NSString stringWithFormat:@"%@/Documents/spreadsheet.xlsx", NSHomeDirectory()];
    NSFileManager* fm = [[NSFileManager alloc] init];
    
    if([fm fileExistsAtPath:sheetPath])
        [fm removeItemAtPath:sheetPath error:nil];
    
    [spreadsheet saveAs:sheetPath];
    
    //Dropbox
    if (![[DBSession sharedSession] isLinked])
        [[DBSession sharedSession] linkFromController:self];
    
    while(!self.isLoadMetaFinished);
    //  NSLog(@"%@", self.fileNamesInDropbox);
    NSString* filename = [self addXlsxFileVersionNumber:1 recordName:recordName];
    NSString* dropBoxpath = [NSString stringWithFormat:@"%@/%@",self.folderName, filename];
    
    NSArray* agus = [[NSArray alloc] initWithObjects: dropBoxpath, sheetPath, nil];
    [self performSelectorOnMainThread:@selector(uploadXlsxFile:) withObject:agus waitUntilDone:0];
    //  [self.restClient uploadFile:filename toPath:@"/" withParentRev:nil fromPath:sheetPath];
}

-(void) generateTimeLineXlsx:(NSDictionary*)dataDic
{
    NSArray* timeLineRecordArray = [dataDic objectForKey:KEY_FOR_TIMELINE];
    NSString* name = [dataDic objectForKey:KEY_FOR_NAME];
    NSString* orgDocumentPath = [[NSBundle mainBundle] pathForResource:@"spreadsheet_for_timeLine" ofType:@"xlsx"];
    BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:orgDocumentPath];
    BRAWorksheet *worksheet = spreadsheet.workbook.worksheets[0];
    
    char outIndex = '\0';
    char interIndex = 'A';
    int rowIndex = 2;
    NSString* cellRef = [NSString stringWithFormat:@"%c%c%d", outIndex, interIndex, rowIndex];
    
    for(NSMutableDictionary* quarterDic in timeLineRecordArray)
    {
        NSArray* playersOnFloorNoArray = [quarterDic objectForKey:KEY_FOR_PLAYER_ON_FLOOR];
        NSString* playersOnFloorNoStr = [NSString stringWithFormat:@"%@,%@,%@,%@,%@", playersOnFloorNoArray[0], playersOnFloorNoArray[1], playersOnFloorNoArray[2], playersOnFloorNoArray[3], playersOnFloorNoArray[4]];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:playersOnFloorNoStr];
        
        NSArray* timeLineRecordArray = [quarterDic objectForKey:KEY_FOR_TIME_LINE_DATA];
    
        int rowI = rowIndex+1;
        int holdBallCount = 0;
        char outI = outIndex;
        char interI = interIndex;
        for(NSDictionary* eventDic in timeLineRecordArray)
        {
            outI =  outIndex;
            interI = interIndex;
            
            cellRef = [NSString stringWithFormat:@"%c%c%d", outI, interI, rowI];
            NSString* timeStr = [eventDic objectForKey:KEY_FOR_TIME];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:timeStr];
            
            if([[eventDic objectForKey:KEY_FOR_TYPE] isEqualToString:SIGNAL_FOR_NORMAL])
            {
                cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:rowI];
                NSString* playerNoStr = [eventDic objectForKey:KEY_FOR_PLAYER_NO];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:playerNoStr];
                
                cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:rowI];
                NSString* attackWayStr = [eventDic objectForKey:KEY_FOR_OFF_MODE];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:attackWayStr];
                
                cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:rowI];
                NSString* detailStr = [eventDic objectForKey:KEY_FOR_SHOT_MODE];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:detailStr];
                
                cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:rowI];
                NSString* resultStr = [eventDic objectForKey:KEY_FOR_RESULT];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:resultStr];
                
                cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:rowI];
                if([resultStr isEqualToString:SIGNAL_FOR_FOUL] || [resultStr isEqualToString:SIGNAL_FOR_AND_ONE])
                {
                    NSString* bonusStr = [eventDic objectForKey:KEY_FOR_BONUS];
                    [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:bonusStr];
                }
                
                cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:rowI];
                NSString* ptsStr = [eventDic objectForKey:KEY_FOR_PTS];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:ptsStr];
                holdBallCount++;
            }
            else if([[eventDic objectForKey:KEY_FOR_TYPE] isEqualToString:SIGNAL_FOR_BONUS])
            {
                cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:rowI];
                NSString* playerNoStr = [eventDic objectForKey:KEY_FOR_PLAYER_NO];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:playerNoStr];
                
                cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:rowI];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:SIGNAL_FOR_BONUS];
                
                cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:rowI];
                cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:rowI];
                cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:rowI];
                NSString* bonusStr = [eventDic objectForKey:KEY_FOR_BONUS];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:bonusStr];
                
                cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:rowI];
                NSString* ptsStr = [eventDic objectForKey:KEY_FOR_PTS];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:ptsStr];
                holdBallCount++;
            }
            else
            {
                NSString* result = [eventDic objectForKey:KEY_FOR_RESULT];
                cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:rowI];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:result];
            }
            rowI++;
        }
        
        cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:rowI];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:@"持球數"];
        
        cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:rowI];
        NSString* holdBallCountStr = [NSString stringWithFormat:@"%d", holdBallCount];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:holdBallCountStr];
        
        for(int i=0; i<6; i++)
            cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:rowIndex];
    }
    
    //Save the xlsx to the app space in the device
    NSString *sheetPath = [NSString stringWithFormat:@"%@/Documents/spreadsheet_for_timeLine.xlsx", NSHomeDirectory()];
    NSFileManager* fm = [[NSFileManager alloc] init];
    
    if([fm fileExistsAtPath:sheetPath])
        [fm removeItemAtPath:sheetPath error:nil];
    
    [spreadsheet saveAs:sheetPath];
    
    NSString* filename = [self addXlsxVersionNumber:1 type:@"時間軸" recordName:name];
    NSString* dropBoxpath = [NSString stringWithFormat:@"%@/%@",self.folderName, filename];
    
    NSArray* agus = [[NSArray alloc] initWithObjects:dropBoxpath, sheetPath, nil];
    [self performSelectorOnMainThread:@selector(uploadXlsxFile:) withObject:agus waitUntilDone:0];
}

-(void) generateGradeXlsx:(NSDictionary*)dataDic
{
    NSString* myTeamName = [dataDic objectForKey:KEY_FOR_MY_TEAM_NAME];
    NSString* xlsxFilePath;
    if(self.isGradeXlsxFileExistInDropbox && [myTeamName isEqualToString:NAME_OF_NTU_MALE_BASKETBALL])
    {
        while (!self.isDownloadPPPXlsxFileFinished);
        xlsxFilePath = [NSString stringWithFormat:@"%@/Documents/%@.xlsx", NSHomeDirectory(), NAME_OF_THE_FINAL_XLSX_FILE];
    }
    else
        xlsxFilePath = [[NSBundle mainBundle] pathForResource:NAME_OF_THE_FINAL_XLSX_FILE ofType:@"xlsx"];
    
    NSArray* playerNoSet = [dataDic objectForKey:KEY_FOR_PLAYER_NO_SET];
    NSString* opponentName = [dataDic objectForKey:KEY_FOR_OPPONENT_NAME];
    NSString* recordName = [dataDic objectForKey:KEY_FOR_NAME];
    NSArray* playerDataArray =[dataDic objectForKey:KEY_FOR_GRADE];
    NSString* gameDate = [dataDic objectForKey:KEY_FOR_DATE];
    
    NSArray* normalDetailItemKeyArray = [NSArray arrayWithObjects:KEY_FOR_DRIVE, KEY_FOR_PULL_UP, KEY_FOR_SPOT_UP, nil];
    NSArray* secondDetailItemKeyArray = [NSArray arrayWithObjects:KEY_FOR_DRIVE, KEY_FOR_PULL_UP, KEY_FOR_SPOT_UP, KEY_FOR_PUT_BACK, nil];
    NSArray* hpShotModeKeyArray = [NSArray arrayWithObjects:KEY_FOR_DRIVE, KEY_FOR_PULL_UP, KEY_FOR_SPOT_UP, KEY_FOR_HL, nil];
    NSArray* PNRDetailItemKeyArray = [NSArray arrayWithObjects:KEY_FOR_BD, KEY_FOR_BP, KEY_FOR_MPD, KEY_FOR_MR, KEY_FOR_MPS, KEY_FOR_MPP, nil];
    NSArray* PUDetailItemKeyArray = [NSArray arrayWithObjects:KEY_FOR_DRIVE, KEY_FOR_PULL_UP, KEY_FOR_SPOT_UP, KEY_FOR_SF, KEY_FOR_SF, nil];
    NSArray* TotalDetailItemArray = [NSArray arrayWithObjects:KEY_FOR_DRIVE, KEY_FOR_PULL_UP, KEY_FOR_SPOT_UP, KEY_FOR_SF, KEY_FOR_LP, KEY_FOR_HL, KEY_FOR_PUT_BACK, KEY_FOR_BD, KEY_FOR_BD, KEY_FOR_MPD, KEY_FOR_MR, KEY_FOR_MPS, KEY_FOR_MPP, nil];
    NSArray* turnOverArray = [NSArray arrayWithObjects:KEY_FOR_STOLEN, KEY_FOR_BAD_PASS, KEY_FOR_CHARGING, KEY_FOR_DROP, KEY_FOR_LINE, KEY_FOR_3_SENCOND, KEY_FOR_TRAVELING, KEY_FOR_TEAM, nil];
    NSArray* attackWayKeySet = [[NSArray alloc] initWithObjects:
                                KEY_FOR_FASTBREAK, KEY_FOR_ISOLATION, KEY_FOR_OFF_SCREEN, KEY_FOR_DK, KEY_FOR_CUT, KEY_FOR_OTHERS, KEY_FOR_PNR, KEY_FOR_SECOND, KEY_FOR_PU, KEY_FOR_HP, KEY_FOR_TOTAL, nil];
    
    BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:xlsxFilePath];
    for(int i=0; i<playerNoSet.count+1; i++)
    {
        char outIndex = '\0';
        char interIndex = 'A';
        int rowIndex = 3;
        
        BRAWorksheet *worksheet = [self lookForWorkSheetWithPlayerIndex:i spreadSheet:spreadsheet playerNoArray:playerNoSet type:PPP];
        
        NSString* cellRef;
        NSString *cellContent;
        do
        {
            rowIndex++;
            cellRef = [NSString stringWithFormat:@"%c%c%d", outIndex, interIndex, rowIndex];
            cellContent = [[worksheet cellForCellReference:cellRef] stringValue];
        }while(cellContent && ![cellContent isEqualToString:@""]);
        
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:gameDate];
        
        cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:rowIndex];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:opponentName];
        
        NSArray* totalGradeArray = [playerDataArray objectAtIndex:0];
        NSDictionary* playerGradeDic = [totalGradeArray objectAtIndex:i];
        for(NSString* keyForAttackWay in attackWayKeySet)
        {
            NSArray* detailArray;
            if([keyForAttackWay isEqualToString:KEY_FOR_SECOND])
                detailArray = secondDetailItemKeyArray;
            else if([keyForAttackWay isEqualToString:KEY_FOR_PNR])
                detailArray = PNRDetailItemKeyArray;
            else if([keyForAttackWay isEqualToString:KEY_FOR_PU])
                detailArray = PUDetailItemKeyArray;
            else if([keyForAttackWay isEqualToString:KEY_FOR_HP])
                detailArray = hpShotModeKeyArray;
            else if([keyForAttackWay isEqualToString:KEY_FOR_TOTAL])
            {
                NSDictionary* turnoverDic = [playerGradeDic objectForKey:KEY_FOR_TURNOVER];
                for(NSString* keyForTurnoverDetail in turnOverArray)
                {
                    cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:rowIndex];
                    NSInteger count = [[turnoverDic objectForKey:keyForTurnoverDetail] integerValue];
                    [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:count];
                }
                detailArray = TotalDetailItemArray;
            }
            else
                detailArray = normalDetailItemKeyArray;
            
            NSDictionary* attackDic = [playerGradeDic objectForKey:keyForAttackWay];
            for(NSString* keyForDetail in detailArray)
            {
                NSDictionary* detailDic = [attackDic objectForKey:keyForDetail];
                
                cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:rowIndex];
                NSInteger madeCount = [[detailDic objectForKey:KEY_FOR_MADE_COUNT] integerValue];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:madeCount];
                
                cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:rowIndex];
                NSInteger attemptCount = [[detailDic objectForKey:KEY_FOR_ATTEMPT_COUNT] integerValue];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:attemptCount];
                
                cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:rowIndex];
                NSInteger foulCount = [[detailDic objectForKey:KEY_FOR_FOUL_COUNT] integerValue];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:foulCount];
                
                cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:rowIndex];
                NSInteger pts = [[detailDic objectForKey:KEY_FOR_SCORE_GET] integerValue];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:pts];
            }
            if(![keyForAttackWay isEqualToString:KEY_FOR_TOTAL])
            {
                cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:rowIndex];
                NSInteger toCount = [[attackDic objectForKey:KEY_FOR_TOTAL_TURNOVER_COUNT] integerValue];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:toCount];
                
                cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:rowIndex];
                NSInteger holdCount = [[attackDic objectForKey:KEY_FOR_HOLD_BALL_COUNT] integerValue];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:holdCount];
            }
            else
            {
                cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:rowIndex];
                NSInteger totalMadeCount = [[attackDic objectForKey:KEY_FOR_TOTAL_MADE_COUNT] integerValue];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:totalMadeCount];
                
                cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:rowIndex];
                NSInteger totalAttempCount = [[attackDic objectForKey:KEY_FOR_TOTAL_ATTEMPT_COUNT] integerValue];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:totalAttempCount];
                
                cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:rowIndex];
                NSInteger totalFoulCount = [[attackDic objectForKey:KEY_FOR_TOTAL_FOUL_COUNT] integerValue];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:totalFoulCount];
                
                cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:rowIndex];
                NSInteger totalPts = [[attackDic objectForKey:KEY_FOR_TOTAL_SCORE_GET] integerValue];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:totalPts];
                
                cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:rowIndex];
                NSInteger totalToCount = [[attackDic objectForKey:KEY_FOR_TOTAL_TURNOVER_COUNT] integerValue];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:totalToCount];
                
                cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:rowIndex];
                NSInteger totalHoldBallCount = [[attackDic objectForKey:KEY_FOR_HOLD_BALL_COUNT] integerValue];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:totalHoldBallCount];
            }
        }
    }
    
    //Save the xlsx to the app space in the device
    NSString *sheetPath = [NSString stringWithFormat:@"%@/Documents/%@.xlsx", NSHomeDirectory(), NAME_OF_THE_FINAL_XLSX_FILE];
    NSFileManager* fm = [[NSFileManager alloc] init];
    
    if([fm fileExistsAtPath:sheetPath])
        [fm removeItemAtPath:sheetPath error:nil];
    
    [spreadsheet saveAs:sheetPath];
    
    NSString* dropboxPath;
    if(![myTeamName isEqualToString:NAME_OF_NTU_MALE_BASKETBALL])
    {
        NSString* fileName = [self addXlsxVersionNumber:1 type:NAME_OF_THE_FINAL_XLSX_FILE recordName:recordName];
        dropboxPath = [NSString stringWithFormat:@"%@/%@",self.folderName, fileName];
    }
    else
        dropboxPath = [NSString stringWithFormat:@"%@.xlsx", NAME_OF_THE_FINAL_XLSX_FILE];
    
    NSArray* agus = [[NSArray alloc] initWithObjects:dropboxPath, sheetPath, nil];
    [self performSelectorOnMainThread:@selector(uploadXlsxFile:) withObject:agus waitUntilDone:0];
}

- (void)analyzePlusMinusXlsxFile:(BRAWorksheet*)worksheet
{
    
    int rowIndex = 2, rowI = 2;
    NSString* cellRef;
    NSInteger score = 1, time, endTime, plusVal;
    while(1)
    {
        cellRef = [NSString stringWithFormat:@"G%d", rowIndex];
        endTime = [[worksheet cellForCellReference:cellRef] integerValue];
        if(!endTime)
            break;
        int minusVal = 0;
        while(score)
        {
            cellRef = [NSString stringWithFormat:@"M%d", rowI];
            time = [[worksheet cellForCellReference:cellRef] integerValue];
            if(time > endTime)
                break;
            
            cellRef = [NSString stringWithFormat:@"N%d", rowI];
            score = [[worksheet cellForCellReference:cellRef] integerValue];
            minusVal += score;
            rowI++;
        }
        
        cellRef = [NSString stringWithFormat:@"I%d", rowIndex];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:minusVal];
        
        cellRef = [NSString stringWithFormat:@"H%d", rowIndex];
        plusVal = [[worksheet cellForCellReference:cellRef] integerValue];
        
        cellRef = [NSString stringWithFormat:@"J%d", rowIndex];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue: plusVal - minusVal];
        
        rowIndex++;
    }
}

- (NSString*) addXlsxVersionNumber:(int)no type:(NSString*)xlsxType recordName:(NSString*) recordName
{
    NSString* fileName;
    if(no == 1)
        fileName = [NSString stringWithFormat:@"%@_%@.xlsx", recordName, xlsxType];
    else
        fileName = [NSString stringWithFormat:@"%@_%@(%d).xlsx", recordName, xlsxType, no];
    
    for(NSString* fileNameInDropbox in self.fileNamesInDropbox)
    {
        if([fileName isEqualToString:fileNameInDropbox])
            return [self addXlsxVersionNumber:no+1 type:xlsxType recordName:recordName];
    }
    return fileName;
}

-(NSString*) addXlsxFileVersionNumber:(int)no recordName:(NSString*) recordName
{
    NSString* fileName;
    if(no == 1)
        fileName = [NSString stringWithFormat:@"%@.xlsx", recordName];
    else
        fileName = [NSString stringWithFormat:@"%@(%d).xlsx", recordName, no];
    for(NSString* fileNameInDropbox in self.fileNamesInDropbox)
    {
        if([fileName isEqualToString:fileNameInDropbox])
            return [self addXlsxFileVersionNumber:no+1 recordName:recordName];
    }
    return fileName;
}

-(BRAWorksheet*) lookForWorkSheetWithPlayerIndex:(int)index spreadSheet:(BRAOfficeDocumentPackage*)spreadSheet playerNoArray:(NSArray*)playerNoSet type:(enum XlsxType)xlsxType
{
    if(index == playerNoSet.count)
        return spreadSheet.workbook.worksheets[0];
    
    int i = 0;
    for(BRAWorksheet* worksheet in spreadSheet.workbook.worksheets)
    {
        if(!i++)
            continue;
        NSInteger playerNo = [[worksheet cellForCellReference:@"A1"] integerValue];
        if([playerNoSet[index] integerValue] == playerNo)
            return worksheet;
    }
    NSString* orgXlsxFilePath;
    if(xlsxType == PPP)
        orgXlsxFilePath = [[NSBundle mainBundle] pathForResource:NAME_OF_THE_FINAL_XLSX_FILE ofType:@"xlsx"];
    else
        orgXlsxFilePath = [[NSBundle mainBundle] pathForResource:NAME_OF_THE_SHOT_CHART_XLSX_FILE ofType:@"xlsx"];
    BRAOfficeDocumentPackage *orgSpreadsheet = [BRAOfficeDocumentPackage open:orgXlsxFilePath];
    BRAWorksheet* newWorkSheet = [spreadSheet.workbook createWorksheetNamed:playerNoSet[index] byCopyingWorksheet:orgSpreadsheet.workbook.worksheets[0]];
    [[newWorkSheet cellForCellReference:@"A1" shouldCreate:YES] setIntegerValue:[playerNoSet[index] integerValue]];
    return newWorkSheet;
}

-(NSString*) cellRefGoRightWithOutIndex:(char*)outIndex interIndex:(char*)interIndex rowIndex:(int)rowIndex
{
    (*interIndex)++;
    if(*interIndex == 91) // (int)'Z' == 90
    {
        if(*outIndex != '\0')
            (*outIndex)++;
        else
            *outIndex = 'A';
        *interIndex = 'A';
    }
    return [NSString stringWithFormat:@"%c%c%d", *outIndex, *interIndex, rowIndex];
}

#pragma mark - DBRestClientDelegate

-(void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
    if(self.loadMetaType == PPP_AND_SHOT_CHART)
    {
        self.isGradeXlsxFileExistInDropbox = NO;
        self.isShotChartXlsxFileExistInDropbox = NO;
        NSString* PPPxlsxFileName = [NSString stringWithFormat:@"%@.xlsx", NAME_OF_THE_FINAL_XLSX_FILE];
        NSString* zoneXlsxFileName = [NSString stringWithFormat:@"%@.xlsx", NAME_OF_THE_SHOT_CHART_XLSX_FILE];
        for (DBMetadata *file in metadata.contents)
        {
            if([file.filename isEqualToString:PPPxlsxFileName])
            {
                self.isGradeXlsxFileExistInDropbox = YES;
                NSString *sheetPath = [NSString stringWithFormat:@"%@/Documents/%@.xlsx", NSHomeDirectory(), NAME_OF_THE_FINAL_XLSX_FILE];
                self.isDownloadPPPXlsxFileFinished = NO;
                [self.restClient loadFile:file.path atRev:nil intoPath:sheetPath];
            }
            else if([file.filename isEqualToString:zoneXlsxFileName])
            {
                self.isShotChartXlsxFileExistInDropbox = YES;
                NSString* sheetPath = [NSString stringWithFormat:@"%@/Documents/%@.xlsx", NSHomeDirectory(), NAME_OF_THE_SHOT_CHART_XLSX_FILE];
                self.isDownloadShotChartXlsxFileFinished = NO;
                [self.restClient loadFile:file.path intoPath:sheetPath];
            }
            if(self.isGradeXlsxFileExistInDropbox && self.isShotChartXlsxFileExistInDropbox)
                break;
        }
        self.isLoadMetaFinished = YES;
    }
    else if(self.loadMetaType == FOLDER_EXIST)
    {
        for (DBMetadata *folder in metadata.contents)
        {
            if(folder.isDirectory && [folder.filename isEqualToString:self.folderName])
            {
                self.isFolderExistAlready = YES;
                break;
            }
        }
        if(!self.isFolderExistAlready)
            [self.restClient createFolder:[NSString stringWithFormat:@"/%@", self.folderName]];
        else
            self.isLoadMetaFinished = YES;
    }
    else
    {
        self.fileNamesInDropbox = [[NSMutableArray alloc] init];
        for (DBMetadata *file in metadata.contents)
            [self.fileNamesInDropbox addObject:file.filename];
        self.isLoadMetaFinished = YES;
    }
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
    NSLog(@"Error loading metadata: %@", error);
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata
{
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    self.uploadFilesCount++;
    if((self.isUploadingOffenseXlsx && self.uploadFilesCount == 6) ||
       (!self.isUploadingOffenseXlsx && self.uploadFilesCount == 1)   )
    {
        [self.spinView removeFromSuperview];
        [self.loadingLabel removeFromSuperview];
        [self.spinner removeFromSuperview];
        self.uploadFilesCount = 0;
    }
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error
{
    NSLog(@"File upload failed with error: %@", error);
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath
       contentType:(NSString *)contentType metadata:(DBMetadata *)metadata
{
    NSString* PPPName = [NSString stringWithFormat:@"%@.xlsx", NAME_OF_THE_FINAL_XLSX_FILE];
    NSString* shotchartName = [NSString stringWithFormat:@"%@.xlsx", NAME_OF_THE_SHOT_CHART_XLSX_FILE];
    if([metadata.filename isEqualToString:PPPName])
        self.isDownloadPPPXlsxFileFinished = YES;
    else if([metadata.filename isEqualToString:shotchartName])
        self.isDownloadShotChartXlsxFileFinished = YES;
    else
    {
        if(!self.isFstPlusMinusGenerateAndUploadFinished)
            self.isDownloadPlusMinusXlsxFileFinished = YES;
        else
            self.isDownloadSecPlusMinusXlsxFileFinished = YES;
    }
  //  NSLog(@"File loaded into path: %@", localPath);
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    NSLog(@"There was an error loading the file: %@", error);
}

- (void)restClient:(DBRestClient *)client deletedPath:(NSString *)path
{
    NSLog(@"FILE deleted in Path:%@", path);
    NSString* PPPPath = [NSString stringWithFormat:@"/%@.xlsx", NAME_OF_THE_FINAL_XLSX_FILE];
    NSString* shotCharPath = [NSString stringWithFormat:@"/%@.xlsx", NAME_OF_THE_SHOT_CHART_XLSX_FILE];
    
    if([path isEqualToString:PPPPath])
    {
        NSString *localPath = [NSString stringWithFormat:@"%@/Documents/%@.xlsx", NSHomeDirectory(), NAME_OF_THE_FINAL_XLSX_FILE];
        [self.restClient uploadFile:PPPPath toPath:@"/" withParentRev:nil fromPath:localPath];
    }
    else if([path isEqualToString:shotCharPath])
    {
        NSString *localPath = [NSString stringWithFormat:@"%@/Documents/%@.xlsx", NSHomeDirectory(), NAME_OF_THE_SHOT_CHART_XLSX_FILE];
        [self.restClient uploadFile:shotCharPath toPath:@"/" withParentRev:nil fromPath:localPath];
    }
    else
    {
        if(!self.isFstPlusMinusGenerateAndUploadFinished)
            self.isDeletePlusMinusXlsxFileFinished = YES;
        else
            self.isDeleteSecPlusMinusXlsxFileFinished = YES;
    }
}

-(void)restClient:(DBRestClient *)client deletePathFailedWithError:(NSError *)error
{
    NSLog(@"File deleted: %@", error);
}

-(void)restClient:(DBRestClient *)client createdFolder:(DBMetadata *)folder
{
    NSLog(@"Folder created: %@", folder.path);
    self.isLoadMetaFinished = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
