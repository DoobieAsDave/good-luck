BPM tempo;

SndBuf tic => dac;

me.dir(-1) + "audio/kick.wav" => tic.read;
tic.samples() => tic.pos;
.5 => tic.gain;

while(true) {
    for (0 => int step; step < 4; step++) {
        if (step == 0) {
            2.7 => tic.rate;            
        }
        else {
            2.0 => tic.rate;
        }
        
        tic.samples() / 4 => tic.pos;
        tempo.quarterNote => now;
    }
}