(
a = [
	["Carrier", -5, 5, 1],
	["Mod", -3, 7, 1],
	["Amp", 0, 190, 10],
	["Cutoff", -2, 11, 0.5]
]
)

(
var newClient = { |arr|
	var window = Window.new("GUI-Test", Rect(100, 100, 420, 40 * arr.size + 10));
	var values = Dictionary.new;

	arr.do { |item, i|
		values.put(item[0], 0);
		EZSlider.new(
			window,
			Rect(10, 10 + (40 * i), 400, 30),
			item[0],
			ControlSpec(item[1], item[2], step: item[3], default: 0),
			{ |self|
				values[item[0]] = self.value;
			}
		).setColors(background: Color.grey);
	};

	window.front;
	values
};

v = newClient.value(a);
)