BPM tempo;

///

SinOsc bass => ADSR adsr => LPF filter => Dyno dyno => dac;

///

31 => int key;
tempo.quarterNote => dur beatDuration;
beatDuration / 2 => dur noteDuration;

///

key + 24 => Std.mtof => filter.freq;
1.8 => filter.Q;

dyno.compress();

noteDuration * .1 => dur attack;
noteDuration * .15 => dur decay;
1.0 => float sustain;
noteDuration * .1 => dur release;

(attack, decay, sustain, release) => adsr.set;

function void runBass(int melody[], dur durations[]) {
    while(true) {
        for (0 => int step; step < melody.cap(); step++) {
            key + melody[step] => Std.mtof => bass.freq;
            
            noteDuration => now;

            adsr.keyOn();
            durations[step] - release => now;
            adsr.keyOff();
            release => now;
        }
    }
}

///

[0, 0, 0, 7] @=> int melodyA[];
[noteDuration, noteDuration, noteDuration, noteDuration] @=> dur durationsA[];

[5, 5, 5, 0, 5, 5, 7, 0] @=> int melodyB[];
[noteDuration, noteDuration, noteDuration, noteDuration, noteDuration, noteDuration, noteDuration, noteDuration] @=> dur durationsB[];


Shred bassShred;

///
tempo.note * 8 => now;

<<< "bass: part a" >>>;
spork ~ runBass(melodyA, durationsA) @=> bassShred;
tempo.note * 16 => now;
<<< "bass: part b" >>>;
Machine.remove(bassShred.id());
spork ~ runBass(melodyB, durationsB) @=> bassShred;
tempo.note * 16 => now;
<<< "bass: part ref" >>>;
tempo.note * 8 => now;
Machine.remove(bassShred.id());
<<< "bass: outro" >>>;
spork ~ runBass(melodyA, durationsA) @=> bassShred;
tempo.note * 8 => now;
<<< "bass: end" >>>;
Machine.remove(bassShred.id());

