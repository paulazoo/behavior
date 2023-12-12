from scipy import io

def load_tonedisc_matfile(tone_discriminiation_matfile):
    """
    Loads a ToneDisc .mat file and returns params, data, 
    respMTX, MTXTrialType, and num_trials from the file.
    
    :param tone_discriminiation_matfile: The parameter "tone_discriminiation_matfile" is the file path
    to the ToneDisc .mat file that you want to load
    :return: the following variables:
    - params: a numpy array containing the parameters of the loaded .mat file
    - response: a numpy array containing the response data of the loaded .mat file
    - respMTX: a numpy array containing the response matrix from the response data
    - MTXTrialType: a numpy array containing the trial types from the parameters
    - num_trials: int number of trials
    """
    loaded_matfile = io.loadmat(tone_discriminiation_matfile)

    data = loaded_matfile['data'][0][0]
    params = data[0][0][0]
    response = data[1][0][0]

    respMTX = response[2]
    print("respMTX shape: "+str(respMTX.shape))

    MTXTrialType = params[16]
    print("MTXTrialType shape: "+str(MTXTrialType.shape))

    num_trials = respMTX.shape[0]
    print("number of trials: "+str(num_trials))

    return params, response, respMTX, MTXTrialType