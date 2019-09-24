BPM tempo;

Gain master;

SndBuf kick => LPF lpFilter => master;
SndBuf snare => master;
SndBuf hihat => master;
SndBuf lowhat => master;
SndBuf sizzle => master;

master => dac;

///

me.dir(-1) + "audio/kick.wav" => kick.read;
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

.75 => kick.gain => snare.gain;
.1 => hihat.gain => lowhat.gain => sizzle.gain;

1.0 / 2.0 => master.gain;

///

[1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0] @=> int kickPattern[];
[0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0] @=> int snarePattern[];
[1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0] @=> int hihatPatternA[];
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1] @=> int hihatPatternB[];
[0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1] @=> int lowhatPattern[];
[0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0] @=> int sizzlePattern[];

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

spork ~ runPattern(kick, kickPattern) @=> kickShred;
tempo.note * 4 => now;
spork ~ runPattern(snare, snarePattern) @=> snareShred;
tempo.note * 4 => now;

spork ~ runPattern(hihat, hihatPatternA) @=> hihatShred;
tempo.note * 16 => now;
spork ~ runPattern(lowhat, lowhatPattern) @=> lowhatShred;
tempo.note * 20 => now;
Machine.remove(hihatShred.id());
spork ~ runPattern(sizzle, sizzlePattern) @=> sizzleShred;
tempo.note * 4 => now;

spork ~ runPattern(hihat, hihatPatternA) @=> hihatShred;
tempo.note * 16 => now;
Machine.remove(sizzleShred.id());
spork ~ runPattern(lowhat, lowhatPattern) @=> lowhatShred;
tempo.note * 20 => now;
Machine.remove(hihatShred.id());

tempo.note * 4 => now;
Machine.remove(lowhatShred.id());
Machine.remove(snareShred.id());
tempo.note * 4 => now;
Machine.remove(kickShred.id());