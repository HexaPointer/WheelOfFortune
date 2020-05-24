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

(
//das hier wird das Master-Fenster
var window = Window.new("WOF - Master", Rect(100, 100, 215, 500), false).background_(Color.white);

window.view.decorator = FlowLayout(window.view.bounds, 5@5, 5@5);

//Button zum Empfangen der IDs
Button.new(window, 100@30)
.states_([["Get IDs", Color.black, Color.blue(1, 0.2)]])
.action_({"Hier werden die IDs gespeichert.".postln;});

//Hier wird die Anzahl der IDs dargestellt (wird dann vielleicht durch den OSCDef aktualisiert??)
StaticText.new(window, 100@30)
.string_(0)
.background_(Color.blue(1, 0.2))
.align_(\center);

//Button zum erstellen und verschicken der Reihenfolge des Kreises
Button.new(window, 100@30)
.states_([["Form Circle", Color.black, Color.yellow(1, 0.2)]])
.action_({"Hier wird die Reihenfolge des Kreises gebildet und verschickt.".postln;});

//Hier wird angezeigt ob alle die Liste erhalten haben
StaticText.new(window, 100@30)
.string_("Waiting...")
.background_(Color.red(1, 0.3))
.align_(\center);

//Button zum Starten des Signals bei der kleinsten ID
Button.new(window, 100@30)
.states_([["Send Signal", Color.black, Color.cyan(1, 0.2)]])
.action_({"Hier wird das erste Signal versendet.".postln;});

//Zähler für Runden?? Wäre vielleicht nice
StaticText.new(window, 100@30)
.string_(0)
.background_(Color.cyan(1, 0.2))
.align_(\center);

window.front;
)



















