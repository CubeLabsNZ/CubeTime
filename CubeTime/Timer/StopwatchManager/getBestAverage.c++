#include <iostream>
#include <map>
#include <vector>
#include "getBestAverage.h++"

using namespace std;

extern "C" {
const int* _Nonnull allSolvesPtr(const struct CalculatedAverageFragment* _Nonnull const cafPtr) {
    return &(cafPtr->allSolves)[0];
}

CalculatedAverageFragment getBestAverageOf(const int n, const int m, const int trim, const double a[_Nonnull]) {
    multimap<double, int> s;
    double best = 100;
    
    double sum = 0;
    
    for (int i = 0; i < m - 1; i++) {
        sum += a[i];
        s.emplace(a[i], i);
    }
    
    double minTrim = 0;
    double maxTrim = 0;
    
    int trimmedSolvesSize = trim*2;
    int accountedSolvesSize = m - (trimmedSolvesSize);
    
    CalculatedAverageFragment* res = (CalculatedAverageFragment*) alloca(sizeof(CalculatedAverageFragment) + sizeof(int) * m);

    int* accountedSolves = res->allSolves;
    int* trimmedSolves = res->allSolves + (accountedSolvesSize);
                                           
    
    for (int i = m - 1; i < n; i++) {
        sum += a[i];
        s.emplace(a[i], i);
        
        auto minItr = s.begin();
        auto maxItr = --s.end();
        
        for (int i = 0; i < trim; ++i) {
            minTrim += (*(minItr++)).first;
            maxTrim += (*(maxItr--)).first;
        }
        
        double avg = (double)(sum - minTrim - maxTrim) /(double) (m - 2*trim);
        
        if (avg < best) {
            auto minItr = s.begin(), maxItr = --s.end();
            for (int i = 0; i < trim; ++i) {
                trimmedSolves[2*i] = (*(minItr++)).second;
                trimmedSolves[2*i + 1] = (*(maxItr--)).second;
            }
            
            for (int i = 0; i < (m - trim); ++i)
                accountedSolves[i] = (*(minItr++)).second;
            
            
            best = avg;
        }
        
        sum -= a[i - m + 1];
        s.erase(s.find(a[i - m + 1]));
        
        minTrim = 0;
        maxTrim = 0;
    }
    
    res->average = best;
    
    for (int i = 0; i < m; i++) cout << res->allSolves[i] << " ";
    cout << endl;
    assert(res->allSolves == allSolvesPtr(res));
    
    cout << allSolvesPtr(res) << endl;
    
    return *res;
}
}
