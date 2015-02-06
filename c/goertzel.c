/* -*- c-file-style:"stroustrup"; indent-tabs-mode: nil -*- */

#include "goertzel.h"

#include <math.h>


struct GoertzelFilter makeGoertzelFilter(double f, double fs)
{
    struct GoertzelFilter rslt;
    rslt.f = f;
    rslt.fs = fs;
    rslt.koef = GoertzelFilter_koef(f, fs);
    GoertzelFilter_Reset(&rslt);

    return rslt;
}

    
void GoertzelFilter_Reset(struct GoertzelFilter *pf)
{
    pf->vn._1 = pf->vn._2 = 0.0;
}


struct GoertzelFilter_Vn GoertzelFilter_kernel(double sample[], size_t n, double k, struct GoertzelFilter_Vn vn)
{
    size_t i;
    for (i = 0; i < n; ++i) {
        double t = k * vn._1 - vn._2 + sample[i];
        vn._2 = vn._1;
        vn._1 = t;
    }
    return vn;
}
    

double GoertzelFilter_power(double koef, struct GoertzelFilter_Vn vn, int n)
{
    double rslt = vn._1*vn._1 + vn._2*vn._2 - koef * vn._1 * vn._2;
    if (rslt < EPSILON) {
        rslt = EPSILON;
    }
    return rslt / (n*n);
}
 

double calc_dBm(double power)
{
    return 10 * log10(2 * power * 1000 / 600.0);
}
    

double GoertzelFilter_koef(double f, double fs)
{
    return 2 * cos(2 * M_PI * f / fs);
}
    

double GoertzelFilter_process(struct GoertzelFilter *pGF, double samples[], size_t n)
{
    pGF->vn = GoertzelFilter_kernel(samples, n, pGF->koef, pGF->vn);
    return GoertzelFilter_power(pGF->koef, pGF->vn, n);
}

