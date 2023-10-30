#include <iostream>
#include <random>
#include <vector>
#include <cmath>
#include <cstdlib> // for input args

#include "Eigen/Dense" // matrix ops library

using namespace std;
using Eigen::MatrixXd;
using Eigen::VectorXd;

static double function_to_integrate(VectorXd x_vec, int d) {
    // f(x) = 2^(-d) * sum of x_i^2
    double sumd;
    for (int i = 0; i < d; ++i) {
    double x_i = x_vec(i);
    sumd = sumd + pow(x_i, 2);
    }
    return pow(2, -1 * d) * sumd;
}


static double g_fcn(VectorXd x_vec, int d) {
    // check if within Volume V
    bool within_V = true;
     for (int i = 0; i < d; ++i) {
        double x_i = x_vec(i);
        if (x_i >= 1 || x_i <= -1) {
            within_V = false;
        }
     }
    
    if (within_V) {
        return function_to_integrate(x_vec, d);
    } else {
        return 0;
    }
}


static double d_dim_normal_pdf(VectorXd x_vec, int d, double std) {
    // supposed to be 1/ (sqrt(2pi)sigma)^d  *  exp(-1/ 2sigma^2 * x^Tx)

    MatrixXd Cov = pow(std, 2) * MatrixXd::Identity(d,d);
    
    // coeff part; M_PI is pi
    double coeff = 1 / sqrt( pow(2*M_PI, d) * pow(std, 2*d));
    
    // exp part
    double exponent = -0.5 * x_vec.transpose() * Cov.inverse() * x_vec;

    return coeff*exp(exponent);
}


double run_4c(VectorXd x_j) {
    // MC method
    VectorXd x_j;
    double sum = 0;
    for (int j = 0; j < M; ++j) {
        x_j = sample_d_dim_normal(d, mean, std); // Generate x_j
        sum = sum + (g_fcn(x_j, d) / d_dim_normal_pdf(x_j, d, std)); // Estimator sum
        
        //cout << x_j << " gave pdf: " << d_dim_normal_pdf(x_j, d, std) << endl;

    }
    double mc_integral = sum/M; // rest of the estimator

    return mc_integral;
}

// for look going through each element of lever_data, if past 5 elements are <2000 and current_element is >2000, then this is a tStart off

