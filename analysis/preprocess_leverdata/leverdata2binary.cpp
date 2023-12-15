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

/**
 * The function saves a vector of doubles to a binary file.
 * 
 * @param data_to_save A reference to a vector of doubles that contains the data to be saved to the
 * binary file.
 * @param filename The filename parameter is a string that represents the name of the file where the
 * vector data will be saved.
 * 
 * @return an integer value of 0.
 */
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

/**
 * The function "slice_double_vec" takes a vector of doubles, a start index, and an end index, and
 * returns a new vector containing a slice of the original vector from the start index to the end
 * index.
 * 
 * @param data A vector of double values that we want to slice.
 * @param start_i The starting index of the slice. It represents the position in the vector where the
 * slice should begin.
 * @param end_i The parameter "end_i" represents the index of the last element (exclusive) that you
 * want to include in the sliced vector.
 * 
 * @return The function `slice_double_vec` returns a vector of type `double`.
 */
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

/**
 * This C++ function reads lever data from a MATLAB .mat file, processes it, and saves trials to binary
 * files.
 */
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
    // Check leverdata taken from .mat file
    cout << "leverdata from .mat size: " << (matvar->dims[0]) << "," << (matvar->dims[0]) << endl;
    cout << "leverdata from .mat rank: " << (matvar->rank) << endl;

    // Check if the variable is a double 1D array (vector) because MATLAB for some reason saves leverdata as MAT_C_DOUBLE
    if ((matvar->rank) == 2 && (matvar->dims[1]) == 1 && (matvar->class_type) == MAT_C_DOUBLE) {
        double *data = static_cast<double *>(matvar->data); // Cast to the appropriate data type
        size_t numElements = matvar->dims[0]; // Number of elements in the vector

        // Create a C++ vector and copy data from the MATIO array
        vector<double> leverdata(data, data + numElements);
        cout << "leverdata vector size: " << leverdata.size() << endl;

        // erase empty, unused rows at the end of leverdata that are equal to 0
        leverdata.erase(remove(leverdata.begin(), leverdata.end(), 0), leverdata.end());
        cout << "leverdata vector with unused rows taken out size: " << leverdata.size() << endl;

        // Save the entire leverdata vector to a binary file
        save_double_vec_to_bin(leverdata, string(output_folder)+"full.bin");
        
        // Break leverdata vector into trial+subsequent ITI chunks ==================================
        // initialize some variables first
        double previous_lever_value = leverdata[beginning_samples_to_skip];
        double lever_value = leverdata[beginning_samples_to_skip];
        int previous_switch_i = beginning_samples_to_skip;
        int num_switches = 0;
        // iterating through lever values...
        for (size_t i = beginning_samples_to_skip; i < leverdata.size(); ++i) {
            lever_value = leverdata[i];
            
            // check if a jump from >2000 to <2000 happened between previous lever value and current lever value
            if (lever_value < 2000 && previous_lever_value > 2000) {
                // switched from 2500 to 500
                cout << "finished a trialITI: " << i << " index:" << num_switches << \
                " trialITI length: " << i - previous_switch_i << " samples = ~" << (i - previous_switch_i)/5888 << "s" << endl;
                
                // Get this trial+subsequent ITI as a separate chunk from the full leverdata
                vector<double> leverdata_chunk = slice_double_vec(leverdata, previous_switch_i, i);
                // Rescale ITI lever values back down to 0-1023 from 2000-2023
                for (size_t j = 0; j < leverdata_chunk.size(); ++j) {
                    if (leverdata_chunk[j] > 2000) {
                        leverdata_chunk[j] = leverdata_chunk[j] - 2000;
                    }
                }

                // save it to a .bin file to be read in python later
                save_double_vec_to_bin(leverdata_chunk, \
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

matvar = matio.matvarread(matfp, "leverdata")
if matvar is None:
    print("Error reading variable 'leverdata' from MAT file")
    exit(1)
print("leverdata from .mat size:", matvar.dims[0], ",", matvar.dims[0])
print("leverdata from .mat rank:", matvar.rank)

if matvar.rank == 2 and matvar.dims[1] == 1 and matvar.class_type == matio.MAT_C_DOUBLE:
    data = matvar.data
    numElements = matvar.dims[0]

    leverdata = np.array(data[:numElements])
    print("leverdata vector size:", leverdata.size)

    leverdata = leverdata[leverdata != 0]
    print("leverdata vector with unused rows taken out size:", leverdata.size)

    save_double_vec_to_bin(leverdata, "./Data/AnB1/B1_20231030_leverdata.bin")

    previous_lever_value = leverdata[beginning_samples_to_skip]
    lever_value = leverdata[beginning_samples_to_skip]
    previous_switch_i = beginning_samples_to_skip
    num_switches = 0
    for i in range(beginning_samples_to_skip, len(leverdata)):
        lever_value = leverdata[i]
        if lever_value < 2000 and previous_lever_value > 2000:
            print("finished a trialITI:", i, "trialITI length:", i - previous_switch_i, "samples = ~", (i - previous_switch_i)/5000, "s")
            leverdata_chunk = slice_double_vec(leverdata, previous_switch_i, i)
            leverdata_chunk[leverdata_chunk > 2000] -= 2000
            save_double_vec_to_bin(leverdata_chunk, "./Data/AnB1/B1_20231030_trial" + str(num_switches) + ".bin")
            num_switches += 1
            previous_switch_i = i
        previous_lever_value = lever_value
    print("total switches:", num_switches)
else:
    print("The variable is not a 1D array of type double.")

matio.matvarfree(matvar)
matio.matclose(matfp)
*/