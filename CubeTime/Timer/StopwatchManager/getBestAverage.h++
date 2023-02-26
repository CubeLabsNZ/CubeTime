#ifndef getBestAverage_h
#define getBestAverage_h

#ifdef __cplusplus
extern "C" {
#endif
struct CalculatedAverageFragment {
    double average;
    int allSolves[]; // [accounted | trimmed]
};

const int* _Nonnull allSolvesPtr(const struct CalculatedAverageFragment* _Nonnull const cafPtr);

struct CalculatedAverageFragment getBestAverageOf(const int n, const int m, const int trim, const double a[_Nonnull]);
#ifdef __cplusplus
}
#endif

#endif /* getBestAverage_h */
