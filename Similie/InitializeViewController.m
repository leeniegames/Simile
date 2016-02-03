//
//  InitializeViewController.m
//  Similie
//
//  Created by Leenie Games Mac on 12/31/15.
//  Copyright © 2015 LeenieGames. All rights reserved.
//

#import "InitializeViewController.h"
#import "LoginViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "UserProfile.h"

@interface InitializeViewController (){
    BOOL loginSuccessful;
    UserProfile *playerProfile;
}

@end

@implementation InitializeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    loginSuccessful = NO;
}

-(void)viewDidAppear:(BOOL)animated{
    
    // ONLY RUN ONE THEN DESTROY
    // [self createTestUsers];
    
    if(![PFUser currentUser]){
        
        
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        
        loginVC.facebookPermissions = @[@"public_profile", @"email", @"user_likes", @"user_about_me", @"user_location"];
        
        loginVC.fields =  PFLogInFieldsFacebook;
        
        [loginVC setDelegate:self];
        
        [self presentViewController:loginVC animated:NO completion:nil];
    }else{
        [[PFUser currentUser] fetchInBackground];
        
        [self performSegueWithIdentifier:@"init2main" sender:nil];
        
    }
    
}

-(void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error{
    NSLog(@"error = %@", error.description);
}

-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user{
    loginSuccessful = YES;
    
    //playerProfile = [[UserProfile alloc]init];
    //playerProfile.userID = @"test";
    
    if ([FBSDKAccessToken currentAccessToken]) {
        FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc]init];
        [connection addRequest:[[FBSDKGraphRequest alloc]initWithGraphPath:@"me" parameters:@{@"fields":@"email, first_name, last_name, age_range"}] completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error){
            
            NSString *pictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", result[@"id"]];
            
            PFUser *userData = [PFUser currentUser];
            userData[@"email"] = result[@"email"]!=nil?result[@"email"]:[NSNull null];
            userData[@"firstName"] = result[@"first_name"]!=nil?result[@"first_name"]:[NSNull null];
            userData[@"lastName"] = result[@"last_name"]!=nil?result[@"last_name"]:[NSNull null];
            userData[@"ageMin"] = result[@"age_range"][@"min"]!=nil?result[@"age_range"][@"min"]:[NSNull null];
            userData[@"ageMax"] = result[@"age_range"][@"max"]!=nil?result[@"age_range"][@"max"]:[NSNull null];
            
            PFFile *image = [PFFile fileWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pictureURL]]];
            
            userData[@"picture"] = image;
            
            [userData saveInBackground];
        }];
        
        [connection addRequest:[[FBSDKGraphRequest alloc]initWithGraphPath:@"me/likes" parameters:@{@"fields":@"name"}] completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error){
            
            NSMutableArray *likes = [NSMutableArray array];
            
            NSArray *data = result[@"data"];
            for(NSDictionary *d in data){
                [likes addObject:d[@"name"]];
            }
            
            //////GET RID OF THIS//////
            likes = [NSMutableArray arrayWithObjects:@"like 0", @"like 10", @"like 20", @"like 30", @"like 40", @"like 50", @"like 60", @"like 70", @"like 80", @"like 90", nil];
            
            
            
            PFUser *userData = [PFUser currentUser];
            userData[@"likes"] = likes;
            
            [userData saveInBackground];
        }];
        
        [connection start];
    }
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createTestUsers{
    // create an array of likes to draw from
    
    for (int i = 0; i<100; ++i) {
        NSMutableArray *defaultLikes = [NSMutableArray array];
        for (int j = 0; j<100; ++j) {
            [defaultLikes addObject:[NSString stringWithFormat:@"like %i", j]];
        }
        
        PFObject *user = [PFObject objectWithClassName:@"testUser"];
        
        user[@"firstName"] = [NSString stringWithFormat:@"firstName %i", i];
        user[@"lastName"] = [NSString stringWithFormat:@"lastName %i", i];
        user[@"email"] = [NSString stringWithFormat:@"email %i", i];
        user[@"ageMin"] = @22;
        user[@"ageMax"] = @33;
        
        NSMutableArray *likes = [NSMutableArray array];
        for (NSString *n in defaultLikes) {
            int rand = arc4random_uniform(100);
            if (rand<30) {
                [likes addObject:n];
            }
        }
        user[@"likes"] = likes;
        
        UIImage *profileImage = [UIImage imageNamed:[NSString stringWithFormat:@"profile%i", (i%7)+1]];
        PFFile *pi = [PFFile fileWithData:UIImageJPEGRepresentation(profileImage, 1.0f)];
        user[@"picture"] = pi;
        
        [user saveInBackgroundWithBlock:^(BOOL success, NSError *error){
            if(!success){
                NSLog(@"test user error: %@", error.description);
            }else{
                NSLog(@"successful save of test user %i", i);
            }
        }];
    }
    
    
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
