.75 => dac.gain;

BPM tempo;
tempo.setBPM(128.0);

Machine.add(me.dir() + "record.ck");

Machine.add(me.dir() + "drum/loop.ck");
Machine.add(me.dir() + "units/synth.ck");
Machine.add(me.dir() + "units/bass.ck");