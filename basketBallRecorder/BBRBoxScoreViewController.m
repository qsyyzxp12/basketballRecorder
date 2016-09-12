//
//  BBRBoxScoreViewController.m
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/9/11.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import "BBRBoxScoreViewController.h"
#import "BBRTableViewCell.h"
#import "BRAOfficeDocumentPackage.h"
#import "BBRMacro.h"

@interface BBRBoxScoreViewController ()

@end

@implementation BBRBoxScoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playerOnFloorDataArray = [NSMutableArray arrayWithCapacity:5];
    for(int i=0; i<5; i++)
    {
        NSMutableDictionary* dic = [[NSMutableDictionary  alloc] init];
        [dic setObject:[NSNumber numberWithInt:0] forKey:KEY_FOR_TIME_WHEN_GO_ON_FLOOR];
        [dic setObject:[NSNumber numberWithInt:i+1] forKey:KEY_FOR_INDEX_IN_PPP_TABLEVIEW];
        [self.playerOnFloorDataArray setObject:dic atIndexedSubscript:i];
    }
    
    self.tmpPlistPath = [NSString stringWithFormat:@"%@/Documents/tmp.plist", NSHomeDirectory()];
    self.isRecordMode = YES;
    self.isTimerRunning = NO;
    self.playerSelectedIndex = 0;
    self.buttonNo = 0;
    self.quarterNo = 1;
    self.timeCounter = 0;
    
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    
    self.itemWayKeySet = [[NSArray alloc] initWithObjects:KEY_FOR_2_PTS, KEY_FOR_3_PTS, KEY_FOR_FREE_THROW, KEY_FOR_OR, KEY_FOR_DR, KEY_FOR_ASSIST, KEY_FOR_STEAL, KEY_FOR_BLOCK, KEY_FOR_TO, KEY_FOR_FOUL, KEY_FOR_TOTAL_TIME_ON_FLOOR, nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.rightBarButtonItem.title = @"本節結束";
    self.navigationItem.rightBarButtonItem.target = self;
    self.navigationItem.rightBarButtonItem.action = @selector(nextQuarterButtonClicked);
    
    if(self.isTmpPlistExist)
        [self reloadPlayerGradeFromTmpPlist];
    else if(self.showOldRecordNo)
        [self reloadPlayerGradeFromRecordPlist];
    else
    {
        [self newPlayerGradeDataStruct];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] init];
        self.navigationItem.leftBarButtonItem.title = @"＜球員登入";
        self.navigationItem.leftBarButtonItem.target = self;
        self.navigationItem.leftBarButtonItem.action = @selector(backButtonClicked);
    }
    int tableViewHeight = TITLE_CELL_HEIGHT + CELL_HEIGHT * (self.playerCount+1) + BAR_HEIGHT;
    if (tableViewHeight + 20 > self.view.frame.size.height)
        tableViewHeight = self.view.frame.size.height - 20;
    
    self.playerListTableView = [[UITableView alloc] initWithFrame:CGRectMake(55, 10, CELL_WIDTH, tableViewHeight)];
    //    self.playerListTableView.backgroundColor = [UIColor redColor];
    self.playerListTableView.delegate = self;
    self.playerListTableView.dataSource = self;
    self.playerListTableView.tag = NO_TABLEVIEW_TAG;
    [self.view addSubview:self.playerListTableView];
    
    self.playerOnFloorListTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 10+BAR_HEIGHT, CELL_WIDTH, TITLE_CELL_HEIGHT + CELL_HEIGHT * MIN(self.playerCount, 5))];
    self.playerOnFloorListTableView.delegate = self;
    self.playerOnFloorListTableView.dataSource = self;
    self.playerOnFloorListTableView.tag = PLAYER_ON_FLOOR_TABLEVIEW_TAG;
    [self.view addSubview:self.playerOnFloorListTableView];
    
    [self drawPicture];
    [self constructAlertControllers];
    
    self.playerDataTableView = [[UITableView alloc] initWithFrame:self.defenseRecordeView.frame];
    self.playerDataTableView.tag = PLAYER_GRADE_TABLEVIEW_TAG;
    self.playerDataTableView.delegate = self;
    self.playerDataTableView.dataSource = self;
    self.playerDataTableView.hidden = YES;
    [self.view addSubview:self.playerDataTableView];
    
    if(self.quarterNo == END)
        [self showConclusionAndGernateXlsxFile:NO];
}

- (void) constructAlertControllers
{
    //Next Quarter Alert
    self.nextQuarterAlert = [UIAlertController alertControllerWithTitle:@"確定？"
                                                                message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action)
                                {
                                    [self goNextQuarter];
                                }];
    UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){}];
    
    [self.nextQuarterAlert addAction:yesAction];
    [self.nextQuarterAlert addAction:noAction];
    
    //Alert for determining if there is playoff or not
    self.playoffOrNotAlert = [UIAlertController alertControllerWithTitle:@"是否有延長賽？"
                                                                 message:nil preferredStyle:UIAlertControllerStyleAlert];
    yesAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                 {
                     [self goNextQuarter];
                 }];
    noAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                {
                    [self showConclusionAndGernateXlsxFile:YES];
                }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){}];
    
    [self.playoffOrNotAlert addAction:yesAction];
    [self.playoffOrNotAlert addAction:noAction];
    [self.playoffOrNotAlert addAction:cancelAction];
    
    self.finishOrNotAlert = [UIAlertController alertControllerWithTitle:@"確定？"
                                                                message:nil preferredStyle:UIAlertControllerStyleAlert];
    yesAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action)
                 {
                     [self showConclusionAndGernateXlsxFile:YES];
                 }];
    noAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){}];
    [self.finishOrNotAlert addAction:yesAction];
    [self.finishOrNotAlert addAction:noAction];
}

-(void) goNextQuarter
{
    self.quarterNo++;
    [self extendPlayerDataWithQuarter:self.quarterNo];
    
    NSMutableDictionary* tmpPlistDic = [NSMutableDictionary dictionaryWithContentsOfFile:self.tmpPlistPath];
    [tmpPlistDic setObject:[NSNumber numberWithInt:self.quarterNo] forKey:KEY_FOR_LAST_RECORD_QUARTER];
    
    [tmpPlistDic writeToFile:self.tmpPlistPath atomically:YES];
    
    [self updateNavigationTitle];
    if(self.quarterNo == 4)
        self.navigationItem.rightBarButtonItem.action = @selector(finishButtonClicked);
}

-(void) showConclusionAndGernateXlsxFile:(BOOL)generateXlsxFile
{
    self.isRecordMode = NO;
    
    self.playerDataTableView.hidden = NO;
    
    [self.undoButton removeFromSuperview];
    [self.timeButton removeFromSuperview];
    [self.switchModeButton removeFromSuperview];
    
    [self.playerOnFloorListTableView removeFromSuperview];
    [self.playerListTableView setFrame:CGRectMake(25, 10, self.playerListTableView.frame.size.width, self.playerListTableView.frame.size.height)];
    self.playerSelectedIndex = 0;
    
    for(int i=1; i<13; i++)
    {
        UIImageView* zone = (UIImageView*)[self.view viewWithTag:i];
        [zone setUserInteractionEnabled:NO];
    }
    
    //Update Record.plist
    if(!self.showOldRecordNo)
    {
        NSString* recordPlistPath = [NSString stringWithFormat:@"%@/Documents/record.plist", NSHomeDirectory()];
        NSMutableArray* recordPlistArray = [NSMutableArray arrayWithContentsOfFile:recordPlistPath];
        
        NSMutableDictionary* newItem = [[NSMutableDictionary alloc] init];
        [newItem setObject:[NSNumber numberWithInt:END] forKey:KEY_FOR_LAST_RECORD_QUARTER];
        [newItem setObject:self.playerDataArray forKey:KEY_FOR_GRADE];
        [newItem setObject:self.playerNoSet forKey:KEY_FOR_PLAYER_NO_SET];
        [newItem setObject:self.recordName forKey:KEY_FOR_NAME];
        [newItem setObject:BOX_RECORD_TYPE_DATA forKey:KEY_FOR_DATA_TYPE];
        
        if([recordPlistArray count] < 5)
            [recordPlistArray addObject:newItem];
        else
        {
            for(int i=0; i<4; i++)
                [recordPlistArray setObject:[recordPlistArray objectAtIndex:i+1] atIndexedSubscript:i];
            [recordPlistArray setObject:newItem atIndexedSubscript:4];
        }
        
        [recordPlistArray writeToFile:recordPlistPath atomically:YES];
        
        //Remove tmp.plist
        NSFileManager* fm = [[NSFileManager alloc] init];
        if([fm fileExistsAtPath:self.tmpPlistPath])
            [fm removeItemAtPath:self.tmpPlistPath error:nil];
    }
    if(generateXlsxFile)
    {
        self.isLoadMetaFinished = NO;
        [self.restClient loadMetadata:@"/"];
        
        [self.view addSubview:self.spinView];
        [self.view addSubview:self.spinner];
        [self.view addSubview:self.loadingLabel];
        
        [self performSelectorInBackground:@selector(xlsxFileGenerateAndUpload) withObject:[NSNumber numberWithInt:self.quarterNo]];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] init];
        self.navigationItem.leftBarButtonItem.title = @"＜選單";
        self.navigationItem.leftBarButtonItem.target = self;
        self.navigationItem.leftBarButtonItem.action = @selector(backMenuButtonClicked);
    }
    
    self.quarterNo = 0;
    
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.title = @"總成績";
    
    self.lastQuarterButton.hidden = NO;
    self.nextQuarterButton.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - File Operation

-(void) reloadPlayerGradeFromRecordPlist
{
    NSString* recordPlistPath = [NSString stringWithFormat:@"%@/Documents/record.plist", NSHomeDirectory()];
    NSArray* recordPlistArray = [NSArray arrayWithContentsOfFile:recordPlistPath];
    NSDictionary* dataDic = [recordPlistArray objectAtIndex:self.showOldRecordNo-1];
    self.playerDataArray = [dataDic objectForKey:KEY_FOR_GRADE];
    self.playerNoSet = [dataDic objectForKey:KEY_FOR_PLAYER_NO_SET];
    self.quarterNo = END;
    self.playerCount = (int)[self.playerNoSet count];
}

-(void) reloadPlayerGradeFromTmpPlist
{
    NSMutableDictionary* tmpPlistDic = [NSMutableDictionary dictionaryWithContentsOfFile:self.tmpPlistPath];
    self.playerDataArray = [tmpPlistDic objectForKey:KEY_FOR_GRADE];
    self.playerNoSet = [tmpPlistDic objectForKey:KEY_FOR_PLAYER_NO_SET];
    self.quarterNo = [[tmpPlistDic objectForKey:KEY_FOR_LAST_RECORD_QUARTER] intValue];
    self.recordName = [tmpPlistDic objectForKey:KEY_FOR_NAME];
    self.timeCounter = [(NSNumber*)[tmpPlistDic objectForKey:KEY_FOR_TIME] intValue];
    self.playerCount = (int)[self.playerNoSet count];
    
    [self updateNavigationTitle];
    if(self.quarterNo > 3)
        self.navigationItem.rightBarButtonItem.action = @selector(finishButtonClicked);
}

-(void)updateTmpPlist
{
    NSMutableDictionary* tmpPlistDic = [NSMutableDictionary dictionaryWithContentsOfFile:self.tmpPlistPath];
    [tmpPlistDic setObject:self.playerDataArray forKey:KEY_FOR_GRADE];
    
    [tmpPlistDic writeToFile:self.tmpPlistPath atomically:YES];
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

-(void) xlsxFileGenerateAndUpload
{
    //Generate the xlsx file
    NSString *documentPath = [[NSBundle mainBundle] pathForResource:@"spreadsheet_for_boxScore" ofType:@"xlsx"];
    BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:documentPath];
    BRAWorksheet *worksheet = spreadsheet.workbook.worksheets[0];

    NSString* cellRef;
    NSArray* totalGradeArray = [self.playerDataArray objectAtIndex:0];
    char outIndex = '\0';
    char interIndex = 'A';
    for(int i=0; i<self.playerCount+1; i++)
    {
        char outI = outIndex;
        char interI = interIndex;
        cellRef = [NSString stringWithFormat:@"%c%c%d", outI, interI, i+2];
        if(i < self.playerCount)
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:self.playerNoSet[i]];
        else
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:@"全隊"];
        
        NSDictionary* playerDataDic = [totalGradeArray objectAtIndex:i];
        
        cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:i+2];
        if(i != self.playerCount)
        {
            int time = [[playerDataDic objectForKey:KEY_FOR_TOTAL_TIME_ON_FLOOR] intValue];
            int min = time/60;
            int sec = time%60;
            NSString* timeStr = [NSString stringWithFormat:@"%02d:%02d", min, sec];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:timeStr];
        }
        else
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:@"-"];
        
        
        for(int j=0; j<3; j++)
        {
            NSDictionary* madeOrAttemptDic = [playerDataDic objectForKey:self.itemWayKeySet[j]];
            NSInteger madeCount = [[madeOrAttemptDic objectForKey:KEY_FOR_MADE_COUNT] integerValue];
            cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:i+2];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:madeCount];
            
            NSInteger attemptCount =[[madeOrAttemptDic objectForKey:KEY_FOR_ATTEMPT_COUNT] integerValue];
            cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:i+2];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:attemptCount];
            
            if(i == self.playerCount)
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
        NSInteger orCount = [[playerDataDic objectForKey:self.itemWayKeySet[3]] integerValue];
        cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:i+2];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:orCount];
        
        NSInteger drCount = [[playerDataDic objectForKey:self.itemWayKeySet[4]] integerValue];
        cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:i+2];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:drCount];
        
        NSInteger trCount = orCount + drCount;
        cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:i+2];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:trCount];

        for(int j=5; j<self.itemWayKeySet.count-1; j++)
        {
            NSInteger count = [[playerDataDic objectForKey:self.itemWayKeySet[j]] integerValue];
            cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:i+2];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:count];
        }
        
        NSInteger totalPts = [[playerDataDic objectForKey:KEY_FOR_TOTAL_SCORE_GET] integerValue];
        cellRef = [self cellRefGoRightWithOutIndex:&outI interIndex:&interI rowIndex:i+2];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setIntegerValue:totalPts];
        
    }
    
    outIndex = '\0';
    interIndex = 'R';
    for(int i=1; i<self.playerDataArray.count; i++)
    {
        cellRef = [self cellRefGoRightWithOutIndex:&outIndex interIndex:&interIndex rowIndex:1];
        NSString* title;
        if(i < 5)
            title = [NSString stringWithFormat:@"%dth", i];
        else
            title = [NSString stringWithFormat:@"OT%d", i-4];
        [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:title];
        
        cellRef = [NSString stringWithFormat:@"%c%c2", outIndex, interIndex];
        NSArray* totalGradeArray = [self.playerDataArray objectAtIndex:i];
        NSDictionary* dic = [totalGradeArray objectAtIndex:self.playerCount];
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
    NSString* filename = [self addXlsxFileVersionNumber:1];
    
    NSArray* agus = [[NSArray alloc] initWithObjects:filename, sheetPath, nil];
    [self performSelectorOnMainThread:@selector(uploadXlsxFile:) withObject:agus waitUntilDone:0];
    //  [self.restClient uploadFile:filename toPath:@"/" withParentRev:nil fromPath:sheetPath];
    
}

-(void) uploadXlsxFile:(NSArray*) parameters
{
    [self.restClient uploadFile:[parameters objectAtIndex:0] toPath:@"/" withParentRev:nil fromPath:[parameters objectAtIndex:1]];
}


-(NSString*) addXlsxFileVersionNumber:(int)no
{
    NSString* fileName;
    if(no == 1)
        fileName = [NSString stringWithFormat:@"%@.xlsx", self.recordName];
    else
        fileName = [NSString stringWithFormat:@"%@(%d).xlsx", self.recordName, no];
    for(NSString* fileNameInDropbox in self.fileNamesInDropbox)
    {
        if([fileName isEqualToString:fileNameInDropbox])
            return [self addXlsxFileVersionNumber:no+1];
    }
    return fileName;
}

#pragma mark - DataStruct Updating

-(void) updateGrade
{
    self.OldPlayerDataArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.playerDataArray]];
    // first for the quarter grade, the last is for the overall grade
    int quarterNo[2] = {self.quarterNo, QUARTER_NO_FOR_ENTIRE_GAME};
    int playerNo[2] = {self.playerSelectedIndex-1, self.playerCount};
    
    for(int i=0; i<2; i++)
    {
        NSMutableArray* quarterGrade = [self.playerDataArray objectAtIndex:quarterNo[i]];
        for(int j=0; j<2; j++)
        {
            NSMutableDictionary* gradeDic = [quarterGrade objectAtIndex:playerNo[j]];
            int tag = self.buttonNo - 20;
            if(tag < 6)
            {
                NSMutableDictionary* madeOrAttemptDic =[gradeDic objectForKey:self.itemWayKeySet[tag/2]];
                int attemptCount = [[madeOrAttemptDic objectForKey:KEY_FOR_ATTEMPT_COUNT] intValue] + 1;
                [madeOrAttemptDic setObject:[NSString stringWithFormat:@"%d", attemptCount] forKey:KEY_FOR_ATTEMPT_COUNT];
                if(tag%2)
                {
                    int madeCount = [[madeOrAttemptDic objectForKey:KEY_FOR_MADE_COUNT] intValue]+1;
                    [madeOrAttemptDic setObject:[NSString stringWithFormat:@"%d", madeCount] forKey:KEY_FOR_MADE_COUNT];
                    int totalPts = [[gradeDic objectForKey:KEY_FOR_TOTAL_SCORE_GET] intValue];
                    totalPts += (((tag/2)+1)%3)+1;
                    [gradeDic setObject:[NSString stringWithFormat:@"%d", totalPts] forKey:KEY_FOR_TOTAL_SCORE_GET];
                }
            }
            else
            {
                int val = [[gradeDic objectForKey:self.itemWayKeySet[tag-3]] intValue] + 1;
                [gradeDic setObject:[NSString stringWithFormat:@"%d", val] forKey:self.itemWayKeySet[tag-3]];
            }
        }
    }
    [self updateTmpPlist];
}

-(void)updateTimeOnFloorOfPlayerWithIndexInOnFloorTableView:(int)index
{
    NSMutableDictionary* dic = [self.playerOnFloorDataArray objectAtIndex:index];
    NSNumber* indexInPPPTableviewNo = [dic objectForKey:KEY_FOR_INDEX_IN_PPP_TABLEVIEW];
    NSNumber* timeWhenWentOnFloor = [dic objectForKey:KEY_FOR_TIME_WHEN_GO_ON_FLOOR];
    int timeOnFloor = self.timeCounter - timeWhenWentOnFloor.intValue;
    
    NSMutableArray* quarterGrade = [self.playerDataArray objectAtIndex:self.quarterNo];
    NSMutableDictionary* playerData = [quarterGrade objectAtIndex:indexInPPPTableviewNo.intValue - 1];
    int time = timeOnFloor + ((NSNumber*)[playerData objectForKey:KEY_FOR_TOTAL_TIME_ON_FLOOR]).intValue;
    [playerData setObject:[NSNumber numberWithInt:time] forKey:KEY_FOR_TOTAL_TIME_ON_FLOOR];
    
    NSMutableArray* playerAllGameGrade = [self.playerDataArray objectAtIndex:0];
    playerData = [playerAllGameGrade objectAtIndex:indexInPPPTableviewNo.intValue-1];
    time = timeOnFloor + ((NSNumber*)[playerData objectForKey:KEY_FOR_TOTAL_TIME_ON_FLOOR]).intValue;
    
    [playerData setObject:[NSNumber numberWithInt:time] forKey:KEY_FOR_TOTAL_TIME_ON_FLOOR];
    [self updateTmpPlist];
}

-(void) newPlayerGradeDataStruct
{
    self.playerDataArray = [NSMutableArray arrayWithCapacity:2];
    
    [self extendPlayerDataWithQuarter:0];
    [self extendPlayerDataWithQuarter:1];
    
    NSString* src = [[NSBundle mainBundle] pathForResource:@"tmp" ofType:@"plist"];
    NSFileManager* fm = [[NSFileManager alloc] init];
    
    if(![fm fileExistsAtPath:self.tmpPlistPath])
        [fm copyItemAtPath:src toPath:self.tmpPlistPath error:nil];
    
    NSMutableDictionary* tmpPlistDic = [NSMutableDictionary dictionaryWithContentsOfFile:self.tmpPlistPath];
    
    [tmpPlistDic setObject:[NSNumber numberWithInt:1] forKey:KEY_FOR_LAST_RECORD_QUARTER];
    [tmpPlistDic setObject:self.playerDataArray forKey:KEY_FOR_GRADE];
    [tmpPlistDic setObject:self.playerNoSet forKey:KEY_FOR_PLAYER_NO_SET];
    [tmpPlistDic setObject:self.recordName forKey:KEY_FOR_NAME];
    [tmpPlistDic setObject:[NSNumber numberWithInt:0] forKey:KEY_FOR_TIME];
    [tmpPlistDic setObject:BOX_RECORD_TYPE_DATA forKey:KEY_FOR_DATA_TYPE];
    
    [tmpPlistDic writeToFile:self.tmpPlistPath atomically:YES];
    
    self.navigationItem.title = @"第一節";
}

-(void) extendPlayerDataWithQuarter:(int) quarterNo
{
    NSMutableArray* quarterData = [NSMutableArray arrayWithCapacity:self.playerCount+1];
    for(int i=0; i<self.playerCount+1; i++)
    {
        NSMutableDictionary* playerDataItem = [[NSMutableDictionary alloc] init];
        
        if(i < [self.playerNoSet count])
            [playerDataItem setObject:[self.playerNoSet objectAtIndex:i] forKey:@"no"];
        else
            [playerDataItem setObject:@"Team" forKey:@"no"];
        
        [playerDataItem setObject:[NSString stringWithFormat:@"%d", quarterNo] forKey:@"QUARTER"];
        
        for(int j=0; j<3; j++)
        {
            NSMutableDictionary* madeOrAttemptDic = [[NSMutableDictionary alloc] init];
            [madeOrAttemptDic setObject:@"0" forKey:KEY_FOR_MADE_COUNT];
            [madeOrAttemptDic setObject:@"0" forKey:KEY_FOR_ATTEMPT_COUNT];
            [playerDataItem setObject:madeOrAttemptDic forKey:self.itemWayKeySet[j]];
        }
        for(int j=3; j<self.itemWayKeySet.count; j++)
            [playerDataItem setObject:@"0" forKey:self.itemWayKeySet[j]];
        
        [playerDataItem setObject:@"0" forKey:KEY_FOR_TOTAL_SCORE_GET];
        [quarterData addObject:playerDataItem];
    }
    [self.playerDataArray addObject:quarterData];
    [self updateTmpPlist];
}


#pragma mark - UI Updating

-(void) removeSpinningView
{
    [self.spinView removeFromSuperview];
    [self.loadingLabel removeFromSuperview];
    [self.spinner removeFromSuperview];
}

-(void)timeCounterChange
{
    self.timeCounter++;
    int min = self.timeCounter/60;
    int sec = self.timeCounter%60;
    [self.timeButton setTitle:[NSString stringWithFormat:@"%02d:%02d", min, sec] forState:UIControlStateNormal];
    
    if(self.timeCounter%3 == 0)
    {
        NSMutableDictionary* tmpPlistDic = [NSMutableDictionary dictionaryWithContentsOfFile:self.tmpPlistPath];
        [tmpPlistDic setObject:[NSNumber numberWithInt:self.timeCounter] forKey:KEY_FOR_TIME];
        [tmpPlistDic writeToFile:self.tmpPlistPath atomically:YES];
    }
}

-(void)updateGradeView
{
    switch(self.quarterNo)
    {
        case 0:
            self.navigationItem.title = @"總成績";
            break;
        case 1:
            self.navigationItem.title = @"第一節成績";
            break;
        case 2:
            self.navigationItem.title = @"第二節成績";
            break;
        case 3:
            self.navigationItem.title = @"第三節成績";
            break;
        case 4:
            self.navigationItem.title = @"第四節成績";
            break;
        case 5:
            self.navigationItem.title = @"延長賽第一節成績";
            break;
        case 6:
            self.navigationItem.title = @"延長賽第二節成績";
            break;
        case 7:
            self.navigationItem.title = @"延長賽第三節成績";
            break;
        case 8:
            self.navigationItem.title = @"延長賽第四節成績";
            break;
        case 9:
            self.navigationItem.title = @"延長賽第五節成績";
            break;
        case 10:
            self.navigationItem.title = @"延長賽第六節成績";
            break;
    }
    
    [(UITableView*)[self.view viewWithTag:PLAYER_GRADE_TABLEVIEW_TAG] reloadData];
}

-(void) updateNavigationTitle
{
    switch(self.quarterNo)
    {
        case 1:
            self.navigationItem.title = @"第一節";
            break;
        case 2:
            self.navigationItem.title = @"第二節";
            break;
        case 3:
            self.navigationItem.title = @"第三節";
            break;
        case 4:
            self.navigationItem.title = @"第四節";
            break;
        case 5:
            self.navigationItem.title = @"延長賽第一節";
            break;
        case 6:
            self.navigationItem.title = @"延長賽第二節";
            break;
        case 7:
            self.navigationItem.title = @"延長賽第三節";
            break;
        case 8:
            self.navigationItem.title = @"延長賽第四節";
            break;
        case 9:
            self.navigationItem.title = @"延長賽第五節";
            break;
        case 10:
            self.navigationItem.title = @"延長賽第六節";
            break;
    }
}

- (void) drawPicture
{
    CGFloat x = (self.view.frame.size.width- CGRectGetMaxX(self.playerListTableView.frame) - BACKGROUND_WIDTH)/5 + CGRectGetMaxX(self.playerListTableView.frame);
    CGFloat y = (self.view.frame.size.height - BAR_HEIGHT - BACKGROUND_HEIGHT)/2 + BAR_HEIGHT;
    
    self.defenseRecordeView = [[UIView alloc] initWithFrame:CGRectMake(x, y, BACKGROUND_WIDTH, BACKGROUND_HEIGHT)];
    self.defenseRecordeView.backgroundColor = [UIColor whiteColor];
    
    NSArray* titleArray = [NSArray arrayWithObjects:@"2PTS", @"3PTS", @"Free Throw", nil];

    int tag = 20;
    for(int i=0; i<titleArray.count; i++)
    {
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, i*70, 100, 25)];
        titleLabel.text = titleArray[i];
        [self.defenseRecordeView addSubview:titleLabel];
        
        UIButton* attemptButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(titleLabel.frame), CGRectGetMaxY(titleLabel.frame), 60, 40)];
        [attemptButton setTitle:@"Attempt" forState:UIControlStateNormal];
        [attemptButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        attemptButton.tag = tag++;
        attemptButton.layer.borderWidth = 1;
        attemptButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        attemptButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [attemptButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [attemptButton setShowsTouchWhenHighlighted:YES];
        [self.defenseRecordeView addSubview:attemptButton];
        
        UIButton* madeButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(attemptButton.frame), CGRectGetMinY(attemptButton.frame), 60, 40)];
        [madeButton setTitle:@"Made" forState:UIControlStateNormal];
        [madeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        madeButton.tag = tag++;
        madeButton.layer.borderWidth = 1;
        madeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        madeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [madeButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [madeButton setShowsTouchWhenHighlighted:YES];
        [self.defenseRecordeView addSubview:madeButton];
    }
   
    UIButton* orButton = [[UIButton alloc] initWithFrame:CGRectMake(180, 25, 60, 40)];
    [orButton setTitle:@"OR" forState:UIControlStateNormal];
    [orButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    orButton.tag = tag++;
    orButton.layer.borderWidth = 1;
    orButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    orButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [orButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [orButton setShowsTouchWhenHighlighted:YES];
    [self.defenseRecordeView addSubview:orButton];
    
    UIButton* drButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(orButton.frame), CGRectGetMinY(orButton.frame), 60, 40)];
    [drButton setTitle:@"DR" forState:UIControlStateNormal];
    [drButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    drButton.tag = tag++;
    drButton.layer.borderWidth = 1;
    drButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    drButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [drButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [drButton setShowsTouchWhenHighlighted:YES];
    [self.defenseRecordeView addSubview:drButton];
    
    NSArray* othersArray = [NSArray arrayWithObjects:@"Assist", @"Steal", @"Block", @"TO", @"Foul", nil];
    
    for(int i=0; i<5; i++)
    {
        CGFloat x, y;
        if(i < 2)
        {
            x = CGRectGetMinX(orButton.frame) + i*60;
            y = CGRectGetMaxY(orButton.frame) + 30;
        }
        else
        {
            x = CGRectGetMinX(orButton.frame) + (i-2)*60;
            y = CGRectGetMaxY(orButton.frame) + 70;
        }
        UIButton* Button = [[UIButton alloc] initWithFrame:CGRectMake(x, y, 60, 40)];
        [Button setTitle:othersArray[i] forState:UIControlStateNormal];
        [Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        Button.tag = tag++;
        Button.layer.borderWidth = 1;
        Button.titleLabel.textAlignment = NSTextAlignmentCenter;
        Button.titleLabel.adjustsFontSizeToFitWidth = YES;
        [Button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [Button setShowsTouchWhenHighlighted:YES];
        [self.defenseRecordeView addSubview:Button];
    }
    
    [self.view addSubview:self.defenseRecordeView];
    
    //Show Grade Switch Button
    self.switchModeButton = [[UIButton alloc] init];
    [self.switchModeButton setFrame:CGRectMake(CGRectGetMaxX(self.defenseRecordeView.frame)+5, CGRectGetMinY(self.defenseRecordeView.frame), 60, RECORD_LABEL_HEIGHT)];
    self.switchModeButton.layer.borderWidth = 1;
    self.switchModeButton.layer.cornerRadius = 5;
    self.switchModeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.switchModeButton setTitle:@"成績" forState:UIControlStateNormal];
    [self.switchModeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.switchModeButton addTarget:self action:@selector(switchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.switchModeButton setShowsTouchWhenHighlighted:YES];
    [self.view addSubview:self.switchModeButton];
    
    //Undo Button
    self.undoButton = [[UIButton alloc] init];
    [self.undoButton setFrame:CGRectMake(CGRectGetMinX(self.switchModeButton.frame), CGRectGetMaxY(self.switchModeButton.frame)+15, 60, RECORD_LABEL_HEIGHT)];
    self.undoButton.layer.borderWidth = 1;
    self.undoButton.layer.cornerRadius = 5;
    [self.undoButton setTitle:@"Undo" forState:UIControlStateNormal];
    [self.undoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.undoButton addTarget:self action:@selector(undoButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.undoButton setShowsTouchWhenHighlighted:YES];
    [self.view addSubview:self.undoButton];
    
    //Timer Button
    self.timeButton = [[UIButton alloc] init];
    [self.timeButton setFrame:CGRectMake(CGRectGetMinX(self.switchModeButton.frame), CGRectGetMaxY(self.undoButton.frame)+15, 60, RECORD_LABEL_HEIGHT)];
    if(self.timeCounter)
    {
        int min = self.timeCounter/60;
        int sec = self.timeCounter%60;
        [self.timeButton setTitle:[NSString stringWithFormat:@"%02d:%02d", min, sec] forState:UIControlStateNormal];
    }
    else
        [self.timeButton setTitle:@"00:00" forState:UIControlStateNormal];
    [self.timeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.timeButton addTarget:self action:@selector(timeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.timeButton];
    
    //Add Two Arrow for Quarter change
    self.lastQuarterButton = [[UIButton alloc] init];
    [self.lastQuarterButton setImage:[UIImage imageNamed:@"leftArrow.png"] forState:UIControlStateNormal];
    [self.lastQuarterButton sizeToFit];
    self.lastQuarterButton.frame = CGRectMake(self.defenseRecordeView.frame.origin.x-self.lastQuarterButton.frame.size.width*0.25-5, self.defenseRecordeView.frame.origin.y+40, self.lastQuarterButton.frame.size.width*0.25, self.lastQuarterButton.frame.size.height*0.25);
    [self.lastQuarterButton addTarget:self action:@selector(gradeOfLastQuarterButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.lastQuarterButton.hidden = YES;
    [self.view addSubview:self.lastQuarterButton];
    
    self.nextQuarterButton = [[UIButton alloc] init];
    [self.nextQuarterButton setImage:[UIImage imageNamed:@"rightArrow.png"] forState:UIControlStateNormal];
    [self.nextQuarterButton sizeToFit];
    self.nextQuarterButton.frame = CGRectMake(CGRectGetMaxX(self.defenseRecordeView.frame)+5, self.defenseRecordeView.frame.origin.y+40, self.nextQuarterButton.frame.size.width*0.25, self.nextQuarterButton.frame.size.height*0.25);
    [self.nextQuarterButton addTarget:self action:@selector(gradeOfNextQuaterButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.nextQuarterButton.hidden = YES;
    [self.view addSubview:self.nextQuarterButton];
    
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
}

#pragma mark - Button Clicked

-(void) buttonClicked:(UIButton*) button
{
    if(self.playerSelectedIndex)
    {
        self.buttonNo = (int)button.tag;
        [self updateGrade];
        self.buttonNo = 0;
        return;
    }
    
    if(self.buttonNo == button.tag)
    {
        button.backgroundColor = [UIColor whiteColor];
        self.buttonNo = 0;
    }
    else if(!self.buttonNo)
    {
        button.backgroundColor = [UIColor blueColor];
        self.buttonNo = (int)button.tag;
    }
    else
    {
        ((UIButton*)[self.view viewWithTag:self.buttonNo]).backgroundColor = [UIColor whiteColor];
        button.backgroundColor = [UIColor blueColor];
        self.buttonNo = (int)button.tag;
    }
}

-(void) timeButtonClicked
{
    if(!self.isTimerRunning)
    {
        [self.timeButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCounterChange) userInfo:nil repeats:YES];
        self.isTimerRunning = YES;
    }
    else
    {
        [self.timeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.timer invalidate];
        self.timer = nil;
        self.isTimerRunning = NO;
        for(int i=0; i<5; i++)
        {
            [self updateTimeOnFloorOfPlayerWithIndexInOnFloorTableView:i];
            NSMutableDictionary* dic = [self.playerOnFloorDataArray objectAtIndex:i];
            [dic setObject:[NSNumber numberWithInt:self.timeCounter] forKey:KEY_FOR_TIME_WHEN_GO_ON_FLOOR];
        }
        
    }
}

-(void)backMenuButtonClicked
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)backButtonClicked
{
    UIAlertController* backAlert = [UIAlertController alertControllerWithTitle:@"注意" message:@"返回後目前紀錄的資料都將消失，確定要返回嗎？" preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action)
                                {
                                    [self.navigationController popViewControllerAnimated:YES];
                                }];
    UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){}];
    [backAlert addAction:yesAction];
    [backAlert addAction:noAction];
    
    NSFileManager* fm = [[NSFileManager alloc] init];
    if([fm fileExistsAtPath:self.tmpPlistPath])
        [fm removeItemAtPath:self.tmpPlistPath error:nil];
    
    [self presentViewController:backAlert animated:YES completion:nil];
}

- (void) nextQuarterButtonClicked
{
    [self presentViewController:self.nextQuarterAlert animated:YES completion:nil];
}

- (void) finishButtonClicked
{
    if(self.quarterNo != 10)
        [self presentViewController:self.playoffOrNotAlert animated:YES completion:nil];
    else
        [self presentViewController:self.finishOrNotAlert animated:YES completion:nil];
}

- (void) gradeOfNextQuaterButtonClicked
{
    if (self.quarterNo < [self.playerDataArray count]-1)
    {
        self.quarterNo++;
        [self updateGradeView];
    }
}

- (void) gradeOfLastQuarterButtonClicked
{
    if(self.quarterNo > 0)
    {
        self.quarterNo--;
        [self updateGradeView];
    }
}

- (void) switchButtonClicked
{
    [self.playerListTableView deselectRowAtIndexPath:self.playerListTableView.indexPathForSelectedRow animated:NO];
    self.playerSelectedIndex = 0;
    if (self.isRecordMode)
    {
        [self.playerOnFloorListTableView removeFromSuperview];
        [self.playerListTableView setFrame:CGRectMake(25, 10, self.playerListTableView.frame.size.width, self.playerListTableView.frame.size.height)];
        for(int i=1; i<13; i++)
        {
            UIImageView* zone = (UIImageView*)[self.view viewWithTag:i];
            [zone setUserInteractionEnabled:NO];
        }
        
        [self.switchModeButton setTitle:@"紀錄" forState:UIControlStateNormal];
        [self.playerDataTableView reloadData];
        self.nextQuarterButton.hidden = NO;
        self.lastQuarterButton.hidden = NO;
        self.timeButton.hidden = YES;
        self.undoButton.hidden = YES;
        self.isRecordMode = NO;
        
        self.rightBarButton = self.navigationItem.rightBarButtonItem;
        self.navigationItem.rightBarButtonItem = nil;
        
        [self.playerOnFloorListTableView deselectRowAtIndexPath:self.playerOnFloorListTableView.indexPathForSelectedRow animated:NO];
        [self updateGradeView];
        self.playerDataTableView.hidden = NO;
    }
    else
    {
        [self.view addSubview:self.playerOnFloorListTableView];
        [self.playerListTableView setFrame:CGRectMake(55, 10, self.playerListTableView.frame.size.width, self.playerListTableView.frame.size.height)];
        for(int i=1; i<13; i++)
        {
            UIImageView* zone = (UIImageView*)[self.view viewWithTag:i];
            [zone setUserInteractionEnabled:YES];
        }
        
        self.quarterNo = (int)[self.playerDataArray count]-1;
        [self.switchModeButton setTitle:@"成績" forState:UIControlStateNormal];
        self.playerDataTableView.hidden = YES;
        self.nextQuarterButton.hidden = YES;
        self.lastQuarterButton.hidden = YES;
        self.timeButton.hidden = NO;
        self.undoButton.hidden = NO;
        self.isRecordMode = YES;
        [self updateNavigationTitle];
        self.navigationItem.rightBarButtonItem = self.rightBarButton;
        
        //[self.view viewWithTag:PLAYER_GRADE_TABLEVIEW_TAG].hidden = YES;
    }
}

- (void) undoButtonClicked
{
    if(self.OldPlayerDataArray)
    {
        self.playerDataArray = self.OldPlayerDataArray;
        [self updateTmpPlist];
    }
}

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == NO_TABLEVIEW_TAG)
        return (self.playerCount + 2); //One for title, the other one for team grade
    else if(tableView.tag == PLAYER_ON_FLOOR_TABLEVIEW_TAG)
        return MIN(self.playerCount, 5)+1;
    return [self.itemWayKeySet count] + 2;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == NO_TABLEVIEW_TAG)
    {
        if(indexPath.row == 0)
        {
            BBRTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"title"];
            if(!cell)
            {
                cell = [[BBRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"title"];
                cell.layer.borderWidth = 1;
                cell.NoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH, TITLE_CELL_HEIGHT)];
                cell.NoLabel.textAlignment = NSTextAlignmentCenter;
                cell.NoLabel.backgroundColor = [UIColor lightGrayColor];
                cell.NoLabel.text = @"PPP";
                [cell addSubview:cell.NoLabel];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
        }
        else if(indexPath.row == self.playerCount+1)
        {
            BBRTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Team"];
            if(!cell)
            {
                cell = [[BBRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Team"];
                cell.layer.borderWidth = 1;
                cell.NoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH, CELL_HEIGHT)];
                cell.NoLabel.textAlignment = NSTextAlignmentCenter;
                cell.NoLabel.text = @"全隊";
                [cell addSubview:cell.NoLabel];
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }
            return cell;
        }
        
        BBRTableViewCell* cell = [[BBRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.layer.borderWidth = 1;
        cell.NoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH, CELL_HEIGHT)];
        cell.NoLabel.textAlignment = NSTextAlignmentCenter;
        cell.NoLabel.text = [NSString stringWithFormat:@"%@", [self.playerNoSet objectAtIndex:indexPath.row-1]];
        [cell addSubview:cell.NoLabel];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        return cell;
    }
    else if(tableView.tag == PLAYER_ON_FLOOR_TABLEVIEW_TAG)
    {
        if(indexPath.row == 0)
        {
            BBRTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"title"];
            if(!cell)
            {
                cell = [[BBRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"title"];
                cell.layer.borderWidth = 1;
                UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH, TITLE_CELL_HEIGHT)];
                label.textAlignment = NSTextAlignmentCenter;
                label.backgroundColor = [UIColor lightGrayColor];
                label.text = @"場上";
                [cell addSubview:label];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
        }
        
        BBRTableViewCell* cell = [[BBRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.layer.borderWidth = 1;
        cell.NoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH, CELL_HEIGHT)];
        cell.NoLabel.textAlignment = NSTextAlignmentCenter;
        cell.NoLabel.text = [NSString stringWithFormat:@"%@", [self.playerNoSet objectAtIndex:indexPath.row-1]];
        [cell addSubview:cell.NoLabel];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        return cell;
    }
    //if(tableview.tag == PLAYER_GRADE_TABLEVIEW_TAG)
    
    NSDictionary* playerData;
    if(self.playerSelectedIndex)
    {
        NSMutableArray* quarterData = [self.playerDataArray objectAtIndex:self.quarterNo];
        playerData = [quarterData objectAtIndex:self.playerSelectedIndex-1];
        
    }
    
    BBRTableViewCell* cell = [[BBRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.layer.borderWidth = 1;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width*0.3, PLAYER_GRADE_TABLECELL_HEIGHT)];
    label.textAlignment = NSTextAlignmentCenter;
    
    
    UILabel* gradeValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame), label.frame.origin.y, tableView.frame.size.width*0.7, PLAYER_GRADE_TABLECELL_HEIGHT)];
    gradeValueLabel.textAlignment = NSTextAlignmentCenter;
    gradeValueLabel.layer.borderWidth = 1;
    
    if(!indexPath.row)
    {
        label.text = @"成績";
        [label setFrame:CGRectMake(0, 0, tableView.frame.size.width, PLAYER_GRADE_TABLECELL_HEIGHT)];
    }
    else if(indexPath.row < 4)
    {
        label.text = self.itemWayKeySet[indexPath.row-1];
        NSDictionary* madeOrAttemptDic = [playerData objectForKey:self.itemWayKeySet[indexPath.row-1]];
        
        NSString* madeCount = [madeOrAttemptDic objectForKey:KEY_FOR_MADE_COUNT];
        NSString* attemptCount = [madeOrAttemptDic objectForKey:KEY_FOR_ATTEMPT_COUNT];
        if(self.playerSelectedIndex)
            gradeValueLabel.text = [NSString stringWithFormat:@"%@/%@", madeCount, attemptCount];
        else
            gradeValueLabel.text = @"0/0";
        [cell addSubview:gradeValueLabel];
    }
    else if(indexPath.row < self.itemWayKeySet.count)
    {
        label.text = self.itemWayKeySet[indexPath.row-1];
        
        if(self.playerSelectedIndex)
            gradeValueLabel.text = [playerData objectForKey:self.itemWayKeySet[indexPath.row-1]];
        else
            gradeValueLabel.text = @"0";
        [cell addSubview:gradeValueLabel];
    }
    else if(indexPath.row == self.itemWayKeySet.count)
    {
        label.text = @"Time";
        if(self.playerSelectedIndex)
        {
            if(self.playerSelectedIndex != self.playerCount+1)
            {
                int time = [[playerData objectForKey:KEY_FOR_TOTAL_TIME_ON_FLOOR] intValue];
                int min = time/60;
                int sec = time%60;
                gradeValueLabel.text = [NSString stringWithFormat:@"%02d:%02d", min, sec];
            }
            else
                gradeValueLabel.text = @"-";
        }
        else
            gradeValueLabel.text = @"00:00";
        [cell addSubview:gradeValueLabel];
    }
    else if(indexPath.row == self.itemWayKeySet.count+1)
    {
        label.text = @"總得分";
        if(self.playerSelectedIndex)
            gradeValueLabel.text = [playerData objectForKey:KEY_FOR_TOTAL_SCORE_GET];
        else
            gradeValueLabel.text = @"0";
        [cell addSubview:gradeValueLabel];
    }
    [cell addSubview:label];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == PLAYER_ON_FLOOR_TABLEVIEW_TAG)
    {
        if(indexPath.row)
        {
            NSMutableDictionary* dic = [self.playerOnFloorDataArray objectAtIndex:indexPath.row-1];
            NSNumber *playerSelectedIndex = [dic objectForKey:KEY_FOR_INDEX_IN_PPP_TABLEVIEW];
            self.playerSelectedIndex = playerSelectedIndex.intValue;
            
            if(self.buttonNo)
            {
                ((UIButton*)[self.view viewWithTag:self.buttonNo]).backgroundColor = [UIColor whiteColor];
                [self updateGrade];
                self.buttonNo = 0;
            }
        }
        else
            self.playerSelectedIndex = 0;
    }
    else if(tableView.tag == NO_TABLEVIEW_TAG)
    {
        if(!self.isRecordMode)
        {
            self.playerSelectedIndex = (int)indexPath.row;
            [self.playerDataTableView reloadData];
        }
        else if(indexPath.row != 0 && indexPath.row != self.playerCount+1)
        {
            BBRTableViewCell* cellOfSelected = [tableView cellForRowAtIndexPath:indexPath];
            
            UIAlertController* changePlayerAlert = [UIAlertController alertControllerWithTitle:@"下場球員" message:nil preferredStyle: UIAlertControllerStyleAlert];
            BOOL isPlayerOnFloorAlready = NO;
            for(int i=1; i<6; i++)
            {
                NSIndexPath* index = [NSIndexPath indexPathForRow:i inSection:0];
                BBRTableViewCell* cellOfChanged = [self.playerOnFloorListTableView cellForRowAtIndexPath:index];
                if([cellOfChanged.NoLabel.text isEqualToString:cellOfSelected.NoLabel.text])
                {
                    isPlayerOnFloorAlready = YES;
                    break;
                }
                UIAlertAction* playerOnFloorNoAction = [UIAlertAction actionWithTitle:cellOfChanged.NoLabel.text style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                    {
                        //caculate the player being placed's time on floor
                        [self updateTimeOnFloorOfPlayerWithIndexInOnFloorTableView:i-1];
                                                            
                        //update the data of the player on floor
                        NSMutableDictionary* dic = [self.playerOnFloorDataArray objectAtIndex:i-1];
                        cellOfChanged.NoLabel.text = cellOfSelected.NoLabel.text;
                        [dic setObject:[NSNumber numberWithInt:[cellOfSelected.NoLabel.text intValue]] forKey:KEY_FOR_INDEX_IN_PPP_TABLEVIEW];
                        [dic setObject:[NSNumber numberWithInt:self.timeCounter] forKey:KEY_FOR_TIME_WHEN_GO_ON_FLOOR];
                    }];
                [changePlayerAlert addAction:playerOnFloorNoAction];
            }
            if(!isPlayerOnFloorAlready)
            {
                UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){}];
                [changePlayerAlert addAction:cancelAction];
                [self presentViewController:changePlayerAlert animated:YES completion:nil];
            }
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
        else if(indexPath.row == self.playerCount+1)
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == NO_TABLEVIEW_TAG || tableView.tag == PLAYER_ON_FLOOR_TABLEVIEW_TAG)
    {
        if(!indexPath.row)
            return TITLE_CELL_HEIGHT;
        return CELL_HEIGHT;
    }
    //if(tableview.tag == PLAYER_GRADE_TABLEVIEW_TAG)
    return PLAYER_GRADE_TABLECELL_HEIGHT;
}

#pragma mark - DBRestClientDelegate

-(void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
    self.fileNamesInDropbox = [[NSMutableArray alloc] init];
    if(metadata.isDirectory)
    {
        for (DBMetadata *file in metadata.contents)
            [self.fileNamesInDropbox addObject:file.filename];
    }
    self.isLoadMetaFinished = YES;
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
    NSLog(@"Error loading metadata: %@", error);
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    [self performSelectorOnMainThread:@selector(removeSpinningView) withObject:nil waitUntilDone:NO];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
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