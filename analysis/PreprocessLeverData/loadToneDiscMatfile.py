from scipy import io

def loadToneDiscMatfile(tone_discriminiation_matfile):
    '''
    load ToneDisc .mat file
    '''
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

    return params, response, respMTX, MTXTrialType, num_trials