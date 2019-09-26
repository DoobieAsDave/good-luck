BPM tempo;

///

Gain mid;
Gain left, right;

SinOsc lfo;
lfo => SawOsc voice1 => left;
lfo => SawOsc voice2 => right;
lfo => SawOsc voice3 => left;
lfo => SawOsc voice4 => right;

LPF lpFilter;
SawOsc voice5 => lpFilter => mid;
SawOsc voice6 => lpFilter => mid;

ADSR adsr;
Chorus chorus;
NRev nReverb;
JCRev jcReverb;
Pan2 stereo;
mid => adsr => chorus => nReverb => stereo => dac;
left => adsr => chorus => nReverb => stereo => dac.left;
right => adsr => jcReverb => stereo => dac.right;

///

2.0 => lfo.freq => lfo.gain; 

2 => voice1.sync => voice2.sync => voice3.sync => voice4.sync;
.8 => voice1.gain => voice2.gain => voice3.gain => voice4.gain;

.75 => chorus.modFreq;
.1 => chorus.modDepth;
.5 => chorus.mix;

1.0 => nReverb.mix;
.2 => jcReverb.mix;

0.0 => left.gain => right.gain;
0.0 => mid.gain;

///

55 => int key;

tempo.note * 2 => dur chordDuration;

dur attack, decay, release;
float sustain;

1.0 / 350.0 => float maxMidVolume;
1.0 / 300.0 => float maxOuterVolume;

//

float midVolume;
float outerVolume;

float stereoPan;

float lfoFreq;
float lfoVolume;

float lpFilterFreq;
float lpFilterQ;
float lpFilterVolume;

///

function void modulateMidVolume(Gain mid, dur modTime, float min, float max, float aps, int direction) {
    aps => float step;
    max - min => float range;
    range / aps => float sit;

    mid.gain() => midVolume;

    while(true) {
        midVolume => mid.gain;        
        step +=> midVolume;

        if (midVolume >= max) {
            aps * -1 => step;
        }
        else if (midVolume <= min) {
            aps => step;
        }   

        modTime / sit => now;
    }
}
function void modulateOuterVolume(Gain left, Gain right, dur modTime, float min, float max, float aps, int direction) {
    aps => float step;
    max - min => float range;
    range / aps => float sit;

    /* if (!direction) {
        min => outerVolume;
    }
    else {
        max => outerVolume;
        aps * -1 => step;
    } */

    left.gain() => outerVolume;

    while(true) {
        outerVolume => left.gain;
        outerVolume => right.gain;
        step +=> outerVolume;

        if (outerVolume >= max) {
            aps * -1 => step;
        }
        else if (outerVolume <= min) {
            aps => step;
        }   

        modTime / sit => now;
    }
}

function void modualteStereoPan(Pan2 stereo, dur modTime, float min, float max, float aps, int direction) {
    aps => float step;
    max - min => float range;
    (range / aps) * 2 => float sit;

    stereo.pan() => stereoPan;

    while(true) {
        stereoPan => stereo.pan;
        step +=> stereoPan;

        if (stereoPan >= max) {
            aps * -1 => step;
        }
        else if (stereoPan <= min) {
            aps => step;
        }

        modTime / sit => now;
    }
}

function void modulateLFOFreq(SinOsc lfo, dur modTime, float min, float max, float aps, int direction) {    
    aps => float step;
    max - min => float range;
    (range / aps) * 2 => float sit;

    lfo.freq() => lfoFreq;

    while(true) {
        lfoFreq => lfo.freq;
        step +=> lfoFreq;

        if (lfoFreq >= max) {
            aps * -1 => step;
        }
        else if (lfoFreq <= min) {
            aps => step;
        }

        modTime / sit => now;
    }
}
function void modulateLFOVolume(SinOsc lfo, dur modTime, float min, float max, float aps, int direction) {
    aps => float step;
    max - min => float range;
    (range / aps) * 2 => float sit;

    lfo.gain() => lfoVolume;

    while(true) {
        lfoVolume => lfo.gain;
        step +=> lfoVolume;

        if (lfoVolume >= max) {
            aps * -1 => step;
        }
        else if (lfoVolume <= min) {
            aps => step;
        }

        modTime / sit => now;
    }
}

function void modulateLPFFreq(LPF filter, dur modTime, float min, float max, float aps, int direction) {
    aps => float step;
    max - min => float range;
    (range / aps) * 2 => float sit;

    filter.freq() => lpFilterFreq;

    while(true) {
        lpFilterFreq => filter.freq;
        step +=> lpFilterFreq;

        if (lpFilterFreq >= max) {
            aps * -1 => step;
        }
        else if (lpFilterFreq <= min) {
            aps => step;
        }

        modTime / sit => now;
    }
}
function void modulateLPFQ(LPF filter, dur modTime, float min, float max, float aps, int direction) {
    aps => float step;
    max - min => float range;
    (range / aps) * 2 => float sit;

    filter.Q() => lpFilterQ;

    while(true) {
        lpFilterQ => filter.Q;
        step +=> lpFilterQ;

        if (lpFilterQ >= max) {
            aps * -1 => step;
        }
        else if (lpFilterQ <= min) {
            aps => step;
        }

        modTime / sit => now;
    }
}
function void modulateLPFVolume(LPF filter, dur modTime, float min, float max, float aps, int direction) {
    aps => float step;
    max - min => float range;
    (range / aps) * 2 => float sit;

    filter.gain() => lpFilterVolume;

    while(true) {
        lpFilterVolume => filter.gain;
        step +=> lpFilterVolume;

        if (lpFilterVolume >= max) {
            aps * -1 => step;
        }
        else if (lpFilterVolume <= min) {
            aps => step;
        }

        modTime / sit => now;
    }
}

///

function void runSynth(int sequence[], int harmony[], dur durations[], int fadeOut) {
    while(true) {
        for (0 => int step; step < sequence.cap(); step++) {
            setADSR(durations[step]);
            
            key + sequence[step] => int baseKey;
            
            Std.mtof(baseKey) => voice1.freq;
            Std.mtof(baseKey + 7) => voice3.freq;
            Std.mtof(baseKey - 12) => voice5.freq;
            Std.mtof(baseKey - 24) => voice6.freq;

            if (harmony[step]) {
                Std.mtof(baseKey + 4) => voice2.freq;            
                Std.mtof(baseKey + 11) => voice4.freq;
            }
            else {
                Std.mtof(baseKey + 3) => voice2.freq;            
                Std.mtof(baseKey + 10) => voice4.freq;
            }                        

            adsr.keyOn();
            durations[step] - release => now;
            adsr.keyOff();
            release => now;

            if (!fadeOut) {
                // let rest of chordDuration run out
                chordDuration - durations[step] => now;
            }
        }

        if (fadeOut) {
            break;
        }
    }
}
function void setADSR(dur duration) {
    duration * .5 => attack;
    duration * .25 => decay;
    Math.random2f(.6, .85) => sustain;

    if (duration != tempo.note * 4) {
        duration * .4 => release;
    }
    else {
        duration * .6 => release;
    }

    (attack, decay, sustain, release) => adsr.set;
}

///

[0] @=> int melodyIntro[];
[1] @=> int harmonyIntro[];
[tempo.note] @=> dur durationsIntro[];

[0, -5] @=> int melodyA[];
[1,  1] @=> int harmonyA[];
[tempo.note, tempo.note * .9] @=> dur durationsA[];

[-7, -3] @=> int melodyB[];
[ 1,  0] @=> int harmonyB[];
[tempo.note, tempo.note * 2] @=> dur durationsB[];

[-7, -4, -5, -3] @=> int melodyRef[];
[ 1,  1,  1,  0] @=> int harmonyRef[];
[tempo.note * 2, tempo.note * 2, tempo.note * 2, tempo.note * 2] @=> dur durationsRef[];

[0, -1, -3, -3] @=> int melodyBridge[];
[1,  0,  0,  0] @=> int harmonyBridge[];
[tempo.note * 2, (tempo.note * 2) * .8, tempo.note * 2, (tempo.note * 2) * .7] @=> dur durationsBridge[];

[0, -1, -3, -3, -4] @=> int melodyOutro[];
[1,  0,  0,  0,  1] @=> int harmonyOutro[];
[tempo.note * 2, tempo.note * 2, tempo.note * 2, tempo.note * 2, tempo.note * 4] @=> dur durationsOutro[];


Shred synthShred;
Shred midVolumeShred, outerVolumeShred, stereoShred, lfoFreqShred, lfoVolShred, lpfFreqShred;

///

spork ~ modulateMidVolume(mid, tempo.note * 16, 0.0, maxMidVolume, .000001, 0) @=> midVolumeShred;
spork ~ modulateOuterVolume(left, right, tempo.note * 16, 0.0, maxOuterVolume, .000001, 0) @=> outerVolumeShred;

spork ~ modualteStereoPan(stereo, tempo.note / 3, -.25, .35, 0.01, 0) @=> stereoShred;
spork ~ modulateLFOFreq(lfo, tempo.quarterNote, 2.0, 8.0, 0.01, 0) @=> lfoFreqShred;
spork ~ modulateLFOVolume(lfo, tempo.note, 2.0, 5.0, 0.01, 0) @=> lfoVolShred;
spork ~ modulateLPFFreq(lpFilter, tempo.note * 2, 20.0, 800.0, 10.0, 0) @=> lpfFreqShred;

<<< "synth: intro" >>>;
spork ~ runSynth(melodyIntro, harmonyIntro, durationsIntro, 0) @=> synthShred;
tempo.note * 16 => now;
<<< "synth: a" >>>;
Machine.remove(midVolumeShred.id());
Machine.remove(outerVolumeShred.id());
Machine.remove(synthShred.id());
spork ~ runSynth(melodyA, harmonyA, durationsA, 0) @=> synthShred;
tempo.note * 16 => now;
<<< "synth: b" >>>;
Machine.remove(synthShred.id());
spork ~ runSynth(melodyB, harmonyB, durationsB, 0) @=> synthShred;
tempo.note * 16 => now;
<<< "synth: ref" >>>;
Machine.remove(synthShred.id());
spork ~ runSynth(melodyRef, harmonyRef, durationsRef, 0) @=> synthShred;
tempo.note * 8 => now;
<<< "synth: bridge" >>>;
Machine.remove(synthShred.id());
spork ~ runSynth(melodyBridge, harmonyBridge, durationsBridge, 0) @=> synthShred;
tempo.note * 8 => now;
<<< "synth: ref" >>>;
Machine.remove(synthShred.id());
spork ~ runSynth(melodyRef, harmonyRef, durationsRef, 0) @=> synthShred;
tempo.note * 8 => now;
<<< "synth: bridge" >>>;
Machine.remove(synthShred.id());
spork ~ runSynth(melodyBridge, harmonyBridge, durationsBridge, 0) @=> synthShred;
tempo.note * 8 => now;
<<< "synth: outro" >>>;
Machine.remove(synthShred.id());
spork ~ runSynth(melodyOutro, harmonyOutro, durationsOutro, 1) @=> synthShred;
tempo.note * 16 => now;
<<< "synth: end" >>>;

// 96 bars - (16 bars intro, 16 bars outro) = 64 bars