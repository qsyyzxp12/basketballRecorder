//
//  BBRMainViewController.m
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/2/22.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import "BBRMainViewController.h"
#import "BBRTableViewCell.h"
#import "BBRDataTableViewController.h"

#define TITLE_CELL_HEIGHT 30
#define CELL_HEIGHT 40
#define CELL_WIDTH 60
#define BACKGROUND_WIDTH 373
#define BACKGROUND_HEIGHT 245
#define IMAGE_SCALE 0.465
#define RECORD_LABEL_HEIGHT 23
#define SIDE_PADDING_RATE 0.25      //for zone 6, 10
#define TOP_PADDING_RATE1 0.1       //for zone 1, 2, 4, 5, 7, 9, 11
#define TOP_PADDING_RATE2 0.3       //for zone 3
#define TOP_PADDING_RATE3 0.6       //for zone 6, 10
#define TOP_PADDING_RATE4 0         //for zone 8

@interface BBRMainViewController ()

@end

@implementation BBRMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.playerDataArray = [NSMutableArray arrayWithCapacity:self.playerCount];
    for(int i=0; i<self.playerCount; i++)
    {
        NSMutableDictionary* playerDataItem = [[NSMutableDictionary alloc] init];
        [playerDataItem setObject:[self.playerNoSet objectAtIndex:i] forKey:@"no"];
        [playerDataItem setObject:@"0" forKey:@"zone1TryCount"];
        [playerDataItem setObject:@"0" forKey:@"zone1ScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"zone2TryCount"];
        [playerDataItem setObject:@"0" forKey:@"zone2ScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"zone3TryCount"];
        [playerDataItem setObject:@"0" forKey:@"zone3ScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"zone4TryCount"];
        [playerDataItem setObject:@"0" forKey:@"zone4ScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"zone5TryCount"];
        [playerDataItem setObject:@"0" forKey:@"zone5ScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"zone6TryCount"];
        [playerDataItem setObject:@"0" forKey:@"zone6ScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"zone7TryCount"];
        [playerDataItem setObject:@"0" forKey:@"zone7ScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"zone8TryCount"];
        [playerDataItem setObject:@"0" forKey:@"zone8ScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"zone9TryCount"];
        [playerDataItem setObject:@"0" forKey:@"zone9ScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"zone10TryCount"];
        [playerDataItem setObject:@"0" forKey:@"zone10ScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"zone11TryCount"];
        [playerDataItem setObject:@"0" forKey:@"zone11ScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"zone12TryCount"];
        [playerDataItem setObject:@"0" forKey:@"zone12ScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"isolationTryCount"];
        [playerDataItem setObject:@"0" forKey:@"isolationScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"spotUpTryCount"];
        [playerDataItem setObject:@"0" forKey:@"spotUpScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"PSTryCount"];
        [playerDataItem setObject:@"0" forKey:@"PSScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"PCTryCount"];
        [playerDataItem setObject:@"0" forKey:@"PCScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"PPSTryCount"];
        [playerDataItem setObject:@"0" forKey:@"PPSScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"PRTryCount"];
        [playerDataItem setObject:@"0" forKey:@"PRScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"CSTryCount"];
        [playerDataItem setObject:@"0" forKey:@"CSScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"fastBreakTryCount"];
        [playerDataItem setObject:@"0" forKey:@"fastBreakScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"lowPostTryCount"];
        [playerDataItem setObject:@"0" forKey:@"lowPostScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"secondTryCount"];
        [playerDataItem setObject:@"0" forKey:@"secondScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"driveTryCount"];
        [playerDataItem setObject:@"0" forKey:@"driveScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"cutTryCount"];
        [playerDataItem setObject:@"0" forKey:@"cutScoreCount"];
        [playerDataItem setObject:@"0" forKey:@"totalScoreGet"];
        [self.playerDataArray addObject:playerDataItem];
    }
    
    self.navigationItem.title = @"記錄";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.rightBarButtonItem.title = @"完成";
    self.navigationItem.rightBarButtonItem.target = self;
    self.navigationItem.rightBarButtonItem.action = @selector(rightBarButtonClicked);
    
    self.playerSelectedIndex = 0;
    self.zoneNo = 0;
    
    int tableViewHeight = TITLE_CELL_HEIGHT + CELL_HEIGHT * self.playerCount+65;
    if (tableViewHeight > self.view.frame.size.height)
        tableViewHeight = self.view.frame.size.height;
    
    self.playerListTableView = [[UITableView alloc] initWithFrame:CGRectMake(20, 5, CELL_WIDTH, tableViewHeight)];
    self.playerListTableView.delegate = self;
    self.playerListTableView.dataSource = self;
    
    [self.view addSubview:self.playerListTableView];
    
    [self drawPicture];
    
    [self constructAlertControllers];
}

- (void) rightBarButtonClicked
{
    self.navigationItem.rightBarButtonItem.title = @"表格";
    self.navigationItem.rightBarButtonItem.action = @selector(showDataTable);
    self.navigationItem.title = @"記錄完成";
    for(int i=1; i<13; i++)
    {
        UIImageView* zone = (UIImageView*)[self.view viewWithTag:i];
        [zone setUserInteractionEnabled:NO];
    }
}

- (void) showDataTable
{
    [self performSegueWithIdentifier:@"showDataTable" sender:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showDataTable"])
    {
        BBRDataTableViewController* tableViewController = [segue destinationViewController];
        tableViewController.playerDataArray = self.playerDataArray;
    }
}

- (void) constructAlertControllers
{
    self.scoreOrNotAlert =
    [UIAlertController alertControllerWithTitle:@"得分" message:nil preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            NSMutableDictionary* playerData = [self.playerDataArray objectAtIndex:self.playerSelectedIndex-1];
            NSString *tryCountStr, *scoreCountStr;
            if(self.zoneNo != 12)
            {
                //更新進攻方式分類的成績
                int attackTryCount = [[playerData objectForKey:self.keyForTryCount] floatValue];
                int attackScoreCount = [[playerData objectForKey:self.keyForScoreCount] floatValue];
                tryCountStr = [NSString stringWithFormat:@"%d", attackTryCount+1];
                scoreCountStr = [NSString stringWithFormat:@"%d", attackScoreCount+1];
                
                [playerData setObject:tryCountStr forKey:self.keyForTryCount];
                [playerData setObject:scoreCountStr forKey:self.keyForScoreCount];
            }
            
            //更新區域分類的成績
            NSString* keyForZoneTryCount = [NSString stringWithFormat:@"zone%dTryCount", self.zoneNo];
            NSString* keyForZoneScoreCount =[NSString stringWithFormat:@"zone%dScoreCount", self.zoneNo];
            float zoneTryCount = [[playerData objectForKey:keyForZoneTryCount] floatValue];
            float zoneScoreCount = [[playerData objectForKey:keyForZoneScoreCount] floatValue];
            tryCountStr = [NSString stringWithFormat:@"%d", (int)zoneTryCount + 1];
            scoreCountStr = [NSString stringWithFormat:@"%d", (int)zoneScoreCount + 1];
                                    
            [playerData setObject:tryCountStr forKey:keyForZoneTryCount];
            [playerData setObject:scoreCountStr forKey:keyForZoneScoreCount];
            
            //更新得分成績
            int totalScoreGet = [[playerData objectForKey:@"totalScoreGet"] intValue];
            NSString* totalScoreGetStr;
            switch (self.zoneNo) {
                case 2: case 3: case 4: case 7: case 8: case 9:
                    totalScoreGetStr = [NSString stringWithFormat:@"%d", totalScoreGet+2];
                    break;
                case 1: case 5: case 6: case 10: case 11:
                    totalScoreGetStr = [NSString stringWithFormat:@"%d", totalScoreGet+3];
                case 12:
                    totalScoreGetStr = [NSString stringWithFormat:@"%d", totalScoreGet+1];
            }
            [playerData setObject:totalScoreGetStr forKey:@"totalScoreGet"];
            
            //Update UI
            [self updatePlayerData];
                                    
            self.zoneNo = 0;
            NSLog(@"%@", self.playerDataArray);
        }];
    UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            NSMutableDictionary* playerData = [self.playerDataArray objectAtIndex:self.playerSelectedIndex-1];
            NSString* tryCountStr;
            //更新進攻方式分類的成績
            if(self.zoneNo != 12)
            {
                float tryCount = [[playerData objectForKey:self.keyForTryCount] floatValue];
                tryCountStr = [NSString stringWithFormat:@"%d", (int)tryCount+1];

                [playerData setObject:tryCountStr forKey:self.keyForTryCount];
            }

            //更新區域分類的成績
            NSString* keyForZoneTryCount = [NSString stringWithFormat:@"zone%dTryCount", self.zoneNo];
            float zoneTryCount = [[playerData objectForKey:keyForZoneTryCount] floatValue];
            tryCountStr = [NSString stringWithFormat:@"%d", (int)zoneTryCount + 1];
                                   
            [playerData setObject:tryCountStr forKey:keyForZoneTryCount];
            
            //Update UI
            [self updatePlayerData];
                                   
            self.zoneNo = 0;
            NSLog(@"%@", self.playerDataArray);
        }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action)
        {
            self.zoneNo = 0;
        }];
    
    [self.scoreOrNotAlert addAction:yesAction];
    [self.scoreOrNotAlert addAction:noAction];
    [self.scoreOrNotAlert addAction:cancelAction];
    
    
    self.attackWayAlert = [UIAlertController alertControllerWithTitle:@"進攻方式"
                                        message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* isolationAction = [UIAlertAction actionWithTitle:@"單打" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                      {
                                          self.keyForTryCount = @"isolationTryCount";
                                          self.keyForScoreCount = @"isolationScoreCount";
                                          [self presentViewController:self.scoreOrNotAlert animated:YES completion:nil];
                                      }];
    UIAlertAction* spotUpAction = [UIAlertAction actionWithTitle:@"定點投籃" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                   {
                                       self.keyForTryCount = @"spotUpTryCount";
                                       self.keyForScoreCount = @"spotUpScoreCount";
                                       [self presentViewController:self.scoreOrNotAlert animated:YES completion:nil];
                                   }];
    UIAlertAction* psAction = [UIAlertAction actionWithTitle:@"PS" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                               {
                                   self.keyForTryCount = @"PSTryCount";
                                   self.keyForScoreCount = @"PSScoreCount";
                                   [self presentViewController:self.scoreOrNotAlert animated:YES completion:nil];
                               }];
    UIAlertAction* pcAction = [UIAlertAction actionWithTitle:@"PC" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                               {
                                   self.keyForTryCount = @"PCTryCount";
                                   self.keyForScoreCount = @"PCScoreCount";
                                   [self presentViewController:self.scoreOrNotAlert animated:YES completion:nil];
                               }];
    UIAlertAction* prAction = [UIAlertAction actionWithTitle:@"PR" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                               {
                                   self.keyForTryCount = @"PRTryCount";
                                   self.keyForScoreCount = @"PRScoreCount";
                                   [self presentViewController:self.scoreOrNotAlert animated:YES completion:nil];
                               }];
    UIAlertAction* ppsAction = [UIAlertAction actionWithTitle:@"PPS" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                {
                                    self.keyForTryCount = @"PPSTryCount";
                                    self.keyForScoreCount = @"PPSScoreCount";
                                    [self presentViewController:self.scoreOrNotAlert animated:YES completion:nil];
                                }];
    UIAlertAction* ppcAction = [UIAlertAction actionWithTitle:@"PPC" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                {
                                    self.keyForTryCount = @"PPCTryCount";
                                    self.keyForScoreCount = @"PPCScoreCount";
                                    [self presentViewController:self.scoreOrNotAlert animated:YES completion:nil];
                                }];
    UIAlertAction* catchShootAction = [UIAlertAction actionWithTitle:@"Catch&Shoot" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                       {
                                           self.keyForTryCount = @"CSTryCount";
                                           self.keyForScoreCount = @"CSScoreCount";
                                           [self presentViewController:self.scoreOrNotAlert animated:YES completion:nil];
                                       }];
    UIAlertAction* fastBreakAction = [UIAlertAction actionWithTitle:@"快攻" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                      {
                                          self.keyForTryCount = @"fastBreakTryCount";
                                          self.keyForScoreCount = @"fastBreakScoreCount";
                                          [self presentViewController:self.scoreOrNotAlert animated:YES completion:nil];
                                      }];
    UIAlertAction* lowPostAction = [UIAlertAction actionWithTitle:@"低位單打" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                    {
                                        self.keyForTryCount = @"lowPostTryCount";
                                        self.keyForScoreCount = @"lowPostScoreCount";
                                        [self presentViewController:self.scoreOrNotAlert animated:YES completion:nil];
                                    }];
    UIAlertAction* secondAction = [UIAlertAction actionWithTitle:@"二波進攻" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                   {
                                       self.keyForTryCount = @"secondTryCount";
                                       self.keyForScoreCount = @"secontScoreCount";
                                       [self presentViewController:self.scoreOrNotAlert animated:YES completion:nil];
                                   }];
    UIAlertAction* driveAction = [UIAlertAction actionWithTitle:@"切入" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                  {
                                      self.keyForTryCount = @"driveTryCount";
                                      self.keyForScoreCount = @"driveScoreCount";
                                      [self presentViewController:self.scoreOrNotAlert animated:YES completion:nil];
                                  }];
    UIAlertAction* cutAction = [UIAlertAction actionWithTitle:@"空切" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                {
                                    self.keyForTryCount = @"cutTryCount";
                                    self.keyForScoreCount = @"cutScoreCount";
                                    [self presentViewController:self.scoreOrNotAlert animated:YES completion:nil];
                                }];
    
    [self.attackWayAlert addAction:isolationAction];
    [self.attackWayAlert addAction:spotUpAction];
    [self.attackWayAlert addAction:psAction];
    [self.attackWayAlert addAction:pcAction];
    [self.attackWayAlert addAction:prAction];
    [self.attackWayAlert addAction:ppsAction];
    [self.attackWayAlert addAction:ppcAction];
    [self.attackWayAlert addAction:catchShootAction];
    [self.attackWayAlert addAction:fastBreakAction];
    [self.attackWayAlert addAction:lowPostAction];
    [self.attackWayAlert addAction:secondAction];
    [self.attackWayAlert addAction:driveAction];
    [self.attackWayAlert addAction:cutAction];
    [self.attackWayAlert addAction:cancelAction];
}

- (void) drawPicture
{
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.jpg"]];
    backgroundImageView.frame = CGRectMake(120, 70, BACKGROUND_WIDTH, BACKGROUND_HEIGHT);
    
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:backgroundImageView];
    
    NSMutableArray* zoneImageViewArray = [NSMutableArray arrayWithCapacity:11];
    
    //ZONE 1
    UIImageView* zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone1.png"] highlightedImage:[UIImage imageNamed:@"zone1-2.png"]];
    
    [zoneImageView sizeToFit];
    zoneImageView.frame = CGRectMake(backgroundImageView.frame.origin.x+2, backgroundImageView.frame.origin.y+2, zoneImageView.frame.size.width*IMAGE_SCALE, zoneImageView.frame.size.height*IMAGE_SCALE);

    zoneImageView.tag = 1;
    
    [zoneImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
    
    //ZONE 2
    CGPoint zonePosition = CGPointMake(zoneImageView.frame.origin.x+zoneImageView.frame.size.width+2, zoneImageView.frame.origin.y);
    zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone2.png"] highlightedImage:[UIImage imageNamed:@"zone2-2.png"]];
    [zoneImageView sizeToFit];
    zoneImageView.frame = CGRectMake(zonePosition.x, zonePosition.y, zoneImageView.frame.size.width*IMAGE_SCALE, zoneImageView.frame.size.height*IMAGE_SCALE);
    
    zoneImageView.tag = 2;
    
    [zoneImageView setUserInteractionEnabled:YES];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
    
    //ZONE 3
    zonePosition = CGPointMake(zoneImageView.frame.origin.x+zoneImageView.frame.size.width+2, zoneImageView.frame.origin.y);
    zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone3.png"] highlightedImage:[UIImage imageNamed:@"zone3-2.png"]];
    [zoneImageView sizeToFit];
    zoneImageView.frame = CGRectMake(zonePosition.x, zonePosition.y, zoneImageView.frame.size.width*IMAGE_SCALE, zoneImageView.frame.size.height*IMAGE_SCALE);
    
    zoneImageView.tag = 3;
    
    [zoneImageView setUserInteractionEnabled:YES];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
    
    //ZONE 4
    zonePosition = CGPointMake(zoneImageView.frame.origin.x+zoneImageView.frame.size.width+2, zoneImageView.frame.origin.y);
    zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone4.png"] highlightedImage:[UIImage imageNamed:@"zone4-2.png"]];
    [zoneImageView sizeToFit];
    zoneImageView.frame = CGRectMake(zonePosition.x, zonePosition.y, zoneImageView.frame.size.width*IMAGE_SCALE-2, zoneImageView.frame.size.height*IMAGE_SCALE);
    
    zoneImageView.tag = 4;
    
    [zoneImageView setUserInteractionEnabled:YES];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
    
    //ZONE 5
    zonePosition = CGPointMake(zoneImageView.frame.origin.x+zoneImageView.frame.size.width+2, zoneImageView.frame.origin.y);
    zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone5.png"] highlightedImage:[UIImage imageNamed:@"zone5-2.png"]];
    [zoneImageView sizeToFit];
    zoneImageView.frame = CGRectMake(zonePosition.x, zonePosition.y, zoneImageView.frame.size.width*IMAGE_SCALE, zoneImageView.frame.size.height*IMAGE_SCALE);
    
    zoneImageView.tag = 5;
    
    [zoneImageView setUserInteractionEnabled:YES];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
    
    //ZONE 6
    UIImageView* zone1 = [self.view viewWithTag:1];
    zonePosition = CGPointMake(zone1.frame.origin.x, zone1.frame.origin.y+zone1.frame.size.height+2);
    zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone6.png"] highlightedImage:[UIImage imageNamed:@"zone6-2.png"]];
    [zoneImageView sizeToFit];
    zoneImageView.frame = CGRectMake(zonePosition.x, zonePosition.y, zoneImageView.frame.size.width*IMAGE_SCALE, zoneImageView.frame.size.height*IMAGE_SCALE-1);
    
    zoneImageView.tag = 6;
    
    [zoneImageView setUserInteractionEnabled:YES];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
    
    //ZONE 7
    UIImageView* zone2 = [self.view viewWithTag:2];
    zonePosition = CGPointMake(zone2.frame.origin.x, zone2.frame.origin.y+zone2.frame.size.height+2);
    zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone7.png"] highlightedImage:[UIImage imageNamed:@"zone7-2.png"]];
    [zoneImageView sizeToFit];
    zoneImageView.frame = CGRectMake(zonePosition.x, zonePosition.y, zoneImageView.frame.size.width*IMAGE_SCALE, zoneImageView.frame.size.height*IMAGE_SCALE);
    
    zoneImageView.tag = 7;
    
    [zoneImageView setUserInteractionEnabled:YES];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
  
    //ZONE 10
    UIImageView* zone4 = [self.view viewWithTag:4];
    zonePosition = CGPointMake(zone4.frame.origin.x, zone4.frame.origin.y+zone4.frame.size.height+2);
    zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone10.png"] highlightedImage:[UIImage imageNamed:@"zone10-2.png"]];
    [zoneImageView sizeToFit];
    zoneImageView.frame = CGRectMake(zonePosition.x, zonePosition.y, zoneImageView.frame.size.width*IMAGE_SCALE-2, zoneImageView.frame.size.height*IMAGE_SCALE-2);
    
    zoneImageView.tag = 10;
    
    [zoneImageView setUserInteractionEnabled:YES];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
    
    //ZONE 9
    zonePosition = CGPointMake(zone4.frame.origin.x, zone4.frame.origin.y+zone4.frame.size.height+2);
    zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone9.png"] highlightedImage:[UIImage imageNamed:@"zone9-2.png"]];
    [zoneImageView sizeToFit];
    zoneImageView.frame = CGRectMake(zonePosition.x, zonePosition.y, zoneImageView.frame.size.width*IMAGE_SCALE-1, zoneImageView.frame.size.height*IMAGE_SCALE-1);
    
    zoneImageView.tag = 9;
    
    [zoneImageView setUserInteractionEnabled:YES];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
    
    //ZONE 11
    UIImageView* zone3 = [self.view viewWithTag:3];
    UIImageView* zone6 = [self.view viewWithTag:6];
    zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone11.png"] highlightedImage:[UIImage imageNamed:@"zone11-2.png"]];
    [zoneImageView sizeToFit];
    CGPoint zoneSize = CGPointMake(zoneImageView.frame.size.width*IMAGE_SCALE-2, zoneImageView.frame.size.height*IMAGE_SCALE-1);
    zonePosition = CGPointMake(zone3.frame.origin.x+1, CGRectGetMaxY(zone6.frame)-zoneSize.y);
    
    zoneImageView.frame = CGRectMake(zonePosition.x, zonePosition.y, zoneSize.x, zoneSize.y);
    
    zoneImageView.tag = 11;
    
    [zoneImageView setUserInteractionEnabled:YES];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
    
    
    //ZONE 8
    zonePosition = CGPointMake(zone3.frame.origin.x, zone3.frame.origin.y+zone3.frame.size.height+2);
    zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone8.png"] highlightedImage:[UIImage imageNamed:@"zone8-2.png"]];
    [zoneImageView sizeToFit];
    zoneImageView.frame = CGRectMake(zonePosition.x+1, zonePosition.y, zoneImageView.frame.size.width*IMAGE_SCALE-2, zoneImageView.frame.size.height*IMAGE_SCALE);
    
    zoneImageView.tag = 8;
    
    [zoneImageView setUserInteractionEnabled:YES];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
    
    //Draw Label for zone1
    UILabel* hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone1.frame.origin.x, zone1.frame.origin.y + zone1.frame.size.height*TOP_PADDING_RATE1, zone1.frame.size.width, RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 101;
    UILabel* gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), CGRectGetWidth(hitRateLabel.frame), RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 102;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Draw Label for zone2
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone2.frame.origin.x, zone2.frame.origin.y + zone2.frame.size.height*TOP_PADDING_RATE1, zone2.frame.size.width, RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 201;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), CGRectGetWidth(hitRateLabel.frame), RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 202;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Draw Label for zone3
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone3.frame.origin.x, zone3.frame.origin.y + zone3.frame.size.height*TOP_PADDING_RATE2, zone3.frame.size.width, RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 301;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), CGRectGetWidth(hitRateLabel.frame), RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 302;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Draw Label for zone4
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone4.frame.origin.x, zone4.frame.origin.y + zone4.frame.size.height*TOP_PADDING_RATE1, zone4.frame.size.width, RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 401;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), CGRectGetWidth(hitRateLabel.frame), RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 402;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Draw Label for zone5
    UIImageView* zone5 = [self.view viewWithTag:5];
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone5.frame.origin.x, zone5.frame.origin.y + zone5.frame.size.height*TOP_PADDING_RATE1, zone5.frame.size.width, RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 501;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), zone5.frame.size.width, RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 502;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Draw Label for zone6
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone6.frame.origin.x, zone6.frame.origin.y+zone6.frame.size.height*TOP_PADDING_RATE3, zone6.frame.size.width*(1-SIDE_PADDING_RATE), RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 601;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), zone6.frame.size.width*(1-SIDE_PADDING_RATE), RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 602;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Draw Label for zone7
    UIImageView* zone7 = [self.view viewWithTag:7];
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone7.frame.origin.x, zone7.frame.origin.y+zone7.frame.size.height*TOP_PADDING_RATE1, zone7.frame.size.width, RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 701;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), zone7.frame.size.width, RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 702;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Draw Label for zone8
    UIImageView* zone8 = [self.view viewWithTag:8];
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone8.frame.origin.x, zone8.frame.origin.y+zone8.frame.size.height*TOP_PADDING_RATE4, zone8.frame.size.width, RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 801;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), zone8.frame.size.width, RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 802;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Draw Label for zone9
    UIImageView* zone9 = [self.view viewWithTag:9];
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone9.frame.origin.x, zone9.frame.origin.y+zone9.frame.size.height*TOP_PADDING_RATE1, zone9.frame.size.width, RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 901;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), zone9.frame.size.width, RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 902;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Draw Label for zone10
    UIImageView* zone10 = [self.view viewWithTag:10];
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone10.frame.origin.x+zone10.frame.size.width*SIDE_PADDING_RATE, zone10.frame.origin.y+zone10.frame.size.height*TOP_PADDING_RATE3, zone10.frame.size.width*(1-SIDE_PADDING_RATE), RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 1001;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), zone10.frame.size.width*(1-SIDE_PADDING_RATE), RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 1002;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Draw Label for zone10
    UIImageView* zone11 = [self.view viewWithTag:11];
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone11.frame.origin.x, zone11.frame.origin.y+zone11.frame.size.height*TOP_PADDING_RATE1, zone11.frame.size.width, RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 1101;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), zone11.frame.size.width, RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 1102;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    
    UILabel* penaltyZone = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(backgroundImageView.frame)+5, CGRectGetMaxY(backgroundImageView.frame)-80, 60, RECORD_LABEL_HEIGHT)];
    penaltyZone.textAlignment = NSTextAlignmentCenter;
    penaltyZone.layer.borderWidth = 1;
    penaltyZone.text = @"罰球";
    
    UIImageView* tapView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone1.png"] highlightedImage:[UIImage imageNamed:@"zone1-2.png"]];
    tapView.frame = penaltyZone.frame;
    [tapView setUserInteractionEnabled:YES];
    tapView.tag = 12;
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [tapView addGestureRecognizer:tapGestureRecognizer];
    
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(penaltyZone.frame.origin.x, CGRectGetMaxY(penaltyZone.frame), 60, RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 1201;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), 60, RECORD_LABEL_HEIGHT)];
    gradeLabel.tag = 1202;
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.text = @"0/0";
    
    [self.view addSubview:tapView];
    [self.view addSubview:penaltyZone];
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
}

- (void) zonePaned:(UIPanGestureRecognizer*) recognizer
{
    if([recognizer.view isKindOfClass:[UIImageView class]])
    {
        if(!((UIImageView*)recognizer.view).highlighted)
        {
            if((int)recognizer.view.tag != self.zoneNo && self.zoneNo)
                [(UIImageView*)[self.view viewWithTag:self.zoneNo] setHighlighted:NO];
            self.zoneNo = (int)recognizer.view.tag;
            [(UIImageView*)recognizer.view setHighlighted:YES];
            if(self.playerSelectedIndex)
                [self showAttackList];
        }
        else
        {
            self.zoneNo = 0;
            [(UIImageView*)recognizer.view setHighlighted:NO];
        }
    }
    
    NSLog(@"select zone %d", self.zoneNo);
}

- (void) showAttackList
{
    if(self.zoneNo != 12)
        [self presentViewController:self.attackWayAlert animated:YES completion:nil];
    else
        [self presentViewController:self.scoreOrNotAlert animated:YES completion:nil];
    
    [(UIImageView*)[self.view viewWithTag:self.zoneNo] setHighlighted:NO];
}

- (void) updatePlayerData
{
    if(self.playerSelectedIndex)
    {
        NSDictionary* playerData = [self.playerDataArray objectAtIndex:self.playerSelectedIndex-1];
        for(int i=1; i<13; i++)
        {
            NSString* keyForTryCount = [NSString stringWithFormat:@"zone%dTryCount", i];
            NSString* keyForScoreCount = [NSString stringWithFormat:@"zone%dScoreCount", i];
            float zoneTryCount = [(NSString*)[playerData objectForKey:keyForTryCount] floatValue];
            float zoneScoreCount = [(NSString*)[playerData objectForKey:keyForScoreCount] floatValue];
            ((UILabel*)[self.view viewWithTag:(i*100+2)]).text = [NSString stringWithFormat:@"%d/%d", (int)zoneScoreCount, (int)zoneTryCount];
            ((UILabel*)[self.view viewWithTag:(i*100+1)]).text = [NSString stringWithFormat:@"%d%c", (int)((zoneScoreCount/zoneTryCount)*100), '%'];
        }
    }
    else
    {
        for(int i=1; i<12; i++)
        {
            ((UILabel*)[self.view viewWithTag:(i*100+2)]).text = @"0/0";
            ((UILabel*)[self.view viewWithTag:(i*100+1)]).text = @"0%";
        }
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIInterfaceOrientationLandscapeLeft]
                                forKey:@"orientation"];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
                                forKey:@"orientation"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (self.playerCount + 1);
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
            label.text = @"背號";
            [cell addSubview:label];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    
    BBRTableViewCell* cell = [[BBRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.layer.borderWidth = 1;
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH, CELL_HEIGHT)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%@", [self.playerNoSet objectAtIndex:indexPath.row-1]];
    [cell addSubview:label];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row)
    {
        self.playerSelectedIndex = (int)indexPath.row;
        
        NSLog(@"select player index = %d", self.playerSelectedIndex);
        if(self.zoneNo)
            [self showAttackList];
    }
    else
        self.playerSelectedIndex = 0;
    
    [self updatePlayerData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!indexPath.row)
        return TITLE_CELL_HEIGHT;
    return CELL_HEIGHT;
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
