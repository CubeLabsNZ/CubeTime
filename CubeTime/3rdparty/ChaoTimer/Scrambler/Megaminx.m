//
//  Megaminx.m
//  DCTimer scrambles
//
//  Created by MeigenChou on 13-2-20.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "Megaminx.h"
#import "stdlib.h"
#import "time.h"

@implementation Megaminx

- (id)init {
    self = [super init];
    if (self) {
        srand((unsigned)time(0));
        // Initialization code here.
    }
    return self;
}

int linelen=10;
int linenbr=7;
int seq[80];

-(void) scramble {
    for(int i=0; i<linenbr*linelen; i++){
        seq[i] = (int)(rand()%2);
    }
}

-(NSString *) scrMinx {
    [self scramble];
    NSMutableString *s = [NSMutableString string];
    int i, j;
    for(j=0; j<linenbr; j++){
        for(i=0; i<linelen; i++){
            if (i%2!=0)
            {
                if (seq[j*linelen + i]!=0) {
                    [s appendString:@"D++ "];
                    //state = applyMove(state, permD2);
                }
                else {
                    [s appendString:@"D-- "];
                    //state = applyMove(state, permD2i);
                }
            }
            else
            {
                if (seq[j*linelen + i]!=0) {
                    [s appendString:@"R++ "];
                    //state = applyMove(state, permR2);
                }
                else {
                    [s appendString:@"R-- "];
                    //state = applyMove(state, permR2i);
                }
            }
        }
        if (seq[(j+1)*linelen - 1]!=0) {
            [s appendString:@"U \n"];
            //state = applyMove(state, permU);
        }
        else {
            [s appendString:@"U' \n"];
            //state = applyMove(state, permUi);
        }
    }
    return s;
}
@end
