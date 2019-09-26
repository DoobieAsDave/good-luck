BPM tempo;

///

SinOsc bass => ADSR adsr => LPF filter => Dyno dyno => dac;

///

31 => int key;
tempo.quarterNote => dur beatDuration;
//beatDuration / 2 => dur noteDuration;
beatDuration => dur noteDuration;

///

key + 24 => Std.mtof => filter.freq;
1.8 => filter.Q;

dyno.compress();

noteDuration * .1 => dur attack;
noteDuration * .15 => dur decay;
1.0 => float sustain;
noteDuration * .1 => dur release;

(attack, decay, sustain, release) => adsr.set;

function void runBassA(int melody[], dur durations[]) {
    while(true) {
        for (0 => int step; step < melody.cap(); step++) {
            key + melody[step] => Std.mtof => bass.freq;
            
            if (step <= melody.cap() - 2) {
                noteDuration => now;
            }

            adsr.keyOn();
            durations[step] - release => now;
            adsr.keyOff();
            release => now;
        }
    }
}
function void runBassB(int melody[], dur durations[]) {
    while(true) {
        for (0 => int step; step < melody.cap(); step++) {
            key + melody[step] => Std.mtof => bass.freq;
            
            if (step % 3 == 1) {
                noteDuration => now;
            }

            adsr.keyOn();
            durations[step] - release => now;
            adsr.keyOff();
            release => now;

            if (step % 3 != 1) {
                noteDuration => now;
            }
        }
    }
}

///

[0, 0, 0, 7, 5] @=> int melodyA[];
[noteDuration, noteDuration, noteDuration, noteDuration / 2, noteDuration / 2] @=> dur durationsA[];

[5, 5, 0, 0, 5, 0, 5, 7] @=> int melodyB[];
[noteDuration, noteDuration, noteDuration, noteDuration, noteDuration, noteDuration, noteDuration, noteDuration] @=> dur durationsB[];


Shred bassShred;

///

tempo.note * 8 => now;
<<< "bass: part a" >>>;
spork ~ runBassA(melodyA, durationsA) @=> bassShred;
tempo.note * 16 => now;
<<< "bass: part b" >>>;
Machine.remove(bassShred.id());
spork ~ runBassB(melodyB, durationsB) @=> bassShred;
tempo.note * 16 => now;
<<< "bass: part ref" >>>;
Machine.remove(bassShred.id());
spork ~ runBassA(melodyA, durationsA) @=> bassShred;
tempo.note * 32 => now;
<<< "bass: outro" >>>;
spork ~ runBassA(melodyA, durationsA) @=> bassShred;
tempo.note * 8 => now;
<<< "bass: end" >>>;
Machine.remove(bassShred.id());

