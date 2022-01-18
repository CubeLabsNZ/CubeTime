//
//  Skewb.m
//  DCTimer solvers
//
//  Created by MeigenChou on 13-2-20.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "Skewb.h"
#import "Im.h"
#import "stdlib.h"
#import "time.h"

@implementation Skewb
short skbFpm[360][4];
char skbCpm[12][4];
char skbCom[27][4];
char skbFcm[81][4];
char skbFd[360];
char skbCd[12][27][81];
NSArray *turnSkb;
NSArray *sufSkb;
int solSkb[12];
bool ini = false;

- (void)cyc:(int[])arr a:(int)a b:(int)b c:(int)c {
    int temp = arr[a];
    arr[a] = arr[b];
    arr[b] = arr[c];
    arr[c] = temp;
}

- (void)initSkb {
    if(ini)return;
    
    int arr2[6];
    // move tables
    for (int i = 0; i < 360; i++)
        for (int j = 0; j < 4; j++) {
            idxToEvenPerm(arr2, i, 6);
            switch(j){
				case 0: [self cyc:arr2 a:0 b:1 c:4]; break;
				case 1: [self cyc:arr2 a:0 b:3 c:2]; break;
				case 2: [self cyc:arr2 a:3 b:4 c:5]; break;
				case 3: [self cyc:arr2 a:1 b:2 c:5]; break;
            }
            skbFpm[i][j] = evenPermToIdx(arr2, 6);
        }
    
    int arr[4];
    for (int i = 0; i < 12; i++)
        for (int j = 0; j < 4; j++) {
            idxToEvenPerm(arr, i, 4);
            switch(j){
				case 0: [self cyc:arr a:0 b:2 c:1]; break;
				case 1: [self cyc:arr a:0 b:1 c:3]; break;
				case 2: [self cyc:arr a:1 b:2 c:3]; break;
				case 3: [self cyc:arr a:0 b:3 c:2]; break;
            }
            skbCpm[i][j] = evenPermToIdx(arr, 4);
        }
    
    for (int i = 0; i < 27; i++)
        for (int j = 0; j < 4; j++) {
            idxToZsOri(arr, i, 3, 4);
            switch(j){
				case 0: [self cyc:arr a:0 b:2 c:1]; arr[0] = (arr[0] + 2) % 3;
                    arr[1] = (arr[1] + 2) % 3; arr[2] = (arr[2] + 2) % 3; break;
				case 1: [self cyc:arr a:0 b:1 c:3]; arr[0] = (arr[0] + 2) % 3;
                    arr[1] = (arr[1] + 2) % 3; arr[3] = (arr[3] + 2) % 3; break;
				case 2: [self cyc:arr a:1 b:2 c:3]; arr[3] = (arr[3] + 2) % 3;
                    arr[1] = (arr[1] + 2) % 3; arr[2] = (arr[2] + 2) % 3; break;
				case 3: [self cyc:arr a:0 b:3 c:2]; arr[0] = (arr[0] + 2) % 3;
                    arr[3] = (arr[3] + 2) % 3; arr[2] = (arr[2] + 2) % 3; break;
            }
            skbCom[i][j] = zsOriToIdx(arr, 3, 4);
        }
    
    int ch[] = {0, 1, 3, 2};
    for (int i = 0; i < 81; i++)
        for (int j = 0; j < 4; j++) {
            idxToOri(arr, i, 3, 4);
            arr[ch[j]] = (arr[ch[j]] + 1) % 3;
            skbFcm[i][j] = oriToIdx(arr, 3, 4);
        }
    
    // distance table
    for (int i = 0; i < 360; i++)
        skbFd[i]=-1;
    for (int j = 0; j < 12; j++)
        for(int k = 0; k < 27; k++)
            for(int l = 0; l < 81; l++)
                skbCd[j][k][l] = -1;
    skbFd[0] = 0; skbCd[0][0][0] = 0;
    for(int depth = 0; depth < 5; depth++) {
        //nVisited = 0;
        for (int i = 0; i < 360; i++)
            if (skbFd[i] == depth)
                for (int m = 0; m < 4; m++) {
                    int p = i;
                    for(int n = 0; n < 2; n++){
                        p = skbFpm[p][m];
                        if (skbFd[p] == -1) {
                            skbFd[p] = depth + 1;
                            //nVisited++;
                        }
                    }
                }
    }
    
    for(int depth = 0; depth < 7; depth++) {
        //nVisited = 0;
        for (int j = 0; j < 12; j++)
            for (int k = 0; k < 27; k++)
                for (int l = 0; l< 81; l++)
                    if (skbCd[j][k][l] == depth)
                        for (int m = 0; m < 4; m++) {
                            int p = j, q = k, r = l;
                            for(int n = 0; n < 2; n++){
                                p = skbCpm[p][m];
                                q = skbCom[q][m];
                                r = skbFcm[r][m];
                                if (skbCd[p][q][r] == -1) {
                                    skbCd[p][q][r] = depth + 1;
                                    //nVisited++;
                                }
                            }
                        }
    }
    ini = true;
}

-(Skewb *) init {
    if(self = [super init]) {
        turnSkb = [[NSArray alloc] initWithObjects:@"L", @"R", @"D", @"B", nil];
        sufSkb = [[NSArray alloc] initWithObjects:@"'", @"", nil];
        //initSkb();
        srand((unsigned)time(0));
    }
    return self;
}

- (bool)search:(int)fp cp:(int)cp co:(int)co fco:(int)fco d:(int)d l:(int)l {
    if(d==0)return skbFd[fp] == 0 && skbCd[cp][co][fco] == 0;
    if(skbFd[fp] > d || skbCd[cp][co][fco] > d)return false;
    for(int k = 0; k < 4; k++)
        if(k != l){
            int p=fp, q=cp, r=co, s=fco;
            for(int m=0; m<2; m++){
                p=skbFpm[p][k]; q=skbCpm[q][k]; r=skbCom[r][k]; s=skbFcm[s][k];
                if([self search:p cp:q co:r fco:s d:d-1 l:k]) {
                    solSkb[d] = k<<1|m;
                    //sb.insert(0, turn[k]+suff[m]+" ");
                    return true;
                }
            }
        }
    return false;
}

- (NSString *)scrSkb {
    [self initSkb];
    
    int fp = rand()%360;
    int cp, co, fco;
    do{
        cp = rand()%12;
        co = rand()%27;
        fco = rand()%81;
    }
    while (skbCd[cp][co][fco] < 0);
    for (int depth = 0; depth < 12; depth++) {
        if([self search:fp cp:cp co:co fco:fco d:depth l:-1]) {
            NSMutableString *s = [NSMutableString string];
            for(int i=1; i<=depth; i++) {
                [s appendFormat:@"%@%@ ", [turnSkb objectAtIndex:(solSkb[i]>>1)], [sufSkb objectAtIndex:(solSkb[i]&1)]];
            }
            return s;
        }
    }
    return @"";
}
@end
