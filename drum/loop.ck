BPM tempo;

SndBuf loop => LPF filter => NRev reverb => Gain master => dac;

me.dir(-1) + "audio/drums/loop.wav" => loop.read;
loop.samples() => loop.pos;

120 => Std.mtof => filter.freq;

.05 => reverb.mix;

///

float masterVolume;
float filterFreq;
float reverbMix;

///

function void modulateVolume(Gain master, dur modTime, float min, float max, float aps, int direction) {
    aps => float step;
    max - min => float range;
    range / aps => float sit;

    if (!direction) {
        min => masterVolume;
    }
    else {
        max => masterVolume;
        aps * -1 => step;
    }

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

function void modulateLPFFReq(LPF filter, dur modTime, float min, float max, float aps, int direction) {
    aps => float step;
    max - min => float range;
    (range / aps) * 2 => float sit;

    if (!direction) {
        min => filterFreq;
    }
    else {
        max => filterFreq;
    }

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

function void modulateReverbMix(NRev reverb, dur modTime, float min, float max, float aps, int direction) {
    aps => float step;
    max - min => float range;
    (range / aps) * 2 => float sit;

    if (!direction) {
        min => reverbMix;
    }
    else {
        max => reverbMix;
    }

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
        0 => loop.pos;
        tempo.note => now;
    }
}

///

Shred loopShred, masterVolumeShred, filterFreqShred, reverbMixShred;

tempo.note * 8 => now;
spork ~ runLoop() @=> loopShred;
spork ~ modulateVolume(master, tempo.note * 8, .001, 1.1, 0.001, 0) @=> masterVolumeShred;
spork ~ modulateLPFFReq(filter, (tempo.note * 6) / 3, Std.mtof(65), Std.mtof(80), 2.0, 0) @=> filterFreqShred;
tempo.note * 8 => now;

Machine.remove(masterVolumeShred.id());
Machine.remove(filterFreqShred.id());
spork ~ modulateLPFFReq(filter, tempo.note * 4, Std.mtof(65), Std.mtof(100), 2.0, 0) @=> filterFreqShred;
tempo.note * 8 => now;

Machine.remove(filterFreqShred.id());
spork ~ modulateLPFFReq(filter, (tempo.note * 8) / 3, Std.mtof(75), Std.mtof(120), 2.0, 0) @=> filterFreqShred;
tempo.note * 2 => now;
Machine.remove(filterFreqShred.id());
spork ~ modulateReverbMix(reverb, tempo.note * 2, .05, .1, 0.01, 0) @=> reverbMixShred;
tempo.note * 14 => now;

spork ~ modulateLPFFReq(filter, tempo.note * 12, Std.mtof(90), Std.mtof(120), 2.0, 0) @=> filterFreqShred;
tempo.note * 16 => now;

Machine.remove(filterFreqShred.id());
spork ~ modulateLPFFReq(filter, tempo.note * 8, Std.mtof(80), Std.mtof(120), 2.0, 0) @=> filterFreqShred;
tempo.note * 12 => now;  

Machine.remove(filterFreqShred.id());
Machine.remove(reverbMixShred.id());
spork ~ modulateVolume(master, tempo.note * 12, .001, 1.1, 0.001, 1) @=> masterVolumeShred;
spork ~ modulateLPFFReq(filter, tempo.note * 8, Std.mtof(70), Std.mtof(120), 2.0, 0) @=> filterFreqShred;
tempo.note * 12 => now;  

Machine.remove(masterVolumeShred.id());
Machine.remove(filterFreqShred.id());
Machine.remove(loopShred.id());
