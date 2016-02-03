//
//  UserProfile.h
//  Similie
//
//  Created by Leenie Games Mac on 1/5/16.
//  Copyright © 2016 LeenieGames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfile : NSObject
    
    @property (strong, nonatomic) NSString *userID;
    @property (strong, nonatomic) NSString *firstName;
    @property (strong, nonatomic) NSString *lastName;
    @property (strong, nonatomic) NSString *email;
    @property (strong, nonatomic) NSMutableArray *friends;
    @property (strong, nonatomic) NSMutableArray *likes;
    @property (strong, nonatomic) UIImage *image;

@end
