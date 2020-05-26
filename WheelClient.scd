NetAddr.langPort;

/*
OSCjunction Setup:
- 'Start Receiving' auf 'WheelOfFortune Circle' (Port: NetAddr.langPort; Default ist 57120)
- 'Start Sending' auf 'WheelOfFortune Circle' (Port: 57140)
*/
(// NUR EINMAL AUSFÜHREN!
~id = 500000000.rand; //eigene ID
~id.postln; //--------------DEBUG--------------
~net = NetAddr("127.0.0.1", 57140);
)
(
var nextID = 0; //Nächster User im Kreis
var paramsArray = [];

var sendParams = {//client sendet seine parameter weiter
	~net.sendMsg('/receiveParams', paramsArray)
};
//##############OSC Defs##############

//Master Commands

//ID vom nächsten kriegen um Kreis zu bilden
OSCdef(\circle, {arg msg;
	(msg[1] == ~id).if({nextID = msg[2];});
	nextID.postln; //--------------DEBUG--------------
}, '/circle');

//Sendet eigene ID an Master
OSCdef(\getID, {
	~net.sendMsg('/sendID', ~id);
}, '/getID');

OSCdef(\signal, {arg msg;
	(msg[1] == ~id).if({
		//Signal wird ausgewertet wenn an diesen Client gerichtet
		//Nicht sicher was hier passieren wird
	});
});

//Circle Commands

//Wird aufgerufen von vorherigen, dier die aktuellen Parameter weiter schickt
OSCdef(\receiveParams, {arg msg;
	msg.postln; //--------------DEBUG--------------

}, '/receiveParams');

)

(
//Beispiel-Array
//die einzelnen Slider lassen sich so konfigurieren: ["Name", MinValue, MaxValue, StepSize, "Einheit"]
a = [
	["Carrier", -5, 5, 1, "hz"],
	["Mod", -3, 7, 1, "hz"],
	["Amp", 0, 190, 10, "db"],
	["Cutoff", -2, 11, 0.5, "hz"],
	["Cutoff 2", -2, 11, 0.5, "hz"],
	["Cutoff 3", -2, 11, 0.5, "hz"],
	["Cutoff 4", -2, 11, 0.5, "hz"],
	["Noch", -2, 11, 0.5, "m"],
	["Mehr", -2, 11, 0.5, "m"],
	["Zeug", -2, 11, 0.5, "m"],
	["Zum", -2, 11, 0.5, "m"],
	["Testen", -2, 11, 0.5, "m"],
];
)

(
//Diese Funktion erzeugt das Client-Fenster
var newClient = { |arr|
	var window = Window.new("Wheel Of Fortune - Client", Rect(100, 100, 410, 35 * arr.size + 40), false)
	.background_(Color.white);
	var values = Dictionary.new;

	window.view.decorator = FlowLayout(window.view.bounds, 5@5, 5@5);

	//Lustiger Button
	Button.new(window, 80@30)
	.states_([
		["an", Color.white, Color.green(0.5)],
		["aus", Color.white, Color.red(0.5)]
	]);

	//Textfeld um die id darzustellen
	StaticText.new(window, 100@30)
	.string_(18229837)
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

v = newClient.value(a);
)