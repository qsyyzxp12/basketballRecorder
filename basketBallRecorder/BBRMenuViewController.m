//
//  BBRMenuViewController.m
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/2/29.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import "BBRMenuViewController.h"
#import "BBRMainViewController.h"
#import "BRAOfficeDocumentPackage.h"

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
    
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    
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
        [self presentViewController:self.dirtyStatusAlert animated:YES completion:nil];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self.view addSubview:self.spinView];
    [self.view addSubview:self.spinner];
    self.loadingLabel.text = @"Loading";
    [self.view addSubview:self.loadingLabel];
    
    [self.restClient loadMetadata:@"/"];
}

-(void) constructAlertController
{
    self.dirtyStatusAlert = [UIAlertController alertControllerWithTitle:@"注意" message:@"上次的紀錄尚未完成，是否要繼續記錄？" preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"要" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            [self performSegueWithIdentifier:@"showMainViewController" sender:nil];
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
    [self performSegueWithIdentifier:@"showMainViewController" sender:nil];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showMainViewController"])
    {
        NSString* recordPlistPath = [NSString stringWithFormat:@"%@/Documents/record.plist", NSHomeDirectory()];
        NSArray* recordPlistArray = [NSArray arrayWithContentsOfFile:recordPlistPath];
        BBRMainViewController* mainViewCntler = [segue destinationViewController];
        mainViewCntler.isTmpPlistExist = self.isTmpPlistExist;

//        NSLog(@"%d", (int)[recordPlistArray count] - self.buttonClickedNo);
        mainViewCntler.showOldRecordNo = (int)[recordPlistArray count] - self.buttonClickedNo + 1;

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DBRestClientDelegate

-(void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
    NSMutableArray* fileNamesInDropbox = [[NSMutableArray alloc] init];
    if(metadata.isDirectory)
        for (DBMetadata *file in metadata.contents)
            [fileNamesInDropbox addObject:file.filename];
    
    NSLog(@"%@", fileNamesInDropbox);
    
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
            
            for(NSString* name in fileNamesInDropbox)
                if([name isEqualToString:[NSString stringWithFormat:@"%@.xlsx", gameName]])
                {
                    [((UIButton*)self.statusButtonArray[buttonIndex]) setTitle:@"已上傳" forState:UIControlStateNormal];
                    [((UIButton*)self.statusButtonArray[buttonIndex]) setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                    ((UIButton*)self.statusButtonArray[buttonIndex]).userInteractionEnabled = NO;
                    break;
                }
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

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
    NSLog(@"Error loading metadata: %@", error);
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata
{
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    [self.restClient loadMetadata:@"/"];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error
{
    NSLog(@"File upload failed with error: %@", error);
    [self.spinView removeFromSuperview];
    [self.loadingLabel removeFromSuperview];
    [self.spinner removeFromSuperview];
}

#pragma mark - Actions

- (IBAction)uploadButtonClicked:(UIButton*)sender
{
    [self.view addSubview:self.spinView];
    self.loadingLabel.text = @"Uploading";
    [self.view addSubview:self.loadingLabel];
    [self.view addSubview:self.spinner];
    
    NSThread *newThread = [[NSThread alloc] initWithTarget:self selector:@selector(xlsxFileGenerateAndUpload:) object:sender];

    [newThread start];
}

-(void) xlsxFileGenerateAndUpload:(UIButton*) sender
{
    NSLog(@"%ld", sender.tag);
    
    NSString* recordPlistPath = [NSString stringWithFormat:@"%@/Documents/record.plist", NSHomeDirectory()];
    NSArray* recordPlistArray = [NSArray arrayWithContentsOfFile:recordPlistPath];
    
    NSString* gameName;
    NSDictionary* dataDic;
    int menuCount = (int)[recordPlistArray count];
    switch (sender.tag) {
        case 5:
            gameName = [[recordPlistArray objectAtIndex:menuCount-1] objectForKey:KEY_FOR_NAME];
            dataDic = [recordPlistArray objectAtIndex:menuCount-1];
            break;
        case 4:
            gameName = [[recordPlistArray objectAtIndex:menuCount-2] objectForKey:KEY_FOR_NAME];
            dataDic = [recordPlistArray objectAtIndex:menuCount-2];
            break;
        case 3:
            gameName = [[recordPlistArray objectAtIndex:menuCount-3] objectForKey:KEY_FOR_NAME];
            dataDic = [recordPlistArray objectAtIndex:menuCount-3];
            break;
        case 2:
            gameName = [[recordPlistArray objectAtIndex:menuCount-4] objectForKey:KEY_FOR_NAME];
            dataDic = [recordPlistArray objectAtIndex:menuCount-4];
            break;
        case 1:
            gameName = [[recordPlistArray objectAtIndex:menuCount-5] objectForKey:KEY_FOR_NAME];
            dataDic = [recordPlistArray objectAtIndex:menuCount-5];
            break;
    }
    
    NSLog(@"gameName = %@", gameName);
    
    NSArray* playerDataArray = [dataDic objectForKey:KEY_FOR_GRADE];
    NSArray* playerNoSet = [dataDic objectForKey:KEY_FOR_PLAYER_NO_SET];
    NSArray* attackWayKeySet = [[NSArray alloc] initWithObjects:
                                @"isolation", @"spotUp", @"PS", @"PD", @"PR", @"PPS", @"PPD", @"CS",
                                @"fastBreak", @"lowPost", @"second", @"drive", @"highLow", @"cut", nil];
    
    int playerCount = (int)[playerNoSet count];
    
    //Generate the xlsx file
    NSString *documentPath = [[NSBundle mainBundle] pathForResource:@"spreadsheet" ofType:@"xlsx"];
    BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:documentPath];
    
    for(int i=0; i<[playerDataArray count]; i++)
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
            [worksheet save];
        }
        else
            worksheet = spreadsheet.workbook.worksheets[i];
        
        NSString* cellRef;
        NSArray* totalGradeArray = [playerDataArray objectAtIndex:i];
        for(int i=0; i<playerCount+1; i++)
        {
            char outIndex = '\0';
            char interIndex = 'A';
            cellRef = [NSString stringWithFormat:@"%c%c%d", outIndex, interIndex++, i+3];
            if(i < playerCount)
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:playerNoSet[i]];
            else
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:@"全隊"];
  
            NSDictionary* playerDataDic = [totalGradeArray objectAtIndex:i];
            for(int j=0; j<[attackWayKeySet count]; j++)
            {
                NSDictionary* offenseGradeDic = [playerDataDic objectForKey:attackWayKeySet[j]];
                NSString* madeCount = [offenseGradeDic objectForKey:KEY_FOR_MADE_COUNT];
                if(interIndex == 91) // (int)'Z' == 90
                {
                    if(outIndex != '\0')
                        outIndex++;
                    else
                        outIndex = 'A';
                    interIndex = 65;
                }
                cellRef = [NSString stringWithFormat:@"%c%c%d", outIndex, interIndex++, i+3];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:madeCount];
                
                NSString* attemptCount = [offenseGradeDic objectForKey:KEY_FOR_ATTEMPT_COUNT];
                if(interIndex == 91) // (int)'Z' == 90
                {
                    if(outIndex != '\0')
                        outIndex++;
                    else
                        outIndex = 'A';
                    interIndex = 65;
                }
                cellRef = [NSString stringWithFormat:@"%c%c%d", outIndex, interIndex++, i+3];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:attemptCount];
                
                NSString* foulCount = [offenseGradeDic objectForKey:KEY_FOR_FOUL_COUNT];
                if(interIndex == 91) // (int)'Z' == 90
                {
                    if(outIndex != '\0')
                        outIndex++;
                    else
                        outIndex = 'A';
                    interIndex = 65;
                }
                cellRef = [NSString stringWithFormat:@"%c%c%d", outIndex, interIndex++, i+3];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:foulCount];
                
                NSString* turnOverCount = [offenseGradeDic objectForKey:KEY_FOR_TURNOVER_COUNT];
                if(interIndex == 91) // (int)'Z' == 90
                {
                    if(outIndex != '\0')
                        outIndex++;
                    else
                        outIndex = 'A';
                    interIndex = 65;
                }
                cellRef = [NSString stringWithFormat:@"%c%c%d", outIndex, interIndex++, i+3];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:turnOverCount];
                
                NSString* score = [offenseGradeDic objectForKey:KEY_FOR_SCORE_GET];
                if(interIndex == 91) // (int)'Z' == 90
                {
                    if(outIndex != '\0')
                        outIndex++;
                    else
                        outIndex = 'A';
                    interIndex = 65;
                }
                cellRef = [NSString stringWithFormat:@"%c%c%d", outIndex, interIndex++, i+3];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:score];
            }
            
            NSDictionary* bonusGrade = [playerDataDic objectForKey:@"zone12"];
            NSString* madeCountInBonus = [bonusGrade objectForKey:KEY_FOR_MADE_COUNT];
            cellRef = [NSString stringWithFormat:@"BT%d", i+3];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:madeCountInBonus];
            
            NSString* attemptCountInBonus = [bonusGrade objectForKey:KEY_FOR_ATTEMPT_COUNT];
            cellRef = [NSString stringWithFormat:@"BU%d", i+3];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:attemptCountInBonus];
            
            cellRef = [NSString stringWithFormat:@"BV%d", i+3];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:madeCountInBonus];
            
            NSString* totalMadeCount = [playerDataDic objectForKey:KEY_FOR_TOTAL_MADE_COUNT];
            cellRef = [NSString stringWithFormat:@"BW%d", i+3];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:totalMadeCount];
            
            NSString* totalAttemptCount = [playerDataDic objectForKey:KEY_FOR_TOTAL_ATTEMPT_COUNT];
            cellRef = [NSString stringWithFormat:@"BX%d", i+3];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:totalAttemptCount];
            
            NSString* totalFoulCount = [playerDataDic objectForKey:KEY_FOR_TOTAL_FOUL_COUNT];
            cellRef = [NSString stringWithFormat:@"BY%d", i+3];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:totalFoulCount];
            
            NSString* totalTurnoverCount = [playerDataDic objectForKey:KEY_FOR_TOTAL_TURNOVER_COUNT];
            cellRef = [NSString stringWithFormat:@"BZ%d", i+3];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:totalTurnoverCount];
 
            NSString* totalScore = [playerDataDic objectForKey:KEY_FOR_TOTAL_SCORE_GET];
            cellRef = [NSString stringWithFormat:@"CA%d", i+3];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:totalScore];
        }
        
    }
    
    //Save the xlsx to the app space in the device
    NSString *sheetPath = [NSString stringWithFormat:@"%@/Documents/spreadsheet.xlsx", NSHomeDirectory()];
    NSFileManager* fm = [[NSFileManager alloc] init];
    
    if([fm fileExistsAtPath:sheetPath])
        [fm removeItemAtPath:sheetPath error:nil];
    
    [spreadsheet saveAs:sheetPath];
    
    NSString* filename = [NSString stringWithFormat:@"%@.xlsx", gameName];
    NSArray* agus = [[NSArray alloc] initWithObjects:filename, sheetPath, nil];
    [self performSelectorOnMainThread:@selector(uploadXlsxFile:) withObject:agus waitUntilDone:0];
}

-(void) uploadXlsxFile:(NSArray*) parameters
{
    [self.restClient uploadFile:[parameters objectAtIndex:0] toPath:@"/" withParentRev:nil fromPath:[parameters objectAtIndex:1]];
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
