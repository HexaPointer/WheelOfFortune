//Das hier wird dann der Client code


/*
OSCjunction Setup:
- 'Start Receiving' auf 'WheelOfFortune Circle' (Port: NetAddr.langPort;)
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
})

//Circle Commands

//Wird aufgerufen von vorherigen, dier die aktuellen Parameter weiter schickt
OSCdef(\receiveParams, {arg msg;
	msg.postln; //--------------DEBUG--------------

}, '/receiveParams');

)
///////////////////////////////////////////////

//Das hier wird dann der Master code

~idList = List.new; //enthält alle IDs der clients
~netMaster = NetAddr("127.0.0.1", 57140);
(

// Fragt alle Clients nach ID
var getIDs = { //verbinden mit "Get IDs" Button
	~netMaster.sendMsg('/getID');
};

// Erstellt aus allen IDs einen Kreis
var generateCircle = { //verbinden mit "Form Circle" Button
	//sendet jedem client die ID vom nächsten im Kreis
	for (0,  ~idList.size - 1,
		{arg index;
			~netMaster.sendMsg('/circle', ~idList.at(index), ~idList.at((index + 1) % ~idList.size));
		}
	);
};

//Sendet Signal an ersten Client im Kreis
var sendStartSignal = { //verbinden mit "Send Signal" Button
	~netMaster.sendMsg('/signal', ~idList.first);
};


//Wird gecalled, wenn ein client seine ID schickt
OSCdef(\sendID, {arg msg;
	//die reinkommende Message besteht aus [s: command, i: id]
	msg.postln; //--------------DEBUG--------------

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

OSCdef(\received, {
	//Rückmeldung ob alle die ihre nextID gekriegt haben?
})

)

(//In diese section können commands die während des Stücks benutzt werden sollen, bspw. messages an alle clients

~netMaster.sendMsg('/receiveParams', "hopefully this worked") //--------------DEBUG--------------

)