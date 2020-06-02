NetAddr.langPort;

s.boot

/*
OSCjunction Setup:
- 'Start Receiving' auf 'WheelOfFortune Circle' (Port: NetAddr.langPort; Default ist 57120)
- 'Start Sending' auf 'WheelOfFortune Circle' (Port: 57140)
*/
(// NUR EINMAL AUSFÜHREN!
~id = 500000000.rand; //eigene ID
~net = NetAddr("127.0.0.1", 57140);
)
(
var nextID = 0; //Nächster User im Kreis
var slider = [
	["synthRoot", -6, 6, 1, "HT"], //freq von synth
	["synthDelay", -0.5, 0.5, 0.1, "s"], //synth delay
	["bassRoot", -6, 6, 1, "HT"], //freq von bass
	["bassLPF", -20, 20, 1, "Hz"],  //lpfFreq von bass
	["bassRelease", -2, 2, 0.1, "s"], //rel von bass
	["kickFreq", -5, 5, 1, "Hz"], //freq von kick
	["kickDecay", -0.5, 0.5, 0.1, "s"], //rel von kick
	["kickTrigger", -1, 1, 0.1, "Hz"], //something
	["kickDist", -10, 10, 1, "x"] //Kick Distortion
];
var delay = 0.2;
var synth, kick;
var setParams = { |msg| //erhaltene Parameter werden interpretiert
	(isRunning.not).if {
		synth = Synth(\synth);
		kick = Synth(\kickLoop);
		isRunning = true;
	};
	fork {
		msg[1].wait;
		synth.set(\freq, (msg[0]).midicps);
	};
	Synth(\bass, [\freq, (msg[2]).midicps, \lpfFreq, msg[3], \rel, msg[4]]);
	kick.set(\freq, msg[5], \rel, msg[6], \trig, msg[7], \dist, msg[8]);
};
var sendParams = { |msg| //client sendet seine parameter weiter
	~net.sendMsg('/receiveParams', nextID, *(msg + params));
};
var params;
var isRunning = false;

var newClient = { |arr| //Fenster wird erstellt
	var window = Window.new("Wheel Of Fortune - Client", Rect(100, 100, 410, 35 * arr.size + 40), false)
	.background_(Color.white);
	var values = Array.new(10);

	window.view.decorator = FlowLayout(window.view.bounds, 5@5, 5@5);

	//values.put(\change, true);XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	//Lustiger Button, suspended die eigenen Veränderungen XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	Button.new(window, 80@30)//raus????????
	.states_([
		["On", Color.white, Color.green(0.5)],
		["Off", Color.white, Color.red(0.5)]
	])
	.action_({ |self|
		(self.value == 0).if(
			{},//values[\change] = true},
			{}//values[\change] = false}
		);
	});
	//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	//Textfeld um die id darzustellen
	StaticText.new(window, 100@30)
	.string_(~id)
	.align_(\center)
	.background_(Color.grey)
	.stringColor_(Color.white);

	//Hier kommen die Slider
	arr.do { |item, i|
		values = values.add(0);
		EZSlider.new(
			window,
			400@30,
			item[0],
			ControlSpec(item[1], item[2], step: item[3], default: 0, units: item[4]),
			{ |self|
				values[i] = self.value;
			},
			labelWidth: 75,
			unitWidth: 25,
			gap: 5@5,
			margin: 5@5
		)
		.setColors(
			stringBackground: Color.hsv(i / arr.size, 0.2, 1),
			background: Color.hsv(i / arr.size, 0.4, 1)
		)
		.labelView.align_(\center);
	};
	window.front;
	values
};

//##############OSC Defs##############

//Master Commands

//ID vom nächsten kriegen um Kreis zu bilden
OSCdef(\circle, {arg msg;
	(msg[1] == ~id).if({
		nextID = msg[2];
		nextID.postln; //--------------DEBUG--------------
	});

}, '/circle');

//Sendet eigene ID an Master
OSCdef(\getID, {
	~net.sendMsg('/sendID', ~id);
}, '/getID');

//Circle Commands

//Wird aufgerufen von vorherigen, der die aktuellen Parameter weiter schickt
//============Hier kommen ab msg[2] die ganzen absoluten werte als KV-Paar===================
// Hier wird bspw. auch Synth(\synth) ausgeführt, als oneShot
OSCdef(\receiveParams, {arg msg;
	var boundWrap;
	(msg[1] == ~id).if({
		msg.postln; //--------------DEBUG--------------
		setParams.value(msg.drop(2));
		msg = msg.drop(2);
		boundWrap = [
			msg[0].wrap(48.0, 84.0), //sorry
			msg[1].wrap(0.0, 2.0),
			msg[2].wrap(24.0, 48.0),
			msg[3].wrap(110.0, 880.0),
			msg[4].wrap(2.0, 7.0),
			msg[5].wrap(30.0, 80.0),
			msg[6].wrap(0.1, 1.0),
			msg[7].wrap(0.2, 50),
			msg[8].wrap(1, 50)
		];
		fork {
			delay.wait;
			sendParams.value(boundWrap);
		}

	});
}, '/receiveParams');

OSCdef(\getDelay, {arg msg;
	delay = msg[1];
}, '/getDelay');

//##############Synth Defs##############
SynthDef(\kickLoop, { |freq=40, amp=0.6, trig=1, rel=0.3, dist=1|
	var trigger = Impulse.ar(trig);
	var sig = SinOsc.ar(EnvGen.ar(Env.perc(0, rel / 4), trigger) * freq * 3 + freq);
	var env = EnvGen.ar(Env.perc(0.01, rel), trigger);
	Out.ar(0, ((sig * env * amp * dist).distort / dist)!2);
}).add;

SynthDef.new(\synth, {|freq = 400, amp = 0.05|
	var sig, freqC;
	freq = freq * [1, 1.25, LFNoise0.ar(2).range(1.5, 1.875)];
	freqC = freq * LFNoise1.kr(2!8).range(-0.25, 0.25).midiratio;
	sig = VarSaw.ar(freqC) * amp;
	sig = Splay.ar(sig);
	Out.ar(0, sig);
}).add;

SynthDef(\bass, {
	|freq = 60, lpfFreq = 440, rel = 2, amp = 0.05|
	var sig, env;
	env = EnvGen.kr(Env.perc(releaseTime: rel), doneAction: 2);
	sig = LFSaw.ar(freq);
	sig = RLPF.ar(sig, lpfFreq + (220 * EnvGen.ar(Env.perc(0.1, rel), doneAction: 2)), 0.1);
	sig = sig * env * amp;
	Out.ar(0, sig!2);
}).add;

params = newClient.value(slider);
)
