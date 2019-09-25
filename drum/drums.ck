BPM tempo;

Gain master;

SndBuf kick => LPF lpFilter => master;
SndBuf snare => master;
SndBuf hihat => master;
SndBuf lowhat => master;
SndBuf sizzle => master;

master => dac;

///

me.dir(-1) + "audio/drums/kick.wav" => kick.read;
me.dir(-1) + "audio/snare.wav" => snare.read;
me.dir(-1) + "audio/hihat.wav" => hihat.read;
me.dir(-1) + "audio/lowhat.wav" => lowhat.read;
me.dir(-1) + "audio/claves.wav" => sizzle.read;

kick.samples() => kick.pos;
snare.samples() => snare.pos;
hihat.samples() => hihat.pos;
lowhat.samples() => lowhat.pos;
sizzle.samples() => sizzle.pos;

124 => Std.mtof => lpFilter.freq;
2.5 => lpFilter.Q;
1.5 => lpFilter.gain;

1.7 => kick.rate;
.5 => kick.gain;

1.0 / 2.0 => master.gain;

///

[
    1, 0, 1, 0,
    0, 0, 0, 0,
    0, 0, 1, 1,
    0, 0, 0, 0/* ,

    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0 */
] @=> int kickPattern[];
[
    0, 0, 0, 0,
    1, 0, 0, 1,
    0, 0, 0, 0,
    1, 0, 0, 0
] @=> int snarePattern[];
[
    1, 0, 1, 0,
    1, 0, 1, 0,
    1, 0, 1, 0,
    1, 0, 1, 0
] @=> int hihatPattern[];

///

function void runPattern(SndBuf sample, int pattern[]) {
    while(true) {
        for (0 => int step; step < pattern.cap(); step++) {
            if (pattern[step]) { 0 => sample.pos; }

            tempo.sixteenthNote => now;
        }
    }
}

///

Shred kickShred, snareShred, hihatShred, lowhatShred, sizzleShred;

spork ~ runPattern(kick, kickPattern);
spork ~ runPattern(snare, snarePattern);
spork ~ runPattern(hihat, hihatPattern);

while(true) second => now;
