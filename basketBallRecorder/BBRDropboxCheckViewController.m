//
//  BBRDropboxCheckViewController.m
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/4/12.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import "BBRDropboxCheckViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface BBRDropboxCheckViewController ()

@end

@implementation BBRDropboxCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([[DBSession sharedSession] isLinked])
        [[DBSession sharedSession] unlinkAll];
    if (![[DBSession sharedSession] isLinked])
        [[DBSession sharedSession] linkFromController:self];
    [self performSelectorInBackground:@selector(tmp) withObject:nil];
}

- (void)tmp
{
    while (![[DBSession sharedSession] isLinked]);
    [self performSegueWithIdentifier:@"showMenuSegue" sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
