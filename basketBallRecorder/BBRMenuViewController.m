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
#import "BBRMacro.h"

#define KEY_FOR_ATTEMPT_COUNT @"attempCount"
#define KEY_FOR_MADE_COUNT @"madeCount"
#define KEY_FOR_FOUL_COUNT @"foulCount"
#define KEY_FOR_TURNOVER_COUNT @"turnoverCount"
#define KEY_FOR_SCORE_GET @"scoreGet"

#define KEY_FOR_TOTAL_MADE_COUNT @"totalMadeCount"
#define KEY_FOR_TOTAL_ATTEMPT_COUNT @"totalAttemptCount"
#define KEY_FOR_TOTAL_FOUL_COUNT @"totalFoulCount"
#define KEY_FOR_TOTAL_TURNOVER_COUNT @"totalTurnoverCount"
#define KEY_FOR_TOTAL_SCORE_GET @"totalScoreGet"

@interface BBRMenuViewController ()

@end

@implementation BBRMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self constructAlertController];
    
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
    
    for(int i=0; i<5; i++)
    {
        ((UIButton*)(self.buttonArray[i])).hidden = YES;
        ((UIButton*)(self.statusButtonArray[i])).hidden = YES;
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
    
    self.isGradeXlsxFileExistInDropbox = NO;
    self.isDownloadXlsxFileFinished = NO;
    self.isLoadMetaFinished = NO;
    self.loadMetaType = PPP_GRADE;
    [self.restClient loadMetadata:@"/" atRev:nil];
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
            NSString* gameName = [[recordPlistContent objectAtIndex:i] objectForKey:KEY_FOR_NAME];
            [((UIButton*)self.buttonArray[buttonIndex]) setTitle:gameName forState:UIControlStateNormal];
            ((UIButton*)self.buttonArray[buttonIndex]).hidden = NO;
            ((UIButton*)self.statusButtonArray[buttonIndex]).hidden = NO;
            [((UIButton*)self.statusButtonArray[buttonIndex]) setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [((UIButton*)self.statusButtonArray[buttonIndex]) setTitle:@"上傳" forState:UIControlStateNormal];
            ((UIButton*)self.statusButtonArray[buttonIndex]).userInteractionEnabled = YES;
            buttonIndex++;
        }
        for(int i=(int)[recordPlistContent count]; i<5; i++)
        {
            ((UIButton*)self.buttonArray[i]).hidden = YES;
            ((UIButton*)self.statusButtonArray[i]).hidden = YES;
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
                [self performSegueWithIdentifier:@"showOffenseController" sender:nil];
            else if([[tmpPlistDic objectForKey:KEY_FOR_DATA_TYPE] isEqualToString:DEFENSE_TYPE_DATA])
                [self performSegueWithIdentifier:@"showDefenseController" sender:nil];
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

- (IBAction)recordButtonClicked:(UIButton*)sender
{
    self.buttonClickedNo = (int)sender.tag;
    NSString* recordPlistPath = [NSString stringWithFormat:@"%@/Documents/record.plist", NSHomeDirectory()];
    NSArray* recordPlistArray = [NSArray arrayWithContentsOfFile:recordPlistPath];
    self.showOldRecordNo = (int)[recordPlistArray count] - self.buttonClickedNo;
    NSDictionary* dataDic = [recordPlistArray objectAtIndex:self.showOldRecordNo];
    if([[dataDic objectForKey:KEY_FOR_DATA_TYPE] isEqualToString:OFFENSE_TYPE_DATA])
        [self performSegueWithIdentifier:@"showOffenseController" sender:nil];
    else if([[dataDic objectForKey:KEY_FOR_DATA_TYPE] isEqualToString:DEFENSE_TYPE_DATA])
        [self performSegueWithIdentifier:@"showDefenseController" sender:nil];
        
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showOffenseController"])
    {
        BBROffenseViewController* mainViewCntler = [segue destinationViewController];
        mainViewCntler.isTmpPlistExist = self.isTmpPlistExist;
        mainViewCntler.showOldRecordNo = self.showOldRecordNo + 1;
        NSLog(@"%d", mainViewCntler.showOldRecordNo);
    }
    else if([segue.identifier isEqualToString:@"showDefenseController"])
    {
        BBRDefenseViewController* defenseViewCntler = [segue destinationViewController];
        defenseViewCntler.isTmpPlistExist = self.isTmpPlistExist;
        defenseViewCntler.showOldRecordNo = self.showOldRecordNo + 1;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)uploadButtonClicked:(UIButton*)sender
{
    [self.view addSubview:self.spinView];
    self.loadingLabel.text = @"Uploading";
    [self.view addSubview:self.loadingLabel];
    [self.view addSubview:self.spinner];
    self.isLoadMetaFinished = NO;
    self.loadMetaType = FILE_NAMES;
    [self.restClient loadMetadata:@"/"];
    NSThread *newThread = [[NSThread alloc] initWithTarget:self selector:@selector(xlsxFileGenerateAndUpload:) object:sender];

    [newThread start];
}

-(void) xlsxFileGenerateAndUpload:(UIButton*) sender
{
    NSString* recordPlistPath = [NSString stringWithFormat:@"%@/Documents/record.plist", NSHomeDirectory()];
    NSArray* recordPlistArray = [NSArray arrayWithContentsOfFile:recordPlistPath];
    
    int menuCount = (int)[recordPlistArray count];
    NSDictionary* dataDic = [recordPlistArray objectAtIndex:menuCount-(6-sender.tag)];
    
    [self generateGradeXlsx:dataDic];
    [self generateTimeLineXlsx:dataDic];
}

-(void) uploadXlsxFile:(NSArray*) parameters
{
    if([parameters[0] isEqualToString:[NSString stringWithFormat:@"%@.xlsx", NAME_OF_THE_FINAL_XLSX_FILE]] && self.isGradeXlsxFileExistInDropbox)
    {
        [self.restClient deletePath:[NSString stringWithFormat:@"/%@.xlsx", NAME_OF_THE_FINAL_XLSX_FILE]];
    }
    
    [self.restClient uploadFile:[parameters objectAtIndex:0] toPath:@"/" withParentRev:nil fromPath:[parameters objectAtIndex:1]];
}

-(void) generateTimeLineXlsx:(NSDictionary*)dataDic
{
    NSArray* timeLineRecordArray = [dataDic objectForKey:KEY_FOR_TIMELINE];
    NSString* opponentName = [dataDic objectForKey:KEY_FOR_OPPONENT_NAME];
    NSString* orgDocumentPath = [[NSBundle mainBundle] pathForResource:@"spreadsheet_for_timeLine" ofType:@"xlsx"];
    BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:orgDocumentPath];
    BRAWorksheet *worksheet = spreadsheet.workbook.worksheets[0];
    
    char outIndex = '\0';
    char interIndex = 'A';
    int rowIndex = 2;
    NSString* cellRef = [NSString stringWithFormat:@"%c%c%d", outIndex, interIndex, rowIndex];
    
    for(NSMutableDictionary* quarterDic in timeLineRecordArray)
    {
        NSString* playersOnFloorStr = [quarterDic objectForKey:KEY_FOR_PLAYER_ON_FLOOR];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:playersOnFloorStr];
        
        NSArray* timeLineRecordArray = [quarterDic objectForKey:KEY_FOR_TIME_LINE_DATA];
        
        int rowI = rowIndex+1;
        int holdBallCount = 0;
        char outI = outIndex;
        char interI = interIndex;
        for(NSDictionary* eventDic in timeLineRecordArray)
        {
            outI =  outIndex;
            interI = interIndex;
            if([[eventDic objectForKey:KEY_FOR_TYPE] isEqualToString:SIGNAL_FOR_NON_EXCHANGE])
            {
                cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:rowI];
                NSString* playerNoStr = [eventDic objectForKey:KEY_FOR_PLAYER_NO];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:playerNoStr];
                
                cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:rowI];
                NSString* attackWayStr = [eventDic objectForKey:KEY_FOR_ATTACK_WAY];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:attackWayStr];
                
                cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:rowI];
                NSString* detailStr = [eventDic objectForKey:KEY_FOR_DETAIL];
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
            else
            {
                NSString* result = [eventDic objectForKey:KEY_FOR_RESULT];
                cellRef = [NSString stringWithFormat:@"%c%c%d", outI, interI, rowI];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:result];
            }
            rowI++;
        }
        
        cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:rowI];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:@"持球數"];
        
        cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:rowI];
        NSString* holdBallCountStr = [NSString stringWithFormat:@"%d", holdBallCount];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:holdBallCountStr];
        
        for(int i=0; i<8; i++)
            cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:rowIndex];
    }
    
    //Save the xlsx to the app space in the device
    NSString *sheetPath = [NSString stringWithFormat:@"%@/Documents/spreadsheet_for_timeLine.xlsx", NSHomeDirectory()];
    NSFileManager* fm = [[NSFileManager alloc] init];
    
    if([fm fileExistsAtPath:sheetPath])
        [fm removeItemAtPath:sheetPath error:nil];
    
    [spreadsheet saveAs:sheetPath];
    
    while(!self.isLoadMetaFinished);
    NSString* filename = [self addTimeLineXlsxFileVersionNumber:1 OpponentName:opponentName];
    
    NSArray* agus = [[NSArray alloc] initWithObjects:filename, sheetPath, nil];
    [self performSelectorOnMainThread:@selector(uploadXlsxFile:) withObject:agus waitUntilDone:0];
}

-(void) generateGradeXlsx:(NSDictionary*)dataDic
{
    NSString* xlsxFilePath;
    if(self.isGradeXlsxFileExistInDropbox)
    {
        while (!self.isDownloadXlsxFileFinished);
        xlsxFilePath = [NSString stringWithFormat:@"%@/Documents/%@.xlsx", NSHomeDirectory(), NAME_OF_THE_FINAL_XLSX_FILE];
    }
    else
        xlsxFilePath = [[NSBundle mainBundle] pathForResource:NAME_OF_THE_FINAL_XLSX_FILE ofType:@"xlsx"];
    
    NSArray* playerNoSet = [dataDic objectForKey:KEY_FOR_PLAYER_NO_SET];
    NSString* opponentName = [dataDic objectForKey:KEY_FOR_OPPONENT_NAME];
    NSArray* playerDataArray =[dataDic objectForKey:KEY_FOR_GRADE];
    
    NSArray* normalDetailItemKeyArray = [NSArray arrayWithObjects:KEY_FOR_DRIVE, KEY_FOR_PULL_UP, KEY_FOR_SPOT_UP, nil];
    NSArray* secondDetailItemKeyArray = [NSArray arrayWithObjects:KEY_FOR_DRIVE, KEY_FOR_PULL_UP, KEY_FOR_SPOT_UP, KEY_FOR_PUT_BACK, nil];
    NSArray* PNRDetailItemKeyArray = [NSArray arrayWithObjects:KEY_FOR_BP, KEY_FOR_BD, KEY_FOR_MR, KEY_FOR_MPP, KEY_FOR_MPD, KEY_FOR_MPS, nil];
    NSArray* PUDetailItemKeyArray = [NSArray arrayWithObjects:KEY_FOR_DRIVE, KEY_FOR_PULL_UP, KEY_FOR_SPOT_UP, KEY_FOR_SF, KEY_FOR_SF, nil];
    NSArray* TotalDetailItemArray = [NSArray arrayWithObjects:KEY_FOR_DRIVE, KEY_FOR_SPOT_UP, KEY_FOR_PULL_UP, KEY_FOR_SF, KEY_FOR_LP, KEY_FOR_PUT_BACK, KEY_FOR_BD, KEY_FOR_BD, KEY_FOR_MPD, KEY_FOR_MR, KEY_FOR_MPS, KEY_FOR_MPP, nil];
    NSArray* turnOverArray = [NSArray arrayWithObjects:KEY_FOR_STOLEN, KEY_FOR_BAD_PASS, KEY_FOR_CHARGING, KEY_FOR_DROP, KEY_FOR_3_SENCOND, KEY_FOR_TRAVELING, KEY_FOR_TEAM, nil];
    NSArray* attackWayKeySet = [[NSArray alloc] initWithObjects:
                            KEY_FOR_FASTBREAK, KEY_FOR_ISOLATION, KEY_FOR_OFF_SCREEN, KEY_FOR_DK, KEY_FOR_CUT, KEY_FOR_OTHERS, KEY_FOR_PNR, KEY_FOR_SECOND, KEY_FOR_PU, KEY_FOR_TOTAL, nil];
    
    BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:xlsxFilePath];
    for(int i=0; i<playerNoSet.count+1; i++)
    {
        char outIndex = '\0';
        char interIndex = 'A';
        int rowIndex = 3;
        
        BRAWorksheet *worksheet = [self lookForWorkSheetWithPlayerIndex:i spreadSheet:spreadsheet platerNoArray:playerNoSet];
        NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY/MM/dd"];
        
        NSString* cellRef;
        NSString *cellContent;
        do
        {
            rowIndex++;
            cellRef = [NSString stringWithFormat:@"%c%c%d", outIndex, interIndex, rowIndex];
            cellContent = [[worksheet cellForCellReference:cellRef] stringValue];
        }while(cellContent && ![cellContent isEqualToString:@""]);
        
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:
         [dateFormatter stringFromDate:[NSDate date]]];
        
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
    
    NSString* filename = [NSString stringWithFormat:@"%@.xlsx", NAME_OF_THE_FINAL_XLSX_FILE];
    
    NSArray* agus = [[NSArray alloc] initWithObjects:filename, sheetPath, nil];
    [self performSelectorOnMainThread:@selector(uploadXlsxFile:) withObject:agus waitUntilDone:0];
}

-(NSString*) addTimeLineXlsxFileVersionNumber:(int)no OpponentName:(NSString*) opponentName
{
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString* fileName;
    if(no == 1)
        fileName = [NSString stringWithFormat:@"%@_%@.xlsx", opponentName, [dateFormatter stringFromDate:[NSDate date]]];
    else
        fileName = [NSString stringWithFormat:@"%@_%@(%d).xlsx", opponentName, [dateFormatter stringFromDate:[NSDate date]], no];
    
    for(NSString* fileNameInDropbox in self.fileNamesInDropbox)
    {
        if([fileName isEqualToString:fileNameInDropbox])
            return [self addTimeLineXlsxFileVersionNumber:no+1 OpponentName:opponentName];
    }
    return fileName;
}


-(BRAWorksheet*) lookForWorkSheetWithPlayerIndex:(int)index spreadSheet:(BRAOfficeDocumentPackage*)spreadSheet platerNoArray:(NSArray*)playerNoSet
{
    if(index == playerNoSet.count)
        return spreadSheet.workbook.worksheets[0];
    
    for(BRAWorksheet* worksheet in spreadSheet.workbook.worksheets)
    {
        NSInteger playerNo = [[worksheet cellForCellReference:@"A1"] integerValue];
        if([playerNoSet[index] integerValue] == playerNo)
            return worksheet;
    }
    NSString* orgXlsxFilePath = [[NSBundle mainBundle] pathForResource:NAME_OF_THE_FINAL_XLSX_FILE ofType:@"xlsx"];
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
    
    self.fileNamesInDropbox = [[NSMutableArray alloc] init];
    if(metadata.isDirectory)
    {
        if(self.loadMetaType == PPP_GRADE)
        {
            NSString* PPPxlsxFileName = [NSString stringWithFormat:@"%@.xlsx", NAME_OF_THE_FINAL_XLSX_FILE];
            for (DBMetadata *file in metadata.contents)
            {
                [self.fileNamesInDropbox addObject:file.filename];
                if([file.filename isEqualToString:PPPxlsxFileName])
                {
                    self.isGradeXlsxFileExistInDropbox = YES;
                    NSString *sheetPath = [NSString stringWithFormat:@"%@/Documents/%@.xlsx", NSHomeDirectory(), NAME_OF_THE_FINAL_XLSX_FILE];
                    self.isDownloadXlsxFileFinished = NO;
                    [self.restClient loadFile:file.path atRev:nil intoPath:sheetPath];
                }
            }
            [self updateButtons];
        }
        else
        {
            for (DBMetadata *file in metadata.contents)
                [self.fileNamesInDropbox addObject:file.filename];
        }
    }
    self.isLoadMetaFinished = YES;
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
    if(self.uploadFilesCount == 2)
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
    self.isDownloadXlsxFileFinished = YES;
    NSLog(@"File loaded into path: %@", localPath);
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    NSLog(@"There was an error loading the file: %@", error);
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
