(SynthDef.new(\sound, {|freq = 440, atk = 0.05, rel = 0.3, amp = 0.5|
	var sig;
	sig = (SinOsc.ar(freq) * EnvGen.kr(Env.new([0,1,0], [atk, rel], [1, -1]), doneAction:2)) * amp;
	Out.ar(0, sig!2);
}).add;
)

(
Pdef(\sounds,
	Pbind(
		\instrument, \sound,
		\dur, Pwhite(0.05, 0.5, inf),
		\midinote, Pseq([30], inf),
		\harmonic, Pexprand(18, 20, inf).round.trace,
		\atk, Pwhite(2.0, 3.0, inf),
		\rel, Pwhite(5.0, 10.0, inf),
		\amp, Pkey(\harmonic).reciprocal * 0.03,
	);
).play;
)


Pdef(\sounds).stop




(
SynthDef(\kick1, {|freq=40, amp=0.1|
	var sig = SinOsc.ar(XLine.ar(4, 1, 0.02) * freq);
	sig = sig * EnvGen.ar(Env.perc(0.001, 0.4));
	Out.ar(0, sig!2);
}).add;
)


(
Pdef(\goKick1, Pbind(
	\instrument, \kick1,
	\freq, 40,
	\dur, Pseq([1, Rest(1/2), 1/2,1, 1, Rest(1/2), 1/2, 1, 1, 1], inf),
	\amp, 0.5,
)).play;)





(
SynthDef.new(\kick2, {
	|freq1 = 500, freq2 = 50, freq3 = 10, freqDur1 = 0.01, freqDur2 = 0.2, freq4 = 1, freq5 = (-1), atk = 0.01, rel = 1, cur1 = 1, cur2 = (-10), amp = 0.5, pan = 0, out = 0|
	var  sig, env, freq;
	freq = Env([freq1, freq2, freq3],[freqDur1, freqDur2], [freq4, freq5]).ar;
	env = Env([0,1,0], [atk, rel], [cur1, cur2]).kr;
	sig = SinOsc.ar(freq, pi/2);
	sig = sig * env;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig)

}).add;
)

(
Pdef(\goKick2, Pbind(
	\instrument, \kick2,
	\freq, 50,
	\dur, Pseq([Rest(0.75), 0.25], inf),
	\amp, 0.5,
)).play;)





(SynthDef(\hat, {
	var sig, env;
	sig = PinkNoise.ar(1);
	env = Env.perc(0, 1/8, 1);
	env = EnvGen.ar(env, doneAction:2);
	sig = sig * env * 0.1;
	Out.ar(0, sig!2);
}).add;)


(
Pdef(\goHat, Pbind(
	\instrument, \hat,
	\dur, Pseq([0.5], inf),
	\amp, 0.01,
)).play;)




(SynthDef(\snare, {|freq = 4000, dur = 1, fco = 4200, res = 0.75|
	var sig, env;
	sig = PinkNoise.ar(1);
	sig = MoogFF.ar(sig, fco, res);
	env = Env.perc(0, 0.25, 1);
	env = EnvGen.ar(env, doneAction:2);
	sig = sig * env * 0.5;
	Out.ar(0, sig!2);
}).add;)


(
Pdef(\goSnare, Pbind(
	\instrument, \snare,
	\dur, Pseq([Rest(1/2), 1/2], inf),
	\amp, 0.5,
)).play;)





(
SynthDef(\bass, {
	|freq = 60, fco = 500, gate = 1|
	var env, sig;
	env = Env.adsr(0.01, 0.1, 1/32);
	env = EnvGen.kr(env, gate, doneAction:2);
	freq = Lag.kr(freq);
	sig = LFSaw.ar(freq);
	fco = Lag.kr(fco, 1);
	sig = MoogFF.ar(sig, fco);
	sig = sig * env * 0.5;
	Out.ar(0, sig!2);
}).add;
)


Pdefn(\scale, Scale.mixolydian);
Pdefn(\mtranspose,0);

(Pdef(\Gobass, PmonoArtic(
	\bass,
	\scale, Pdefn(\scale),
	\mtranspose, Pdefn(\mtranspose),
	\octave, 4,
	\degree, Pseq([
		-7, -7, -3, -3,
		0, 0, 0, 0,
		-4, -4, -4,
		-4, -7, -5, -4, -1,
		], inf),
	\dur, 1/4,
	\amp, 1,

)).play);


Pdef(\Gobass).play;

(
SynthDef.new(\sound1, {|freq = 400, amp = 0.05, rel = 2|
	var sig, freqC, env;
	env = EnvGen.kr(Env.perc(releaseTime:5), doneAction: 2);
	freqC = freq * LFNoise1.kr(2!8).range(-0.25, 0.25).midiratio;
	sig = VarSaw.ar(freqC) * env * amp;
	sig = Splay.ar(sig);
	Out.ar(0, sig);
}).add;
)
(
x = [43, 48, 55, 64].collect({|note, index|
	Synth.new(\sound1, [\freq, (note).midicps]);
})
)

(
x = [38, 48, 52].collect({|note, index|
	Synth.new(\sound1, [\freq, (note).midicps]);
})
)
