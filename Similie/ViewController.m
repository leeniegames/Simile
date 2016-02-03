//
//  ViewController.m
//  Similie
//
//  Created by Leenie Games Mac on 10/20/15.
//  Copyright © 2015 LeenieGames. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>

@interface ViewController ()<UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITableView *likesTable;
@property (weak, nonatomic) IBOutlet UILabel *percentage;
@property (weak, nonatomic) IBOutlet UILabel *profileDescription;
@property (weak, nonatomic) IBOutlet UIImageView *checkMark;

@end

@implementation ViewController{
    
    NSArray *users;
    int currentUser;
    int appState;
    NSMutableArray *likes;
    
    NSArray *myLikes;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /*
    PFObject *testObject = [PFObject objectWithClassName:@"UserData"];
    testObject[@"name"] = @"Jenna";
    testObject[@"age"] = @44;
    testObject[@"city"] = @"Seattle";
    testObject[@"state"] = @"WA";
    //testObject[@"likes"] = @[@"Rome", @"Horses", @"Soap", @"Water", @"Planking", @"Dirt", @"Shopping"];
    //testObject[@"likes"] = @[@"Trucks", @"Horses", @"Beer", @"Rocky", @"Scuba Diving", @"Shopping", @"Paramedics", @"Monet", @"Robots"];
    testObject[@"likes"] = @[@"Trucks", @"Bottles", @"Crepes", @"Skyscrapers", @"Scuba Diving", @"Shopping", @"Dogs", @"Ducks", @"Ghostbusters"];
    [testObject saveInBackground];
     */
    
    appState = 0;
    currentUser = -1;
    
    //myLikes = @[@"Trucks", @"Bottles", @"Crepes", @"Skyscrapers", @"Rome", @"Horses", @"Planking", @"Dirt", @"Monet"];
    myLikes = @[@"Trucks", @"Bottles", @"Crepes", @"Skyscrapers", @"Shopping", @"Dogs", @"Ducks", @"Ghostbusters"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserData"];
    [query whereKeyExists:@"name"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        NSLog(@"objects = %@", objects[0]);
        users = objects;
        [self displayNextUser];
    }];
}

-(void)displayNextUser{
    currentUser++;
    if (currentUser>=users.count) {
        currentUser = 0;
    }
    
    PFFile *image = [users[currentUser] objectForKey:@"image"];
    [image getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        _profileImage.image = [UIImage imageWithData:data];
    }];
    
    NSString *name = [users[currentUser] objectForKey:@"name"];
    NSString *city = [users[currentUser] objectForKey:@"city"];
    NSString *state = [users[currentUser] objectForKey:@"state"];
    int age = [[users[currentUser] objectForKey:@"age"]intValue];
    
    NSString *info = [NSString stringWithFormat:@"%@, %i, %@, %@", name, age, city, state];
    
    _profileDescription.text = info;
    
    likes = [users[currentUser] objectForKey:@"likes"];
    
    int similies = 0;
    for (NSString *ml in myLikes) {
        for (NSString *l in likes) {
            if ([l isEqualToString:ml]) {
                similies++;
                break;
            }
        }
    }
    
    double ratio = (double)similies/(double)myLikes.count;
    int percentage = ratio*100;
    
    _percentage.text = [NSString stringWithFormat:@"%i%%", percentage];
    
    [_likesTable reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return likes.count;
};

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = likes[indexPath.row];
    
    return cell;
};

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    if(CGRectContainsPoint(_checkMark.frame, location)){
        [self displayNextUser];
    }
}

@end
