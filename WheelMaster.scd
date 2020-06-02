NetAddr.langPort;

(
~idList = List.new; //enthält alle IDs der clients
~net = NetAddr("127.0.0.1", 57140);
)

(
var initParams = [
	60.0, //synth root note
	0, //synth delay
	36.0, //bass root note
	440.0, //bass LPF frequency
	2.0, //bass release time
	40.0, //kick frequency
	0.3, //kick decay
	1, //kick trigger
	1, //kick distortion
];

//das hier wird das Master-Fenster erstellt
var window = Window.new("WheelOfFortune - Master", Rect(100, 100, 530, 75), false).background_(Color.white);

// Fragt alle Clients nach ID, verbunden mit "Get IDs" Button
var getIDs = {
	~net.sendMsg('/getID');
};

// Erstellt aus allen IDs einen Kreis, verbunden mit "Form Circle" Button
var formCircle = {
	//sendet jedem client die ID vom nächsten im Kreis
	for (0,  ~idList.size - 1,
		{arg index;
			~net.sendMsg('/circle', ~idList.at(index), ~idList.at((index + 1) % ~idList.size));
		}
	);
};

//Sendet Startsignal an ersten Client im Kreis, verbinden mit "Send Signal" Button
var sendStartSignal = {
	~net.sendMsg('/receiveParams', ~idList.first, *initParams);
};

//Wird gecalled, wenn ein client seine ID schickt
OSCdef(\sendID, {arg msg;
	(~idList.includes(msg[1]) || (msg[1].isInteger).not).if (
		{//die angekommene ID ist schon im User-Array!
			"ID nicht hinzugefügt! Entweder die ID ist mehrfach oder jemand hat keine Integer gesendet.".postln;
		},
		{//die angekommene ID ist neu
			~idList.add(msg[1]);
			"ID wurde aufgenommen.".postln;
			~idList.postln; //--------------DEBUG--------------
		}
	)
}, '/sendID');

OSCdef(\received, {//Das hier raus? XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	//Rückmeldung ob alle die ihre nextID gekriegt haben?
}, '\recieved');

//// GUI Stuff ////
window.view.decorator = FlowLayout(window.view.bounds, 5@5, 5@5);

//Button zum Empfangen der IDs
Button.new(window, 100@30)
.states_([["Get IDs", Color.black, Color.blue(1, 0.2)]])
.action_({
	getIDs.value;
	~idCounter.string_(~idList.size;);//Das hier vielleicht eher in den OSCDef, damit es sich immer aktualisiert? XXXXXXXXXX
});

//Hier wird die Anzahl der IDs dargestellt
~idCounter = StaticText.new(window, 100@30)
.string_(~idList.size;)
.background_(Color.blue(1, 0.2))
.align_(\center);

//Button zum erstellen und verschicken der Reihenfolge des Kreises
Button.new(window, 100@30)
.states_([["Form Circle", Color.black, Color.yellow(1, 0.2)]])
.action_({formCircle.value;});

//Hier wird angezeigt ob alle die Liste erhalten haben
StaticText.new(window, 100@30)
.string_("Waiting...")
.background_(Color.red(1, 0.3))
.align_(\center);

//Button zum Starten des Signals bei der kleinsten ID
Button.new(window, 100@30)
.states_([["Send Signal", Color.black, Color.cyan(1, 0.2)]])
.action_({sendStartSignal.value;};);

//DELAY TIME SLIDER
EZSlider.new(window, 520@30, "Delay", ControlSpec(0, 0.5, step: 0.02), { |self|
	~net.sendMsg('/getDelay', self.value);
});

window.front;
)
