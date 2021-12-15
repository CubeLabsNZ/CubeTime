//
//  SQ1.m
//  DCTimer scramblers
//
//  Created by MeigenChou on 13-3-3.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "SQ1.h"
#import "stdlib.h"
#import "time.h"

@implementation SQ1

- (id) init {
    if(self = [super init]) {
        srand((unsigned)time(0));
    }
    return self;
}

- (bool)sq1_domove:(int[])p x:(int)x y:(int)y {
    int i, temp;
    if (x == 7) {
        for (i=0; i<6; i++) {
            temp = p[i+6];
            p[i+6] = p[i+12];
            p[i+12] = temp;
        }
        return true;
    } else {
        if (p[(17-x)%12]!=0 || p[(11-x)%12]!=0 || p[12+(17-y)%12]!=0 || p[12+(11-y)%12]!=0) {
            return false;
        } else {
            // do the move itself
            int px[12], py[12];
            for(int j=0;j<12;j++)px[j]=p[j];
            for(int j=12;j<24;j++)py[j-12]=p[j];
            for (i=0; i<12; i++) {
                p[i] = px[(12+i-x)%12];
                p[i+12] = py[(12+i-y)%12];
            }
            return true;
        }
    }
}

- (void)sq1_getseq:(NSMutableArray *)seq type:(int)type len:(int)len {
    int p[] = {1,0,0,1,0,0,1,0,0,1,0,0,0,1,0,0,1,0,0,1,0,0,1,0};
    int cnt = 0;
    while (cnt < len) {
        int x = rand() % 12 - 5;
        int y = (type==2) ? 0 : rand() % 12 - 5;
        int size = (x==0?0:1) + (y==0?0:1);
        if ((cnt + size <= len || type != 1) && (size > 0 || cnt == 0)) {
            if ([self sq1_domove:p x:x y:y]) {
                if (type == 1) cnt += size;
                if (size > 0) {
                    NSArray *m = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:x], [NSNumber numberWithInt:y], nil];
                    //seq[seql][0] = x;
                    //seq[seql++][1] = y;
                    [seq addObject:m];
                }
                if (cnt < len || type != 1) {
                    cnt++;
                    NSArray *n = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:7], [NSNumber numberWithInt:0], nil];
                    //seq[seql][0] = 7;
                    //seq[seql++][1] = 0;
                    [seq addObject:n];
                    //seq[n][seql++] = new byte[]{7,0};
                    [self sq1_domove:p x:7 y:0];
                }
            }
        }
    }
}

- (NSString *) sq1_scramble: (int)type {
    NSMutableArray *seq = [[NSMutableArray alloc] init];//int seq[40][2];
    int i, len = type==1?40:20;
    //byte[] k;
    [self sq1_getseq:seq type:type len:len];
    NSMutableString *s = [NSMutableString string];
    for(i=0; i<seq.count; i++){
        //k=seq[0][i];
        if([[[seq objectAtIndex:i] objectAtIndex:0] intValue] == 7) {
            [s appendString:@"/ "];
        } else {
            [s appendFormat:@"(%d,%d) ", [[[seq objectAtIndex:i] objectAtIndex:0] intValue], [[[seq objectAtIndex:i] objectAtIndex:1] intValue]];
            //s.append("(" + seq[0][i][0] + "," + seq[0][i][1] + ") ");
        }
    }
    return s;
}

- (NSString *) ssq1t_scramble {
    NSMutableArray *seq = [[NSMutableArray alloc] init];
    NSMutableArray *seq1 = [[NSMutableArray alloc] init];
    int i;
    [self sq1_getseq:seq type:0 len:20];
    [self sq1_getseq:seq1 type:0 len:20];
    NSMutableString *u = [NSMutableString string];
    //int[][] temp={{0,0}};
    int st = 0, st1 = 0;
    if ([[[seq objectAtIndex:0] objectAtIndex:0] intValue] == 7) {
        st = 1;
    }
    if ([[[seq1 objectAtIndex:0] objectAtIndex:0] intValue]==7) {
        st1 = 1;
    }
    for(i=0;i<20;i++){
        [u appendFormat:@"(%d,%d,%d,%d) / ", [[[seq objectAtIndex:2*i+st] objectAtIndex:0] intValue], [[[seq1 objectAtIndex:2*i+st] objectAtIndex:0] intValue], [[[seq1 objectAtIndex:2*i+st] objectAtIndex:1] intValue], [[[seq objectAtIndex:2*i+st] objectAtIndex:1] intValue]];
        //u.append("(" + s[2*i][0] + "," + t[2*i][0] + "," + t[2*i][1] + "," + s[2*i][1] + ") / ");
    }
    return u;
}

@end
