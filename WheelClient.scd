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
	["Test", -1, 1, 0.1, "wichse"]
];
var delay = 0.2;
var sendParams = {//client sendet seine parameter weiter
	//~net.sendMsg('/receiveParams', paramsArray)
	~net.sendMsg('/receiveParams', nextID, v["Test"]); //für Testzwecke
};

var params;

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
OSCdef(\receiveParams, {arg msg;
	(msg[1] == ~id).if({
		msg.postln; //--------------DEBUG--------------
		fork {
			delay.wait;
			sendParams.value;
		}

	});
}, '/receiveParams');

OSCdef(\getDelay, {arg msg;
	delay = msg[1];
}, '/getDelay');

//##############Synth Defs##############
SynthDef(\kick1, {|freq=40, amp=0.1|
	var sig = SinOsc.ar(XLine.ar(4, 1, 0.02) * freq);
	sig = sig * EnvGen.ar(Env.perc(0.001, 0.4));
	Out.ar(0, sig!2);
}).add;


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

SynthDef.new(\sound1, {|freq = 400, amp = 0.05, rel = 2|
	var sig, freqC, env;
	env = EnvGen.kr(Env.perc(releaseTime:5), doneAction: 2);
	freqC = freq * LFNoise1.kr(2!8).range(-0.25, 0.25).midiratio;
	sig = VarSaw.ar(freqC) * env * amp;
	sig = Splay.ar(sig);
	Out.ar(0, sig);
}).add;

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

params = newClient.value(paramsArray);
)
