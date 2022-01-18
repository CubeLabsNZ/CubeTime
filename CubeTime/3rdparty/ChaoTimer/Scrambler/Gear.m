//
//  Gear.m
//  DCTimer solvers
//
//  Created by MeigenChou on 13-3-3.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "Gear.h"
#import "Im.h"
#import "stdlib.h"
#import "time.h"

@implementation Gear

char geCpm[24][3], geEpm[24][3], geEom[27][3];
char gePd[3][576];
int geseq[7];
NSArray *turnge, *suffge;

- (void) iniGear {
    int arr[4];
    for(int i = 0; i < 24; i++){
        for(int j = 0; j < 3; j++){
            idxToPerm(arr, i, 4);
            cir3(arr, 3, j);
            geCpm[i][j] = permToIdx(arr, 4);
        }
    }
    for(int i = 0; i < 24; i++){
        for(int j = 0; j < 3; j++){
            idxToPerm(arr, i, 4);
            switch(j){
				case 0: cir(arr, 0, 3, 2, 1); break;
				case 1: cir3(arr, 0, 1); break;
				case 2: cir3(arr, 1, 2); break;
            }
            geEpm[i][j] = permToIdx(arr, 4);
        }
    }
    //arr = new int[3];
    for(int i = 0; i < 27; i++){
        for(int j = 0; j < 3; j++){
            idxToOri(arr, i, 3, 3);
            arr[j] = (arr[j] + 1) % 3;
            geEom[i][j] = oriToIdx(arr, 3, 3);
        }
    }
    //int n;
    for (int i = 0; i < 3; i++) {
        for(int j = 1; j < 576; j++)gePd[i][j] = -1;
        gePd[i][0] = 0;
        for(int d = 0; d < 5; d++) {
            //n = 0;
            for(int j = 0; j < 576; j++)
                if(gePd[i][j] == d)
                    for (int k = 0; k < 3; k++) {
                        int p = j;
                        for (int m = 0; m < 11; m++) {
                            int e = p % 24;
                            p = p / 24;
                            p = geCpm[p][k];
                            e = geEpm[e][(k + i) % 3];
                            p = 24 * p + e;
                            if(gePd[i][p] == -1){
                                gePd[i][p] = d + 1;
                                //n++;
                            }
                        }
                    }
        }
    }
}

- (id) init {
    if(self = [super init]) {
        turnge = [[NSArray alloc] initWithObjects:@"U", @"R", @"F", nil];
        suffge = [[NSArray alloc] initWithObjects:@"'", @"2'", @"3'", @"4'", @"5'", @"6", @"5", @"4", @"3", @"2", @"", nil];
        [self iniGear];
        srand((unsigned)time(0));
    }
    return self;
}

- (BOOL) searchGear:(int) cp ep1:(int)ep1 ep2:(int)ep2 ep3:(int)ep3 eo:(int)eo d:(int)d l:(int)l {
    if (d == 0) return cp == 0 && ep1 == 0 && ep2 == 0 && ep3 == 0 && eo == 0;
    if (MAX(MAX(gePd[0][24 * cp + ep1], gePd[1][24 * cp + ep2]), gePd[2][24 * cp + ep3]) > d) return NO;
    for (int n = 0; n < 3; n++)
        if (n != l) {
            int cn = cp, e1n = ep1, e2n = ep2, e3n = ep3, en = eo;
            for (int m = 0; 11 > m; m++){
                cn = geCpm[cn][n]; e1n = geEpm[e1n][n]; e2n = geEpm[e2n][(n + 1) % 3];
                e3n = geEpm[e3n][(n + 2) % 3]; en = geEom[en][n];
                if ([self searchGear:cn ep1:e1n ep2:e2n ep3:e3n eo:en d:d-1 l:n]){
                    geseq[d] = n*12+m;//sb.insert(0, turn[n] + suff[m] + " ");
                    return YES;
                }
            }
        }
    return NO;
}

- (NSString *)scrGear {
    int cp = rand()%24;
    int ep[3];
    for(int i = 0; i < 3; i++){
        do ep[i] = rand()%24;
        while (gePd[i][24 * cp + ep[i]] < 0);
    }
    int eo = rand()%27;
    NSMutableString *s = [NSMutableString string];
    for (int d = 3; d<7; d++) {
        if([self searchGear:cp ep1:ep[0] ep2:ep[1] ep3:ep[2] eo:eo d:d l:-1]) {
            for(int i=1; i<=d; i++)
                [s appendFormat:@"%@%@ ", [turnge objectAtIndex:(geseq[i]/12)], [suffge objectAtIndex:(geseq[i]%12)]];
            return s;
        }
    }
    return @"";
}

@end
