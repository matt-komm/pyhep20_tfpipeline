import tensorflow as tf
import keras

def create_model(input_globalvars,input_cpf,input_npf,input_sv,nlabels):
    
    cpf = input_cpf
    for nfilters in [32,32,8]:
        cpf = keras.layers.Conv1D(nfilters,1,padding='same',activation='selu')(cpf)
        cpf = keras.layers.Dropout(0.1)(cpf)
    cpf = keras.layers.Flatten()(cpf)
    
    npf = input_npf
    for nfilters in [16,16,4]:
        npf = keras.layers.Conv1D(nfilters,1,padding='same',activation='selu')(npf)
        npf = keras.layers.Dropout(0.1)(npf)
    npf = keras.layers.Flatten()(npf)
    
    sv = input_sv
    for nfilters in [32,32,8]:
        sv = keras.layers.Conv1D(nfilters,1,padding='same',activation='selu')(sv)
        sv = keras.layers.Dropout(0.1)(sv)
    sv = keras.layers.Flatten()(sv)
    
    globalvars = input_globalvars
    features = keras.layers.Concatenate(axis=1)([cpf,npf,sv,globalvars])
    for nnodes in [200,100,100]:
        features = keras.layers.Dense(nnodes,activation='selu')(features)
        features = keras.layers.Dropout(0.1)(features)
    predicted_labels = keras.layers.Dense(nlabels)(features)
    
    model = keras.models.Model(
        inputs=[
            input_globalvars,
            input_cpf,
            input_npf,
            input_sv
        ],
        outputs=[predicted_labels]
    )
    
    return model
    
    
