//
//  Im.h
//  DCTimer Solvers
//
//  Created by MeigenChou on 13-2-18.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Im : NSObject

void initIm();

void set8Perm(int arr[], int idx);
int get8Perm(int arr[]);

void setComb(int arr[], int idx, int mask);
int getComb(int arr[], int mask);
int get8Comb(int arr[]);

void cir(int arr[], int a, int b, int c, int d);
void cir2(int arr[], int a, int b, int c, int d);
void cir3(int arr[], int a, int b);

int permToIdx(int p[], int len);
void idxToPerm(int p[], int idx, int l);

int evenPermToIdx(int p[], int len);
void idxToEvenPerm(int p[], int idx, int len);

int oriToIdx(int o[], int n, int len);
void idxToOri(int o[], int idx, int n, int len);

int zsOriToIdx(int o[], int n, int len);
void idxToZsOri(int o[], int idx, int n, int l);

int combToIdx(bool comb[], int k, int len);
void idxToComb(bool comb[], int idx, int k, int len);
@end
