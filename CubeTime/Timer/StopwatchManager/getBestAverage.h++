#ifndef getBestAverage_h
#define getBestAverage_h

#ifdef __cplusplus
extern "C" {
#endif
double getBestAverageOf(const int n,
                        const int m,
                        const int trim,
                        const double a[_Nonnull],
                        int accountedSolves[_Nonnull],
                        int trimmedSolves[_Nonnull]);
#ifdef __cplusplus
}
#endif

#endif /* getBestAverage_h */
