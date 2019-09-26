BPM tempo;

SndBuf loop => LPF filter => NRev reverb => Gain master => dac;

me.dir(-1) + "audio/drums/loop.wav" => loop.read;
loop.samples() => loop.pos;

65 => Std.mtof => filter.freq;

.05 => reverb.mix;

0 => master.gain;

///

1.1 => float maxMasterVolume;

float masterVolume;
float filterFreq;
float reverbMix;

///

function void modulateVolume(Gain master, dur modTime, float min, float max, float aps) {
    aps => float step;
    max - min => float range;
    range / aps => float sit;

    master.gain() => masterVolume;

    while(true) {
        masterVolume => master.gain;
        step +=> masterVolume;

        if (masterVolume >= max) {
            aps * -1 => step;
        }
        else if (masterVolume <= min) {
            aps => step;
        }

        modTime / sit => now;
    }
}

function void modulateLPFFReq(LPF filter, dur modTime, float min, float max, float aps) {
    aps => float step;
    max - min => float range;
    (range / aps) * 2 => float sit;

    filter.freq() => filterFreq;

    while(true) {
        filterFreq => filter.freq;
        step +=> filterFreq;

        if (filterFreq >= max) {
            aps * -1 => step;
        }
        else if (filterFreq <= min) {
            aps => step;
        }

        modTime / sit => now;
    }
}

function void modulateReverbMix(NRev reverb, dur modTime, float min, float max, float aps) {
    aps => float step;
    max - min => float range;
    (range / aps) * 2 => float sit;

    reverb.mix() => reverbMix;

    while(true) {
        reverbMix => reverb.mix;
        step +=> reverbMix;

        if (reverbMix >= max) {
            aps * -1 => step;
        }
        else if (reverbMix <= min) {
            aps => step;
        }

        modTime / sit => now;
    }
}

//

function void runLoop() {    
    while(true) {
        for (0 => int part; part < 4; part++) {
            for (0 => int beat; beat < 8; beat++) {
                if (part != 3) {
                    0 => loop.pos;                
                    tempo.note => now;
                }
                else {
                    if (beat != 3 && beat != 7) {
                        0 => loop.pos;                
                        tempo.note => now;
                    }
                    else if (beat == 3) {    
                        if (Math.random2(0, 10) < 6) {
                            Math.random2(1, 2) => int repCount;

                            for (0 => int rep; rep < repCount; rep++) {
                                0 => loop.pos;
                                tempo.note / repCount => now;
                            }
                        }
                        else {
                            0 => loop.pos;
                            tempo.note / 2 => now;
                            loop.samples() * .25 => Std.ftoi => loop.pos;
                            tempo.note / 2 => now;
                        }
                    }
                    else {
                        for (0 => int rep; rep < 4; rep++) {
                            if (rep != 3) {
                                0 => loop.pos;                        
                                tempo.note / 4 => now;
                            }
                            else {                        
                                if (Math.random2(0, 1)) {
                                    loop.samples() / 2 => Std.ftoi => loop.pos;                            
                                    tempo.note / 4 => now;
                                }
                                else {
                                    0 => loop.pos;
                                    (tempo.note / 4) / 2 => now;
                                    loop.samples() / 2 => Std.ftoi => loop.pos;                            
                                    (tempo.note / 4) / 2 => now;
                                }
                            }                    
                        }
                    }
                }                
            }
        }
    }
}

///

Shred loopShred, masterVolumeShred, filterFreqShred, reverbMixShred;

tempo.note * 8 => now;
spork ~ runLoop() @=> loopShred;
spork ~ modulateVolume(master, tempo.note * 8, .001, maxMasterVolume, 0.001) @=> masterVolumeShred;
spork ~ modulateLPFFReq(filter, (tempo.note * 6) / 3, Std.mtof(65), Std.mtof(80), 2.0) @=> filterFreqShred;
tempo.note * 8 => now;

Machine.remove(masterVolumeShred.id());
Machine.remove(filterFreqShred.id());
spork ~ modulateLPFFReq(filter, tempo.note * 4, Std.mtof(70), Std.mtof(100), 2.0) @=> filterFreqShred;
tempo.note * 8 => now;

Machine.remove(filterFreqShred.id());
spork ~ modulateLPFFReq(filter, (tempo.note * 8) / 3, Std.mtof(75), Std.mtof(120), 2.0) @=> filterFreqShred;
tempo.note * 2 => now;
Machine.remove(filterFreqShred.id());
spork ~ modulateReverbMix(reverb, tempo.note * 2, .05, .1, 0.01) @=> reverbMixShred;
tempo.note * 14 => now;

spork ~ modulateLPFFReq(filter, tempo.note * 12, Std.mtof(90), Std.mtof(120), 2.0) @=> filterFreqShred;
tempo.note * 16 => now;

Machine.remove(filterFreqShred.id());
spork ~ modulateLPFFReq(filter, tempo.note * 8, Std.mtof(80), Std.mtof(120), 2.0) @=> filterFreqShred;
tempo.note * 12 => now;  

Machine.remove(filterFreqShred.id());
Machine.remove(reverbMixShred.id());
spork ~ modulateVolume(master, tempo.note * 12, 0.0, maxMasterVolume, 0.001) @=> masterVolumeShred;
spork ~ modulateLPFFReq(filter, tempo.note * 8, Std.mtof(70), Std.mtof(120), 2.0) @=> filterFreqShred;
tempo.note * 12 => now;  

Machine.remove(masterVolumeShred.id());
Machine.remove(filterFreqShred.id());
Machine.remove(loopShred.id());
