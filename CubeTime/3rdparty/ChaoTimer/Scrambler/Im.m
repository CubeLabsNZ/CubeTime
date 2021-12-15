//
//  Im.m
//  DCTimer Solvers
//
//  Created by MeigenChou on 13-2-18.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "Im.h"

@implementation Im

int fact[13];
int Cnk[12][12];
bool iniim = false;

void initIm() {
    if(iniim) return;
    fact[0] = 1;
    for (int i=0; i<12; i++) {
        Cnk[i][0] = Cnk[i][i] = 1;
        fact[i+1] = fact[i] * (i+1);
        for (int j=1; j<i; j++) {
            Cnk[i][j] = Cnk[i-1][j-1] + Cnk[i-1][j];
        }
    }
    iniim = true;
}

void set8Perm(int arr[], int idx) {
    int val = 0x76543210;
    for (int i=0; i<7; i++) {
        int p = fact[7-i];
        int v = idx / p;
        idx -= v*p;
        v <<= 2;
        arr[i] = (val >> v) & 07;
        int m = (1 << v) - 1;
        val = (val & m) + ((val >> 4) & ~m);
    }
    arr[7] = val;
}

int get8Perm(int arr[]) {
    int idx = 0;
    int val = 0x76543210;
    for (int i=0; i<7; i++) {
        int v = arr[i] << 2;
        idx = (8 - i) * idx + ((val >> v) & 07);
        val -= 0x11111110 << v;
    }
    return idx;
}

void setComb(int arr[], int idx, int mask) {
    int r = 4, fill = 11, val = 0x123;
    int idxC = 494 - (idx & 0x1ff);
    int idxP = ((unsigned)idx >> (unsigned)9);
    for (int i=11; i>=0; i--) {
        if (idxC >= Cnk[i][r]) {
            idxC -= Cnk[i][r--];
            int p = fact[r & 3];
            int v = idxP / p << 2;
            idxP %= p;
            arr[i] = (int) (((val >> v) & 3) | mask);
            int m = (1 << v) - 1;
            val = (val & m) + ((val >> 4) & ~m);
        } else {
            if ((fill & 0xc) == mask) {
                fill -= 4;
            }
            arr[i] = (int) (fill--);
        }
    }
}

int getComb(int arr[], int mask) {
    int idxC = 0, idxP = 0, r = 4, val = 0x123;
    for (int i=11; i>=0; i--) {
        if ((arr[i] & 0xc) == mask) {
            int v = (arr[i] & 3) << 2;
            idxP = r * idxP + ((val >> v) & 0x0f);
            val -= 0x0111 >> (12-v);
            idxC += Cnk[i][r--];
        }
    }
    return idxP << 9 | (494 - idxC);
}

int get8Comb(int arr[]) {
	int idx = 0, r = 4;
	for (int i=0; i<8; i++) {
		if (arr[i] >= 4) {
			idx += Cnk[7-i][r--];
		}
	}
	return idx;
}

void cir(int arr[], int a, int b, int c, int d) {
    int temp=arr[a]; arr[a]=arr[b]; arr[b]=arr[c]; arr[c]=arr[d]; arr[d]=temp;
}

void cir2(int arr[], int a, int b, int c, int d) {
    int temp=arr[a]; arr[a]=arr[b]; arr[b]=temp;
    temp=arr[c]; arr[c]=arr[d]; arr[d]=temp;
}

void cir3(int arr[], int a, int b) {
    int temp=arr[a]; arr[a]=arr[b]; arr[b]=temp;
}

// permutation
int permToIdx(int p[], int len) {
    int idx = 0;
    for(int i=0; i<len-1; i++) {
        idx *= len-i;
        for(int j=i+1; j<len; j++) {
            if(p[i] > p[j]) idx++;
        }
    }
    return idx;
}

void idxToPerm(int p[], int idx, int l) {
    p[l-1] = 0;
    for(int i=l-2; i>=0; i--) {
        p[i] = idx % (l-i);
        idx /= l-i;
        for(int j=i+1; j<l; j++)
            if(p[j] >= p[i]) p[j]++;
    }
}

// even permutation
int evenPermToIdx(int p[], int len) {
    int index = 0;
    for (int i = 0; i < len - 2; i++) {
        index *= len - i;
        for (int j = i + 1; j < len; j++)
            if (p[i] > p[j]) index++;
    }
    return index;
}

void idxToEvenPerm(int p[], int idx, int len) {
    int sum = 0;
    p[len - 1] = 1;
    p[len - 2] = 0;
    for (int i = len - 3; i >= 0; i--) {
        p[i] = idx % (len - i);
        sum += p[i];
        idx /= len - i;
        for (int j = i + 1; j < len; j++)
            if (p[j] >= p[i]) p[j]++;
    }
    if (sum % 2 != 0) {
        int temp = p[len - 1];
        p[len - 1] = p[len - 2];
        p[len - 2] = temp;
    }
}

// orientation
int oriToIdx(int o[], int n, int len) {
    int index = 0;
    for (int i = 0; i < len; i++)
        index = n * index + o[i];
    return index;
}

void idxToOri(int o[], int idx, int n, int len) {
    for (int i = len - 1; i >= 0; i--) {
        o[i] = idx % n;
        idx /= n;
    }
}

// zero sum orientation
int zsOriToIdx(int o[], int n, int len) {
    int index = 0;
    for (int i = 0; i < len - 1; i++)
        index = n * index + o[i];
    return index;
}

void idxToZsOri(int o[], int idx, int n, int l) {
    o[l - 1] = 0;
    for (int i = l - 2; i >= 0; i--) {
        o[i] = idx % n;
        idx /= n;
        o[l - 1] += o[i];
    }
    o[l - 1] = (n - o[l - 1] % n) % n;
}

// combinations
int nChooseK(int n, int k) {
    int value = 1;
    for (int i = 0; i < k; i++) {
        value *= n - i;
    }
    for (int i = 0; i < k; i++) {
        value /= k - i;
    }
    return value;
}

int combToIdx(bool comb[], int k, int len) {
    int index = 0;
    for (int i = len - 1; i >= 0 && k > 0; i--) {
        if (comb[i]) {
            index += nChooseK(i, k--);
        }
    }
    return index;
}

void idxToComb(bool comb[], int idx, int k, int len) {
    //boolean[] combination = new boolean[length];
    for(int i=0; i<len; i++)comb[i] = false;
    for (int i = len - 1; i >= 0 && k >= 0; i--) {
        if (idx >= nChooseK(i, k)) {
            comb[i] = true;
            idx -= nChooseK(i, k--);
        }
    }
}
@end
