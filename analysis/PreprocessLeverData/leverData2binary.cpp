//g++ -I/opt/homebrew/opt/libmatio/include/ -L/opt/homebrew/Cellar/libmatio/1.5.24/lib/ -o 0a_main 0a_main.cpp -lmatio

#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
#include <string>
#include <sys/types.h>
#include <sys/stat.h>

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

int main(int argc, char** argv) {
    // Inputs; argv[0] is file name
    char* output_folder = argv[1]; // the output folder where the binaries will be saved e.g. ./Data/AnB1/B1_20231030/
    char* matlab_filename = argv[2]; // the lever data .mat filename e.g. ./Data/AnB1/B1_20231030.mat
    int beginning_samples_to_skip = atoi(argv[3]); // number of beginning samples to skip

    // Create output folder directory
    mkdir(output_folder, 0777);

    // Initialize MATIO library
    mat_t *matfp;
    matvar_t *matvar;

    // Open .mat file
    matfp = Mat_Open(matlab_filename, MAT_ACC_RDONLY);
    if ( nullptr == matfp ) {
       cerr << "Error opening LeverData MAT file" << endl;
       return EXIT_FAILURE;
    }

    // Read .mat file
    matvar = Mat_VarRead(matfp, "lever_data");
    if ( nullptr == matvar ) {
       cerr << "Error reading variable 'lever_data' from MAT file" << endl;
       return EXIT_FAILURE;
    }
    // Check lever_data taken from .mat file
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
        save_double_vec_to_bin(lever_data, string(output_folder)+"full.bin");
        
        // Break lever_data vector into trial+subsequent ITI chunks ==================================
        // initialize some variables first
        double previous_lever_value = lever_data[beginning_samples_to_skip];
        double lever_value = lever_data[beginning_samples_to_skip];
        int previous_switch_i = beginning_samples_to_skip;
        int num_switches = 0;
        // iterating through lever values...
        for (size_t i = beginning_samples_to_skip; i < lever_data.size(); ++i) {
            lever_value = lever_data[i];
            
            // check if a jump from >2000 to <2000 happened between previous lever value and current lever value
            if (lever_value < 2000 && previous_lever_value > 2000) {
                // switched from 2500 to 500
                cout << "finished a trialITI: " << i << \
                " trialITI length: " << i - previous_switch_i << " samples = ~" << (i - previous_switch_i)/5888 << "s" << endl;
                
                // Get this trial+subsequent ITI as a separate chunk from the full lever_data
                vector<double> lever_data_chunk = slice_double_vec(lever_data, previous_switch_i, i);
                // Rescale ITI lever values back down to 0-1023 from 2000-2023
                for (size_t j = 0; j < lever_data_chunk.size(); ++j) {
                    if (lever_data_chunk[j] > 2000) {
                        lever_data_chunk[j] = lever_data_chunk[j] - 2000;
                    }
                }

                // save it to a .bin file to be read in python later
                save_double_vec_to_bin(lever_data_chunk, \
                string(output_folder)+"trial"+to_string(num_switches)+".bin");

                // keep track of total num_switchess
                // a switch is when lever values jump from >2000 to <2000 since this should happen every time tStart is turned to HIGH again
                num_switches = num_switches + 1;

                // note the lever value index which will become the starting index for the next chunk
                previous_switch_i = i;
            }

            // save current lever value to previous lever value so comparisons can be made
            previous_lever_value = lever_value;
        }
        // ===========================================

        // at the end, print out the total number of switches detected. This should align with the number of trials
        cout << "total switches/trials detected: " << num_switches << endl;

    } else {
        // uh.
        cerr << "The variable is not a 1D array of type double." << endl;
    }
    
    // Free up MATIO resources
    Mat_VarFree(matvar);
    Mat_Close(matfp);

    return EXIT_SUCCESS;
}

/*
Equivalent python program for Giselle:

import numpy as np
import struct

def save_double_vec_to_bin(data_to_save, filename):
    with open(filename, 'wb') as outputFile:
        outputFile.write(struct.pack('d'*len(data_to_save), *data_to_save))
    print("vector saved to .bin file", filename)

def slice_double_vec(data, start_i, end_i):
    if start_i < 0:
        start_i = 0
    if end_i > len(data):
        end_i = len(data)
    if start_i > end_i:
        return []
    return data[start_i:end_i]

beginning_samples_to_skip = 15460

matfp = matio.matopen("./Data/AnB1/B1_20231030.mat", "r")
if matfp is None:
    print("Error opening MAT file")
    exit(1)

matvar = matio.matvarread(matfp, "lever_data")
if matvar is None:
    print("Error reading variable 'lever_data' from MAT file")
    exit(1)
print("lever_data from .mat size:", matvar.dims[0], ",", matvar.dims[0])
print("lever_data from .mat rank:", matvar.rank)

if matvar.rank == 2 and matvar.dims[1] == 1 and matvar.class_type == matio.MAT_C_DOUBLE:
    data = matvar.data
    numElements = matvar.dims[0]

    lever_data = np.array(data[:numElements])
    print("lever_data vector size:", lever_data.size)

    lever_data = lever_data[lever_data != 0]
    print("lever_data vector with unused rows taken out size:", lever_data.size)

    save_double_vec_to_bin(lever_data, "./Data/AnB1/B1_20231030_lever_data.bin")

    previous_lever_value = lever_data[beginning_samples_to_skip]
    lever_value = lever_data[beginning_samples_to_skip]
    previous_switch_i = beginning_samples_to_skip
    num_switches = 0
    for i in range(beginning_samples_to_skip, len(lever_data)):
        lever_value = lever_data[i]
        if lever_value < 2000 and previous_lever_value > 2000:
            print("finished a trialITI:", i, "trialITI length:", i - previous_switch_i, "samples = ~", (i - previous_switch_i)/5000, "s")
            lever_data_chunk = slice_double_vec(lever_data, previous_switch_i, i)
            lever_data_chunk[lever_data_chunk > 2000] -= 2000
            save_double_vec_to_bin(lever_data_chunk, "./Data/AnB1/B1_20231030_trial" + str(num_switches) + ".bin")
            num_switches += 1
            previous_switch_i = i
        previous_lever_value = lever_value
    print("total switches:", num_switches)
else:
    print("The variable is not a 1D array of type double.")

matio.matvarfree(matvar)
matio.matclose(matfp)
*/