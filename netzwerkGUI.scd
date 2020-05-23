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
//Diese Funktion erzeugt das Fenster
var newClient = { |arr|
	var window = Window.new("GUI-Test", Rect(100, 100, 420, 35 * arr.size + 45), false).background_(Color.white);
	var values = Dictionary.new;

	//Lustiger Button
	Button.new(window, Rect(10, 10, 75, 25))
	.states_([
		["an", Color.white, Color.green(0.5)],
		["aus", Color.white, Color.red(0.5)]
	]);

	//Textfeld um die id darzustellen
	StaticText.new(window, Rect(310, 10, 100, 25))
	.string_(18229837)
	.align_(\center)
	.background_(Color.grey)
	.stringColor_(Color.white);

	//Hier kommen die Slider
	arr.do { |item, i|
		values.put(item[0], 0);
		EZSlider.new(
			window,
			Rect(10, 45 + (35 * i), 400, 25),
			item[0],
			ControlSpec(item[1], item[2], step: item[3], default: 0, units: item[4]),
			{ |self|
				values[item[0]] = self.value;
			},
			labelWidth: 75,
			unitWidth: 25,
			gap: 4@4,
			margin: 4@4
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