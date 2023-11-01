//g++ -I/opt/homebrew/opt/libmatio/include/ -L/opt/homebrew/Cellar/libmatio/1.5.24/lib/ -o 0a_main 0a_main.cpp -lmatio

#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
#include <matio.h> // for reading .mat files into C

using namespace std;

int save_double_vec_to_bin(const vector<double> &data_to_save, string filename) {
    ofstream outputFile(filename, ios::binary);
    if (outputFile.is_open()) {
        outputFile.write(reinterpret_cast<const char*>(data_to_save.data()), data_to_save.size() * sizeof(double));
        outputFile.close();
        cout << "vector saved to .bin file " << filename << endl;
    } else {
        cerr << "Error opening .bin file " << filename << endl;
    }

    return 0;
}

vector<double> slice_double_vec(const vector<double> &data, int start_i, int end_i) {
    if (start_i < 0) {
        start_i = 0;
    }
    if (end_i > data.size()) {
        end_i = data.size();
    }
    if (start_i > end_i) {
        return vector<double>();
    }
    return vector<double>(data.begin() + start_i, data.begin() + end_i);
}

int main() {
    int beginning_samples_to_skip = 15460;

    // Initialize MATIO library
    mat_t *matfp;
    matvar_t *matvar;

    // Open .mat file
    matfp = Mat_Open("./Data/AnB1/B1_20231030.mat", MAT_ACC_RDONLY);
    if ( nullptr == matfp ) {
       cerr << "Error opening MAT file" << endl;
       return EXIT_FAILURE;
    }

    // Read .mat file
    matvar = Mat_VarRead(matfp, "lever_data");
    if ( nullptr == matvar ) {
       cerr << "Error reading variable 'lever_data' from MAT file" << endl;
       return EXIT_FAILURE;
    }
    cout << "lever_data from .mat size: " << (matvar->dims[0]) << "," << (matvar->dims[0]) << endl;
    cout << "lever_data from .mat rank: " << (matvar->rank) << endl;

    // Check if the variable is a double 1D array (vector) because MATLAB for some reason saves lever_data as MAT_C_DOUBLE
    if ((matvar->rank) == 2 && (matvar->dims[1]) == 1 && (matvar->class_type) == MAT_C_DOUBLE) {
        double *data = static_cast<double *>(matvar->data); // Cast to the appropriate data type
        size_t numElements = matvar->dims[0]; // Number of elements in the vector

        // Create a C++ vector and copy data from the MATIO array
        vector<double> lever_data(data, data + numElements);
        cout << "lever_data vector size: " << lever_data.size() << endl;

        // erase empty, unused rows at the end of lever_data that are equal to 0
        lever_data.erase(remove(lever_data.begin(), lever_data.end(), 0), lever_data.end());
        cout << "lever_data vector with unused rows taken out size: " << lever_data.size() << endl;

        // Save the entire lever_data vector to a binary file
        save_double_vec_to_bin(lever_data, "./Data/AnB1/B1_20231030_lever_data.bin");
        
        // break lever_data vector into trial and ITI chunks
        double previous_lever_value = lever_data[beginning_samples_to_skip];
        double lever_value = lever_data[beginning_samples_to_skip];
        int previous_switch_i = beginning_samples_to_skip;
        int num_switches = 0;

        for (size_t i = beginning_samples_to_skip; i < lever_data.size(); ++i) {

            lever_value = lever_data[i];
            
            if (lever_value < 2000 && previous_lever_value > 2000) {
                // switched from 2500 to 500
                cout << "finished a trialITI: " << i << \
                " trialITI length: " << i - previous_switch_i << " samples = ~" << (i - previous_switch_i)/5000 << "s" << endl;
                
                vector<double> lever_data_chunk = slice_double_vec(lever_data, previous_switch_i, i);
                save_double_vec_to_bin(lever_data_chunk, \
                "./Data/AnB1/B1_20231030_trial"+to_string(num_switches)+".bin");

                num_switches = num_switches + 1;
                previous_switch_i = i;
            }

            previous_lever_value = lever_value;
        }

        cout << "total switches: " << num_switches << endl;

    } else {
        cerr << "The variable is not a 1D array of type double." << endl;
    }
    
    // Free MATIO resources
    Mat_VarFree(matvar);
    Mat_Close(matfp);

    return EXIT_SUCCESS;
}