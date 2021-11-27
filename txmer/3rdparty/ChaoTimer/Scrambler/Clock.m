//
//  Clock.m
//  DCTimer scramblers
//
//  Created by MeigenChou on 13-3-2.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "Clock.h"
#import "stdlib.h"
#import "time.h"

@implementation Clock

NSArray *clkTurns;
int moves[9][18] = { 
    {0,1,1,0,1,1,0,0,0,  -1, 0, 0, 0, 0, 0, 0, 0, 0},// UR
    {0,0,0,0,1,1,0,1,1,   0, 0, 0, 0, 0, 0,-1, 0, 0},// DR
    {0,0,0,1,1,0,1,1,0,   0, 0, 0, 0, 0, 0, 0, 0,-1},// DL
    {1,1,0,1,1,0,0,0,0,   0, 0,-1, 0, 0, 0, 0, 0, 0},// UL
    {1,1,1,1,1,1,0,0,0,  -1, 0,-1, 0, 0, 0, 0, 0, 0},// U
    {0,1,1,0,1,1,0,1,1,  -1, 0, 0, 0, 0, 0,-1, 0, 0},// R
    {0,0,0,1,1,1,1,1,1,   0, 0, 0, 0, 0, 0,-1, 0,-1},// D
    {1,1,0,1,1,0,1,1,0,   0, 0,-1, 0, 0, 0, 0, 0,-1},// L
    {1,1,1,1,1,1,1,1,1,  -1, 0,-1, 0, 0, 0,-1, 0,-1},// A
};
int movesOld[][18] = {
    {1,1,1,1,1,1,0,0,0,  -1, 0,-1, 0, 0, 0, 0, 0, 0},//UUdd
    {0,1,1,0,1,1,0,1,1,  -1, 0, 0, 0, 0, 0,-1, 0, 0},//dUdU
    {0,0,0,1,1,1,1,1,1,   0, 0, 0, 0, 0, 0,-1, 0,-1},//ddUU
    {1,1,0,1,1,0,1,1,0,   0, 0,-1, 0, 0, 0, 0, 0,-1},//UdUd
    {0,0,0,0,0,0,1,0,1,   0, 0, 0,-1,-1,-1,-1,-1,-1},
    {1,0,0,0,0,0,1,0,0,   0,-1,-1, 0,-1,-1, 0,-1,-1},
    {1,0,1,0,0,0,0,0,0,  -1,-1,-1,-1,-1,-1, 0, 0, 0},
    {0,0,1,0,0,0,0,0,1,  -1,-1, 0,-1,-1, 0,-1,-1, 0},
    {0,1,1,1,1,1,1,1,1,  -1, 0, 0, 0, 0, 0,-1, 0,-1},//dUUU
    {1,1,0,1,1,1,1,1,1,   0, 0,-1, 0, 0, 0,-1, 0,-1},//UdUU
    {1,1,1,1,1,1,1,1,0,  -1, 0,-1, 0, 0, 0, 0, 0,-1},//UUUd
    {1,1,1,1,1,1,0,1,1,  -1, 0,-1, 0, 0, 0,-1, 0, 0},//UUdU
    {1,1,1,1,1,1,1,1,1,  -1, 0,-1, 0, 0, 0,-1, 0,-1},//UUUU
    {1,0,1,0,0,0,1,0,1,  -1,-1,-1,-1,-1,-1,-1,-1,-1},//dddd
};
int clkIdx[] = {1, 3, 2, 0};
int posit[18];
int pegs[4];
int epoIdx[] = {12, 8, 1, 5, 11, 0, 4, 10, 3, 7, 9, 2, 6, 13};

- (id) init {
    if(self = [super init]) {
        clkTurns = [[NSArray alloc] initWithObjects:@"UR", @"DR", @"DL", @"UL", @"U", @"R", @"D", @"L", @"ALL", nil];
        srand((unsigned)time(0));
    }
    return self;
}

- (NSString *) scramble {
    int x;
    for(x=0; x<18; x++)posit[x]=0;
    NSMutableString *scr = [NSMutableString string];
    int positCopy[18];
    for(x=0; x<9; x++) {
        int turn = rand()%12-5;
        for(int j=0; j<18; j++){
            positCopy[j]+=turn*moves[x][j];
        }
        bool clockwise = ( turn >= 0 );
        [scr appendFormat:@"%@%d%@ ", [clkTurns objectAtIndex:x], ABS(turn), (clockwise?@"+":@"-")];
        //scramble.append( turns[x] + turn + (clockwise?"+":"-") + " ");
    }
    [scr appendString:@"y2 "];
    for(x=0; x<9; x++){
        posit[x] = positCopy[x+9];
        posit[x+9] = positCopy[x];
    }
    for(int x=4; x<9; x++) {
        int turn = rand()%12-5;
        for(int j=0; j<18; j++){
            posit[j]+=turn*moves[x][j];
        }
        bool clockwise = ( turn >= 0 );
        [scr appendFormat:@"%@%d%@ ", [clkTurns objectAtIndex:x], ABS(turn), (clockwise?@"+":@"-")];
        //scramble.append( turns[x] + turn + (clockwise?"+":"-") + " ");
    }
    for(int j=0; j<18; j++){
        posit[j]%=12;
        while( posit[j]<=0 ) posit[j]+=12;
    }
    bool isFirst = true;
    for(x=0; x<4; x++) {
        pegs[clkIdx[x]] = rand()%2;
        if (pegs[clkIdx[x]] == 0) {
            [scr appendFormat:@"%@%@", (isFirst?@"":@" "), [clkTurns objectAtIndex:x]];
            //scramble.append((isFirst?"":" ")+turns[x]);
            isFirst = false;
        }
    }
    return scr;
}

- (NSString *)scrambleOld:(bool) concise {
    int seq[14];
    int i,j;
    for(i=0;i<18;i++)posit[i]=0;
    for(i=0; i<14; i++){
        seq[i] = rand()%12-5;
    }
    for( i=0; i<14; i++){
        for( j=0; j<18; j++){
            posit[j]+=seq[i]*movesOld[i][j];
        }
    }
    for( j=0; j<18; j++){
        posit[j]%=12;
        while( posit[j]<=0 ) posit[j]+=12;
    }
    NSMutableString *scr = [NSMutableString string];
    if(concise) {
        for(i=0; i<4; i++)
            [scr appendFormat:@"(%d, %d) / ", seq[i], seq[i+4]];
        for(i=8; i<14; i++)
            [scr appendFormat:@"(%d) / ", seq[i]];
    } else {
        [scr appendFormat:@"%@%d%@%d%@", @"UUdd u=", seq[0], @",d=", seq[4], @" / "];
        [scr appendFormat:@"%@%d%@%d%@", @"dUdU u=", seq[1], @",d=", seq[5], @" / "];
        [scr appendFormat:@"%@%d%@%d%@", @"ddUU u=", seq[2], @",d=", seq[6], @" / "];
        [scr appendFormat:@"%@%d%@%d%@", @"UdUd u=", seq[3], @",d=", seq[7], @" / "];
        [scr appendFormat:@"%@%d%@", @"dUUU u=", seq[8], @" / "];
        [scr appendFormat:@"%@%d%@", @"UdUU u=", seq[9], @" / "];
        [scr appendFormat:@"%@%d%@", @"UUUd u=", seq[10], @" / "];
        [scr appendFormat:@"%@%d%@", @"UUdU u=", seq[11], @" / "];
        [scr appendFormat:@"%@%d%@", @"UUUU u=", seq[12], @" / "];
        [scr appendFormat:@"%@%d%@", @"dddd d=", seq[13], @" / "];
    }
    for(int i=0; i<4; i++){
        pegs[i] = rand()%2;
        if(pegs[i]==0)[scr appendString:@"U"];
        else [scr appendString:@"d"];
    }
    return scr;
}

- (NSString *)scrambleEpo {
    int seq[14];
    int i,j;
    for(i=0;i<18;i++)posit[i]=0;
    for(i=0; i<14; i++){
        seq[i] = rand()%12-5;
    }
    for( i=0; i<14; i++){
        for( j=0; j<18; j++){
            posit[j]+=seq[i]*movesOld[epoIdx[i]][j];
        }
    }
    for( j=0; j<18; j++){
        posit[j]%=12;
        while( posit[j]<=0 ) posit[j]+=12;
    }
    NSMutableString *scr = [NSMutableString string];
    [scr appendFormat:@"%@%d%@", @"UUUU u=", seq[0], @" / "];
    [scr appendFormat:@"%@%d%@", @"dUUU u=", seq[1], @" / "];
    [scr appendFormat:@"%@%d%@%d%@", @"dUdU u=", seq[2], @",d=", seq[3], @" / "];
    [scr appendFormat:@"%@%d%@", @"UUdU u=", seq[4], @" / "];
    [scr appendFormat:@"%@%d%@%d%@", @"UUdd u=", seq[0], @",d=", seq[4], @" / "];
    [scr appendFormat:@"%@%d%@", @"UUUd u=", seq[0], @" / "];    
    [scr appendFormat:@"%@%d%@%d%@", @"UdUd u=", seq[3], @",d=", seq[7], @" / "];
    [scr appendFormat:@"%@%d%@", @"UdUU u=", seq[9], @" / "];
    [scr appendFormat:@"%@%d%@%d%@", @"ddUU u=", seq[2], @",d=", seq[6], @" / "];
    [scr appendFormat:@"%@%d%@", @"dddd d=", seq[13], @" / "];
    for(int i=0; i<4; i++){
        pegs[i] = rand()%2;
        if(pegs[i]==0)[scr appendString:@"U"];
        else [scr appendString:@"d"];
    }
    return scr;
}
@end
