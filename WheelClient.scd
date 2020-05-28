NetAddr.langPort;

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
var paramsArray = [
	//["Test", -1, 1, 0.1, "wichse"],
	["Root Shift", -6, 6, 1, "HT"], //freq von sound1
	["Release 1", -2, 2, 0.1, "s"], //rel von sound1
	["Bass Shift", -6, 6, 1, "HT"], //freq von bass
	["Lowpass", -20, 20, 1, "Hz"],  //lpfFreq von bass
	["Kick Shift", -5, 5, 1, "Hz"], //freq von kick
	["Decay", -0.5, 0.5, 0.1, "s"], //rel von kick
	["Pause", -0.1, 0.1, 0.01, "s"], //something
	//["Huren", 0, 1, 1, "Sohn"],
];
var delay = 0.2;

var setParams = {};

var changeParams = {};

var sendParams = { |msg| //client sendet seine parameter weiter
	//~net.sendMsg('/receiveParams', paramsArray)
	//~net.sendMsg('/receiveParams', nextID, v["Test"]); //für Testzwecke
	~net.sendMsg('/receiveParams', nextID, changeParams.value(msg));
};

var params;
var isRunning = false;

var setParams = { |msg|
	//synths und patterns starten falls not isRunning
	//parameter auf synths anwenden
};

var changeParams = { |msg|
	//parameter verändern und zurückgeben
};

var newClient = { |arr|
	var window = Window.new("Wheel Of Fortune - Client", Rect(100, 100, 410, 35 * arr.size + 40), false)
	.background_(Color.white);
	var values = Dictionary.new;

	window.view.decorator = FlowLayout(window.view.bounds, 5@5, 5@5);

	values.put(\change, true);

	//Lustiger Button, suspended die eigenen Veränderungen, parameter unverändert weitergegeben
	Button.new(window, 80@30)
	.states_([
		["On", Color.white, Color.green(0.5)],
		["Off", Color.white, Color.red(0.5)]
	])
	.action_({ |self|
		(self.value == 0).if(
			{values[\change] = true},
			{values[\change] = false}
		);
	});

	//Textfeld um die id darzustellen
	StaticText.new(window, 100@30)
	.string_(~id)
	.align_(\center)
	.background_(Color.grey)
	.stringColor_(Color.white);

	//Hier kommen die Slider
	arr.do { |item, i|
		values.put(item[0], 0);
		EZSlider.new(
			window,
			400@30,
			item[0],
			ControlSpec(item[1], item[2], step: item[3], default: 0, units: item[4]),
			{ |self|
				values[item[0]] = self.value;
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

	//Fenster erscheint und Dictionary wird zurückgegeben
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
// Hier wird bspw. auch Synth(\sound1) ausgeführt, als oneShot
OSCdef(\receiveParams, {arg msg;
	(msg[1] == ~id).if({
		msg.postln; //--------------DEBUG--------------
		fork {
			setParams.value(msg);
			delay.wait;
			sendParams.value(msg);
		}

	});
}, '/receiveParams');

OSCdef(\getDelay, {arg msg;
	delay = msg[1];
}, '/getDelay');

//##############Synth Defs##############
SynthDef(\kick, {|freq=40, amp=0.1, rel=0.3|
	var sig = SinOsc.ar(XLine.ar(4, 1, 0.02) * freq);
	sig = sig * EnvGen.ar(Env.perc(0.001, rel));
	Out.ar(0, sig!2);
}).add;

SynthDef.new(\sound1, {|freq = 400, amp = 0.05, rel = 2|
	var sig, freqC, env;
	env = EnvGen.kr(Env.perc(releaseTime: rel), doneAction: 2);
	freqC = freq * LFNoise1.kr(2!8).range(-0.25, 0.25).midiratio;
	sig = VarSaw.ar(freqC) * env * amp;
	sig = Splay.ar(sig);
	Out.ar(0, sig);
}).add;

SynthDef(\bass, {
	|freq = 60, fco = 500, lpfFreq = 440|
	var sig;
	freq = Lag.kr(freq);
	sig = LFSaw.ar(freq);
	fco = Lag.kr(fco, 1);
	sig = MoogFF.ar(sig, fco);
	sig = LPF.ar(sig, lpfFreq);
	sig = sig * 0.5;
	Out.ar(0, sig!2);
}).add;

Pdef(\goKick, Pbind(
	\instrument, \kick,
	\freq, 40,
	\dur, 0.25,
	\amp, 0.5,
));

Pdef(\goKick).play;
params = newClient.value(paramsArray);
)
